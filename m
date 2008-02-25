From: Shaohua Li <shaohua.li@intel.com>
Date: Mon, 25 Feb 2008 08:38:40 +0000
Subject: [patch 2/3] regset IA64 implementation
Message-Id: <1203928720.3841.20.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is the regset implementation under IA64. Basically register
read/write, which is derived from current ptrace register read/write.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/ia32/sys_ia32.c  |  497 +++++++++++++++++++++++++++++++
 arch/ia64/kernel/process.c |   30 -
 arch/ia64/kernel/ptrace.c  |  701 +++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/elf.h     |   31 +
 4 files changed, 1223 insertions(+), 36 deletions(-)

Index: linux/arch/ia64/ia32/sys_ia32.c
=================================--- linux.orig/arch/ia64/ia32/sys_ia32.c	2008-02-25 15:18:53.000000000 +0800
+++ linux/arch/ia64/ia32/sys_ia32.c	2008-02-25 15:42:45.000000000 +0800
@@ -43,6 +43,7 @@
 #include <linux/eventpoll.h>
 #include <linux/personality.h>
 #include <linux/ptrace.h>
+#include <linux/regset.h>
 #include <linux/stat.h>
 #include <linux/ipc.h>
 #include <linux/capability.h>
@@ -1883,6 +1884,502 @@ sys32_ptrace (int request, pid_t pid, un
 	return ret;
 }
 
+struct regset_get {
+	void *kbuf;
+	void __user *ubuf;
+};
+
+struct regset_set {
+	const void *kbuf;
+	const void __user *ubuf;
+};
+
+struct regset_getset {
+	struct task_struct *target;
+	const struct user_regset *regset;
+	union {
+		struct regset_get get;
+		struct regset_set set;
+	} u;
+	unsigned int pos;
+	unsigned int count;
+	int ret;
+};
+
+static void getfpreg(struct task_struct *task, int regno, int *val)
+{
+	switch (regno / sizeof(int)) {
+	case 0:
+		*val = task->thread.fcr & 0xffff;
+		break;
+	case 1:
+		*val = task->thread.fsr & 0xffff;
+		break;
+	case 2:
+		*val = (task->thread.fsr>>16) & 0xffff;
+		break;
+	case 3:
+		*val = task->thread.fir;
+		break;
+	case 4:
+		*val = (task->thread.fir>>32) & 0xffff;
+		break;
+	case 5:
+		*val = task->thread.fdr;
+		break;
+	case 6:
+		*val = (task->thread.fdr >> 32) & 0xffff;
+		break;
+	}
+}
+
+static void setfpreg(struct task_struct *task, int regno, int val)
+{
+	switch (regno / sizeof(int)) {
+	case 0:
+		task->thread.fcr = (task->thread.fcr & (~0x1f3f))
+			| (val & 0x1f3f);
+		break;
+	case 1:
+		task->thread.fsr = (task->thread.fsr & (~0xffff)) | val;
+		break;
+	case 2:
+		task->thread.fsr = (task->thread.fsr & (~0xffff0000))
+			| (val << 16);
+		break;
+	case 3:
+		task->thread.fir = (task->thread.fir & (~0xffffffff)) | val;
+		break;
+	case 5:
+		task->thread.fdr = (task->thread.fdr & (~0xffffffff)) | val;
+		break;
+	}
+}
+
+static void access_fpreg_ia32(int regno, void *reg,
+		struct pt_regs *pt, struct switch_stack *sw,
+		int tos, int write)
+{
+	void *f;
+
+	if ((regno += tos) >= 8)
+		regno -= 8;
+	if (regno < 4)
+		f = &pt->f8 + regno;
+	else if (regno <= 7)
+		f = &sw->f12 + (regno - 4);
+	else {
+		printk(KERN_ERR "regno must be less than 7 \n");
+		 return;
+	}
+
+	if (write)
+		memcpy(f, reg, sizeof(struct _fpreg_ia32));
+	else
+		memcpy(reg, f, sizeof(struct _fpreg_ia32));
+}
+
+static void do_fpregs_get(struct unw_frame_info *info, void *arg)
+{
+	struct regset_getset *dst = arg;
+	struct task_struct *task = dst->target;
+	struct pt_regs *pt;
+	int start, end, tos;
+	char buf[80];
+
+	if (dst->count = 0 || unw_unwind_to_user(info) < 0)
+		return;
+	if (dst->pos < 7 * sizeof(int)) {
+		end = min((dst->pos + dst->count),
+			(unsigned int)(7 * sizeof(int)));
+		for (start = dst->pos; start < end; start += sizeof(int))
+			getfpreg(task, start, (int *)(buf + start));
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf, buf,
+				0, 7 * sizeof(int));
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+	if (dst->pos < sizeof(struct ia32_user_i387_struct)) {
+		pt = task_pt_regs(task);
+		tos = (task->thread.fsr >> 11) & 7;
+		end = min(dst->pos + dst->count,
+			(unsigned int)(sizeof(struct ia32_user_i387_struct)));
+		start = (dst->pos - 7 * sizeof(int)) /
+			sizeof(struct _fpreg_ia32);
+		end = (end - 7 * sizeof(int)) / sizeof(struct _fpreg_ia32);
+		for (; start < end; start++)
+			access_fpreg_ia32(start,
+				(struct _fpreg_ia32 *)buf + start,
+				pt, info->sw, tos, 0);
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf,
+				buf, 7 * sizeof(int),
+				sizeof(struct ia32_user_i387_struct));
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+}
+
+static void do_fpregs_set(struct unw_frame_info *info, void *arg)
+{
+	struct regset_getset *dst = arg;
+	struct task_struct *task = dst->target;
+	struct pt_regs *pt;
+	char buf[80];
+	int end, start, tos;
+
+	if (dst->count = 0 || unw_unwind_to_user(info) < 0)
+		return;
+
+	if (dst->pos < 7 * sizeof(int)) {
+		start = dst->pos;
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf, buf,
+				0, 7 * sizeof(int));
+		if (dst->ret)
+			return;
+		for (; start < dst->pos; start += sizeof(int))
+			setfpreg(task, start, *((int *)(buf + start)));
+		if (dst->count = 0)
+			return;
+	}
+	if (dst->pos < sizeof(struct ia32_user_i387_struct)) {
+		start = (dst->pos - 7 * sizeof(int)) /
+			sizeof(struct _fpreg_ia32);
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf,
+				buf, 7 * sizeof(int),
+				sizeof(struct ia32_user_i387_struct));
+		if (dst->ret)
+			return;
+		pt = task_pt_regs(task);
+		tos = (task->thread.fsr >> 11) & 7;
+		end = (dst->pos - 7 * sizeof(int)) / sizeof(struct _fpreg_ia32);
+		for (; start < end; start++)
+			access_fpreg_ia32(start,
+				(struct _fpreg_ia32 *)buf + start,
+				pt, info->sw, tos, 1);
+		if (dst->count = 0)
+			return;
+	}
+}
+
+#define OFFSET(member) ((int)(offsetof(struct ia32_user_fxsr_struct, member)))
+static void getfpxreg(struct task_struct *task, int start, int end, char *buf)
+{
+	int min_val;
+
+	min_val = min(end, OFFSET(fop));
+	while (start < min_val) {
+		if (start = OFFSET(cwd))
+			*((short *)buf) = task->thread.fcr & 0xffff;
+		else if (start = OFFSET(swd))
+			*((short *)buf) = task->thread.fsr & 0xffff;
+		else if (start = OFFSET(twd))
+			*((short *)buf) = (task->thread.fsr>>16) & 0xffff;
+		buf += 2;
+		start += 2;
+	}
+	/* skip fop element */
+	if (start = OFFSET(fop)) {
+		start += 2;
+		buf += 2;
+	}
+	while (start < end) {
+		if (start = OFFSET(fip))
+			*((int *)buf) = task->thread.fir;
+		else if (start = OFFSET(fcs))
+			*((int *)buf) = (task->thread.fir>>32) & 0xffff;
+		else if (start = OFFSET(foo))
+			*((int *)buf) = task->thread.fdr;
+		else if (start = OFFSET(fos))
+			*((int *)buf) = (task->thread.fdr>>32) & 0xffff;
+		else if (start = OFFSET(mxcsr))
+			*((int *)buf) = ((task->thread.fcr>>32) & 0xff80)
+					 | ((task->thread.fsr>>32) & 0x3f);
+		buf += 4;
+		start += 4;
+	}
+}
+
+static void setfpxreg(struct task_struct *task, int start, int end, char *buf)
+{
+	int min_val, num32;
+	short num;
+	unsigned long num64;
+
+	min_val = min(end, OFFSET(fop));
+	while (start < min_val) {
+		num = *((short *)buf);
+		if (start = OFFSET(cwd)) {
+			task->thread.fcr = (task->thread.fcr & (~0x1f3f))
+						| (num & 0x1f3f);
+		} else if (start = OFFSET(swd)) {
+			task->thread.fsr = (task->thread.fsr & (~0xffff)) | num;
+		} else if (start = OFFSET(twd)) {
+			task->thread.fsr = (task->thread.fsr & (~0xffff0000))
+				| (((int)num) << 16);
+		}
+		buf += 2;
+		start += 2;
+	}
+	/* skip fop element */
+	if (start = OFFSET(fop)) {
+		start += 2;
+		buf += 2;
+	}
+	while (start < end) {
+		num32 = *((int *)buf);
+		if (start = OFFSET(fip))
+			task->thread.fir = (task->thread.fir & (~0xffffffff))
+						 | num32;
+		else if (start = OFFSET(foo))
+			task->thread.fdr = (task->thread.fdr & (~0xffffffff))
+						 | num32;
+		else if (start = OFFSET(mxcsr)) {
+			num64 = num32 & 0xff10;
+			task->thread.fcr = (task->thread.fcr &
+				(~0xff1000000000UL)) | (num64<<32);
+			num64 = num32 & 0x3f;
+			task->thread.fsr = (task->thread.fsr &
+				(~0x3f00000000UL)) | (num64<<32);
+		}
+		buf += 4;
+		start += 4;
+	}
+}
+
+static void do_fpxregs_get(struct unw_frame_info *info, void *arg)
+{
+	struct regset_getset *dst = arg;
+	struct task_struct *task = dst->target;
+	struct pt_regs *pt;
+	char buf[128];
+	int start, end, tos;
+
+	if (dst->count = 0 || unw_unwind_to_user(info) < 0)
+		return;
+	if (dst->pos < OFFSET(st_space[0])) {
+		end = min(dst->pos + dst->count, (unsigned int)32);
+		getfpxreg(task, dst->pos, end, buf);
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf, buf,
+				0, OFFSET(st_space[0]));
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+	if (dst->pos < OFFSET(xmm_space[0])) {
+		pt = task_pt_regs(task);
+		tos = (task->thread.fsr >> 11) & 7;
+		end = min(dst->pos + dst->count,
+				(unsigned int)OFFSET(xmm_space[0]));
+		start = (dst->pos - OFFSET(st_space[0])) / 16;
+		end = (end - OFFSET(st_space[0])) / 16;
+		for (; start < end; start++)
+			access_fpreg_ia32(start, buf + 16 * start, pt,
+						info->sw, tos, 0);
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf,
+				buf, OFFSET(st_space[0]), OFFSET(xmm_space[0]));
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+	if (dst->pos < OFFSET(padding[0]))
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf,
+				&info->sw->f16, OFFSET(xmm_space[0]),
+				OFFSET(padding[0]));
+}
+
+static void do_fpxregs_set(struct unw_frame_info *info, void *arg)
+{
+	struct regset_getset *dst = arg;
+	struct task_struct *task = dst->target;
+	char buf[128];
+	int start, end;
+
+	if (dst->count = 0 || unw_unwind_to_user(info) < 0)
+		return;
+
+	if (dst->pos < OFFSET(st_space[0])) {
+		start = dst->pos;
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf,
+				buf, 0, OFFSET(st_space[0]));
+		if (dst->ret)
+			return;
+		setfpxreg(task, start, dst->pos, buf);
+		if (dst->count = 0)
+			return;
+	}
+	if (dst->pos < OFFSET(xmm_space[0])) {
+		struct pt_regs *pt;
+		int tos;
+		pt = task_pt_regs(task);
+		tos = (task->thread.fsr >> 11) & 7;
+		start = (dst->pos - OFFSET(st_space[0])) / 16;
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf,
+				buf, OFFSET(st_space[0]), OFFSET(xmm_space[0]));
+		if (dst->ret)
+			return;
+		end = (dst->pos - OFFSET(st_space[0])) / 16;
+		for (; start < end; start++)
+			access_fpreg_ia32(start, buf + 16 * start, pt, info->sw,
+						 tos, 1);
+		if (dst->count = 0)
+			return;
+	}
+	if (dst->pos < OFFSET(padding[0]))
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf,
+				&info->sw->f16, OFFSET(xmm_space[0]),
+				 OFFSET(padding[0]));
+}
+#undef OFFSET
+
+static int do_regset_call(void (*call)(struct unw_frame_info *, void *),
+		struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		const void *kbuf, const void __user *ubuf)
+{
+	struct regset_getset info = { .target = target, .regset = regset,
+		.pos = pos, .count = count,
+		.u.set = { .kbuf = kbuf, .ubuf = ubuf },
+		.ret = 0 };
+
+	if (target = current)
+		unw_init_running(call, &info);
+	else {
+		struct unw_frame_info ufi;
+		memset(&ufi, 0, sizeof(ufi));
+		unw_init_from_blocked_task(&ufi, target);
+		(*call)(&ufi, &info);
+	}
+
+	return info.ret;
+}
+
+static int ia32_fpregs_get(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		void *kbuf, void __user *ubuf)
+{
+	return do_regset_call(do_fpregs_get, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static int ia32_fpregs_set(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		const void *kbuf, const void __user *ubuf)
+{
+	return do_regset_call(do_fpregs_set, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static int ia32_fpxregs_get(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		void *kbuf, void __user *ubuf)
+{
+	return do_regset_call(do_fpxregs_get, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static int ia32_fpxregs_set(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		const void *kbuf, const void __user *ubuf)
+{
+	return do_regset_call(do_fpxregs_set, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static int ia32_genregs_get(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		void *kbuf, void __user *ubuf)
+{
+	if (kbuf) {
+		u32 *kp = kbuf;
+		while (count > 0) {
+			*kp++ = getreg(target, pos);
+			pos += 4;
+			count -= 4;
+		}
+	} else {
+		u32 __user *up = ubuf;
+		while (count > 0) {
+			if (__put_user(getreg(target, pos), up++))
+				return -EFAULT;
+			pos += 4;
+			count -= 4;
+		}
+	}
+	return 0;
+}
+
+static int ia32_genregs_set(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		const void *kbuf, const void __user *ubuf)
+{
+	int ret = 0;
+
+	if (kbuf) {
+		const u32 *kp = kbuf;
+		while (!ret && count > 0) {
+			putreg(target, pos, *kp++);
+			pos += 4;
+			count -= 4;
+		}
+	} else {
+		const u32 __user *up = ubuf;
+		u32 val;
+		while (!ret && count > 0) {
+			ret = __get_user(val, up++);
+			if (!ret)
+				putreg(target, pos, val);
+			pos += 4;
+			count -= 4;
+		}
+	}
+	return ret;
+}
+
+/*
+ * This should match arch/i386/kernel/ptrace.c:native_regsets.
+ * XXX ioperm? vm86?
+ */
+static const struct user_regset ia32_regsets[] = {
+	{
+		.core_note_type = NT_PRSTATUS,
+		.n = sizeof(struct user_regs_struct32)/4,
+		.size = 4, .align = 4,
+		.get = ia32_genregs_get, .set = ia32_genregs_set
+	},
+	{
+		.core_note_type = NT_PRFPREG,
+		.n = sizeof(struct ia32_user_i387_struct) / 4,
+		.size = 4, .align = 4,
+		.get = ia32_fpregs_get, .set = ia32_fpregs_set
+	},
+	{
+		.core_note_type = NT_PRXFPREG,
+		.n = sizeof(struct ia32_user_fxsr_struct) / 4,
+		.size = 4, .align = 4,
+		.get = ia32_fpxregs_get, .set = ia32_fpxregs_set
+	},
+};
+
+const struct user_regset_view user_ia32_view = {
+	.name = "i386", .e_machine = EM_386,
+	.regsets = ia32_regsets, .n = ARRAY_SIZE(ia32_regsets)
+};
+
 typedef struct {
 	unsigned int	ss_sp;
 	unsigned int	ss_flags;
Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	2008-02-25 15:18:53.000000000 +0800
+++ linux/arch/ia64/kernel/ptrace.c	2008-02-25 15:44:22.000000000 +0800
@@ -3,6 +3,9 @@
  *
  * Copyright (C) 1999-2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2006 Intel Co
+ *  2006-08-12	- IA64 Native Utrace implementation support added by
+ *	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
  *
  * Derived from the x86 and Alpha versions.
  */
@@ -17,6 +20,8 @@
 #include <linux/security.h>
 #include <linux/audit.h>
 #include <linux/signal.h>
+#include <linux/regset.h>
+#include <linux/elf.h>
 
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -1626,3 +1631,699 @@ syscall_trace_leave (long arg0, long arg
 	if (test_thread_flag(TIF_RESTORE_RSE))
 		ia64_sync_krbs();
 }
+
+/* Utrace implementation starts here */
+struct regset_get {
+	void *kbuf;
+	void __user *ubuf;
+};
+
+struct regset_set {
+	const void *kbuf;
+	const void __user *ubuf;
+};
+
+struct regset_getset {
+	struct task_struct *target;
+	const struct user_regset *regset;
+	union {
+		struct regset_get get;
+		struct regset_set set;
+	} u;
+	unsigned int pos;
+	unsigned int count;
+	int ret;
+};
+
+static int
+access_elf_gpreg(struct task_struct *target, struct unw_frame_info *info,
+		unsigned long addr, unsigned long *data, int write_access)
+{
+	struct pt_regs *pt;
+	unsigned long *ptr = NULL;
+	int ret;
+	char nat = 0;
+
+	pt = task_pt_regs(target);
+	switch (addr) {
+	case ELF_GR_OFFSET(1):
+		ptr = &pt->r1;
+		break;
+	case ELF_GR_OFFSET(2):
+	case ELF_GR_OFFSET(3):
+		ptr = (void *)&pt->r2 + (addr - ELF_GR_OFFSET(2));
+		break;
+	case ELF_GR_OFFSET(4) ... ELF_GR_OFFSET(7):
+		if (write_access) {
+			/* read NaT bit first: */
+			unsigned long dummy;
+
+			ret = unw_get_gr(info, addr/8, &dummy, &nat);
+			if (ret < 0)
+				return ret;
+		}
+		return unw_access_gr(info, addr/8, data, &nat, write_access);
+	case ELF_GR_OFFSET(8) ... ELF_GR_OFFSET(11):
+		ptr = (void *)&pt->r8 + addr - ELF_GR_OFFSET(8);
+		break;
+	case ELF_GR_OFFSET(12):
+	case ELF_GR_OFFSET(13):
+		ptr = (void *)&pt->r12 + addr - ELF_GR_OFFSET(12);
+		break;
+	case ELF_GR_OFFSET(14):
+		ptr = &pt->r14;
+		break;
+	case ELF_GR_OFFSET(15):
+		ptr = &pt->r15;
+	}
+	if (write_access)
+		*ptr = *data;
+	else
+		*data = *ptr;
+	return 0;
+}
+
+static int
+access_elf_breg(struct task_struct *target, struct unw_frame_info *info,
+		unsigned long addr, unsigned long *data, int write_access)
+{
+	struct pt_regs *pt;
+	unsigned long *ptr = NULL;
+
+	pt = task_pt_regs(target);
+	switch (addr) {
+	case ELF_BR_OFFSET(0):
+		ptr = &pt->b0;
+		break;
+	case ELF_BR_OFFSET(1) ... ELF_BR_OFFSET(5):
+		return unw_access_br(info, (addr - ELF_BR_OFFSET(0))/8,
+				     data, write_access);
+	case ELF_BR_OFFSET(6):
+		ptr = &pt->b6;
+		break;
+	case ELF_BR_OFFSET(7):
+		ptr = &pt->b7;
+	}
+	if (write_access)
+		*ptr = *data;
+	else
+		*data = *ptr;
+	return 0;
+}
+
+static int
+access_elf_areg(struct task_struct *target, struct unw_frame_info *info,
+		unsigned long addr, unsigned long *data, int write_access)
+{
+	struct pt_regs *pt;
+	unsigned long cfm, urbs_end;
+	unsigned long *ptr = NULL;
+
+	pt = task_pt_regs(target);
+	if (addr >= ELF_AR_RSC_OFFSET && addr <= ELF_AR_SSD_OFFSET) {
+		switch (addr) {
+		case ELF_AR_RSC_OFFSET:
+			/* force PL3 */
+			if (write_access)
+				pt->ar_rsc = *data | (3 << 2);
+			else
+				*data = pt->ar_rsc;
+			return 0;
+		case ELF_AR_BSP_OFFSET:
+			/*
+			 * By convention, we use PT_AR_BSP to refer to
+			 * the end of the user-level backing store.
+			 * Use ia64_rse_skip_regs(PT_AR_BSP, -CFM.sof)
+			 * to get the real value of ar.bsp at the time
+			 * the kernel was entered.
+			 *
+			 * Furthermore, when changing the contents of
+			 * PT_AR_BSP (or PT_CFM) while the task is
+			 * blocked in a system call, convert the state
+			 * so that the non-system-call exit
+			 * path is used.  This ensures that the proper
+			 * state will be picked up when resuming
+			 * execution.  However, it *also* means that
+			 * once we write PT_AR_BSP/PT_CFM, it won't be
+			 * possible to modify the syscall arguments of
+			 * the pending system call any longer.  This
+			 * shouldn't be an issue because modifying
+			 * PT_AR_BSP/PT_CFM generally implies that
+			 * we're either abandoning the pending system
+			 * call or that we defer it's re-execution
+			 * (e.g., due to GDB doing an inferior
+			 * function call).
+			 */
+			urbs_end = ia64_get_user_rbs_end(target, pt, &cfm);
+			if (write_access) {
+				if (*data != urbs_end) {
+					if (in_syscall(pt))
+						convert_to_non_syscall(target,
+								       pt,
+								       cfm);
+					/*
+					 * Simulate user-level write
+					 * of ar.bsp:
+					 */
+					pt->loadrs = 0;
+					pt->ar_bspstore = *data;
+				}
+			} else
+				*data = urbs_end;
+			return 0;
+		case ELF_AR_BSPSTORE_OFFSET:
+			ptr = &pt->ar_bspstore;
+			break;
+		case ELF_AR_RNAT_OFFSET:
+			ptr = &pt->ar_rnat;
+			break;
+		case ELF_AR_CCV_OFFSET:
+			ptr = &pt->ar_ccv;
+			break;
+		case ELF_AR_UNAT_OFFSET:
+			ptr = &pt->ar_unat;
+			break;
+		case ELF_AR_FPSR_OFFSET:
+			ptr = &pt->ar_fpsr;
+			break;
+		case ELF_AR_PFS_OFFSET:
+			ptr = &pt->ar_pfs;
+			break;
+		case ELF_AR_LC_OFFSET:
+			return unw_access_ar(info, UNW_AR_LC, data,
+					     write_access);
+		case ELF_AR_EC_OFFSET:
+			return unw_access_ar(info, UNW_AR_EC, data,
+					     write_access);
+		case ELF_AR_CSD_OFFSET:
+			ptr = &pt->ar_csd;
+			break;
+		case ELF_AR_SSD_OFFSET:
+			ptr = &pt->ar_ssd;
+		}
+	} else if (addr >= ELF_CR_IIP_OFFSET && addr <= ELF_CR_IPSR_OFFSET) {
+		switch (addr) {
+		case ELF_CR_IIP_OFFSET:
+			ptr = &pt->cr_iip;
+			break;
+		case ELF_CFM_OFFSET:
+			urbs_end = ia64_get_user_rbs_end(target, pt, &cfm);
+			if (write_access) {
+				if (((cfm ^ *data) & PFM_MASK) != 0) {
+					if (in_syscall(pt))
+						convert_to_non_syscall(target,
+								       pt,
+								       cfm);
+					pt->cr_ifs = ((pt->cr_ifs & ~PFM_MASK)
+						      | (*data & PFM_MASK));
+				}
+			} else
+				*data = cfm;
+			return 0;
+		case ELF_CR_IPSR_OFFSET:
+			if (write_access) {
+				unsigned long tmp = *data;
+				/* psr.ri=3 is a reserved value: SDM 2:25 */
+				if ((tmp & IA64_PSR_RI) = IA64_PSR_RI)
+					tmp &= ~IA64_PSR_RI;
+				pt->cr_ipsr = ((tmp & IPSR_MASK)
+					       | (pt->cr_ipsr & ~IPSR_MASK));
+			} else
+				*data = (pt->cr_ipsr & IPSR_MASK);
+			return 0;
+		}
+	} else if (addr = ELF_NAT_OFFSET)
+		return access_nat_bits(target, pt, info,
+				       data, write_access);
+	else if (addr = ELF_PR_OFFSET)
+		ptr = &pt->pr;
+	else
+		return -1;
+
+	if (write_access)
+		*ptr = *data;
+	else
+		*data = *ptr;
+
+	return 0;
+}
+
+static int
+access_elf_reg(struct task_struct *target, struct unw_frame_info *info,
+		unsigned long addr, unsigned long *data, int write_access)
+{
+	if (addr >= ELF_GR_OFFSET(1) && addr <= ELF_GR_OFFSET(15))
+		return access_elf_gpreg(target, info, addr, data, write_access);
+	else if (addr >= ELF_BR_OFFSET(0) && addr <= ELF_BR_OFFSET(7))
+		return access_elf_breg(target, info, addr, data, write_access);
+	else
+		return access_elf_areg(target, info, addr, data, write_access);
+}
+
+void do_gpregs_get(struct unw_frame_info *info, void *arg)
+{
+	struct pt_regs *pt;
+	struct regset_getset *dst = arg;
+	elf_greg_t tmp[16];
+	unsigned int i, index, min_copy;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+
+	/*
+	 * coredump format:
+	 *      r0-r31
+	 *      NaT bits (for r0-r31; bit N = 1 iff rN is a NaT)
+	 *      predicate registers (p0-p63)
+	 *      b0-b7
+	 *      ip cfm user-mask
+	 *      ar.rsc ar.bsp ar.bspstore ar.rnat
+	 *      ar.ccv ar.unat ar.fpsr ar.pfs ar.lc ar.ec
+	 */
+
+
+	/* Skip r0 */
+	if (dst->count > 0 && dst->pos < ELF_GR_OFFSET(1)) {
+		dst->ret = user_regset_copyout_zero(&dst->pos, &dst->count,
+						      &dst->u.get.kbuf,
+						      &dst->u.get.ubuf,
+						      0, ELF_GR_OFFSET(1));
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+
+	/* gr1 - gr15 */
+	if (dst->count > 0 && dst->pos < ELF_GR_OFFSET(16)) {
+		index = (dst->pos - ELF_GR_OFFSET(1)) / sizeof(elf_greg_t);
+		min_copy = ELF_GR_OFFSET(16) > (dst->pos + dst->count) ?
+			 (dst->pos + dst->count) : ELF_GR_OFFSET(16);
+		for (i = dst->pos; i < min_copy; i += sizeof(elf_greg_t),
+				index++)
+			if (access_elf_reg(dst->target, info, i,
+						&tmp[index], 0) < 0) {
+				dst->ret = -EIO;
+				return;
+			}
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf, tmp,
+				ELF_GR_OFFSET(1), ELF_GR_OFFSET(16));
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+
+	/* r16-r31 */
+	if (dst->count > 0 && dst->pos < ELF_NAT_OFFSET) {
+		pt = task_pt_regs(dst->target);
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf, &pt->r16,
+				ELF_GR_OFFSET(16), ELF_NAT_OFFSET);
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+
+	/* nat, pr, b0 - b7 */
+	if (dst->count > 0 && dst->pos < ELF_CR_IIP_OFFSET) {
+		index = (dst->pos - ELF_NAT_OFFSET) / sizeof(elf_greg_t);
+		min_copy = ELF_CR_IIP_OFFSET > (dst->pos + dst->count) ?
+			 (dst->pos + dst->count) : ELF_CR_IIP_OFFSET;
+		for (i = dst->pos; i < min_copy; i += sizeof(elf_greg_t),
+				index++)
+			if (access_elf_reg(dst->target, info, i,
+						&tmp[index], 0) < 0) {
+				dst->ret = -EIO;
+				return;
+			}
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf, tmp,
+				ELF_NAT_OFFSET, ELF_CR_IIP_OFFSET);
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+
+	/* ip cfm psr ar.rsc ar.bsp ar.bspstore ar.rnat
+	 * ar.ccv ar.unat ar.fpsr ar.pfs ar.lc ar.ec ar.csd ar.ssd
+	 */
+	if (dst->count > 0 && dst->pos < (ELF_AR_END_OFFSET)) {
+		index = (dst->pos - ELF_CR_IIP_OFFSET) / sizeof(elf_greg_t);
+		min_copy = ELF_AR_END_OFFSET > (dst->pos + dst->count) ?
+			 (dst->pos + dst->count) : ELF_AR_END_OFFSET;
+		for (i = dst->pos; i < min_copy; i += sizeof(elf_greg_t),
+				index++)
+			if (access_elf_reg(dst->target, info, i,
+						&tmp[index], 0) < 0) {
+				dst->ret = -EIO;
+				return;
+			}
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf, tmp,
+				ELF_CR_IIP_OFFSET, ELF_AR_END_OFFSET);
+	}
+}
+
+void do_gpregs_set(struct unw_frame_info *info, void *arg)
+{
+	struct pt_regs *pt;
+	struct regset_getset *dst = arg;
+	elf_greg_t tmp[16];
+	unsigned int i, index;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+
+	/* Skip r0 */
+	if (dst->count > 0 && dst->pos < ELF_GR_OFFSET(1)) {
+		dst->ret = user_regset_copyin_ignore(&dst->pos, &dst->count,
+						       &dst->u.set.kbuf,
+						       &dst->u.set.ubuf,
+						       0, ELF_GR_OFFSET(1));
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+
+	/* gr1-gr15 */
+	if (dst->count > 0 && dst->pos < ELF_GR_OFFSET(16)) {
+		i = dst->pos;
+		index = (dst->pos - ELF_GR_OFFSET(1)) / sizeof(elf_greg_t);
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf, tmp,
+				ELF_GR_OFFSET(1), ELF_GR_OFFSET(16));
+		if (dst->ret)
+			return;
+		for ( ; i < dst->pos; i += sizeof(elf_greg_t), index++)
+			if (access_elf_reg(dst->target, info, i,
+						&tmp[index], 1) < 0) {
+				dst->ret = -EIO;
+				return;
+			}
+		if (dst->count = 0)
+			return;
+	}
+
+	/* gr16-gr31 */
+	if (dst->count > 0 && dst->pos < ELF_NAT_OFFSET) {
+		pt = task_pt_regs(dst->target);
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf, &pt->r16,
+				ELF_GR_OFFSET(16), ELF_NAT_OFFSET);
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+
+	/* nat, pr, b0 - b7 */
+	if (dst->count > 0 && dst->pos < ELF_CR_IIP_OFFSET) {
+		i = dst->pos;
+		index = (dst->pos - ELF_NAT_OFFSET) / sizeof(elf_greg_t);
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf, tmp,
+				ELF_NAT_OFFSET, ELF_CR_IIP_OFFSET);
+		if (dst->ret)
+			return;
+		for (; i < dst->pos; i += sizeof(elf_greg_t), index++)
+			if (access_elf_reg(dst->target, info, i,
+						&tmp[index], 1) < 0) {
+				dst->ret = -EIO;
+				return;
+			}
+		if (dst->count = 0)
+			return;
+	}
+
+	/* ip cfm psr ar.rsc ar.bsp ar.bspstore ar.rnat
+	 * ar.ccv ar.unat ar.fpsr ar.pfs ar.lc ar.ec ar.csd ar.ssd
+	 */
+	if (dst->count > 0 && dst->pos < (ELF_AR_END_OFFSET)) {
+		i = dst->pos;
+		index = (dst->pos - ELF_CR_IIP_OFFSET) / sizeof(elf_greg_t);
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf, tmp,
+				ELF_CR_IIP_OFFSET, ELF_AR_END_OFFSET);
+		if (dst->ret)
+			return;
+		for ( ; i < dst->pos; i += sizeof(elf_greg_t), index++)
+			if (access_elf_reg(dst->target, info, i,
+						&tmp[index], 1) < 0) {
+				dst->ret = -EIO;
+				return;
+			}
+	}
+}
+
+#define ELF_FP_OFFSET(i)	(i * sizeof(elf_fpreg_t))
+
+void do_fpregs_get(struct unw_frame_info *info, void *arg)
+{
+	struct regset_getset *dst = arg;
+	struct task_struct *task = dst->target;
+	elf_fpreg_t tmp[30];
+	int index, min_copy, i;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+
+	/* Skip pos 0 and 1 */
+	if (dst->count > 0 && dst->pos < ELF_FP_OFFSET(2)) {
+		dst->ret = user_regset_copyout_zero(&dst->pos, &dst->count,
+						      &dst->u.get.kbuf,
+						      &dst->u.get.ubuf,
+						      0, ELF_FP_OFFSET(2));
+		if (dst->count = 0 || dst->ret)
+			return;
+	}
+
+	/* fr2-fr31 */
+	if (dst->count > 0 && dst->pos < ELF_FP_OFFSET(32)) {
+		index = (dst->pos - ELF_FP_OFFSET(2)) / sizeof(elf_fpreg_t);
+
+		min_copy = min(((unsigned int)ELF_FP_OFFSET(32)),
+				dst->pos + dst->count);
+		for (i = dst->pos; i < min_copy; i += sizeof(elf_fpreg_t),
+				index++)
+			if (unw_get_fr(info, i / sizeof(elf_fpreg_t),
+					 &tmp[index])) {
+				dst->ret = -EIO;
+				return;
+			}
+		dst->ret = user_regset_copyout(&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf, tmp,
+				ELF_FP_OFFSET(2), ELF_FP_OFFSET(32));
+		if (dst->count = 0 || dst->ret)
+			return;
+	}
+
+	/* fph */
+	if (dst->count > 0) {
+		ia64_flush_fph(dst->target);
+		if (task->thread.flags & IA64_THREAD_FPH_VALID)
+			dst->ret = user_regset_copyout(
+				&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf,
+				&dst->target->thread.fph,
+				ELF_FP_OFFSET(32), -1);
+		else
+			/* Zero fill instead.  */
+			dst->ret = user_regset_copyout_zero(
+				&dst->pos, &dst->count,
+				&dst->u.get.kbuf, &dst->u.get.ubuf,
+				ELF_FP_OFFSET(32), -1);
+	}
+}
+
+void do_fpregs_set(struct unw_frame_info *info, void *arg)
+{
+	struct regset_getset *dst = arg;
+	elf_fpreg_t fpreg, tmp[30];
+	int index, start, end;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+
+	/* Skip pos 0 and 1 */
+	if (dst->count > 0 && dst->pos < ELF_FP_OFFSET(2)) {
+		dst->ret = user_regset_copyin_ignore(&dst->pos, &dst->count,
+						       &dst->u.set.kbuf,
+						       &dst->u.set.ubuf,
+						       0, ELF_FP_OFFSET(2));
+		if (dst->count = 0 || dst->ret)
+			return;
+	}
+
+	/* fr2-fr31 */
+	if (dst->count > 0 && dst->pos < ELF_FP_OFFSET(32)) {
+		start = dst->pos;
+		end = min(((unsigned int)ELF_FP_OFFSET(32)),
+			 dst->pos + dst->count);
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+				&dst->u.set.kbuf, &dst->u.set.ubuf, tmp,
+				ELF_FP_OFFSET(2), ELF_FP_OFFSET(32));
+		if (dst->ret)
+			return;
+
+		if (start & 0xF) { /* only write high part */
+			if (unw_get_fr(info, start / sizeof(elf_fpreg_t),
+					 &fpreg)) {
+				dst->ret = -EIO;
+				return;
+			}
+			tmp[start / sizeof(elf_fpreg_t) - 2].u.bits[0]
+				= fpreg.u.bits[0];
+			start &= ~0xFUL;
+		}
+		if (end & 0xF) { /* only write low part */
+			if (unw_get_fr(info, end / sizeof(elf_fpreg_t),
+					&fpreg)) {
+				dst->ret = -EIO;
+				return;
+			}
+			tmp[end / sizeof(elf_fpreg_t) - 2].u.bits[1]
+				= fpreg.u.bits[1];
+			end = (end + 0xF) & ~0xFUL;
+		}
+
+		for ( ;	start < end ; start += sizeof(elf_fpreg_t)) {
+			index = start / sizeof(elf_fpreg_t);
+			if (unw_set_fr(info, index, tmp[index - 2])) {
+				dst->ret = -EIO;
+				return;
+			}
+		}
+		if (dst->ret || dst->count = 0)
+			return;
+	}
+
+	/* fph */
+	if (dst->count > 0 && dst->pos < ELF_FP_OFFSET(128)) {
+		ia64_sync_fph(dst->target);
+		dst->ret = user_regset_copyin(&dst->pos, &dst->count,
+						&dst->u.set.kbuf,
+						&dst->u.set.ubuf,
+						&dst->target->thread.fph,
+						ELF_FP_OFFSET(32), -1);
+	}
+}
+
+static int
+do_regset_call(void (*call)(struct unw_frame_info *, void *),
+	       struct task_struct *target,
+	       const struct user_regset *regset,
+	       unsigned int pos, unsigned int count,
+	       const void *kbuf, const void __user *ubuf)
+{
+	struct regset_getset info = { .target = target, .regset = regset,
+				 .pos = pos, .count = count,
+				 .u.set = { .kbuf = kbuf, .ubuf = ubuf },
+				 .ret = 0 };
+
+	if (target = current)
+		unw_init_running(call, &info);
+	else {
+		struct unw_frame_info ufi;
+		memset(&ufi, 0, sizeof(ufi));
+		unw_init_from_blocked_task(&ufi, target);
+		(*call)(&ufi, &info);
+	}
+
+	return info.ret;
+}
+
+static int
+gpregs_get(struct task_struct *target,
+	   const struct user_regset *regset,
+	   unsigned int pos, unsigned int count,
+	   void *kbuf, void __user *ubuf)
+{
+	return do_regset_call(do_gpregs_get, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static int gpregs_set(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		const void *kbuf, const void __user *ubuf)
+{
+	return do_regset_call(do_gpregs_set, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static void do_gpregs_writeback(struct unw_frame_info *info, void *arg)
+{
+	struct pt_regs *pt;
+	struct regset_getset *dst = arg;
+	unsigned long urbs_end;
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+	pt = task_pt_regs(dst->target);
+	urbs_end = ia64_get_user_rbs_end(dst->target, pt, NULL);
+	dst->ret = ia64_sync_user_rbs(dst->target, info->sw, pt->ar_bspstore,
+				urbs_end);
+}
+
+/*
+ * This is called to write back the register backing store.
+ * ptrace does this before it stops, so that a tracer reading the user
+ * memory after the thread stops will get the current register data.
+ */
+static int
+gpregs_writeback(struct task_struct *target,
+		 const struct user_regset *regset,
+		 int now)
+{
+	return do_regset_call(do_gpregs_writeback, target, regset, 0, 0,
+		NULL, NULL);
+}
+
+static int
+fpregs_active(struct task_struct *target, const struct user_regset *regset)
+{
+	return (target->thread.flags & IA64_THREAD_FPH_VALID) ? 128 : 32;
+}
+
+static int fpregs_get(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		void *kbuf, void __user *ubuf)
+{
+	return do_regset_call(do_fpregs_get, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static int fpregs_set(struct task_struct *target,
+		const struct user_regset *regset,
+		unsigned int pos, unsigned int count,
+		const void *kbuf, const void __user *ubuf)
+{
+	return do_regset_call(do_fpregs_set, target, regset, pos, count,
+		kbuf, ubuf);
+}
+
+static const struct user_regset native_regsets[] = {
+	{
+		.core_note_type = NT_PRSTATUS,
+		.n = ELF_NGREG,
+		.size = sizeof(elf_greg_t), .align = sizeof(elf_greg_t),
+		.get = gpregs_get, .set = gpregs_set,
+		.writeback = gpregs_writeback
+	},
+	{
+		.core_note_type = NT_PRFPREG,
+		.n = ELF_NFPREG,
+		.size = sizeof(elf_fpreg_t), .align = sizeof(elf_fpreg_t),
+		.get = fpregs_get, .set = fpregs_set, .active = fpregs_active
+	},
+};
+
+static const struct user_regset_view user_ia64_view = {
+	.name = "ia64",
+	.e_machine = EM_IA_64,
+	.regsets = native_regsets, .n = ARRAY_SIZE(native_regsets)
+};
+
+const struct user_regset_view *task_user_regset_view(struct task_struct *tsk)
+{
+#ifdef CONFIG_IA32_SUPPORT
+	extern const struct user_regset_view user_ia32_view;
+	if (IS_IA32_PROCESS(task_pt_regs(tsk)))
+		return &user_ia32_view;
+#endif
+	return &user_ia64_view;
+}
Index: linux/include/asm-ia64/elf.h
=================================--- linux.orig/include/asm-ia64/elf.h	2008-02-25 15:18:53.000000000 +0800
+++ linux/include/asm-ia64/elf.h	2008-02-25 15:20:53.000000000 +0800
@@ -26,6 +26,7 @@
 #define ELF_ARCH	EM_IA_64
 
 #define USE_ELF_CORE_DUMP
+#define CORE_DUMP_USE_REGSET
 
 /* Least-significant four bits of ELF header's e_flags are OS-specific.  The bits are
    interpreted as follows by Linux: */
@@ -154,6 +155,30 @@ extern void ia64_init_addr_space (void);
 #define ELF_NGREG	128	/* we really need just 72 but let's leave some headroom... */
 #define ELF_NFPREG	128	/* f0 and f1 could be omitted, but so what... */
 
+/* elf_gregset_t register offsets */
+#define ELF_GR_0_OFFSET     0
+#define ELF_NAT_OFFSET     (32 * sizeof(elf_greg_t))
+#define ELF_PR_OFFSET      (33 * sizeof(elf_greg_t))
+#define ELF_BR_0_OFFSET    (34 * sizeof(elf_greg_t))
+#define ELF_CR_IIP_OFFSET  (42 * sizeof(elf_greg_t))
+#define ELF_CFM_OFFSET     (43 * sizeof(elf_greg_t))
+#define ELF_CR_IPSR_OFFSET (44 * sizeof(elf_greg_t))
+#define ELF_GR_OFFSET(i)   (ELF_GR_0_OFFSET + i * sizeof(elf_greg_t))
+#define ELF_BR_OFFSET(i)   (ELF_BR_0_OFFSET + i * sizeof(elf_greg_t))
+#define ELF_AR_RSC_OFFSET  (45 * sizeof(elf_greg_t))
+#define ELF_AR_BSP_OFFSET  (46 * sizeof(elf_greg_t))
+#define ELF_AR_BSPSTORE_OFFSET (47 * sizeof(elf_greg_t))
+#define ELF_AR_RNAT_OFFSET (48 * sizeof(elf_greg_t))
+#define ELF_AR_CCV_OFFSET  (49 * sizeof(elf_greg_t))
+#define ELF_AR_UNAT_OFFSET (50 * sizeof(elf_greg_t))
+#define ELF_AR_FPSR_OFFSET (51 * sizeof(elf_greg_t))
+#define ELF_AR_PFS_OFFSET  (52 * sizeof(elf_greg_t))
+#define ELF_AR_LC_OFFSET   (53 * sizeof(elf_greg_t))
+#define ELF_AR_EC_OFFSET   (54 * sizeof(elf_greg_t))
+#define ELF_AR_CSD_OFFSET  (55 * sizeof(elf_greg_t))
+#define ELF_AR_SSD_OFFSET  (56 * sizeof(elf_greg_t))
+#define ELF_AR_END_OFFSET  (57 * sizeof(elf_greg_t))
+
 typedef unsigned long elf_fpxregset_t;
 
 typedef unsigned long elf_greg_t;
@@ -183,12 +208,6 @@ extern void ia64_elf_core_copy_regs (str
 
 struct task_struct;
 
-extern int dump_task_regs(struct task_struct *, elf_gregset_t *);
-extern int dump_task_fpu (struct task_struct *, elf_fpregset_t *);
-
-#define ELF_CORE_COPY_TASK_REGS(tsk, elf_gregs) dump_task_regs(tsk, elf_gregs)
-#define ELF_CORE_COPY_FPREGS(tsk, elf_fpregs) dump_task_fpu(tsk, elf_fpregs)
-
 #define GATE_EHDR	((const struct elfhdr *) GATE_ADDR)
 
 /* update AT_VECTOR_SIZE_ARCH if the number of NEW_AUX_ENT entries changes */
Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2008-02-25 15:18:53.000000000 +0800
+++ linux/arch/ia64/kernel/process.c	2008-02-25 15:20:53.000000000 +0800
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


