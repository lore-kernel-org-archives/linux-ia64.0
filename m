From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 11 Nov 2005 21:42:24 +0000
Subject: [patch] MCA recovery: user errors surfacing in kernel context
Message-Id: <200511112142.jABLgOSr026981@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

[patch] MCA recovery: user errors surfacing in kernel context

Memory errors encountered by user applications may surface
when the CPU is running in kernel context.  An example is
a user process lauching a load of memory with bad ECC, but
an interrupt comes in before the MCA surfaces.  Since the CPU=20
is in privilaged mode, the current code will assume the error=20
is a kernel error and not recover.  This patch adds a check=20
for cases where the user initiated the load that surfaces in=20
kernel interrupt code.

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/kernel/mca_drv.c     |   19 +++++++++++++------
 arch/ia64/kernel/mca_drv.h     |    7 +++++++
 arch/ia64/kernel/mca_drv_asm.S |    6 ++++--
 3 files changed, 24 insertions(+), 8 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/mca_drv.c	2005-11-08=
 16:14:23.925602126 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2005-11-09 18:26:37.323328530 -0600
@@ -121,10 +121,12 @@ mca_page_isolate(unsigned long paddr)
  */
=20
 void
-mca_handler_bh(unsigned long paddr)
+mca_handler_bh(unsigned long paddr, void *iip, unsigned long ipsr)
 {
-	printk(KERN_DEBUG "OS_MCA: process [pid: %d](%s) encounters MCA.\n",
-		current->pid, current->comm);
+	printk(KERN_DEBUG "OS_MCA: process [cpu %d, pid: %d, uid: %d, "
+		"iip: %p, psr: 0x%lx,paddr: 0x%lx](%s) encounters MCA.\n",
+		raw_smp_processor_id(), current->pid, current->uid,
+		iip, ipsr, paddr, current->comm);
=20
 	spin_lock(&mca_bh_lock);
 	switch (mca_page_isolate(paddr)) {
@@ -438,21 +440,25 @@ recover_from_read_error(slidx_table_t *s
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
+
+	pmsa =3D sos->pal_min_state;
+	if (psr1->cpl !=3D 0 || ((psr2->cpl !=3D 0) && in_interrupt_code(pmsa->pm=
sa_iip))) {
 		smei =3D peidx_bus_check(peidx, 0);
 		if (smei->valid.target_identifier) {
 			/*
 			 *  setup for resume to bottom half of MCA,
 			 * "mca_handler_bhhook"
 			 */
-			pmsa =3D sos->pal_min_state;
-			/* pass to bhhook as 1st argument (gr8) */
+			/* pass to bhhook as argument (gr8, ...) */
 			pmsa->pmsa_gr[8-1] =3D smei->target_identifier;
+			pmsa->pmsa_gr[9-1] =3D pmsa->pmsa_iip;
+			pmsa->pmsa_gr[10-1] =3D pmsa->pmsa_ipsr;
 			/* set interrupted return address (but no use) */
 			pmsa->pmsa_br0 =3D pmsa->pmsa_iip;
 			/* change resume address to bottom half */
@@ -462,6 +468,7 @@ recover_from_read_error(slidx_table_t *s
 			psr2 =3D (struct ia64_psr *)&pmsa->pmsa_ipsr;
 			psr2->cpl =3D 0;
 			psr2->ri  =3D 0;
+			psr2->bn  =3D 1;
 			psr2->i  =3D 0;
=20
 			return 1;
Index: test/arch/ia64/kernel/mca_drv.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/mca_drv.h	2005-11-08=
 16:14:23.924625661 -0600
+++ test/arch/ia64/kernel/mca_drv.h	2005-11-09 19:24:16.218162450 -0600
@@ -111,3 +111,10 @@ typedef struct slidx_table {
 	slidx_foreach_entry(__pos, &((slidx)->sec)) { __count++; }\
 	__count; })
=20
+/* Returns non-zero if the PC is in the Interrupt Vector Table */
+static __inline__ int in_interrupt_code(unsigned long pc)
+{
+	extern char ia64_ivt[];
+	return (pc >=3D (u_long)ia64_ivt && pc < (u_long)ia64_ivt+32768);
+}
+
Index: test/arch/ia64/kernel/mca_drv_asm.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/mca_drv_asm.S	2005-1=
1-08 16:14:23.924625661 -0600
+++ test/arch/ia64/kernel/mca_drv_asm.S	2005-11-08 16:14:53.228349917 -0600
@@ -19,7 +19,7 @@ GLOBAL_ENTRY(mca_handler_bhhook)
 	;;
 	clrrrb
 	;;					=09
-	alloc	r16=3Dar.pfs,0,2,1,0	// make a new frame
+	alloc	r16=3Dar.pfs,0,2,3,0	// make a new frame
 	;;
 	mov	ar.rsc=3D0
 	;;
@@ -40,11 +40,13 @@ GLOBAL_ENTRY(mca_handler_bhhook)
 	movl	loc1=3Dmca_handler_bh	// recovery C function
 	;;
 	mov	out0=3Dr8			// poisoned address
+	mov	out1=3Dr9			// iip
+	mov	out2=3Dr10		// psr
 	mov	b6=3Dloc1
 	;;
 	mov	loc1=3Drp
 	;;
-	ssm	psr.i
+	ssm	psr.i | psr.ic
 	;;
 	br.call.sptk.many rp=B6		// does not return ...
 	;;

--=20
Russ Anderson, OS RAS/Partitioning Project Lead =20
SGI - Silicon Graphics Inc          rja@sgi.com
