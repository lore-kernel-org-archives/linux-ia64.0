From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 27 Aug 2003 20:01:33 +0000
Subject: [patch] backport of user stack size patch to 2.4
Message-Id: <marc-linux-ia64-106201491230937@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Bjorn,

Here is a backport of the user stack size patch that I pushed to David a
couple months ago.  It seems to be working well in 2.6.

The patch is against your latest bk.

Thanks
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1081  -> 1.1082 
#	include/asm-ia64/page.h	1.8     -> 1.9    
#	include/asm-ia64/pgtable.h	1.11    -> 1.12   
#	include/asm-ia64/processor.h	1.26    -> 1.27   
#	 arch/ia64/mm/init.c	1.17    -> 1.18   
#	include/asm-ia64/resource.h	1.1     -> 1.2    
#	include/asm-ia64/a.out.h	1.4     -> 1.5    
#	               (new)	        -> 1.1     include/asm-ia64/ustack.h
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/27	mort@green.i.bork.org	1.1082
# A backport of the user stack size patch that went into 2.5 a couple
# months ago.  It seems to be working correctly in 2.5/2.6.
# --------------------------------------------
#
diff -Nru a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c	Wed Aug 27 15:57:50 2003
+++ b/arch/ia64/mm/init.c	Wed Aug 27 15:57:50 2003
@@ -65,6 +65,16 @@
 	return freed;
 }
 
+inline void
+ia64_set_rbs_bot (void)
+{
+	unsigned long stack_size = current->rlim[RLIMIT_STACK].rlim_max & -16;
+
+	if (stack_size > MAX_USER_STACK_SIZE)
+		stack_size = MAX_USER_STACK_SIZE;
+	current->thread.rbs_bot = STACK_TOP - stack_size;
+}
+
 /*
  * This performs some platform-dependent address space initialization.
  * On IA-64, we want to setup the VM area for the register backing
@@ -76,6 +86,8 @@
 {
 	struct vm_area_struct *vma;
 
+	ia64_set_rbs_bot();
+
 	/*
 	 * If we're out of memory and kmem_cache_alloc() returns NULL, we simply ignore
 	 * the problem.  When the process attempts to write to the register backing store
@@ -84,7 +96,7 @@
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (vma) {
 		vma->vm_mm = current->mm;
-		vma->vm_start = IA64_RBS_BOT;
+		vma->vm_start = current->thread.rbs_bot & PAGE_MASK;
 		vma->vm_end = vma->vm_start + PAGE_SIZE;
 		vma->vm_page_prot = PAGE_COPY;
 		vma->vm_flags = VM_READ|VM_WRITE|VM_MAYREAD|VM_MAYWRITE|VM_GROWSUP;
diff -Nru a/include/asm-ia64/a.out.h b/include/asm-ia64/a.out.h
--- a/include/asm-ia64/a.out.h	Wed Aug 27 15:57:50 2003
+++ b/include/asm-ia64/a.out.h	Wed Aug 27 15:57:50 2003
@@ -30,9 +30,6 @@
 #define N_TXTOFF(x)	0
 
 #ifdef __KERNEL__
-# include <asm/page.h>
-# define STACK_TOP	(0x6000000000000000UL + (1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)
-# define IA64_RBS_BOT	(STACK_TOP - 0x80000000L + PAGE_SIZE)	/* bottom of reg. backing store */
+#include <asm/ustack.h>
 #endif
-
 #endif /* _ASM_IA64_A_OUT_H */
diff -Nru a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Wed Aug 27 15:57:50 2003
+++ b/include/asm-ia64/page.h	Wed Aug 27 15:57:50 2003
@@ -30,6 +30,8 @@
 #define PAGE_MASK		(~(PAGE_SIZE - 1))
 #define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
 
+#define RGN_MAP_LIMIT   ((1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)      /* per region addr limit */
+
 #ifdef CONFIG_HUGETLB_PAGE
 #if defined(CONFIG_HUGETLB_PAGE_SIZE_4GB)
 #define HPAGE_SHIFT                 32
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	Wed Aug 27 15:57:50 2003
+++ b/include/asm-ia64/pgtable.h	Wed Aug 27 15:57:50 2003
@@ -191,7 +191,6 @@
 #define set_pte(ptep, pteval)	(*(ptep) = (pteval))
 
 #define RGN_SIZE	(1UL << 61)
-#define RGN_MAP_LIMIT	((1UL << (4*PAGE_SHIFT - 12)) - PAGE_SIZE)	/* per region addr limit */
 #define RGN_KERNEL	7
 
 #define VMALLOC_START		(0xa000000000000000 + 3*PAGE_SIZE)
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Wed Aug 27 15:57:50 2003
+++ b/include/asm-ia64/processor.h	Wed Aug 27 15:57:50 2003
@@ -19,6 +19,7 @@
 #include <asm/ptrace.h>
 #include <asm/kregs.h>
 #include <asm/types.h>
+#include <asm/ustack.h>
 
 #define IA64_NUM_DBG_REGS	8
 /*
@@ -261,6 +262,7 @@
 	unsigned long flags;		/* various flags */
 	__u64 map_base;			/* base address for get_unmapped_area() */
 	__u64 task_size;		/* limit for task size */
+	__u64 rbs_bot;                  /* the base address of the RBS */
 	struct siginfo *siginfo;	/* current siginfo struct for ptrace() */
 
 #ifdef CONFIG_IA32_SUPPORT
@@ -298,6 +300,7 @@
 	0,				/* flags */	\
 	DEFAULT_MAP_BASE,		/* map_base */	\
 	DEFAULT_TASK_SIZE,		/* task_size */	\
+	DEFAULT_USER_STACK_SIZE,	/* rbs_bot */	\
 	0,				/* siginfo */	\
 	INIT_THREAD_IA32				\
 	INIT_THREAD_PM					\
@@ -314,7 +317,7 @@
 	regs->cr_iip = new_ip;									\
 	regs->ar_rsc = 0xf;		/* eager mode, privilege level 3 */			\
 	regs->ar_rnat = 0;									\
-	regs->ar_bspstore = IA64_RBS_BOT;							\
+	regs->ar_bspstore = current->thread.rbs_bot;						\
 	regs->ar_fpsr = FPSR_DEFAULT;								\
 	regs->loadrs = 0;									\
 	regs->r8 = current->mm->dumpable;	/* set "don't zap registers" flag */		\
diff -Nru a/include/asm-ia64/resource.h b/include/asm-ia64/resource.h
--- a/include/asm-ia64/resource.h	Wed Aug 27 15:57:50 2003
+++ b/include/asm-ia64/resource.h	Wed Aug 27 15:57:50 2003
@@ -8,6 +8,8 @@
  * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
+#include <asm/ustack.h>
+
 #define RLIMIT_CPU	0		/* CPU time in ms */
 #define RLIMIT_FSIZE	1		/* Maximum filesize */
 #define RLIMIT_DATA	2		/* max data size */
@@ -35,7 +37,7 @@
 	{ RLIM_INFINITY, RLIM_INFINITY },		\
 	{ RLIM_INFINITY, RLIM_INFINITY },		\
 	{ RLIM_INFINITY, RLIM_INFINITY },		\
-	{      _STK_LIM, RLIM_INFINITY },		\
+	{      _STK_LIM, DEFAULT_USER_STACK_SIZE },	\
 	{             0, RLIM_INFINITY },		\
 	{ RLIM_INFINITY, RLIM_INFINITY },		\
 	{             0,             0 },		\
diff -Nru a/include/asm-ia64/ustack.h b/include/asm-ia64/ustack.h
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/include/asm-ia64/ustack.h	Wed Aug 27 15:57:50 2003
@@ -0,0 +1,16 @@
+#ifndef _ASM_IA64_USTACK_H
+#define _ASM_IA64_USTACK_H
+
+/*
+ * Constants for the user stack size
+ */
+
+#include <asm/page.h>
+
+/* The absolute hard limit for stack size is 1/2 of the mappable space in the region */
+#define MAX_USER_STACK_SIZE     (RGN_MAP_LIMIT/2)
+/* Make the default stack size 2GB */
+#define DEFAULT_USER_STACK_SIZE (1UL << 31)
+#define STACK_TOP               (0x6000000000000000UL + RGN_MAP_LIMIT)
+
+#endif /* _ASM_IA64_USTACK_H */
