From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 Jan 2005 00:13:06 +0000
Subject: [PATCH] fault.c long line & coding style cleanup
Message-Id: <200501061613.06931.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_SQd3BvpnY/hP9O7"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_SQd3BvpnY/hP9O7
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Small patch to clean up long lines in fault.c and make the function 
definitions adhere to codingstyle conventions.  It also removes the #include 
of smp_lock.h since fault.c doesn't use the bkl.

 fault.c |   76 ++++++++++++++++++++++++++++++++++----------------------------
 1 files changed, 43 insertions(+), 33 deletions(-)

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_SQd3BvpnY/hP9O7
Content-Type: text/plain;
  charset="us-ascii";
  name="fault-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="fault-cleanup.patch"

===== arch/ia64/mm/fault.c 1.23 vs edited =====
--- 1.23/arch/ia64/mm/fault.c	2004-12-22 01:32:06 -08:00
+++ edited/arch/ia64/mm/fault.c	2005-01-06 15:56:58 -08:00
@@ -7,15 +7,13 @@
 #include <linux/sched.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/smp_lock.h>
 #include <linux/interrupt.h>
-
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-extern void die (char *, struct pt_regs *, long);
+extern void die(char *, struct pt_regs *, long);
 
 /*
  * This routine is analogous to expand_stack() but instead grows the
@@ -26,14 +24,13 @@
  * because the total process size is still limited by RLIMIT_STACK and
  * RLIMIT_AS.
  */
-static inline long
-expand_backing_store (struct vm_area_struct *vma, unsigned long address)
+static inline long expand_backing_store(struct vm_area_struct *vma,
+					unsigned long address)
 {
 	unsigned long grow;
 
 	grow = PAGE_SIZE >> PAGE_SHIFT;
-	if (address - vma->vm_start > current->signal->rlim[RLIMIT_STACK].rlim_cur
-	    || (((vma->vm_mm->total_vm + grow) << PAGE_SHIFT) > current->signal->rlim[RLIMIT_AS].rlim_cur))
+	if (address - vma->vm_start > current->signal->rlim[RLIMIT_STACK].rlim_cur || (((vma->vm_mm->total_vm + grow) << PAGE_SHIFT) > current->signal->rlim[RLIMIT_AS].rlim_cur))
 		return -ENOMEM;
 	vma->vm_end += PAGE_SIZE;
 	vma->vm_mm->total_vm += grow;
@@ -47,8 +44,7 @@
  * Return TRUE if ADDRESS points at a page in the kernel's mapped segment
  * (inside region 5, on ia64) and that page is present.
  */
-static int
-mapped_kernel_page_is_present (unsigned long address)
+static int mapped_kernel_page_is_present(unsigned long address)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -75,8 +71,8 @@
 	return pte_present(pte);
 }
 
-void
-ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *regs)
+void ia64_do_page_fault(unsigned long address, unsigned long isr,
+			struct pt_regs *regs)
 {
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
@@ -85,7 +81,8 @@
 	unsigned long mask;
 
 	/*
-	 * If we're in an interrupt or have no user context, we must not take the fault..
+	 * If we're in an interrupt or have no user context, we must not take
+	 * the fault..
 	 */
 	if (in_atomic() || !mm)
 		goto no_context;
@@ -108,20 +105,26 @@
 	if (!vma)
 		goto bad_area;
 
-	/* find_vma_prev() returns vma such that address < vma->vm_end or NULL */
+	/*
+	 * find_vma_prev() returns vma such that address < vma->vm_end or
+	 * NULL
+	 */
 	if (address < vma->vm_start)
 		goto check_expansion;
 
   good_area:
 	code = SEGV_ACCERR;
 
-	/* OK, we've got a good vm_area for this memory area.  Check the access permissions: */
+	/*
+	 * OK, we've got a good vm_area for this memory area.  Check the
+	 * access permissions:
+	 */
 
 #	define VM_READ_BIT	0
 #	define VM_WRITE_BIT	1
 #	define VM_EXEC_BIT	2
 
-#	if (((1 << VM_READ_BIT) != VM_READ || (1 << VM_WRITE_BIT) != VM_WRITE) \
+#	if (((1 << VM_READ_BIT) != VM_READ || (1 << VM_WRITE_BIT) != VM_WRITE)\
 	    || (1 << VM_EXEC_BIT) != VM_EXEC)
 #		error File is out of sync with <linux/mm.h>.  Please update.
 #	endif
@@ -163,7 +166,8 @@
 	return;
 
   check_expansion:
-	if (!(prev_vma && (prev_vma->vm_flags & VM_GROWSUP) && (address == prev_vma->vm_end))) {
+	if (!(prev_vma && (prev_vma->vm_flags & VM_GROWSUP) &&
+	      (address == prev_vma->vm_end))) {
 		if (!(vma->vm_flags & VM_GROWSDOWN))
 			goto bad_area;
 		if (REGION_NUMBER(address) != REGION_NUMBER(vma->vm_start)
@@ -186,13 +190,15 @@
 #ifdef CONFIG_VIRTUAL_MEM_MAP
   bad_area_no_up:
 #endif
-	if ((isr & IA64_ISR_SP)
-	    || ((isr & IA64_ISR_NA) && (isr & IA64_ISR_CODE_MASK) == IA64_ISR_CODE_LFETCH))
+	if ((isr & IA64_ISR_SP) ||
+	    ((isr & IA64_ISR_NA) &&
+	     (isr & IA64_ISR_CODE_MASK) == IA64_ISR_CODE_LFETCH))
 	{
 		/*
-		 * This fault was due to a speculative load or lfetch.fault, set the "ed"
-		 * bit in the psr to ensure forward progress.  (Target register will get a
-		 * NaT for ld.s, lfetch will be canceled.)
+		 * This fault was due to a speculative load or lfetch.fault,
+		 * set the "ed" bit in the psr to ensure forward progress.
+		 * (Target register will get a NaT for ld.s, lfetch will be
+		 * canceled.)
 		 */
 		ia64_psr(regs)->ed = 1;
 		return;
@@ -211,8 +217,9 @@
   no_context:
 	if (isr & IA64_ISR_SP) {
 		/*
-		 * This fault was due to a speculative load set the "ed" bit in the psr to
-		 * ensure forward progress (target register will get a NaT).
+		 * This fault was due to a speculative load set the "ed" bit in
+		 * the psr to ensure forward progress (target register will get
+		 * a NaT).
 		 */
 		ia64_psr(regs)->ed = 1;
 		return;
@@ -222,26 +229,29 @@
 		return;
 
 	/*
-	 * Since we have no vma's for region 5, we might get here even if the address is
-	 * valid, due to the VHPT walker inserting a non present translation that becomes
-	 * stale. If that happens, the non present fault handler already purged the stale
-	 * translation, which fixed the problem. So, we check to see if the translation is
-	 * valid, and return if it is.
+	 * Since we have no vma's for region 5, we might get here even if the
+	 * address is valid, due to the VHPT walker inserting a non present
+	 * translation that becomes stale. If that happens, the non present
+	 * fault handler already purged the stale translation, which fixed the
+	 * problem. So, we check to see if the translation is valid, and return
+	 * if it is.
 	 */
-	if (REGION_NUMBER(address) == 5 && mapped_kernel_page_is_present(address))
+	if (REGION_NUMBER(address) == 5 &&
+	    mapped_kernel_page_is_present(address))
 		return;
 
 	/*
-	 * Oops. The kernel tried to access some bad page. We'll have to terminate things
-	 * with extreme prejudice.
+	 * Oops. The kernel tried to access some bad page. We'll have to
+	 * terminate things with extreme prejudice.
 	 */
 	bust_spinlocks(1);
 
 	if (address < PAGE_SIZE)
-		printk(KERN_ALERT "Unable to handle kernel NULL pointer dereference (address %016lx)\n", address);
+		printk(KERN_ALERT "Unable to handle kernel NULL pointer "
+		       "dereference (address 0x%016lx)\n", address);
 	else
 		printk(KERN_ALERT "Unable to handle kernel paging request at "
-		       "virtual address %016lx\n", address);
+		       "virtual address 0x%016lx\n", address);
 	die("Oops", regs, isr);
 	bust_spinlocks(0);
 	do_exit(SIGKILL);

--Boundary-00=_SQd3BvpnY/hP9O7--
