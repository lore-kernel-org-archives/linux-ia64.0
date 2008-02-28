From: Shaohua Li <shaohua.li@intel.com>
Date: Thu, 28 Feb 2008 08:09:33 +0000
Subject: [PATCH 2/4] IA64 regset: 32-bit support
Message-Id: <1204186173.11494.17.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is the 32-bit regset implementation under IA64. Basically register
read/write, which is derived from current ptrace register read/write.
This version added TLS support.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/ia32/sys_ia32.c |  649 ++++++++++++++++++++++++++++++++++++++++++++--
 arch/ia64/kernel/ptrace.c |    5 
 2 files changed, 629 insertions(+), 25 deletions(-)

Index: linux/arch/ia64/ia32/sys_ia32.c
=================================--- linux.orig/arch/ia64/ia32/sys_ia32.c	2008-02-28 07:19:34.000000000 +0800
+++ linux/arch/ia64/ia32/sys_ia32.c	2008-02-28 10:51:22.000000000 +0800
@@ -43,6 +43,7 @@
 #include <linux/eventpoll.h>
 #include <linux/personality.h>
 #include <linux/ptrace.h>
+#include <linux/regset.h>
 #include <linux/stat.h>
 #include <linux/ipc.h>
 #include <linux/capability.h>
@@ -2392,16 +2393,45 @@ get_free_idx (void)
 	return -ESRCH;
 }
 
+static void set_tls_desc(struct task_struct *p, int idx,
+		const struct ia32_user_desc *info, int n)
+{
+	struct thread_struct *t = &p->thread;
+	struct desc_struct *desc = &t->tls_array[idx - GDT_ENTRY_TLS_MIN];
+	int cpu;
+
+	/*
+	 * We must not get preempted while modifying the TLS.
+	 */
+	cpu = get_cpu();
+
+	while (n-- > 0) {
+		if (LDT_empty(info)) {
+			desc->a = 0;
+			desc->b = 0;
+		} else {
+			desc->a = LDT_entry_a(info);
+			desc->b = LDT_entry_b(info);
+		}
+
+		++info;
+		++desc;
+	}
+
+	if (t = &current->thread)
+		load_TLS(t, cpu);
+
+	put_cpu();
+}
+
 /*
  * Set a given TLS descriptor:
  */
 asmlinkage int
 sys32_set_thread_area (struct ia32_user_desc __user *u_info)
 {
-	struct thread_struct *t = &current->thread;
 	struct ia32_user_desc info;
-	struct desc_struct *desc;
-	int cpu, idx;
+	int idx;
 
 	if (copy_from_user(&info, u_info, sizeof(info)))
 		return -EFAULT;
@@ -2421,18 +2451,7 @@ sys32_set_thread_area (struct ia32_user_
 	if (idx < GDT_ENTRY_TLS_MIN || idx > GDT_ENTRY_TLS_MAX)
 		return -EINVAL;
 
-	desc = t->tls_array + idx - GDT_ENTRY_TLS_MIN;
-
-	cpu = smp_processor_id();
-
-	if (LDT_empty(&info)) {
-		desc->a = 0;
-		desc->b = 0;
-	} else {
-		desc->a = LDT_entry_a(&info);
-		desc->b = LDT_entry_b(&info);
-	}
-	load_TLS(t, cpu);
+	set_tls_desc(current, idx, &info, 1);
 	return 0;
 }
 
@@ -2456,6 +2475,20 @@ sys32_set_thread_area (struct ia32_user_
 #define GET_PRESENT(desc)	(((desc)->b >> 15) & 1)
 #define GET_USEABLE(desc)	(((desc)->b >> 20) & 1)
 
+static void fill_user_desc(struct ia32_user_desc *info, int idx,
+		const struct desc_struct *desc)
+{
+	info->entry_number = idx;
+	info->base_addr = GET_BASE(desc);
+	info->limit = GET_LIMIT(desc);
+	info->seg_32bit = GET_32BIT(desc);
+	info->contents = GET_CONTENTS(desc);
+	info->read_exec_only = !GET_WRITABLE(desc);
+	info->limit_in_pages = GET_LIMIT_PAGES(desc);
+	info->seg_not_present = !GET_PRESENT(desc);
+	info->useable = GET_USEABLE(desc);
+}
+
 asmlinkage int
 sys32_get_thread_area (struct ia32_user_desc __user *u_info)
 {
@@ -2469,22 +2502,588 @@ sys32_get_thread_area (struct ia32_user_
 		return -EINVAL;
 
 	desc = current->thread.tls_array + idx - GDT_ENTRY_TLS_MIN;
-
-	info.entry_number = idx;
-	info.base_addr = GET_BASE(desc);
-	info.limit = GET_LIMIT(desc);
-	info.seg_32bit = GET_32BIT(desc);
-	info.contents = GET_CONTENTS(desc);
-	info.read_exec_only = !GET_WRITABLE(desc);
-	info.limit_in_pages = GET_LIMIT_PAGES(desc);
-	info.seg_not_present = !GET_PRESENT(desc);
-	info.useable = GET_USEABLE(desc);
+	fill_user_desc(&info, idx, desc);
 
 	if (copy_to_user(u_info, &info, sizeof(info)))
 		return -EFAULT;
 	return 0;
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
+static int ia32_tls_active(struct task_struct *target,
+		const struct user_regset *regset)
+{
+	struct thread_struct *t = &target->thread;
+	int n = GDT_ENTRY_TLS_ENTRIES;
+	while (n > 0 && desc_empty(&t->tls_array[n -1]))
+		--n;
+	return n;
+}
+
+static int ia32_tls_get(struct task_struct *target,
+		const struct user_regset *regset, unsigned int pos,
+		unsigned int count, void *kbuf, void __user *ubuf)
+{
+	const struct desc_struct *tls;
+
+	if (pos > GDT_ENTRY_TLS_ENTRIES * sizeof(struct ia32_user_desc) ||
+			(pos % sizeof(struct ia32_user_desc)) != 0 ||
+			(count % sizeof(struct ia32_user_desc)) != 0)
+		return -EINVAL;
+
+	pos /= sizeof(struct ia32_user_desc);
+	count /= sizeof(struct ia32_user_desc);
+
+	tls = &target->thread.tls_array[pos];
+
+	if (kbuf) {
+		struct ia32_user_desc *info = kbuf;
+		while (count-- > 0)
+			fill_user_desc(info++, GDT_ENTRY_TLS_MIN + pos++,
+					tls++);
+	} else {
+		struct ia32_user_desc __user *u_info = ubuf;
+		while (count-- > 0) {
+			struct ia32_user_desc info;
+			fill_user_desc(&info, GDT_ENTRY_TLS_MIN + pos++, tls++);
+			if (__copy_to_user(u_info++, &info, sizeof(info)))
+				return -EFAULT;
+		}
+	}
+
+	return 0;
+}
+
+static int ia32_tls_set(struct task_struct *target,
+		const struct user_regset *regset, unsigned int pos,
+		unsigned int count, const void *kbuf, const void __user *ubuf)
+{
+	struct ia32_user_desc infobuf[GDT_ENTRY_TLS_ENTRIES];
+	const struct ia32_user_desc *info;
+
+	if (pos > GDT_ENTRY_TLS_ENTRIES * sizeof(struct ia32_user_desc) ||
+			(pos % sizeof(struct ia32_user_desc)) != 0 ||
+			(count % sizeof(struct ia32_user_desc)) != 0)
+		return -EINVAL;
+
+	if (kbuf)
+		info = kbuf;
+	else if (__copy_from_user(infobuf, ubuf, count))
+		return -EFAULT;
+	else
+		info = infobuf;
+
+	set_tls_desc(target,
+		GDT_ENTRY_TLS_MIN + (pos / sizeof(struct ia32_user_desc)),
+		info, count / sizeof(struct ia32_user_desc));
+
+	return 0;
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
+	{
+		.core_note_type = NT_386_TLS,
+		.n = GDT_ENTRY_TLS_ENTRIES,
+		.bias = GDT_ENTRY_TLS_MIN,
+		.size = sizeof(struct ia32_user_desc),
+		.align = sizeof(struct ia32_user_desc),
+		.active = ia32_tls_active,
+		.get = ia32_tls_get, .set = ia32_tls_set,
+	},
+};
+
+const struct user_regset_view user_ia32_view = {
+	.name = "i386", .e_machine = EM_386,
+	.regsets = ia32_regsets, .n = ARRAY_SIZE(ia32_regsets)
+};
+
 long sys32_fadvise64_64(int fd, __u32 offset_low, __u32 offset_high, 
 			__u32 len_low, __u32 len_high, int advice)
 { 
Index: linux/arch/ia64/kernel/ptrace.c
=================================--- linux.orig/arch/ia64/kernel/ptrace.c	2008-02-28 07:48:05.000000000 +0800
+++ linux/arch/ia64/kernel/ptrace.c	2008-02-28 10:53:48.000000000 +0800
@@ -2314,5 +2314,10 @@ static const struct user_regset_view use
 
 const struct user_regset_view *task_user_regset_view(struct task_struct *tsk)
 {
+#ifdef CONFIG_IA32_SUPPORT
+	extern const struct user_regset_view user_ia32_view;
+	if (IS_IA32_PROCESS(task_pt_regs(tsk)))
+		return &user_ia32_view;
+#endif
 	return &user_ia64_view;
 }


