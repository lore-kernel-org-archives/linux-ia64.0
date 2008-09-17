From: shaohua.li@intel.com
Date: Wed, 17 Sep 2008 08:13:21 +0000
Subject: [patch 1/4] syscall.h support for ia64
Message-Id: <20080917082022.087263904@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add asm/syscall.h for IA64. Utrace requires this.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/include/asm/ptrace.h  |    6 ++
 arch/ia64/include/asm/syscall.h |   90 ++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/ptrace.c       |   58 +++++++++++++++++++++++++
 3 files changed, 154 insertions(+)

Index: linux/arch/ia64/include/asm/ptrace.h
=================================--- linux.orig/arch/ia64/include/asm/ptrace.h	2008-09-17 13:30:39.000000000 +0800
+++ linux/arch/ia64/include/asm/ptrace.h	2008-09-17 13:53:48.000000000 +0800
@@ -240,6 +240,12 @@ struct switch_stack {
  */
 # define instruction_pointer(regs) ((regs)->cr_iip + ia64_psr(regs)->ri)
 
+static inline unsigned long user_stack_pointer(struct pt_regs *regs)
+{
+	/* FIXME: should this be bspstore + nr_dirty regs? */
+	return regs->ar_bspstore;
+}
+
 #define regs_return_value(regs) ((regs)->r8)
 
 /* Conserve space in histogram by encoding slot bits in address
Index: linux/arch/ia64/include/asm/syscall.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/include/asm/syscall.h	2008-09-17 13:53:48.000000000 +0800
@@ -0,0 +1,90 @@
+/*
+ * Access to user system call parameters and results
+ *
+ * Copyright (C) 2008 Intel Corp.  Shaohua Li <shaohua.li@intel.com>
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * See asm-generic/syscall.h for descriptions of what we must do here.
+ */
+
+#ifndef _ASM_SYSCALL_H
+#define _ASM_SYSCALL_H	1
+
+#include <linux/sched.h>
+#include <linux/err.h>
+
+static inline long syscall_get_nr(struct task_struct *task,
+				  struct pt_regs *regs)
+{
+	BUG_ON(IS_IA32_PROCESS(regs));
+
+	return regs->r15;
+}
+
+static inline void syscall_rollback(struct task_struct *task,
+				    struct pt_regs *regs)
+{
+	BUG_ON(IS_IA32_PROCESS(regs));
+	/* do nothing */
+}
+
+static inline long syscall_get_error(struct task_struct *task,
+				     struct pt_regs *regs)
+{
+	BUG_ON(IS_IA32_PROCESS(regs));
+
+	return regs->r10 = -1 ? regs->r8:0;
+}
+
+static inline long syscall_get_return_value(struct task_struct *task,
+					    struct pt_regs *regs)
+{
+	BUG_ON(IS_IA32_PROCESS(regs));
+
+	return regs->r8;
+}
+
+static inline void syscall_set_return_value(struct task_struct *task,
+					    struct pt_regs *regs,
+					    int error, long val)
+{
+	BUG_ON(IS_IA32_PROCESS(regs));
+
+	if (error) {
+		/* error < 0, but ia64 uses > 0 return value */
+		regs->r8 = -error;
+		regs->r10 = -1;
+	} else {
+		regs->r8 = val;
+		regs->r10 = 0;
+	}
+}
+
+extern void ia64_syscall_get_set_arguments(struct task_struct *task,
+	struct pt_regs *regs, unsigned int i, unsigned int n,
+	unsigned long *args, int rw);
+static inline void syscall_get_arguments(struct task_struct *task,
+					 struct pt_regs *regs,
+					 unsigned int i, unsigned int n,
+					 unsigned long *args)
+{
+	BUG_ON(IS_IA32_PROCESS(regs));
+	BUG_ON(i + n > 6);
+
+	ia64_syscall_get_set_arguments(task, regs, i, n, args, 0);
+}
+
+static inline void syscall_set_arguments(struct task_struct *task,
+					 struct pt_regs *regs,
+					 unsigned int i, unsigned int n,
+					 const unsigned long *args)
+{
+	BUG_ON(IS_IA32_PROCESS(regs));
+	BUG_ON(i + n > 6);
+
+	ia64_syscall_get_set_arguments(task, regs, i, n, args, 1);
+}
+#endif	/* _ASM_SYSCALL_H */
Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	2008-09-17 13:30:38.000000000 +0800
+++ linux/arch/ia64/kernel/ptrace.c	2008-09-17 13:53:48.000000000 +0800
@@ -2199,3 +2199,61 @@ const struct user_regset_view *task_user
 #endif
 	return &user_ia64_view;
 }
+
+struct syscall_get_set_args {
+	unsigned int i;
+	unsigned int n;
+	unsigned long *args;
+	struct pt_regs *regs;
+	int rw;
+};
+
+static void syscall_get_set_args_cb(struct unw_frame_info *info, void *data)
+{
+	struct syscall_get_set_args *args = data;
+	struct pt_regs *pt = args->regs;
+	unsigned long *krbs, cfm, ndirty;
+	int i, count;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+
+	cfm = pt->cr_ifs;
+	krbs = (unsigned long *)info->task + IA64_RBS_OFFSET/8;
+	ndirty = ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
+
+	count = args->n;
+	if (in_syscall(pt))
+		count = min_t(int, args->n, cfm & 0x7f);
+
+	for (i = 0; i < count; i++) {
+		if (args->rw)
+			*ia64_rse_skip_regs(krbs, ndirty + i + args->i) +				args->args[i];
+		else
+			args->args[i] = *ia64_rse_skip_regs(krbs,
+				ndirty + i + args->i);
+	}
+}
+
+void ia64_syscall_get_set_arguments(struct task_struct *task,
+	struct pt_regs *regs, unsigned int i, unsigned int n,
+	unsigned long *args, int rw)
+{
+	struct syscall_get_set_args data = {
+		.i = i,
+		.n = n,
+		.args = args,
+		.regs = regs,
+		.rw = rw,
+	};
+
+	if (task = current)
+		unw_init_running(syscall_get_set_args_cb, &data);
+	else {
+		struct unw_frame_info ufi;
+		memset(&ufi, 0, sizeof(ufi));
+		unw_init_from_blocked_task(&ufi, task);
+		syscall_get_set_args_cb(&ufi, &data);
+	}
+}

-- 
