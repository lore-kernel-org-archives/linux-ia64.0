From: Shaohua Li <shaohua.li@intel.com>
Date: Wed, 31 Dec 2008 09:11:25 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <1230714685.4132.4.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Tue, 2008-12-23 at 14:08 +0800, Shaohua Li wrote:
> IA64 dynamic ftrace support. The main tricky thing here is to support mod=
ule.
> In a module, each routine's mcount call will call a PLT stub, which
> will call kernel mcount. We can't simply make the mcount call call into
> kernel mcount, as kernel and mocule have different gp and the
> instruction just supports 25bit offset. So I introduced a new PLT stub,
> which will call into kernel ftrace_caller. When module loading, all
> mcount call will be converted to nop. When the nop is converted to call,
> we make the call to the new PLT stub instead of old mcount PLT stub.
This is the new implementation for dyn-ftrace. Previous 4 patches are
still required and can be applied to latest kernel too. Just replace the
5 patch with this one. This new patch should address Steven's concern.

IA64 dynamic ftrace support.
The original _mcount stub for each function is like:
	alloc r40=3Dar.pfs,12,8,0
	mov r43=3Dr0;;
	mov r42=B0
	mov r41=3Dr1
	nop.i 0x0
	br.call.sptk.many b0 =3D _mcount;;

The patch convert it to below for nop:
	[MII] nop.m 0x0
	mov r3=3Dip
	nop.i 0x0
	[MLX] nop.m 0x0
	nop.x 0x0;;
This isn't completely nop, as there is one instuction 'mov r3=3Dip', but
it should be light and harmless for code follow it.

And below is for call
	[MII] nop.m 0x0
	mov r3=3Dip
	nop.i 0x0
	[MLX] nop.m 0x0
	brl.many .;;
In this way, only one instruction is changed to convert code between nop
and call. This should meet dyn-ftrace's requirement.
But this requires CPU support brl instruction, so dyn-ftrace isn't
supported for old Itanium system. Assume there are quite few such old
system running.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/Kconfig              |    2=20
 arch/ia64/include/asm/ftrace.h |   13 ++
 arch/ia64/kernel/Makefile      |    5=20
 arch/ia64/kernel/entry.S       |   52 +++++++++
 arch/ia64/kernel/ftrace.c      |  235 ++++++++++++++++++++++++++++++++++++=
+++++
 scripts/recordmcount.pl        |    7 +
 6 files changed, 314 insertions(+)

Index: linux/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/Kconfig	2008-12-31 10:30:2=
6.000000000 +0800
+++ linux/arch/ia64/Kconfig	2008-12-31 16:55:05.000000000 +0800
@@ -21,6 +21,8 @@ config IA64
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
+	select HAVE_FTRACE_MCOUNT_RECORD
+	select HAVE_DYNAMIC_FTRACE if (!ITANIUM)
 	select HAVE_FUNCTION_TRACER
 	select HAVE_DMA_ATTRS
 	select HAVE_KVM
Index: linux/arch/ia64/kernel/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/Makefile	2008-12-31=
 10:30:26.000000000 +0800
+++ linux/arch/ia64/kernel/Makefile	2008-12-31 10:30:41.000000000 +0800
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
Index: linux/arch/ia64/kernel/ftrace.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/kernel/ftrace.c	2008-12-31 16:58:56.000000000 +0800
@@ -0,0 +1,235 @@
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
+struct ftrace_caller_code {
+	u64 dummy1:46;
+	u64 imm41_18:64-46;
+	u64 imm41_23:41-(64-46);
+	u64 dummy2:13;
+	u64 imm7b:7;
+	u64 dummy3:1;
+	u64 ic:1;
+	u64 imm5c:5;
+	u64 imm9d:9;
+	u64 i:1;
+	u64 dummy4:4;
+};
+
+/* in IA64, _mcount can't directly call ftrace_stub. Only jump is ok */
+int ftrace_update_ftrace_func(ftrace_func_t func)
+{
+	unsigned long ip;
+	unsigned long addr =3D ((struct fnptr *)ftrace_call)->ip;
+	struct ftrace_caller_code *code =3D  (void *)addr;
+
+	if (func =3D ftrace_stub)
+		return 0;
+	ip =3D ((struct fnptr *)func)->ip;
+
+	code->i =3D ip >> 63;
+	code->imm9d =3D ip >> 7;
+	code->imm5c =3D ip >> 16;
+	code->ic =3D ip >> 21;
+	code->imm7b =3D ip & 0x7f;
+	code->imm41_18 =3D ip >> 22;
+	code->imm41_23 =3D ip >> 40;
+
+	flush_icache_range(addr, addr + 16);
+	return 0;
+}
+
+extern void ftrace_patch_gp(void);
+
+/* run from kstop_machine */
+int __init ftrace_dyn_arch_init(void *data)
+{
+	unsigned long ip =3D ((struct fnptr *)ftrace_patch_gp)->ip;
+	unsigned long gp =3D ((struct fnptr *)ftrace_dyn_arch_init)->gp;
+
+	ia64_patch_imm64(ip + 2, gp);
+	flush_icache_range(ip, ip + 16);
+
+	*(unsigned long *)data =3D 0;
+
+	return 0;
+}
Index: linux/scripts/recordmcount.pl
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/scripts/recordmcount.pl	2008-12-31 1=
0:30:26.000000000 +0800
+++ linux/scripts/recordmcount.pl	2008-12-31 10:30:41.000000000 +0800
@@ -206,6 +206,13 @@ if ($arch eq "x86_64") {
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
Index: linux/arch/ia64/include/asm/ftrace.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/include/asm/ftrace.h	2008-=
12-31 10:30:26.000000000 +0800
+++ linux/arch/ia64/include/asm/ftrace.h	2008-12-31 10:30:41.000000000 +0800
@@ -8,6 +8,19 @@
 extern void _mcount(unsigned long pfs, unsigned long r1, unsigned long b0,=
 unsigned long r0);
 #define mcount _mcount
=20
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
 #endif
=20
 #endif /* CONFIG_FUNCTION_TRACER */
Index: linux/arch/ia64/kernel/entry.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/entry.S	2008-12-31 =
10:30:26.000000000 +0800
+++ linux/arch/ia64/kernel/entry.S	2008-12-31 15:26:21.000000000 +0800
@@ -1406,6 +1406,57 @@ GLOBAL_ENTRY(unw_init_running)
 END(unw_init_running)
=20
 #ifdef CONFIG_FUNCTION_TRACER
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
+.global ftrace_patch_gp;
+ftrace_patch_gp:
+	movl gp=3D0
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
 GLOBAL_ENTRY(_mcount)
 	movl r2 =3D ftrace_stub
 	movl r3 =3D ftrace_trace_function;;
@@ -1435,6 +1486,7 @@ GLOBAL_ENTRY(_mcount)
 	br ftrace_stub
 	;;
 END(_mcount)
+#endif
=20
 GLOBAL_ENTRY(ftrace_stub)
 	mov r3 =3D b0


