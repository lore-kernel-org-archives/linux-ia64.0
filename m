From: Shaohua Li <shaohua.li@intel.com>
Date: Thu, 28 Feb 2008 08:09:38 +0000
Subject: [PATCH 3/4] IA64: use CORE_DUMP_USE_REGSET
Message-Id: <1204186178.11494.18.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

After we have regset support, we can use CORE_DUMP_USE_REGSET.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/kernel/process.c |   30 ------------------------------
 include/asm-ia64/elf.h     |    7 +------
 2 files changed, 1 insertion(+), 36 deletions(-)

Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2008-02-28 07:54:50.000000000 +0800
+++ linux/arch/ia64/kernel/process.c	2008-02-28 10:47:42.000000000 +0800
@@ -625,21 +625,6 @@ do_dump_fpu (struct unw_frame_info *info
 	do_dump_task_fpu(current, info, arg);
 }
 
-int
-dump_task_regs(struct task_struct *task, elf_gregset_t *regs)
-{
-	struct unw_frame_info tcore_info;
-
-	if (current = task) {
-		unw_init_running(do_copy_regs, regs);
-	} else {
-		memset(&tcore_info, 0, sizeof(tcore_info));
-		unw_init_from_blocked_task(&tcore_info, task);
-		do_copy_task_regs(task, &tcore_info, regs);
-	}
-	return 1;
-}
-
 void
 ia64_elf_core_copy_regs (struct pt_regs *pt, elf_gregset_t dst)
 {
@@ -647,21 +632,6 @@ ia64_elf_core_copy_regs (struct pt_regs 
 }
 
 int
-dump_task_fpu (struct task_struct *task, elf_fpregset_t *dst)
-{
-	struct unw_frame_info tcore_info;
-
-	if (current = task) {
-		unw_init_running(do_dump_fpu, dst);
-	} else {
-		memset(&tcore_info, 0, sizeof(tcore_info));
-		unw_init_from_blocked_task(&tcore_info, task);
-		do_dump_task_fpu(task, &tcore_info, dst);
-	}
-	return 1;
-}
-
-int
 dump_fpu (struct pt_regs *pt, elf_fpregset_t dst)
 {
 	unw_init_running(do_dump_fpu, dst);
Index: linux/include/asm-ia64/elf.h
=================================--- linux.orig/include/asm-ia64/elf.h	2008-02-28 07:54:50.000000000 +0800
+++ linux/include/asm-ia64/elf.h	2008-02-28 10:47:42.000000000 +0800
@@ -26,6 +26,7 @@
 #define ELF_ARCH	EM_IA_64
 
 #define USE_ELF_CORE_DUMP
+#define CORE_DUMP_USE_REGSET
 
 /* Least-significant four bits of ELF header's e_flags are OS-specific.  The bits are
    interpreted as follows by Linux: */
@@ -207,12 +208,6 @@ extern void ia64_elf_core_copy_regs (str
 
 struct task_struct;
 
-extern int dump_task_regs(struct task_struct *, elf_gregset_t *);
-extern int dump_task_fpu (struct task_struct *, elf_fpregset_t *);
-
-#define ELF_CORE_COPY_TASK_REGS(tsk, elf_gregs) dump_task_regs(tsk, elf_gregs)
-#define ELF_CORE_COPY_FPREGS(tsk, elf_fpregs) dump_task_fpu(tsk, elf_fpregs)
-
 #define GATE_EHDR	((const struct elfhdr *) GATE_ADDR)
 
 /* update AT_VECTOR_SIZE_ARCH if the number of NEW_AUX_ENT entries changes */


