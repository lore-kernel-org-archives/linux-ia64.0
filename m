From: Russ Anderson <rja@sgi.com>
Date: Thu, 23 Jun 2005 17:30:23 +0000
Subject: [patch] Memory Error Handling Improvement
Message-Id: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

	[patch] Memory Error Handling Improvement

With the current memory recovery code, if the MCA surfaces while the CPU is
in privilage mode, the code does not try to recover.  There are cases where
a read is launched in user context, but an interrupt starts a context
switch causing the MCA to surface early in the context switch code.  This
patch add a check to see if the MCA surfaced in the interrupt code while
saving user state, and if so, the MCA was due to a useland read and can
be recovered.

Jack Steiner wrote the significant parts of this code.

Testing: The test program allocates memory, does a SAL call to change the=20
	ECC on that memory to create a hardware uncorrectable error, then=20
	consumes the data, causing the MCA.  With other interrupt traffic=20
	(to force context switches) the 2.6.12 code will not recover after
	8-100 passes.  With this patch, the test consistently reaches the
	1024 recovery limit.  Analysis of the recovered MCA records shows=20
	7-10% are in the interrupt code saving user state.  Those MCAs
	become recovered with this patch.

Signed-off-by: Russ Anderson (rja@sgi.com)

----------------------------------------------------------------------
Index: linux-2.6/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/mca_drv.c	2005-=
06-22 10:27:30.006898406 -0500
+++ linux-2.6/arch/ia64/kernel/mca_drv.c	2005-06-23 10:58:30.145638400 -0500
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
@@ -394,6 +395,7 @@
 	pal_min_state_area_t *pmsa;
 	struct ia64_psr *psr1, *psr2;
 	ia64_fptr_t *mca_hdlr_bh =3D (ia64_fptr_t*)mca_handler_bhhook;
+	extern void *interrupt, *interrupt_pnr;
=20
 	/* Is target address valid? */
 	if (!pbci->tv)
@@ -419,16 +421,19 @@
 	 *  Check the privilege level of interrupted context.
 	 *   If it is user-mode, then terminate affected process.
 	 */
-	if (psr1->cpl !=3D 0) {
+	pmsa =3D (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_state =
| (6ul<<61));
+	if (psr1->cpl !=3D 0 || (pmsa->pmsa_iip >=3D (unsigned long)&interrupt &&
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
@@ -438,6 +443,7 @@
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
005-06-22 10:27:30.006898406 -0500
+++ linux-2.6/arch/ia64/kernel/mca_drv_asm.S	2005-06-22 15:30:35.506339996 =
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
05-06-22 10:27:30.006898406 -0500
+++ linux-2.6/arch/ia64/kernel/ia64_ksyms.c	2005-06-22 15:30:35.507316546 -=
0500
@@ -123,5 +123,9 @@
 # endif
 #endif
=20
+extern char interrupt, interrupt_pnr;
+EXPORT_SYMBOL(interrupt);
+EXPORT_SYMBOL(interrupt_pnr);
+
 extern char ia64_ivt[];
 EXPORT_SYMBOL(ia64_ivt);
Index: linux-2.6/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/ivt.S	2005-06-2=
2 10:27:30.007874957 -0500
+++ linux-2.6/arch/ia64/kernel/ivt.S	2005-06-22 15:30:35.508293097 -0500
@@ -768,7 +768,7 @@
 	.org ia64_ivt+0x3000
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
-ENTRY(interrupt)
+GLOBAL_ENTRY(interrupt)
 	DBG_FAULT(12)
 	mov r31=3Dpr		// prepare to save predicates
 	;;
@@ -780,6 +780,8 @@
 	;;
 	SAVE_REST
 	;;
+	.global	interrupt_pnr
+interrupt_pnr:
 	alloc r14=3Dar.pfs,0,0,2,0 // must be first in an insn group
 	mov out0=3Dcr.ivr		// pass cr.ivr as first arg
 	add out1=16,sp		// pass pointer to pt_regs as second arg
