From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 16:54:07 +0000
Subject: Re: [PATCH 0/9] ftrace: updates for tip
Message-Id: <alpine.DEB.1.10.0901131147310.9837@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org> <alpine.DEB.1.10.0901130905110.31098@gandalf.stny.rr.com>
In-Reply-To: <alpine.DEB.1.10.0901130905110.31098@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: LKML <linux-kernel@vger.kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de


On Tue, 13 Jan 2009, Steven Rostedt wrote:

>=20
>=20
> On Tue, 13 Jan 2009, Steven Rostedt wrote:
>=20
> >=20
> > The following patches are in:
> >=20
> >   git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace=
.git
> >=20
> >     branch: tip/devel
>=20
> Ingo,
>=20
> Don't pull any of this yet please. I'm going to rebase some of the patche=
s=20
> to fix the change logs (typos). I'll let you know when that's finished.
>=20

OK, I rebased in changing the change logs. Here's what I did:

s/destinct/distinct/
s/K?nig/Koenig/

Here's the changes:


The following patches are in:

  git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git

    branch: tip/devel


Frederic Weisbecker (2):
      tracing/ftrace: separate events tracing and stats tracing engine
      tracing: add a new workqueue tracer

Shaohua Li (6):
      ftrace, ia64: make recordmcount distinct module compile
      ftrace, ia64: explictly ignore a file in recordmcount.pl
      ftrace, ia64: Add macro for ftrace_caller
      ftrace, ia64: Add recordmcount for ia64
      ftrace, ia64: IA64 static ftrace support
      ftrace, ia64: IA64 dynamic ftrace support

Uwe Kleine-Koenig (1):
      ftrace, trivial: fix typo "resgister" -> "register"

----
 arch/ia64/Kconfig              |    3 +
 arch/ia64/include/asm/ftrace.h |   28 ++++
 arch/ia64/kernel/Makefile      |    5 +
 arch/ia64/kernel/entry.S       |  100 ++++++++++++++
 arch/ia64/kernel/ftrace.c      |  206 ++++++++++++++++++++++++++++
 arch/ia64/kernel/ia64_ksyms.c  |    6 +
 include/linux/ftrace.h         |    4 +
 include/trace/workqueue.h      |   25 ++++
 kernel/trace/Kconfig           |   11 ++
 kernel/trace/Makefile          |    1 +
 kernel/trace/ftrace.c          |   14 +--
 kernel/trace/trace.c           |    2 -
 kernel/trace/trace.h           |   20 ---
 kernel/trace/trace_branch.c    |  108 +++++++++-------
 kernel/trace/trace_stat.c      |  191 +++++++++++---------------
 kernel/trace/trace_stat.h      |   31 +++++
 kernel/trace/trace_workqueue.c |  287 ++++++++++++++++++++++++++++++++++++=
++++
 kernel/workqueue.c             |   16 ++-
 scripts/Makefile.build         |   13 +-
 scripts/recordmcount.pl        |   18 ++-
 20 files changed, 888 insertions(+), 201 deletions(-)
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 3d31636..e20c1d4 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -21,6 +21,9 @@ config IA64
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
+	select HAVE_FTRACE_MCOUNT_RECORD
+	select HAVE_DYNAMIC_FTRACE if (!ITANIUM)
+	select HAVE_FUNCTION_TRACER
 	select HAVE_DMA_ATTRS
 	select HAVE_KVM
 	select HAVE_ARCH_TRACEHOOK
diff --git a/arch/ia64/include/asm/ftrace.h b/arch/ia64/include/asm/ftrace.h
new file mode 100644
index 0000000..d20db3c
--- /dev/null
+++ b/arch/ia64/include/asm/ftrace.h
@@ -0,0 +1,28 @@
+#ifndef _ASM_IA64_FTRACE_H
+#define _ASM_IA64_FTRACE_H
+
+#ifdef CONFIG_FUNCTION_TRACER
+#define MCOUNT_INSN_SIZE        32 /* sizeof mcount call */
+
+#ifndef __ASSEMBLY__
+extern void _mcount(unsigned long pfs, unsigned long r1, unsigned long b0,=
 unsigned long r0);
+#define mcount _mcount
+
+#include <asm/kprobes.h>
+/* In IA64, MCOUNT_ADDR is set in link time, so it's not a constant at com=
pile time */
+#define MCOUNT_ADDR (((struct fnptr *)mcount)->ip)
+#define FTRACE_ADDR (((struct fnptr *)ftrace_caller)->ip)
+
+static inline unsigned long ftrace_call_adjust(unsigned long addr)
+{
+	/* second bundle, insn 2 */
+	return addr - 0x12;
+}
+
+struct dyn_arch_ftrace {
+};
+#endif
+
+#endif /* CONFIG_FUNCTION_TRACER */
+
+#endif /* _ASM_IA64_FTRACE_H */
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index f2778f2..dc62df0 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -2,6 +2,10 @@
 # Makefile for the linux kernel.
 #
=20
+ifdef CONFIG_DYNAMIC_FTRACE
+CFLAGS_REMOVE_ftrace.o =3D -pg
+endif
+
 extra-y	:=3D head.o init_task.o vmlinux.lds
=20
 obj-y :=3D acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o=
 irq.o irq_ia64.o	\
@@ -28,6 +32,7 @@ obj-$(CONFIG_IA64_CYCLONE)	+=3D cyclone.o
 obj-$(CONFIG_CPU_FREQ)		+=3D cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+=3D mca_recovery.o
 obj-$(CONFIG_KPROBES)		+=3D kprobes.o jprobes.o
+obj-$(CONFIG_DYNAMIC_FTRACE)	+=3D ftrace.o
 obj-$(CONFIG_KEXEC)		+=3D machine_kexec.o relocate_kernel.o crash.o
 obj-$(CONFIG_CRASH_DUMP)	+=3D crash_dump.o
 obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+=3D uncached.o
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index d435f4a..e0be92a 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -47,6 +47,7 @@
 #include <asm/processor.h>
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
+#include <asm/ftrace.h>
=20
 #include "minstate.h"
=20
@@ -1404,6 +1405,105 @@ GLOBAL_ENTRY(unw_init_running)
 	br.ret.sptk.many rp
 END(unw_init_running)
=20
+#ifdef CONFIG_FUNCTION_TRACER
+#ifdef CONFIG_DYNAMIC_FTRACE
+GLOBAL_ENTRY(_mcount)
+	br ftrace_stub
+END(_mcount)
+
+.here:
+	br.ret.sptk.many b0
+
+GLOBAL_ENTRY(ftrace_caller)
+	alloc out0 =3D ar.pfs, 8, 0, 4, 0
+	mov out3 =3D r0
+	;;
+	mov out2 =3D b0
+	add r3 =3D 0x20, r3
+	mov out1 =3D r1;
+	br.call.sptk.many b0 =3D ftrace_patch_gp
+	//this might be called from module, so we must patch gp
+ftrace_patch_gp:
+	movl gp=3D__gp
+	mov b0 =3D r3
+	;;
+.global ftrace_call;
+ftrace_call:
+{
+	.mlx
+	nop.m 0x0
+	movl r3 =3D .here;;
+}
+	alloc loc0 =3D ar.pfs, 4, 4, 2, 0
+	;;
+	mov loc1 =3D b0
+	mov out0 =3D b0
+	mov loc2 =3D r8
+	mov loc3 =3D r15
+	;;
+	adds out0 =3D -MCOUNT_INSN_SIZE, out0
+	mov out1 =3D in2
+	mov b6 =3D r3
+
+	br.call.sptk.many b0 =3D b6
+	;;
+	mov ar.pfs =3D loc0
+	mov b0 =3D loc1
+	mov r8 =3D loc2
+	mov r15 =3D loc3
+	br ftrace_stub
+	;;
+END(ftrace_caller)
+
+#else
+GLOBAL_ENTRY(_mcount)
+	movl r2 =3D ftrace_stub
+	movl r3 =3D ftrace_trace_function;;
+	ld8 r3 =3D [r3];;
+	ld8 r3 =3D [r3];;
+	cmp.eq p7,p0 =3D r2, r3
+(p7)	br.sptk.many ftrace_stub
+	;;
+
+	alloc loc0 =3D ar.pfs, 4, 4, 2, 0
+	;;
+	mov loc1 =3D b0
+	mov out0 =3D b0
+	mov loc2 =3D r8
+	mov loc3 =3D r15
+	;;
+	adds out0 =3D -MCOUNT_INSN_SIZE, out0
+	mov out1 =3D in2
+	mov b6 =3D r3
+
+	br.call.sptk.many b0 =3D b6
+	;;
+	mov ar.pfs =3D loc0
+	mov b0 =3D loc1
+	mov r8 =3D loc2
+	mov r15 =3D loc3
+	br ftrace_stub
+	;;
+END(_mcount)
+#endif
+
+GLOBAL_ENTRY(ftrace_stub)
+	mov r3 =3D b0
+	movl r2 =3D _mcount_ret_helper
+	;;
+	mov b6 =3D r2
+	mov b7 =3D r3
+	br.ret.sptk.many b6
+
+_mcount_ret_helper:
+	mov b0 =3D r42
+	mov r1 =3D r41
+	mov ar.pfs =3D r40
+	br b7
+END(ftrace_stub)
+
+#endif /* CONFIG_FUNCTION_TRACER */
+
 	.rodata
 	.align 8
 	.globl sys_call_table
diff --git a/arch/ia64/kernel/ftrace.c b/arch/ia64/kernel/ftrace.c
new file mode 100644
index 0000000..7fc8c96
--- /dev/null
+++ b/arch/ia64/kernel/ftrace.c
@@ -0,0 +1,206 @@
+/*
+ * Dynamic function tracing support.
+ *
+ * Copyright (C) 2008 Shaohua Li <shaohua.li@intel.com>
+ *
+ * For licencing details, see COPYING.
+ *
+ * Defines low-level handling of mcount calls when the kernel
+ * is compiled with the -pg flag. When using dynamic ftrace, the
+ * mcount call-sites get patched lazily with NOP till they are
+ * enabled. All code mutation routines here take effect atomically.
+ */
+
+#include <linux/uaccess.h>
+#include <linux/ftrace.h>
+
+#include <asm/cacheflush.h>
+#include <asm/patch.h>
+
+/* In IA64, each function will be added below two bundles with -pg option =
*/
+static unsigned char __attribute__((aligned(8)))
+ftrace_orig_code[MCOUNT_INSN_SIZE] =3D {
+	0x02, 0x40, 0x31, 0x10, 0x80, 0x05, /* alloc r40=3Dar.pfs,12,8,0 */
+	0xb0, 0x02, 0x00, 0x00, 0x42, 0x40, /* mov r43=3Dr0;; */
+	0x05, 0x00, 0xc4, 0x00,             /* mov r42=B0 */
+	0x11, 0x48, 0x01, 0x02, 0x00, 0x21, /* mov r41=3Dr1 */
+	0x00, 0x00, 0x00, 0x02, 0x00, 0x00, /* nop.i 0x0 */
+	0x08, 0x00, 0x00, 0x50              /* br.call.sptk.many b0 =3D _mcount;;=
 */
+};
+
+struct ftrace_orig_insn {
+	u64 dummy1, dummy2, dummy3;
+	u64 dummy4:64-41+13;
+	u64 imm20:20;
+	u64 dummy5:3;
+	u64 sign:1;
+	u64 dummy6:4;
+};
+
+/* mcount stub will be converted below for nop */
+static unsigned char ftrace_nop_code[MCOUNT_INSN_SIZE] =3D {
+	0x00, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MII] nop.m 0x0 */
+	0x30, 0x00, 0x00, 0x60, 0x00, 0x00, /* mov r3=3Dip */
+	0x00, 0x00, 0x04, 0x00,             /* nop.i 0x0 */
+	0x05, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0x0 */
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* nop.x 0x0;; */
+	0x00, 0x00, 0x04, 0x00
+};
+
+static unsigned char *ftrace_nop_replace(void)
+{
+	return ftrace_nop_code;
+}
+
+/*
+ * mcount stub will be converted below for call
+ * Note: Just the last instruction is changed against nop
+ * */
+static unsigned char __attribute__((aligned(8)))
+ftrace_call_code[MCOUNT_INSN_SIZE] =3D {
+	0x00, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MII] nop.m 0x0 */
+	0x30, 0x00, 0x00, 0x60, 0x00, 0x00, /* mov r3=3Dip */
+	0x00, 0x00, 0x04, 0x00,             /* nop.i 0x0 */
+	0x05, 0x00, 0x00, 0x00, 0x01, 0x00, /* [MLX] nop.m 0x0 */
+	0xff, 0xff, 0xff, 0xff, 0x7f, 0x00, /* brl.many .;;*/
+	0xf8, 0xff, 0xff, 0xc8
+};
+
+struct ftrace_call_insn {
+	u64 dummy1, dummy2;
+	u64 dummy3:48;
+	u64 imm39_l:16;
+	u64 imm39_h:23;
+	u64 dummy4:13;
+	u64 imm20:20;
+	u64 dummy5:3;
+	u64 i:1;
+	u64 dummy6:4;
+};
+
+static unsigned char *ftrace_call_replace(unsigned long ip, unsigned long =
addr)
+{
+	struct ftrace_call_insn *code =3D (void *)ftrace_call_code;
+	unsigned long offset =3D addr - (ip + 0x10);
+
+	code->imm39_l =3D offset >> 24;
+	code->imm39_h =3D offset >> 40;
+	code->imm20 =3D offset >> 4;
+	code->i =3D offset >> 63;
+	return ftrace_call_code;
+}
+
+static int
+ftrace_modify_code(unsigned long ip, unsigned char *old_code,
+		   unsigned char *new_code, int do_check)
+{
+	unsigned char replaced[MCOUNT_INSN_SIZE];
+
+	/*
+	 * Note: Due to modules and __init, code can
+	 *  disappear and change, we need to protect against faulting
+	 *  as well as code changing. We do this by using the
+	 *  probe_kernel_* functions.
+	 *
+	 * No real locking needed, this code is run through
+	 * kstop_machine, or before SMP starts.
+	 */
+
+	if (!do_check)
+		goto skip_check;
+
+	/* read the text we want to modify */
+	if (probe_kernel_read(replaced, (void *)ip, MCOUNT_INSN_SIZE))
+		return -EFAULT;
+
+	/* Make sure it is what we expect it to be */
+	if (memcmp(replaced, old_code, MCOUNT_INSN_SIZE) !=3D 0)
+		return -EINVAL;
+
+skip_check:
+	/* replace the text with the new text */
+	if (probe_kernel_write(((void *)ip), new_code, MCOUNT_INSN_SIZE))
+		return -EPERM;
+	flush_icache_range(ip, ip + MCOUNT_INSN_SIZE);
+
+	return 0;
+}
+
+static int ftrace_make_nop_check(struct dyn_ftrace *rec, unsigned long add=
r)
+{
+	unsigned char __attribute__((aligned(8))) replaced[MCOUNT_INSN_SIZE];
+	unsigned long ip =3D rec->ip;
+
+	if (probe_kernel_read(replaced, (void *)ip, MCOUNT_INSN_SIZE))
+		return -EFAULT;
+	if (rec->flags & FTRACE_FL_CONVERTED) {
+		struct ftrace_call_insn *call_insn, *tmp_call;
+
+		call_insn =3D (void *)ftrace_call_code;
+		tmp_call =3D (void *)replaced;
+		call_insn->imm39_l =3D tmp_call->imm39_l;
+		call_insn->imm39_h =3D tmp_call->imm39_h;
+		call_insn->imm20 =3D tmp_call->imm20;
+		call_insn->i =3D tmp_call->i;
+		if (memcmp(replaced, ftrace_call_code, MCOUNT_INSN_SIZE) !=3D 0)
+			return -EINVAL;
+		return 0;
+	} else {
+		struct ftrace_orig_insn *call_insn, *tmp_call;
+
+		call_insn =3D (void *)ftrace_orig_code;
+		tmp_call =3D (void *)replaced;
+		call_insn->sign =3D tmp_call->sign;
+		call_insn->imm20 =3D tmp_call->imm20;
+		if (memcmp(replaced, ftrace_orig_code, MCOUNT_INSN_SIZE) !=3D 0)
+			return -EINVAL;
+		return 0;
+	}
+}
+
+int ftrace_make_nop(struct module *mod,
+		    struct dyn_ftrace *rec, unsigned long addr)
+{
+	int ret;
+	char *new;
+
+	ret =3D ftrace_make_nop_check(rec, addr);
+	if (ret)
+		return ret;
+	new =3D ftrace_nop_replace();
+	return ftrace_modify_code(rec->ip, NULL, new, 0);
+}
+
+int ftrace_make_call(struct dyn_ftrace *rec, unsigned long addr)
+{
+	unsigned long ip =3D rec->ip;
+	unsigned char *old, *new;
+
+	old=3D  ftrace_nop_replace();
+	new =3D ftrace_call_replace(ip, addr);
+	return ftrace_modify_code(ip, old, new, 1);
+}
+
+/* in IA64, _mcount can't directly call ftrace_stub. Only jump is ok */
+int ftrace_update_ftrace_func(ftrace_func_t func)
+{
+	unsigned long ip;
+	unsigned long addr =3D ((struct fnptr *)ftrace_call)->ip;
+
+	if (func =3D ftrace_stub)
+		return 0;
+	ip =3D ((struct fnptr *)func)->ip;
+
+	ia64_patch_imm64(addr + 2, ip);
+
+	flush_icache_range(addr, addr + 16);
+	return 0;
+}
+
+/* run from kstop_machine */
+int __init ftrace_dyn_arch_init(void *data)
+{
+	*(unsigned long *)data =3D 0;
+
+	return 0;
+}
diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index 6da1f20..2d31186 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -112,3 +112,9 @@ EXPORT_SYMBOL_GPL(esi_call_phys);
 #endif
 extern char ia64_ivt[];
 EXPORT_SYMBOL(ia64_ivt);
+
+#include <asm/ftrace.h>
+#ifdef CONFIG_FUNCTION_TRACER
+/* mcount is defined in assembly */
+EXPORT_SYMBOL(_mcount);
+#endif
diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 677432b..0547214 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -126,6 +126,10 @@ extern int ftrace_update_ftrace_func(ftrace_func_t fun=
c);
 extern void ftrace_caller(void);
 extern void ftrace_call(void);
 extern void mcount_call(void);
+
+#ifndef FTRACE_ADDR
+#define FTRACE_ADDR ((unsigned long)ftrace_caller)
+#endif
 #ifdef CONFIG_FUNCTION_GRAPH_TRACER
 extern void ftrace_graph_caller(void);
 extern int ftrace_enable_ftrace_graph_caller(void);
diff --git a/include/trace/workqueue.h b/include/trace/workqueue.h
new file mode 100644
index 0000000..867829d
--- /dev/null
+++ b/include/trace/workqueue.h
@@ -0,0 +1,25 @@
+#ifndef __TRACE_WORKQUEUE_H
+#define __TRACE_WORKQUEUE_H
+
+#include <linux/tracepoint.h>
+#include <linux/workqueue.h>
+#include <linux/sched.h>
+
+DECLARE_TRACE(workqueue_insertion,
+	   TPPROTO(struct task_struct *wq_thread, struct work_struct *work),
+	   TPARGS(wq_thread, work));
+
+DECLARE_TRACE(workqueue_execution,
+	   TPPROTO(struct task_struct *wq_thread, struct work_struct *work),
+	   TPARGS(wq_thread, work));
+
+/* Trace the creation of one workqueue thread on a cpu */
+DECLARE_TRACE(workqueue_creation,
+	   TPPROTO(struct task_struct *wq_thread, int cpu),
+	   TPARGS(wq_thread, cpu));
+
+DECLARE_TRACE(workqueue_destruction,
+	   TPPROTO(struct task_struct *wq_thread),
+	   TPARGS(wq_thread));
+
+#endif /* __TRACE_WORKQUEUE_H */
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 9442392..dde1d46 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -284,6 +284,17 @@ config KMEMTRACE
=20
 	  If unsure, say N.
=20
+config WORKQUEUE_TRACER
+	bool "Trace workqueues"
+	select TRACING
+	help
+	  The workqueue tracer provides some statistical informations
+          about each cpu workqueue thread such as the number of the
+          works inserted and executed since their creation. It can help
+          to evaluate the amount of work each of them have to perform.
+          For example it can help a developer to decide whether he should
+          choose a per cpu workqueue instead of a singlethreaded one.
+
=20
 config DYNAMIC_FTRACE
 	bool "enable/disable ftrace tracepoints dynamically"
diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
index 05c9182..f76d48f 100644
--- a/kernel/trace/Makefile
+++ b/kernel/trace/Makefile
@@ -36,5 +36,6 @@ obj-$(CONFIG_TRACE_BRANCH_PROFILING) +=3D trace_branch.o
 obj-$(CONFIG_HW_BRANCH_TRACER) +=3D trace_hw_branches.o
 obj-$(CONFIG_POWER_TRACER) +=3D trace_power.o
 obj-$(CONFIG_KMEMTRACE) +=3D kmemtrace.o
+obj-$(CONFIG_WORKQUEUE_TRACER) +=3D trace_workqueue.o
=20
 libftrace-y :=3D ftrace.o
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 9e54a6c..8c1c9c0 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -263,14 +263,6 @@ static void ftrace_update_pid_func(void)
 # error Dynamic ftrace depends on MCOUNT_RECORD
 #endif
=20
-/*
- * Since MCOUNT_ADDR may point to mcount itself, we do not want
- * to get it confused by reading a reference in the code as we
- * are parsing on objcopy output of text. Use a variable for
- * it instead.
- */
-static unsigned long mcount_addr =3D MCOUNT_ADDR;
-
 enum {
 	FTRACE_ENABLE_CALLS		=3D (1 << 0),
 	FTRACE_DISABLE_CALLS		=3D (1 << 1),
@@ -463,7 +455,7 @@ __ftrace_replace_code(struct dyn_ftrace *rec, int enabl=
e)
 	unsigned long ip, fl;
 	unsigned long ftrace_addr;
=20
-	ftrace_addr =3D (unsigned long)ftrace_caller;
+	ftrace_addr =3D (unsigned long)FTRACE_ADDR;
=20
 	ip =3D rec->ip;
=20
@@ -575,7 +567,7 @@ ftrace_code_disable(struct module *mod, struct dyn_ftra=
ce *rec)
=20
 	ip =3D rec->ip;
=20
-	ret =3D ftrace_make_nop(mod, rec, mcount_addr);
+	ret =3D ftrace_make_nop(mod, rec, MCOUNT_ADDR);
 	if (ret) {
 		ftrace_bug(ret, ip);
 		rec->flags |=3D FTRACE_FL_FAILED;
@@ -1902,7 +1894,7 @@ int register_ftrace_function(struct ftrace_ops *ops)
 }
=20
 /**
- * unregister_ftrace_function - unresgister a function for profiling.
+ * unregister_ftrace_function - unregister a function for profiling.
  * @ops - ops structure that holds the function to unregister
  *
  * Unregister a function that was added to be called by ftrace profiling.
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 0418fc3..40217fb 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2353,7 +2353,6 @@ static int tracing_set_tracer(char *buf)
 		if (ret)
 			goto out;
 	}
-	init_tracer_stat(t);
=20
 	trace_branch_enable(tr);
  out:
@@ -3218,7 +3217,6 @@ __init static int tracer_alloc_buffers(void)
 #else
 	current_trace =3D &nop_trace;
 #endif
-	init_tracer_stat(current_trace);
 	/* All seems OK, enable tracing */
 	tracing_disabled =3D 0;
=20
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index b3f9ad1..79c8721 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -334,24 +334,6 @@ struct tracer_flags {
 /* Makes more easy to define a tracer opt */
 #define TRACER_OPT(s, b)	.name =3D #s, .bit =3D b
=20
-/*
- * If you want to provide a stat file (one-shot statistics), fill
- * an iterator with stat_start/stat_next and a stat_show callbacks.
- * The others callbacks are optional.
- */
-struct tracer_stat {
-	/* The name of your stat file */
-	const char		*name;
-	/* Iteration over statistic entries */
-	void			*(*stat_start)(void);
-	void			*(*stat_next)(void *prev, int idx);
-	/* Compare two entries for sorting (optional) for stats */
-	int			(*stat_cmp)(void *p1, void *p2);
-	/* Print a stat entry */
-	int			(*stat_show)(struct seq_file *s, void *p);
-	/* Print the headers of your stat entries */
-	int			(*stat_headers)(struct seq_file *s);
-};
=20
 /*
  * A specific tracer, represented by methods that operate on a trace array:
@@ -466,8 +448,6 @@ void tracing_start_sched_switch_record(void);
 int register_tracer(struct tracer *type);
 void unregister_tracer(struct tracer *type);
=20
-void init_tracer_stat(struct tracer *trace);
-
 extern unsigned long nsecs_to_usecs(unsigned long nsecs);
=20
 extern unsigned long tracing_max_latency;
diff --git a/kernel/trace/trace_branch.c b/kernel/trace/trace_branch.c
index da5cf3e..ca017e0 100644
--- a/kernel/trace/trace_branch.c
+++ b/kernel/trace/trace_branch.c
@@ -16,12 +16,12 @@
 #include <asm/local.h>
=20
 #include "trace.h"
+#include "trace_stat.h"
 #include "trace_output.h"
=20
-static struct tracer branch_trace;
-
 #ifdef CONFIG_BRANCH_TRACER
=20
+static struct tracer branch_trace;
 static int branch_tracing_enabled __read_mostly;
 static DEFINE_MUTEX(branch_tracing_mutex);
=20
@@ -191,6 +191,30 @@ static struct trace_event trace_branch_event =3D {
 	.binary		=3D trace_nop_print,
 };
=20
+static struct tracer branch_trace __read_mostly +{
+	.name		=3D "branch",
+	.init		=3D branch_trace_init,
+	.reset		=3D branch_trace_reset,
+#ifdef CONFIG_FTRACE_SELFTEST
+	.selftest	=3D trace_selftest_startup_branch,
+#endif /* CONFIG_FTRACE_SELFTEST */
+};
+
+__init static int init_branch_tracer(void)
+{
+	int ret;
+
+	ret =3D register_ftrace_event(&trace_branch_event);
+	if (!ret) {
+		printk(KERN_WARNING "Warning: could not register "
+				    "branch events\n");
+		return 1;
+	}
+	return register_tracer(&branch_trace);
+}
+device_initcall(init_branch_tracer);
+
 #else
 static inline
 void trace_likely_condition(struct ftrace_branch_data *f, int val, int exp=
ect)
@@ -305,6 +329,29 @@ static int annotated_branch_stat_cmp(void *p1, void *p=
2)
 		return 0;
 }
=20
+static struct tracer_stat annotated_branch_stats =3D {
+	.name =3D "branch_annotated",
+	.stat_start =3D annotated_branch_stat_start,
+	.stat_next =3D annotated_branch_stat_next,
+	.stat_cmp =3D annotated_branch_stat_cmp,
+	.stat_headers =3D annotated_branch_stat_headers,
+	.stat_show =3D branch_stat_show
+};
+
+__init static int init_annotated_branch_stats(void)
+{
+	int ret;
+
+	ret =3D register_stat_tracer(&annotated_branch_stats);
+	if (!ret) {
+		printk(KERN_WARNING "Warning: could not register "
+				    "annotated branches stats\n");
+		return 1;
+	}
+	return 0;
+}
+fs_initcall(init_annotated_branch_stats);
+
 #ifdef CONFIG_PROFILE_ALL_BRANCHES
=20
 extern unsigned long __start_branch_profile[];
@@ -339,60 +386,25 @@ all_branch_stat_next(void *v, int idx)
 	return p;
 }
=20
-static struct tracer_stat branch_stats[] =3D {
-	{.name =3D "annotated",
-	.stat_start =3D annotated_branch_stat_start,
-	.stat_next =3D annotated_branch_stat_next,
-	.stat_cmp =3D annotated_branch_stat_cmp,
-	.stat_headers =3D annotated_branch_stat_headers,
-	.stat_show =3D branch_stat_show},
-
-	{.name =3D "all",
+static struct tracer_stat all_branch_stats =3D {
+	.name =3D "branch_all",
 	.stat_start =3D all_branch_stat_start,
 	.stat_next =3D all_branch_stat_next,
 	.stat_headers =3D all_branch_stat_headers,
-	.stat_show =3D branch_stat_show},
-
-	{ }
-};
-#else
-static struct tracer_stat branch_stats[] =3D {
-	{.name =3D "annotated",
-	.stat_start =3D annotated_branch_stat_start,
-	.stat_next =3D annotated_branch_stat_next,
-	.stat_cmp =3D annotated_branch_stat_cmp,
-	.stat_headers =3D annotated_branch_stat_headers,
-	.stat_show =3D branch_stat_show},
-
-	{ }
+	.stat_show =3D branch_stat_show
 };
-#endif /* CONFIG_PROFILE_ALL_BRANCHES */
=20
-
-static struct tracer branch_trace __read_mostly +__init static int all_ann=
otated_branch_stats(void)
 {
-	.name		=3D "branch",
-#ifdef CONFIG_BRANCH_TRACER
-	.init		=3D branch_trace_init,
-	.reset		=3D branch_trace_reset,
-#ifdef CONFIG_FTRACE_SELFTEST
-	.selftest	=3D trace_selftest_startup_branch,
-#endif /* CONFIG_FTRACE_SELFTEST */
-#endif
-	.stats		=3D branch_stats
-};
-
-__init static int init_branch_trace(void)
-{
-#ifdef CONFIG_BRANCH_TRACER
 	int ret;
-	ret =3D register_ftrace_event(&trace_branch_event);
+
+	ret =3D register_stat_tracer(&all_branch_stats);
 	if (!ret) {
-		printk(KERN_WARNING "Warning: could not register branch events\n");
+		printk(KERN_WARNING "Warning: could not register "
+				    "all branches stats\n");
 		return 1;
 	}
-#endif
-
-	return register_tracer(&branch_trace);
+	return 0;
 }
-device_initcall(init_branch_trace);
+fs_initcall(all_annotated_branch_stats);
+#endif /* CONFIG_PROFILE_ALL_BRANCHES */
diff --git a/kernel/trace/trace_stat.c b/kernel/trace/trace_stat.c
index 1515f9e..cb29282 100644
--- a/kernel/trace/trace_stat.c
+++ b/kernel/trace/trace_stat.c
@@ -10,28 +10,32 @@
=20
=20
 #include <linux/list.h>
-#include <linux/seq_file.h>
 #include <linux/debugfs.h>
+#include "trace_stat.h"
 #include "trace.h"
=20
=20
 /* List of stat entries from a tracer */
 struct trace_stat_list {
-	struct list_head list;
-	void *stat;
+	struct list_head 	list;
+	void 			*stat;
 };
=20
 /* A stat session is the stats output in one file */
 struct tracer_stat_session {
-	struct tracer_stat *ts;
-	struct list_head stat_list;
-	struct mutex stat_mutex;
+	struct list_head	session_list;
+	struct tracer_stat 	*ts;
+	struct list_head 	stat_list;
+	struct mutex 		stat_mutex;
+	struct dentry		*file;
 };
=20
 /* All of the sessions currently in use. Each stat file embeed one session=
 */
-static struct tracer_stat_session **all_stat_sessions;
-static int nb_sessions;
-static struct dentry *stat_dir, **stat_files;
+static LIST_HEAD(all_stat_sessions);
+static DEFINE_MUTEX(all_stat_sessions_mutex);
+
+/* The root directory for all stat files */
+static struct dentry *stat_dir;
=20
=20
 static void reset_stat_session(struct tracer_stat_session *session)
@@ -44,66 +48,77 @@ static void reset_stat_session(struct tracer_stat_sessi=
on *session)
 	INIT_LIST_HEAD(&session->stat_list);
 }
=20
-/* Called when a tracer is initialized */
-static int init_all_sessions(int nb, struct tracer_stat *ts)
+static void destroy_session(struct tracer_stat_session *session)
 {
-	int i, j;
-	struct tracer_stat_session *session;
+	debugfs_remove(session->file);
+	reset_stat_session(session);
+	mutex_destroy(&session->stat_mutex);
+	kfree(session);
+}
=20
-	nb_sessions =3D 0;
=20
-	if (all_stat_sessions) {
-		for (i =3D 0; i < nb_sessions; i++) {
-			session =3D all_stat_sessions[i];
-			reset_stat_session(session);
-			mutex_destroy(&session->stat_mutex);
-			kfree(session);
-		}
-	}
-	all_stat_sessions =3D kmalloc(sizeof(struct tracer_stat_session *) * nb,
-				    GFP_KERNEL);
-	if (!all_stat_sessions)
-		return -ENOMEM;
+static int init_stat_file(struct tracer_stat_session *session);
=20
-	for (i =3D 0; i < nb; i++) {
-		session =3D kmalloc(sizeof(struct tracer_stat_session) * nb,
-				  GFP_KERNEL);
-		if (!session)
-			goto free_sessions;
+int register_stat_tracer(struct tracer_stat *trace)
+{
+	struct tracer_stat_session *session, *node, *tmp;
+	int ret;
+
+	if (!trace)
+		return -EINVAL;
+
+	if (!trace->stat_start || !trace->stat_next || !trace->stat_show)
+		return -EINVAL;
=20
-		INIT_LIST_HEAD(&session->stat_list);
-		mutex_init(&session->stat_mutex);
-		session->ts =3D &ts[i];
-		all_stat_sessions[i] =3D session;
+	/* Already registered? */
+	mutex_lock(&all_stat_sessions_mutex);
+	list_for_each_entry_safe(node, tmp, &all_stat_sessions, session_list) {
+		if (node->ts =3D trace)
+			return -EINVAL;
 	}
-	nb_sessions =3D nb;
-	return 0;
+	mutex_unlock(&all_stat_sessions_mutex);
+
+	/* Init the session */
+	session =3D kmalloc(sizeof(struct tracer_stat_session), GFP_KERNEL);
+	if (!session)
+		return -ENOMEM;
=20
-free_sessions:
+	session->ts =3D trace;
+	INIT_LIST_HEAD(&session->session_list);
+	INIT_LIST_HEAD(&session->stat_list);
+	mutex_init(&session->stat_mutex);
+	session->file =3D NULL;
=20
-	for (j =3D 0; j < i; j++)
-		kfree(all_stat_sessions[i]);
+	ret =3D init_stat_file(session);
+	if (ret) {
+		destroy_session(session);
+		return ret;
+	}
=20
-	kfree(all_stat_sessions);
-	all_stat_sessions =3D NULL;
+	/* Register */
+	mutex_lock(&all_stat_sessions_mutex);
+	list_add_tail(&session->session_list, &all_stat_sessions);
+	mutex_unlock(&all_stat_sessions_mutex);
=20
-	return -ENOMEM;
+	return 0;
 }
=20
-static int basic_tracer_stat_checks(struct tracer_stat *ts)
+void unregister_stat_tracer(struct tracer_stat *trace)
 {
-	int i;
+	struct tracer_stat_session *node, *tmp;
=20
-	if (!ts)
-		return 0;
-
-	for (i =3D 0; ts[i].name; i++) {
-		if (!ts[i].stat_start || !ts[i].stat_next || !ts[i].stat_show)
-			return -EBUSY;
+	mutex_lock(&all_stat_sessions_mutex);
+	list_for_each_entry_safe(node, tmp, &all_stat_sessions, session_list) {
+		if (node->ts =3D trace) {
+			list_del(&node->session_list);
+			destroy_session(node);
+			break;
+		}
 	}
-	return i;
+	mutex_unlock(&all_stat_sessions_mutex);
 }
=20
+
 /*
  * For tracers that don't provide a stat_cmp callback.
  * This one will force an immediate insertion on tail of
@@ -280,63 +295,7 @@ static const struct file_operations tracing_stat_fops =
=3D {
 	.release	=3D tracing_stat_release
 };
=20
-
-static void destroy_trace_stat_files(void)
-{
-	int i;
-
-	if (stat_files) {
-		for (i =3D 0; i < nb_sessions; i++)
-			debugfs_remove(stat_files[i]);
-		kfree(stat_files);
-		stat_files =3D NULL;
-	}
-}
-
-static void init_trace_stat_files(void)
-{
-	int i;
-
-	if (!stat_dir || !nb_sessions)
-		return;
-
-	stat_files =3D kmalloc(sizeof(struct dentry *) * nb_sessions, GFP_KERNEL);
-
-	if (!stat_files) {
-		pr_warning("trace stat: not enough memory\n");
-		return;
-	}
-
-	for (i =3D 0; i < nb_sessions; i++) {
-		struct tracer_stat_session *session =3D all_stat_sessions[i];
-		stat_files[i] =3D debugfs_create_file(session->ts->name, 0644,
-						stat_dir,
-						session, &tracing_stat_fops);
-		if (!stat_files[i])
-			pr_warning("cannot create %s entry\n",
-				   session->ts->name);
-	}
-}
-
-void init_tracer_stat(struct tracer *trace)
-{
-	int nb =3D basic_tracer_stat_checks(trace->stats);
-
-	destroy_trace_stat_files();
-
-	if (nb < 0) {
-		pr_warning("stat tracing: missing stat callback on %s\n",
-			   trace->name);
-		return;
-	}
-	if (!nb)
-		return;
-
-	init_all_sessions(nb, trace->stats);
-	init_trace_stat_files();
-}
-
-static int __init tracing_stat_init(void)
+static int tracing_stat_init(void)
 {
 	struct dentry *d_tracing;
=20
@@ -348,4 +307,16 @@ static int __init tracing_stat_init(void)
 			   "'trace_stat' entry\n");
 	return 0;
 }
-fs_initcall(tracing_stat_init);
+
+static int init_stat_file(struct tracer_stat_session *session)
+{
+	if (!stat_dir && tracing_stat_init())
+		return -ENODEV;
+
+	session->file =3D debugfs_create_file(session->ts->name, 0644,
+					    stat_dir,
+					    session, &tracing_stat_fops);
+	if (!session->file)
+		return -ENOMEM;
+	return 0;
+}
diff --git a/kernel/trace/trace_stat.h b/kernel/trace/trace_stat.h
new file mode 100644
index 0000000..202274c
--- /dev/null
+++ b/kernel/trace/trace_stat.h
@@ -0,0 +1,31 @@
+#ifndef __TRACE_STAT_H
+#define __TRACE_STAT_H
+
+#include <linux/seq_file.h>
+
+/*
+ * If you want to provide a stat file (one-shot statistics), fill
+ * an iterator with stat_start/stat_next and a stat_show callbacks.
+ * The others callbacks are optional.
+ */
+struct tracer_stat {
+	/* The name of your stat file */
+	const char		*name;
+	/* Iteration over statistic entries */
+	void			*(*stat_start)(void);
+	void			*(*stat_next)(void *prev, int idx);
+	/* Compare two entries for stats sorting */
+	int			(*stat_cmp)(void *p1, void *p2);
+	/* Print a stat entry */
+	int			(*stat_show)(struct seq_file *s, void *p);
+	/* Print the headers of your stat entries */
+	int			(*stat_headers)(struct seq_file *s);
+};
+
+/*
+ * Destroy or create a stat file
+ */
+extern int register_stat_tracer(struct tracer_stat *trace);
+extern void unregister_stat_tracer(struct tracer_stat *trace);
+
+#endif /* __TRACE_STAT_H */
diff --git a/kernel/trace/trace_workqueue.c b/kernel/trace/trace_workqueue.c
new file mode 100644
index 0000000..f8118d3
--- /dev/null
+++ b/kernel/trace/trace_workqueue.c
@@ -0,0 +1,287 @@
+/*
+ * Workqueue statistical tracer.
+ *
+ * Copyright (C) 2008 Frederic Weisbecker <fweisbec@gmail.com>
+ *
+ */
+
+
+#include <trace/workqueue.h>
+#include <linux/list.h>
+#include "trace_stat.h"
+#include "trace.h"
+
+
+/* A cpu workqueue thread */
+struct cpu_workqueue_stats {
+	struct list_head            list;
+/* Useful to know if we print the cpu headers */
+	bool		            first_entry;
+	int		            cpu;
+	pid_t 			    pid;
+/* Can be inserted from interrupt or user context, need to be atomic */
+	atomic_t 	            inserted;
+/*
+ *  Don't need to be atomic, works are serialized in a single workqueue th=
read
+ *  on a single CPU.
+ */
+	unsigned int 	 	    executed;
+};
+
+/* List of workqueue threads on one cpu */
+struct workqueue_global_stats {
+	struct list_head	list;
+	spinlock_t		lock;
+};
+
+/* Don't need a global lock because allocated before the workqueues, and
+ * never freed.
+ */
+static struct workqueue_global_stats *all_workqueue_stat;
+
+/* Insertion of a work */
+static void
+probe_workqueue_insertion(struct task_struct *wq_thread,
+			  struct work_struct *work)
+{
+	int cpu =3D cpumask_first(&wq_thread->cpus_allowed);
+	struct cpu_workqueue_stats *node, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	list_for_each_entry_safe(node, next, &all_workqueue_stat[cpu].list,
+							list) {
+		if (node->pid =3D wq_thread->pid) {
+			atomic_inc(&node->inserted);
+			goto found;
+		}
+	}
+	pr_debug("trace_workqueue: entry not found\n");
+found:
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+}
+
+/* Execution of a work */
+static void
+probe_workqueue_execution(struct task_struct *wq_thread,
+			  struct work_struct *work)
+{
+	int cpu =3D cpumask_first(&wq_thread->cpus_allowed);
+	struct cpu_workqueue_stats *node, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	list_for_each_entry_safe(node, next, &all_workqueue_stat[cpu].list,
+							list) {
+		if (node->pid =3D wq_thread->pid) {
+			node->executed++;
+			goto found;
+		}
+	}
+	pr_debug("trace_workqueue: entry not found\n");
+found:
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+}
+
+/* Creation of a cpu workqueue thread */
+static void probe_workqueue_creation(struct task_struct *wq_thread, int cp=
u)
+{
+	struct cpu_workqueue_stats *cws;
+	unsigned long flags;
+
+	WARN_ON(cpu < 0 || cpu >=3D num_possible_cpus());
+
+	/* Workqueues are sometimes created in atomic context */
+	cws =3D kzalloc(sizeof(struct cpu_workqueue_stats), GFP_ATOMIC);
+	if (!cws) {
+		pr_warning("trace_workqueue: not enough memory\n");
+		return;
+	}
+	tracing_record_cmdline(wq_thread);
+
+	INIT_LIST_HEAD(&cws->list);
+	cws->cpu =3D cpu;
+
+	cws->pid =3D wq_thread->pid;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	if (list_empty(&all_workqueue_stat[cpu].list))
+		cws->first_entry =3D true;
+	list_add_tail(&cws->list, &all_workqueue_stat[cpu].list);
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+}
+
+/* Destruction of a cpu workqueue thread */
+static void probe_workqueue_destruction(struct task_struct *wq_thread)
+{
+	/* Workqueue only execute on one cpu */
+	int cpu =3D cpumask_first(&wq_thread->cpus_allowed);
+	struct cpu_workqueue_stats *node, *next;
+	unsigned long flags;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	list_for_each_entry_safe(node, next, &all_workqueue_stat[cpu].list,
+							list) {
+		if (node->pid =3D wq_thread->pid) {
+			list_del(&node->list);
+			kfree(node);
+			goto found;
+		}
+	}
+
+	pr_debug("trace_workqueue: don't find workqueue to destroy\n");
+found:
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+}
+
+static struct cpu_workqueue_stats *workqueue_stat_start_cpu(int cpu)
+{
+	unsigned long flags;
+	struct cpu_workqueue_stats *ret =3D NULL;
+
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+
+	if (!list_empty(&all_workqueue_stat[cpu].list))
+		ret =3D list_entry(all_workqueue_stat[cpu].list.next,
+				 struct cpu_workqueue_stats, list);
+
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+	return ret;
+}
+
+static void *workqueue_stat_start(void)
+{
+	int cpu;
+	void *ret =3D NULL;
+
+	for_each_possible_cpu(cpu) {
+		ret =3D workqueue_stat_start_cpu(cpu);
+		if (ret)
+			return ret;
+	}
+	return NULL;
+}
+
+static void *workqueue_stat_next(void *prev, int idx)
+{
+	struct cpu_workqueue_stats *prev_cws =3D prev;
+	int cpu =3D prev_cws->cpu;
+	unsigned long flags;
+	void *ret =3D NULL;
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	if (list_is_last(&prev_cws->list, &all_workqueue_stat[cpu].list)) {
+		spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+		for (++cpu ; cpu < num_possible_cpus(); cpu++) {
+			ret =3D workqueue_stat_start_cpu(cpu);
+			if (ret)
+				return ret;
+		}
+		return NULL;
+	}
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+	return list_entry(prev_cws->list.next, struct cpu_workqueue_stats,
+			  list);
+}
+
+static int workqueue_stat_show(struct seq_file *s, void *p)
+{
+	struct cpu_workqueue_stats *cws =3D p;
+	unsigned long flags;
+	int cpu =3D cws->cpu;
+
+	seq_printf(s, "%3d %6d     %6u       %s\n", cws->cpu,
+		   atomic_read(&cws->inserted),
+		   cws->executed,
+		   trace_find_cmdline(cws->pid));
+
+	spin_lock_irqsave(&all_workqueue_stat[cpu].lock, flags);
+	if (&cws->list =3D all_workqueue_stat[cpu].list.next)
+		seq_printf(s, "\n");
+	spin_unlock_irqrestore(&all_workqueue_stat[cpu].lock, flags);
+
+	return 0;
+}
+
+static int workqueue_stat_headers(struct seq_file *s)
+{
+	seq_printf(s, "# CPU  INSERTED  EXECUTED   NAME\n");
+	seq_printf(s, "# |      |         |          |\n\n");
+	return 0;
+}
+
+struct tracer_stat workqueue_stats __read_mostly =3D {
+	.name =3D "workqueues",
+	.stat_start =3D workqueue_stat_start,
+	.stat_next =3D workqueue_stat_next,
+	.stat_show =3D workqueue_stat_show,
+	.stat_headers =3D workqueue_stat_headers
+};
+
+
+int __init stat_workqueue_init(void)
+{
+	if (register_stat_tracer(&workqueue_stats)) {
+		pr_warning("Unable to register workqueue stat tracer\n");
+		return 1;
+	}
+
+	return 0;
+}
+fs_initcall(stat_workqueue_init);
+
+/*
+ * Workqueues are created very early, just after pre-smp initcalls.
+ * So we must register our tracepoints at this stage.
+ */
+int __init trace_workqueue_early_init(void)
+{
+	int ret, cpu;
+
+	ret =3D register_trace_workqueue_insertion(probe_workqueue_insertion);
+	if (ret)
+		goto out;
+
+	ret =3D register_trace_workqueue_execution(probe_workqueue_execution);
+	if (ret)
+		goto no_insertion;
+
+	ret =3D register_trace_workqueue_creation(probe_workqueue_creation);
+	if (ret)
+		goto no_execution;
+
+	ret =3D register_trace_workqueue_destruction(probe_workqueue_destruction);
+	if (ret)
+		goto no_creation;
+
+	all_workqueue_stat =3D kmalloc(sizeof(struct workqueue_global_stats)
+				     * num_possible_cpus(), GFP_KERNEL);
+
+	if (!all_workqueue_stat) {
+		pr_warning("trace_workqueue: not enough memory\n");
+		goto no_creation;
+	}
+
+	for_each_possible_cpu(cpu) {
+		spin_lock_init(&all_workqueue_stat[cpu].lock);
+		INIT_LIST_HEAD(&all_workqueue_stat[cpu].list);
+	}
+
+	return 0;
+
+no_creation:
+	unregister_trace_workqueue_creation(probe_workqueue_creation);
+no_execution:
+	unregister_trace_workqueue_execution(probe_workqueue_execution);
+no_insertion:
+	unregister_trace_workqueue_insertion(probe_workqueue_insertion);
+out:
+	pr_warning("trace_workqueue: unable to trace workqueues\n");
+
+	return 1;
+}
+early_initcall(trace_workqueue_early_init);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 2f44583..1fc2bc2 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -33,6 +33,7 @@
 #include <linux/kallsyms.h>
 #include <linux/debug_locks.h>
 #include <linux/lockdep.h>
+#include <trace/workqueue.h>
=20
 /*
  * The per-CPU workqueue (if single thread, we always use the first
@@ -125,9 +126,13 @@ struct cpu_workqueue_struct *get_wq_data(struct work_s=
truct *work)
 	return (void *) (atomic_long_read(&work->data) & WORK_STRUCT_WQ_DATA_MASK=
);
 }
=20
+DEFINE_TRACE(workqueue_insertion);
+
 static void insert_work(struct cpu_workqueue_struct *cwq,
 			struct work_struct *work, struct list_head *head)
 {
+	trace_workqueue_insertion(cwq->thread, work);
+
 	set_wq_data(work, cwq);
 	/*
 	 * Ensure that we get the right work->data if we see the
@@ -259,6 +264,8 @@ int queue_delayed_work_on(int cpu, struct workqueue_str=
uct *wq,
 }
 EXPORT_SYMBOL_GPL(queue_delayed_work_on);
=20
+DEFINE_TRACE(workqueue_execution);
+
 static void run_workqueue(struct cpu_workqueue_struct *cwq)
 {
 	spin_lock_irq(&cwq->lock);
@@ -284,7 +291,7 @@ static void run_workqueue(struct cpu_workqueue_struct *=
cwq)
 		 */
 		struct lockdep_map lockdep_map =3D work->lockdep_map;
 #endif
-
+		trace_workqueue_execution(cwq->thread, work);
 		cwq->current_work =3D work;
 		list_del_init(cwq->worklist.next);
 		spin_unlock_irq(&cwq->lock);
@@ -765,6 +772,8 @@ init_cpu_workqueue(struct workqueue_struct *wq, int cpu)
 	return cwq;
 }
=20
+DEFINE_TRACE(workqueue_creation);
+
 static int create_workqueue_thread(struct cpu_workqueue_struct *cwq, int c=
pu)
 {
 	struct sched_param param =3D { .sched_priority =3D MAX_RT_PRIO-1 };
@@ -787,6 +796,8 @@ static int create_workqueue_thread(struct cpu_workqueue=
_struct *cwq, int cpu)
 		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
 	cwq->thread =3D p;
=20
+	trace_workqueue_creation(cwq->thread, cpu);
+
 	return 0;
 }
=20
@@ -868,6 +879,8 @@ struct workqueue_struct *__create_workqueue_key(const c=
har *name,
 }
 EXPORT_SYMBOL_GPL(__create_workqueue_key);
=20
+DEFINE_TRACE(workqueue_destruction);
+
 static void cleanup_workqueue_thread(struct cpu_workqueue_struct *cwq)
 {
 	/*
@@ -891,6 +904,7 @@ static void cleanup_workqueue_thread(struct cpu_workque=
ue_struct *cwq)
 	 * checks list_empty(), and a "normal" queue_work() can't use
 	 * a dead CPU.
 	 */
+	trace_workqueue_destruction(cwq->thread);
 	kthread_stop(cwq->thread);
 	cwq->thread =3D NULL;
 }
diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 5d90030..b5efa98 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -112,13 +112,13 @@ endif
 # ------------------------------------------------------------------------=
---
=20
 # Default is built-in, unless we know otherwise
-modkern_cflags :=3D $(CFLAGS_KERNEL)
+modkern_cflags =3D $(if $(part-of-module), $(CFLAGS_MODULE), $(CFLAGS_KERN=
EL))
 quiet_modtag :=3D $(empty)   $(empty)
=20
-$(real-objs-m)        : modkern_cflags :=3D $(CFLAGS_MODULE)
-$(real-objs-m:.o=3D.i)  : modkern_cflags :=3D $(CFLAGS_MODULE)
-$(real-objs-m:.o=3D.s)  : modkern_cflags :=3D $(CFLAGS_MODULE)
-$(real-objs-m:.o=3D.lst): modkern_cflags :=3D $(CFLAGS_MODULE)
+$(real-objs-m)        : part-of-module :=3D y
+$(real-objs-m:.o=3D.i)  : part-of-module :=3D y
+$(real-objs-m:.o=3D.s)  : part-of-module :=3D y
+$(real-objs-m:.o=3D.lst): part-of-module :=3D y
=20
 $(real-objs-m)        : quiet_modtag :=3D [M]
 $(real-objs-m:.o=3D.i)  : quiet_modtag :=3D [M]
@@ -215,7 +215,8 @@ endif
 ifdef CONFIG_FTRACE_MCOUNT_RECORD
 cmd_record_mcount =3D perl $(srctree)/scripts/recordmcount.pl "$(ARCH)" \
 	"$(if $(CONFIG_64BIT),64,32)" \
-	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" "$(@)";
+	"$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" "$(NM)" "$(RM)" "$(MV)" \
+	"$(if $(part-of-module),1,0)" "$(@)";
 endif
=20
 define rule_cc_o_c
diff --git a/scripts/recordmcount.pl b/scripts/recordmcount.pl
index fe83141..2ded5c8 100755
--- a/scripts/recordmcount.pl
+++ b/scripts/recordmcount.pl
@@ -100,14 +100,19 @@ $P =3D~ s@.*/@@g;
=20
 my $V =3D '0.1';
=20
-if ($#ARGV < 6) {
-	print "usage: $P arch objdump objcopy cc ld nm rm mv inputfile\n";
+if ($#ARGV < 7) {
+	print "usage: $P arch objdump objcopy cc ld nm rm mv is_module inputfile\=
n";
 	print "version: $V\n";
 	exit(1);
 }
=20
 my ($arch, $bits, $objdump, $objcopy, $cc,
-    $ld, $nm, $rm, $mv, $inputfile) =3D @ARGV;
+    $ld, $nm, $rm, $mv, $is_module, $inputfile) =3D @ARGV;
+
+# This file refers to mcount and shouldn't be ftraced, so lets' ignore it
+if ($inputfile eq "kernel/trace/ftrace.o") {
+    exit(0);
+}
=20
 # Acceptable sections to record.
 my %text_sections =3D (
@@ -201,6 +206,13 @@ if ($arch eq "x86_64") {
     $alignment =3D 2;
     $section_type =3D '%progbits';
=20
+} elsif ($arch eq "ia64") {
+    $mcount_regex =3D "^\\s*([0-9a-fA-F]+):.*\\s_mcount\$";
+    $type =3D "data8";
+
+    if ($is_module eq "0") {
+        $cc .=3D " -mconstant-gp";
+    }
 } else {
     die "Arch $arch is not supported with CONFIG_FTRACE_MCOUNT_RECORD";
 }
