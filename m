From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 23 May 2003 18:15:55 +0000
Subject: [Linux-ia64] [PATCH] 2.5 - Another user stack size patch
Message-Id: <marc-linux-ia64-105590723706006@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

I hope this user stack size patch is better.  This one places the RBS
based on the max size of the stack.  The max size of the user stack
is 1TB.

The patch is against linux-ia64-2.5
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1101  -> 1.1103 
#	include/asm-ia64/processor.h	1.44    -> 1.45   
#	 arch/ia64/mm/init.c	1.37    -> 1.39   
#	include/asm-ia64/a.out.h	1.4     -> 1.5    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/23	mort@green.i.bork.org	1.1102
# Change the maximum user stack size and the location of the Register 
# Backing Store to be based on the stack size rlimit.
# --------------------------------------------
# 03/05/23	mort@green.i.bork.org	1.1103
# Remove an extra #include that isn't needed.
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Fri May 23 14:14:06 2003
+++ b/arch/ia64/mm/init.c	Fri May 23 14:14:06 2003
@@ -67,6 +67,17 @@
 	}
 }
 
+inline unsigned long ia64_rbs_bot(void)
+{
+        unsigned long stack_base = current->rlim[RLIMIT_STACK].rlim_max;
+
+        if (stack_base > MAX_USER_STACK)
+                stack_base = MAX_USER_STACK;
+	stack_base = PAGE_ALIGN(STACK_TOP - stack_base + PAGE_SIZE);
+        return PAGE_ALIGN(STACK_TOP - stack_base + PAGE_SIZE);
+}
+
+
 /*
  * This performs some platform-dependent address space initialization.
  * On IA-64, we want to setup the VM area for the register backing
@@ -86,7 +97,7 @@
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (vma) {
 		vma->vm_mm = current->mm;
-		vma->vm_start = IA64_RBS_BOT;
+		vma->vm_start = ia64_rbs_bot();
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
 		vma->vm_page_prot = protection_map[VM_DATA_DEFAULT_FLAGS & 0x7];
 		vma->vm_flags = VM_READ|VM_WRITE|VM_MAYREAD|VM_MAYWRITE|VM_GROWSUP;
diff -Nru a/include/asm-ia64/a.out.h b/include/asm-ia64/a.out.h
--- a/include/asm-ia64/a.out.h	Fri May 23 14:14:06 2003
+++ b/include/asm-ia64/a.out.h	Fri May 23 14:14:06 2003
@@ -32,7 +32,7 @@
 #ifdef __KERNEL__
 # include <asm/page.h>
 # define STACK_TOP	(0x6000000000000000UL + (1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)
-# define IA64_RBS_BOT	(STACK_TOP - 0x80000000L + PAGE_SIZE)	/* bottom of reg. backing store */
+# define MAX_USER_STACK (1UL<<40)
 #endif
 
 #endif /* _ASM_IA64_A_OUT_H */
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Fri May 23 14:14:06 2003
+++ b/include/asm-ia64/processor.h	Fri May 23 14:14:06 2003
@@ -296,6 +296,8 @@
 	.fph =		{{{{0}}}, }		\
 }
 
+extern unsigned long ia64_rbs_bot(void);
+
 #define start_thread(regs,new_ip,new_sp) do {							\
 	set_fs(USER_DS);									\
 	regs->cr_ipsr = ((regs->cr_ipsr | (IA64_PSR_BITS_TO_SET | IA64_PSR_CPL))		\
@@ -303,7 +305,7 @@
 	regs->cr_iip = new_ip;									\
 	regs->ar_rsc = 0xf;		/* eager mode, privilege level 3 */			\
 	regs->ar_rnat = 0;									\
-	regs->ar_bspstore = IA64_RBS_BOT;							\
+	regs->ar_bspstore = ia64_rbs_bot();							\
 	regs->ar_fpsr = FPSR_DEFAULT;								\
 	regs->loadrs = 0;									\
 	regs->r8 = current->mm->dumpable;	/* set "don't zap registers" flag */		\

