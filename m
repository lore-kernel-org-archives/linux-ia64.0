From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 24 Feb 2006 20:42:41 +0000
Subject: [patch] MCA recovery: kernel context recovery table
Message-Id: <200602242042.k1OKgftP1421288@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

[patch] MCA recovery: kernel context recovery table

Memory errors encountered by user applications may surface
when the CPU is running in kernel context.  The current code
will not attempt recovery if the MCA surfaces in kernel=20
context (privilage mode 0).  This patch adds a check for cases=20
where the user initiated the load that surfaces in kernel=20
interrupt code.

An example is a user process lauching a load from memory=20
and the data in memory had bad ECC.  Before the bad data
gets to the CPU register, and interrupt comes in.  The=20
code jumps to the IVT interrupt entry point and begins=20
execution in kernel context.  The process of saving the
user registers (SAVE_REST) causes the bad data to be loaded
into a CPU register, triggering the MCA.  The MCA surfaces in
kernel context, even though the load was initiated from
user context.

As suggested by David and Tony, this patch uses an exception
table like approach, puting the tagged recovery addresses in
a searchable table.  One difference from the exception table=20
is that MCAs do not surface in precise places (such as with
a TLB miss), so instead of tagging specific instructions,
address ranges are registers.  A single macro is used to do
the tagging, with the input parameter being the label
of the starting address and the macro being the ending
address.  This limits clutter in the code.

This patch only tags one spot, the interrupt ivt entry.
Testing showed that spot to be a "heavy hitter" with=20
MCAs surfacing while saving user registers.  Other spots
can be added as needed by adding a single macro.

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/kernel/ivt.S         |    1=20
 arch/ia64/kernel/mca.c         |   98 ++++++++++++++++++++++++++++++------=
-----
 arch/ia64/kernel/mca_drv.c     |   20 +++++---
 arch/ia64/kernel/mca_drv.h     |    7 ++
 arch/ia64/kernel/mca_drv_asm.S |    6 +-
 arch/ia64/kernel/vmlinux.lds.S |    9 +++
 include/asm-ia64/asmmacro.h    |   11 ++++
 7 files changed, 119 insertions(+), 33 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/mca_drv.c	2006-02-10=
 13:09:51.982352916 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2006-02-10 17:59:34.278072781 -0600
@@ -6,6 +6,7 @@
  * Copyright (C) Hidetoshi Seto (seto.hidetoshi@jp.fujitsu.com)
  * Copyright (C) 2005 Silicon Graphics, Inc
  * Copyright (C) 2005 Keith Owens <kaos@sgi.com>
+ * Copyright (C) 2006 Russ Anderson <rja@sgi.com>
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -121,10 +122,12 @@ mca_page_isolate(unsigned long paddr)
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
@@ -441,21 +444,25 @@ recover_from_read_error(slidx_table_t *s
 	if (!peidx_bottom(peidx) || !(peidx_bottom(peidx)->valid.minstate))
 		return 0;
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
+	if (psr1->cpl !=3D 0 || ((psr2->cpl !=3D 0) && mca_recover_range(pmsa->pm=
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
@@ -465,6 +472,7 @@ recover_from_read_error(slidx_table_t *s
 			psr2 =3D (struct ia64_psr *)&pmsa->pmsa_ipsr;
 			psr2->cpl =3D 0;
 			psr2->ri  =3D 0;
+			psr2->bn  =3D 1;
 			psr2->i  =3D 0;
=20
 			return 1;
Index: test/arch/ia64/kernel/mca_drv.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/mca_drv.h	2006-02-10=
 13:09:51.982352916 -0600
+++ test/arch/ia64/kernel/mca_drv.h	2006-02-10 17:59:34.285884520 -0600
@@ -111,3 +111,10 @@ typedef struct slidx_table {
 	slidx_foreach_entry(__pos, &((slidx)->sec)) { __count++; }\
 	__count; })
=20
+struct mca_table_entry {
+	int start_addr;	/* location-relative starting address of MCA recoverable =
range */
+	int end_addr;	/* location-relative ending address of MCA recoverable rang=
e */
+};
+
+extern const struct mca_table_entry *search_mca_tables (unsigned long addr=
);
+extern int mca_recover_range(unsigned long);
Index: test/arch/ia64/kernel/mca_drv_asm.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/mca_drv_asm.S	2006-0=
2-10 13:09:51.982352916 -0600
+++ test/arch/ia64/kernel/mca_drv_asm.S	2006-02-10 17:59:34.288813922 -0600
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
Index: test/arch/ia64/kernel/ivt.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/ivt.S	2006-02-10 13:=
09:51.978447050 -0600
+++ test/arch/ia64/kernel/ivt.S	2006-02-10 17:59:34.296625660 -0600
@@ -862,6 +862,7 @@ ENTRY(interrupt)
 	;;
 	SAVE_REST
 	;;
+	MCA_RECOVER_RANGE(interrupt)
 	alloc r14=3Dar.pfs,0,0,2,0 // must be first in an insn group
 	mov out0=3Dcr.ivr		// pass cr.ivr as first arg
 	add out1=16,sp		// pass pointer to pt_regs as second arg
Index: test/arch/ia64/kernel/vmlinux.lds.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/vmlinux.lds.S	2006-0=
2-10 13:09:51.999929316 -0600
+++ test/arch/ia64/kernel/vmlinux.lds.S	2006-02-10 17:59:34.297602128 -0600
@@ -70,6 +70,15 @@ SECTIONS
 	  __stop___ex_table =3D .;
 	}
=20
+  /* MCA table */
+  . =3D ALIGN(16);
+  __mca_table : AT(ADDR(__mca_table) - LOAD_OFFSET)
+	{
+	  __start___mca_table =3D .;
+	  *(__mca_table)
+	  __stop___mca_table =3D .;
+	}
+
   .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)
 	{
 	  __start___vtop_patchlist =3D .;
Index: test/include/asm-ia64/asmmacro.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/include/asm-ia64/asmmacro.h	2006-02-1=
0 13:09:56.878356655 -0600
+++ test/include/asm-ia64/asmmacro.h	2006-02-24 13:56:35.528818597 -0600
@@ -51,6 +51,17 @@ name:
   [99:]	x
=20
 /*
+ * Tag MCA recoverable instruction ranges.
+ */
+
+	.section "__mca_table", "a"		// declare section & section attributes
+	.previous
+
+# define MCA_RECOVER_RANGE(y)			\
+	.xdata4 "__mca_table", y-., 99f-.;	\
+  [99:]
+
+/*
  * Mark instructions that need a load of a virtual address patched to be
  * a load of a physical address.  We use this either in critical performan=
ce
  * path (ivt.S - TLB miss processing) or in places where it might not be
Index: test/arch/ia64/kernel/mca.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- test.orig/arch/ia64/kernel/mca.c	2006-02-10 13:=
09:51.980399983 -0600
+++ test/arch/ia64/kernel/mca.c	2006-02-23 16:52:49.392092270 -0600
@@ -83,6 +83,7 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
=20
+#include "mca_drv.h"
 #include "entry.h"
=20
 #if defined(IA64_MCA_DEBUG_INFO)
@@ -282,6 +283,50 @@ ia64_mca_log_sal_error_record(int sal_in
 }
=20
 /*
+ * search_mca_table
+ *  See if the MCA surfaced in an instruction range
+ *  that has been tagged as recoverable.
+ *
+ *  Inputs
+ *	first	First address range to check
+ *	last	Last address range to check
+ *	ip	Instruction pointer, address we are looking for
+ *
+ * Return value:
+ *      1 on Success (in the table)/ 0 on Failure (not in the  table)
+ */
+int
+search_mca_table (const struct mca_table_entry *first,
+                const struct mca_table_entry *last,
+                unsigned long ip)
+{
+        const struct mca_table_entry *curr;
+        u64 curr_start, curr_end;
+
+        curr =3D first;
+        while (curr <=3D last) {
+                curr_start =3D (u64) &curr->start_addr + curr->start_addr;
+                curr_end =3D (u64) &curr->end_addr + curr->end_addr;
+
+                if ((ip >=3D curr_start) && (ip <=3D curr_end)) {
+                        return 1;
+                }
+                curr++;
+        }
+        return 0;
+}
+
+/* Given an address, look for it in the mca tables. */
+int mca_recover_range(unsigned long addr)
+{
+	extern struct mca_table_entry __start___mca_table[];
+	extern struct mca_table_entry __stop___mca_table[];
+
+	return search_mca_table(__start___mca_table, __stop___mca_table-1, addr);
+}
+EXPORT_SYMBOL(mca_recover_range);
+
+/*
  * platform dependent error handling
  */
 #ifndef PLATFORM_MCA_HANDLERS
@@ -723,31 +768,34 @@ ia64_mca_modify_original_stack(struct pt
 		msg =3D "occurred in user space";
 		goto no_mod;
 	}
-	if (r13 !=3D sos->prev_IA64_KR_CURRENT) {
-		msg =3D "inconsistent previous current and r13";
-		goto no_mod;
-	}
-	if ((r12 - r13) >=3D KERNEL_STACK_SIZE) {
-		msg =3D "inconsistent r12 and r13";
-		goto no_mod;
-	}
-	if ((ar_bspstore - r13) >=3D KERNEL_STACK_SIZE) {
-		msg =3D "inconsistent ar.bspstore and r13";
-		goto no_mod;
-	}
-	va.p =3D old_bspstore;
-	if (va.f.reg < 5) {
-		msg =3D "old_bspstore is in the wrong region";
-		goto no_mod;
-	}
-	if ((ar_bsp - r13) >=3D KERNEL_STACK_SIZE) {
-		msg =3D "inconsistent ar.bsp and r13";
-		goto no_mod;
-	}
-	size +=3D (ia64_rse_skip_regs(old_bspstore, slots) - old_bspstore) * 8;
-	if (ar_bspstore + size > r12) {
-		msg =3D "no room for blocked state";
-		goto no_mod;
+
+	if (!mca_recover_range(ms->pmsa_iip)) {
+		if (r13 !=3D sos->prev_IA64_KR_CURRENT) {
+			msg =3D "inconsistent previous current and r13";
+			goto no_mod;
+		}
+		if ((r12 - r13) >=3D KERNEL_STACK_SIZE) {
+			msg =3D "inconsistent r12 and r13";
+			goto no_mod;
+		}
+		if ((ar_bspstore - r13) >=3D KERNEL_STACK_SIZE) {
+			msg =3D "inconsistent ar.bspstore and r13";
+			goto no_mod;
+		}
+		va.p =3D old_bspstore;
+		if (va.f.reg < 5) {
+			msg =3D "old_bspstore is in the wrong region";
+			goto no_mod;
+		}
+		if ((ar_bsp - r13) >=3D KERNEL_STACK_SIZE) {
+			msg =3D "inconsistent ar.bsp and r13";
+			goto no_mod;
+		}
+		size +=3D (ia64_rse_skip_regs(old_bspstore, slots) - old_bspstore) * 8;
+		if (ar_bspstore + size > r12) {
+			msg =3D "no room for blocked state";
+			goto no_mod;
+		}
 	}
=20
 	/* Change the comm field on the MCA/INT task to include the pid that
--=20
Russ Anderson, OS RAS/Partitioning Project Lead =20
SGI - Silicon Graphics Inc          rja@sgi.com
