From: Russ Anderson <rja@sgi.com>
Date: Fri, 24 Jun 2005 20:11:09 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <200506242011.j5OKB9TV857297@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>
>   Russ> I assume you mean usage like in
>   Russ> arch/ia64/oprofile/backtrace.c, so the usage in mca_drv.c
>   Russ> would be along the lines of:
>
>   Russ>       extern char ia64_ivt[];
>
>   Russ>       if (psr1->cpl !=3D 0 || (pmsa->pmsa_iip >=3D (unsigned
>   Russ> long)ia64_ivt+0x3000 &&
>
>   Russ> Do you have the same objection for interrupt_pnr?  If so, what
>   Russ> is the best way to calculate the offset in ivt.S (which looks
>   Russ> hardcoded for other routines)?
>
> I thought interrupt_pnr was at the end of the vector.  Now that I look
> closer, the whole thing looks rather doubious/fragile to me.  What
> exactly are you trying to do there?

The intent is to deal with cases where the user application does
a load of memory with bad ECC, but the MCA surfaces in the interrupt
(kernel) code.  =20

Testing with error injection showed a significant number of cases
where the MCA surfaced early in the interrupt routine, even though
the load of the bad data was launched from a user process.  Adding=20
the second condition to look for these cases allowed them to be=20
recovered.  Analysis of the recovered MCA records showed 7-10%
of the recoverys were this condition, when running the error
recovery code with other activity that caused interrupts.

Previously, if the MCA surfaced while the cpu was in privilage=20
mode the code would not try to recover.  This change adds a second=20
condition, to see if the kernel is early in the interrupt
routine.  It does this by checking the instruction range.  As
Hidetoshi Seto points out, the check should also make sure
the interrupted process was in user mode.  That has been added=20
to the patch and tested.

A major concern is verifying that the correct process is killed. =20
The name of the process killed is logged to /var/log/messages.
The test also verifies that the correct process is killed.  Early
on there was a bug in the error injection routine, that resulted
in changing the ECC on the wrong physical address.  This was=20
identified because the error injection test completed without=20
being killed.  If the recovery code killed the wrong process,=20
it would be obvious because the error injection test would not=20
get killed.=20

We have also been testing the recovery code in manufacturing=20
with real bad DIMMs.

The updated patch.

Signed-off-by: Russ Anderson (rja@sgi.com)

-----------------------------------------------------------
Index: linux-2.6/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/mca_drv.c	2005-=
06-24 14:24:08.100951706 -0500
+++ linux-2.6/arch/ia64/kernel/mca_drv.c	2005-06-24 14:31:03.253211915 -0500
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
@@ -414,21 +415,27 @@
 	 */
=20
 	psr1 =3D(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_ipsr);
+	psr2 =3D(struct ia64_psr *)&(peidx_minstate_area(peidx)->pmsa_xpsr);
=20
 	/*
 	 *  Check the privilege level of interrupted context.
 	 *   If it is user-mode, then terminate affected process.
 	 */
-	if (psr1->cpl !=3D 0) {
+	pmsa =3D (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_state =
| (6ul<<61));
+
+	if (psr1->cpl !=3D 0 || ((psr2->cpl !=3D 0) &&
+			       (pmsa->pmsa_iip >=3D (unsigned long)ia64_ivt+0x3000 &&
+			        pmsa->pmsa_iip <  (unsigned long)&interrupt_pnr))) {
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
@@ -438,6 +445,7 @@
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
005-06-24 14:24:08.100951706 -0500
+++ linux-2.6/arch/ia64/kernel/mca_drv_asm.S	2005-06-24 14:31:03.254188466 =
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
Index: linux-2.6/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/ivt.S	2005-06-2=
4 14:24:08.097045503 -0500
+++ linux-2.6/arch/ia64/kernel/ivt.S	2005-06-24 14:31:03.255165017 -0500
@@ -785,6 +785,8 @@
 	;;
 	SAVE_REST
 	;;
+	.global	interrupt_pnr
+interrupt_pnr:
 	alloc r14=3Dar.pfs,0,0,2,0 // must be first in an insn group
 	mov out0=3Dcr.ivr		// pass cr.ivr as first arg
 	add out1=16,sp		// pass pointer to pt_regs as second arg
Index: linux-2.6/arch/ia64/kernel/mca_drv.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/mca_drv.h	2005-=
06-24 14:24:08.100951706 -0500
+++ linux-2.6/arch/ia64/kernel/mca_drv.h	2005-06-24 14:31:03.256141568 -0500
@@ -111,3 +111,6 @@
 	slidx_foreach_entry(__pos, &((slidx)->sec)) { __count++; }\
 	__count; })
=20
+extern char ia64_ivt[];
+extern void *interrupt_pnr;
+EXPORT_SYMBOL(interrupt_pnr);
