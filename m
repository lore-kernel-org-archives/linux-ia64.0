From: Arun Sharma <arun.sharma@intel.com>
Date: Wed, 13 Nov 2002 19:50:28 +0000
Subject: [Linux-ia64] ia32 emulation fixes for 2.5.45
Message-Id: <marc-linux-ia64-105590709805411@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I found that Linux 2.5.45 had some problems passing arguments to ia32
programs running on ia64 in emulation mode.

The attached patch fixes the problems.

	-Arun

==File g:/t/ia32-static.patch===============
--- linux-2.5.45/arch/ia64/ia32/binfmt_elf32.c-	Tue Nov 12 19:36:57 2002
+++ linux-2.5.45/arch/ia64/ia32/binfmt_elf32.c	Tue Nov 12 19:45:17 2002
@@ -162,9 +162,11 @@
 {
 	unsigned long stack_base;
 	struct vm_area_struct *mpnt;
+	struct mm_struct *mm = current->mm;
 	int i;
 
 	stack_base = IA32_STACK_TOP - MAX_ARG_PAGES*PAGE_SIZE;
+	mm->arg_start = bprm->p + stack_base;
 
 	bprm->p += stack_base;
 	if (bprm->loader)
@@ -175,6 +177,11 @@
 	if (!mpnt)
 		return -ENOMEM;
 
+	if (!vm_enough_memory((IA32_STACK_TOP - (PAGE_MASK & (unsigned long) bprm->p))>>PAGE_SHIFT)) {
+		kmem_cache_free(vm_area_cachep, mpnt);
+		return -ENOMEM;
+	}
+
 	down_write(&current->mm->mmap_sem);
 	{
 		mpnt->vm_mm = current->mm;
==============================


