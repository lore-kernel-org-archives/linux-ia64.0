From: Russ Anderson <rja@sgi.com>
Date: Thu, 23 Jun 2005 19:30:20 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <200506231930.j5NJUKS07004521@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>=20
>   Russ> -ENTRY(interrupt)
>   Russ> +GLOBAL_ENTRY(interrupt)
>=20
> Please don't create such name-space pollution.
>=20
> AFAICS, you should be able to use ia64_ivt and the architected offset
> for the external-interrupt handler instead.

I assume you mean usage like in arch/ia64/oprofile/backtrace.c, so the
usage in mca_drv.c would be along the lines of:

	extern char ia64_ivt[];

	if (psr1->cpl !=3D 0 || (pmsa->pmsa_iip >=3D (unsigned long)ia64_ivt+0x300=
0 &&

Do you have the same objection for interrupt_pnr?  If so, what is=20
the best way to calculate the offset in ivt.S (which looks hardcoded for
other routines)?


The updated patch with GLOBAL_ENTRY(interrupt) removed:

--------------------------------------------------------------------------
Index: linux-2.6/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/mca_drv.c	2005-=
06-23 14:04:13.741379508 -0500
+++ linux-2.6/arch/ia64/kernel/mca_drv.c	2005-06-23 14:04:18.584089395 -0500
@@ -118,10 +118,11 @@
  */
=20
 void
-mca_handler_bh(unsigned long paddr)
+mca_handler_bh(unsigned long paddr, void *iip, unsigned long ipsr)
 {
-	printk(KERN_DEBUG "OS_MCA: process [pid: %d](%s) encounters MCA.\n",
-		current->pid, current->comm);
+	printk(KERN_DEBUG "OS_MCA: process [cpu %d, pid: %d, uid: %d, iip: %p, ps=
r: 0x%lx, paddr: 0x%lx](%s) encounters MCA.\n",
+		smp_processor_id(), current->pid, current->uid, iip, ipsr, paddr, curren=
t->
+comm);
=20
 	spin_lock(&mca_bh_lock);
 	if (mca_page_isolate(paddr) =3D ISOLATE_OK) {
@@ -394,6 +395,8 @@
 	pal_min_state_area_t *pmsa;
 	struct ia64_psr *psr1, *psr2;
 	ia64_fptr_t *mca_hdlr_bh =3D (ia64_fptr_t*)mca_handler_bhhook;
+	extern char ia64_ivt[];
+	extern void *interrupt_pnr;
=20
 	/* Is target address valid? */
 	if (!pbci->tv)
@@ -419,16 +422,19 @@
 	 *  Check the privilege level of interrupted context.
 	 *   If it is user-mode, then terminate affected process.
 	 */
-	if (psr1->cpl !=3D 0) {
+	pmsa =3D (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_state =
| (6ul<<61));
+	if (psr1->cpl !=3D 0 || (pmsa->pmsa_iip >=3D (unsigned long)ia64_ivt+0x30=
00 &&
+			       pmsa->pmsa_iip <  (unsigned long)&interrupt_pnr)) {
 		smei =3D peidx_bus_check(peidx, 0);
 		if (smei->valid.target_identifier) {
 			/*
 			 *  setup for resume to bottom half of MCA,
 			 * "mca_handler_bhhook"
 			 */
-			pmsa =3D (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_stat=
e | (6ul<<61));
-			/* pass to bhhook as 1st argument (gr8) */
+			/* pass to bhhook as argument (gr8, ...) */
 			pmsa->pmsa_gr[8-1] =3D smei->target_identifier;
+			pmsa->pmsa_gr[9-1] =3D pmsa->pmsa_iip;
+			pmsa->pmsa_gr[10-1] =3D pmsa->pmsa_ipsr;
 			/* set interrupted return address (but no use) */
 			pmsa->pmsa_br0 =3D pmsa->pmsa_iip;
 			/* change resume address to bottom half */
@@ -438,6 +444,7 @@
 			psr2 =3D (struct ia64_psr *)&pmsa->pmsa_ipsr;
 			psr2->cpl =3D 0;
 			psr2->ri  =3D 0;
+			psr2->bn  =3D 1;
 			psr2->i  =3D 0;
=20
 			return 1;
Index: linux-2.6/arch/ia64/kernel/mca_drv_asm.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/mca_drv_asm.S	2=
005-06-23 14:04:13.742356057 -0500
+++ linux-2.6/arch/ia64/kernel/mca_drv_asm.S	2005-06-23 14:04:18.585065944 =
-0500
@@ -19,7 +19,7 @@
 	;;						//
 	clrrrb						//
 	;;					=09
-	alloc		r16=3Dar.pfs,0,2,1,0		// make a new frame
+	alloc		r16=3Dar.pfs,0,2,3,0		// make a new frame
 	;;
 	mov		ar.rsc=3D0
 	;;
@@ -40,11 +40,13 @@
 	movl		loc1=3Dmca_handler_bh		// recovery C function
 	;;
 	mov		out0=3Dr8				// poisoned address
+	mov		out1=3Dr9				// iip
+	mov		out2=3Dr10			// psr
 	mov		b6=3Dloc1
 	;;
 	mov		loc1=3Drp
 	;;
-	ssm		psr.i
+	ssm		psr.i | psr.ic
 	;;
 	br.call.sptk.many    rp=B6			// does not return ...
 	;;
Index: linux-2.6/arch/ia64/kernel/ia64_ksyms.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/ia64_ksyms.c	20=
05-06-23 14:04:13.742356057 -0500
+++ linux-2.6/arch/ia64/kernel/ia64_ksyms.c	2005-06-23 14:04:18.585065944 -=
0500
@@ -123,5 +123,8 @@
 # endif
 #endif
=20
+extern char interrupt_pnr;
+EXPORT_SYMBOL(interrupt_pnr);
+
 extern char ia64_ivt[];
 EXPORT_SYMBOL(ia64_ivt);
Index: linux-2.6/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/ivt.S	2005-06-2=
3 14:04:13.742356057 -0500
+++ linux-2.6/arch/ia64/kernel/ivt.S	2005-06-23 14:04:18.586042494 -0500
@@ -780,6 +780,8 @@
 	;;
 	SAVE_REST
 	;;
+	.global	interrupt_pnr
+interrupt_pnr:
 	alloc r14=3Dar.pfs,0,0,2,0 // must be first in an insn group
 	mov out0=3Dcr.ivr		// pass cr.ivr as first arg
 	add out1=16,sp		// pass pointer to pt_regs as second arg
