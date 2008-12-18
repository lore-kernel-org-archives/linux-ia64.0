From: Shaohua Li <shaohua.li@intel.com>
Date: Thu, 18 Dec 2008 03:17:21 +0000
Subject: [RFC 2/2] dyn ftrace porting of IA64
Message-Id: <1229570241.28616.32.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This is the IA64 port of dyn ftrace. In IA64, there are some issues we
must solve.
1. kernel compile has different option against module compile, so I
extend the Makefile.build/recordmcount.pl script to distinct the two
cases.
2. in a module, each routine's mcount call will call a PLT stub, which
will call kernel mcount. We can't simply make the mcount call call into
kernel mcount, as kernel and mocule have different gp and the
instruction just supports 25bit offset. So I introduced a new PLT stub,
which will call into kernel ftrace_caller. When module loading, all
mcount call will be converted to nop. When the nop is converted to call,
we make the call to the new PLT stub instead of old mcount PLT stub.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/Kconfig              |    2=20
 arch/ia64/include/asm/ftrace.h |   12 ++
 arch/ia64/include/asm/module.h |    4=20
 arch/ia64/kernel/Makefile      |    5 +
 arch/ia64/kernel/entry.S       |   37 +++++++++
 arch/ia64/kernel/ftrace.c      |  165 ++++++++++++++++++++++++++++++++++++=
+++++
 arch/ia64/kernel/module.c      |   15 +++
 kernel/trace/ftrace.c          |   12 --
 scripts/Makefile.build         |    8 +
 scripts/recordmcount.pl        |   20 ++++
 10 files changed, 267 insertions(+), 13 deletions(-)

Index: linux/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/Kconfig	2008-12-17 17:14:4=
9.000000000 +0800
+++ linux/arch/ia64/Kconfig	2008-12-17 17:15:10.000000000 +0800
@@ -21,6 +21,8 @@ config IA64
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
+	select HAVE_FTRACE_MCOUNT_RECORD
+	select HAVE_DYNAMIC_FTRACE
 	select HAVE_FUNCTION_TRACER
 	select HAVE_DMA_ATTRS
 	select HAVE_KVM
Index: linux/arch/ia64/kernel/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/Makefile	2008-12-17=
 17:14:49.000000000 +0800
+++ linux/arch/ia64/kernel/Makefile	2008-12-17 17:15:10.000000000 +0800
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
+++ linux/arch/ia64/kernel/ftrace.c	2008-12-18 10:46:50.000000000 +0800
@@ -0,0 +1,165 @@
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
+#include <asm/ftrace.h>
+
+static unsigned char ftrace_nop_code[MCOUNT_INSN_SIZE] =3D {
+	0x00, 0x00, 0x00, 0x00, 0x01, 0x00,	/* nop.m 0x0 */
+	0x00, 0x00, 0x00, 0x02, 0x00, 0x00,	/* nop.i 0x0 */
+	0x00, 0x00, 0x04, 0x00,			/* nop.i 0x0 */
+	0x01, 0x00, 0x00, 0x00, 0x01, 0x00,	/* nop.m 0x0 */
+	0x00, 0x00, 0x00, 0x02, 0x00, 0x00,	/* nop.i 0x0 */
+	0x00, 0x00, 0x04, 0x00			/* nop.i 0x0;; */
+};
+
+unsigned char *ftrace_nop_replace(void)
+{
+	return ftrace_nop_code;
+}
+
+/* In IA64, each function will be added below two bundles with -pg option =
*/
+static unsigned char __attribute__((aligned(8)))
+ftrace_call_code[MCOUNT_INSN_SIZE] =3D {
+	0x02, 0x40, 0x31, 0x10, 0x80, 0x05, /* alloc r40=3Dar.pfs,12,8,0 */
+	0xb0, 0x02, 0x00, 0x00, 0x42, 0x40, /* mov r43=3Dr0;; */
+	0x05, 0x00, 0xc4, 0x00,             /* mov r42=B0 */
+	0x11, 0x48, 0x01, 0x02, 0x00, 0x21, /* mov r41=3Dr1 */
+	0x00, 0x00, 0x00, 0x02, 0x00, 0x00, /* nop.i 0x0 */
+	0x08, 0x00, 0x00, 0x50              /* br.call.sptk.many b0 =3D _mcount;;=
 */
+};
+
+struct ftrace_call_insn {
+	u64 dummy1, dummy2, dummy3;
+	u64 dummy4:64-41+13;
+	u64 imm20:20;
+	u64 dummy5:3;
+	u64 sign:1;
+	u64 dummy6:4;
+};
+
+static void calculate_offset(unsigned long ip, unsigned long addr,
+	unsigned long *offset, int *sign)
+{
+	long of =3D addr - (ip + 0x10);
+	if (of < 0)
+		*sign =3D 1;
+	else
+		*sign =3D 0;
+	*offset =3D of >> 4;
+}
+
+unsigned char *ftrace_call_replace(unsigned long ip, unsigned long addr)
+{
+	struct ftrace_call_insn *code =3D (void *)ftrace_call_code;
+	unsigned long offset;
+	int sign;
+
+	calculate_offset(ip, addr, &offset, &sign);
+	code->sign =3D sign;
+	code->imm20 =3D offset;
+
+	return ftrace_call_code;
+}
+
+#define CODE_IS_INVALID 0
+#define CODE_IS_NOP 1
+#define CODE_IS_CALL 2
+int ftrace_modify_code(unsigned long ip, unsigned char *old_code,
+		       unsigned char *new_code)
+{
+	unsigned char __attribute__((aligned(8))) replaced[MCOUNT_INSN_SIZE];
+	struct ftrace_call_insn *call_insn =3D (void *)ftrace_call_code, *tmp_cal=
l;
+	int old_code_type =3D CODE_IS_INVALID;
+	struct module *mod =3D module_text_address(ip);
+	int is_kernel_address =3D core_kernel_text(ip);
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
+	/* read the text we want to modify */
+	if (probe_kernel_read(replaced, (void *)ip, MCOUNT_INSN_SIZE))
+		return -EFAULT;
+	/*
+	 * the routine could be called before the module add into the module
+	 * list. At that time, even the ip is a module address,
+	 * module_text_address() will return wrong. Foutunately, this only
+	 * happens on convert call insn to nop. In this case, we don't need
+	 * module, so we can workaround the issue.
+	 * FIXME: make the routine accepts a 'struct module' parameter
+	 * */
+	if (!mod && is_kernel_address) {
+		/* Make sure it is what we expect it to be */
+		if (memcmp(replaced, old_code, MCOUNT_INSN_SIZE) !=3D 0)
+			return -EINVAL;
+		goto do_replace;
+	}
+
+	/* for a mcount call in a module, the mcount will call a PLT entry */
+	old_code_type =3D CODE_IS_NOP;
+
+	tmp_call =3D (void *)replaced;
+	call_insn->sign =3D tmp_call->sign;
+	call_insn->imm20 =3D tmp_call->imm20;
+	/* is original code call? */
+	if (memcmp(replaced, ftrace_call_code, MCOUNT_INSN_SIZE) =3D 0)
+		old_code_type =3D CODE_IS_CALL;
+
+	if (!mod && old_code_type !=3D CODE_IS_CALL)
+		return -EINVAL;
+
+	/* from nop to call */
+	if (old_code_type =3D CODE_IS_NOP) {
+		unsigned long offset;
+		int sign;
+
+		if (memcmp(replaced, ftrace_nop_code, MCOUNT_INSN_SIZE) !=3D 0)
+			return -EINVAL;
+		calculate_offset(ip, mod->arch.ftrace_caller_plt, &offset, &sign);
+		call_insn->sign =3D sign;
+		call_insn->imm20 =3D offset;
+		new_code =3D ftrace_call_code;
+	}
+
+do_replace:
+	/* replace the text with the new text */
+	if (probe_kernel_write((void *)ip, new_code, MCOUNT_INSN_SIZE))
+		return -EPERM;
+
+	flush_icache_range(ip, ip + MCOUNT_INSN_SIZE);
+	return 0;
+}
+
+/* we don't support update ftrace_func */
+int ftrace_update_ftrace_func(ftrace_func_t func)
+{
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
Index: linux/scripts/recordmcount.pl
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/scripts/recordmcount.pl	2008-12-17 1=
7:14:49.000000000 +0800
+++ linux/scripts/recordmcount.pl	2008-12-17 17:15:10.000000000 +0800
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
+# This file refers to mcount, so let's ignore it
+if ($inputfile eq "kernel/trace/ftrace.o") {
+	exit(0);
+}
=20
 # Acceptable sections to record.
 my %text_sections =3D (
@@ -167,6 +172,15 @@ if ($arch eq "x86_64") {
     $objcopy .=3D " -O elf32-i386";
     $cc .=3D " -m32";
=20
+} elsif ($arch eq "ia64") {
+    $section_regex =3D "Disassembly of section\\s+(\\S+):";
+    $function_regex =3D "^([0-9a-fA-F]+)\\s+<(.*?)>:";
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
12-17 17:14:49.000000000 +0800
+++ linux/arch/ia64/include/asm/ftrace.h	2008-12-17 17:15:10.000000000 +0800
@@ -7,6 +7,18 @@
 #ifndef __ASSEMBLY__
 extern void _mcount(unsigned long pfs, unsigned long r1, unsigned long b0,=
 unsigned long r0);
 #define mcount _mcount
+#define ftrace_call ftrace_caller
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
=20
 #endif
=20
Index: linux/kernel/trace/ftrace.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/kernel/trace/ftrace.c	2008-12-17 17:=
14:49.000000000 +0800
+++ linux/kernel/trace/ftrace.c	2008-12-17 17:15:10.000000000 +0800
@@ -168,14 +168,6 @@ static int __unregister_ftrace_function(
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
@@ -322,7 +314,9 @@ ftrace_record_ip(unsigned long ip)
 	return rec;
 }
=20
+#ifndef FTRACE_ADDR
 #define FTRACE_ADDR ((long)(ftrace_caller))
+#endif
=20
 static int
 __ftrace_replace_code(struct dyn_ftrace *rec,
@@ -458,7 +452,7 @@ ftrace_code_disable(struct dyn_ftrace *r
 	ip =3D rec->ip;
=20
 	nop =3D ftrace_nop_replace();
-	call =3D ftrace_call_replace(ip, mcount_addr);
+	call =3D ftrace_call_replace(ip, MCOUNT_ADDR);
=20
 	ret =3D ftrace_modify_code(ip, call, nop);
 	if (ret) {
Index: linux/scripts/Makefile.build
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/scripts/Makefile.build	2008-12-17 17=
:14:50.000000000 +0800
+++ linux/scripts/Makefile.build	2008-12-17 17:15:10.000000000 +0800
@@ -114,6 +114,7 @@ endif
 # Default is built-in, unless we know otherwise
 modkern_cflags :=3D $(CFLAGS_KERNEL)
 quiet_modtag :=3D $(empty)   $(empty)
+is_module :=3D 0
=20
 $(real-objs-m)        : modkern_cflags :=3D $(CFLAGS_MODULE)
 $(real-objs-m:.o=3D.i)  : modkern_cflags :=3D $(CFLAGS_MODULE)
@@ -125,6 +126,11 @@ $(real-objs-m:.o=3D.i)  : quiet_modtag :=3D=20
 $(real-objs-m:.o=3D.s)  : quiet_modtag :=3D [M]
 $(real-objs-m:.o=3D.lst): quiet_modtag :=3D [M]
=20
+$(real-objs-m)        : is_module :=3D 1
+$(real-objs-m:.o=3D.i)  : is_module :=3D 1
+$(real-objs-m:.o=3D.s)  : is_module :=3D 1
+$(real-objs-m:.o=3D.lst): is_module :=3D 1
+
 $(obj-m)              : quiet_modtag :=3D [M]
=20
 # Default for not multi-part modules
@@ -207,7 +213,7 @@ endif
 ifdef CONFIG_FTRACE_MCOUNT_RECORD
 cmd_record_mcount =3D perl $(srctree)/scripts/recordmcount.pl \
 	"$(ARCH)" "$(arch_bits)" "$(OBJDUMP)" "$(OBJCOPY)" "$(CC)" "$(LD)" \
-	"$(NM)" "$(RM)" "$(MV)" "$(@)";
+	"$(NM)" "$(RM)" "$(MV)" "$(is_module)" "$(@)";
 endif
=20
 define rule_cc_o_c
Index: linux/arch/ia64/include/asm/module.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/include/asm/module.h	2008-=
12-17 17:14:49.000000000 +0800
+++ linux/arch/ia64/include/asm/module.h	2008-12-17 17:15:10.000000000 +0800
@@ -21,6 +21,10 @@ struct mod_arch_specific {
 	void *core_unw_table;		/* core unwind-table cookie returned by unwinder */
 	void *init_unw_table;		/* init unwind-table cookie returned by unwinder */
 	unsigned int next_got_entry;	/* index of next available got entry */
+
+#ifdef CONFIG_DYNAMIC_FTRACE
+	uint64_t ftrace_caller_plt;
+#endif
 };
=20
 #define Elf_Shdr	Elf64_Shdr
Index: linux/arch/ia64/kernel/module.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/module.c	2008-12-17=
 17:14:49.000000000 +0800
+++ linux/arch/ia64/kernel/module.c	2008-12-17 17:15:10.000000000 +0800
@@ -32,6 +32,7 @@
 #include <linux/moduleloader.h>
 #include <linux/string.h>
 #include <linux/vmalloc.h>
+#include <linux/ftrace.h>
=20
 #include <asm/patch.h>
 #include <asm/unaligned.h>
@@ -468,6 +469,9 @@ module_frob_arch_sections (Elf_Ehdr *ehd
 			core_plts +=3D count_plts(rels, numrels);
 	}
=20
+#ifdef CONFIG_DYNAMIC_FTRACE
+	core_plts++;
+#endif
 	mod->arch.core_plt->sh_type =3D SHT_NOBITS;
 	mod->arch.core_plt->sh_flags =3D SHF_EXECINSTR | SHF_ALLOC;
 	mod->arch.core_plt->sh_addralign =3D 16;
@@ -839,6 +843,17 @@ apply_relocate_add (Elf64_Shdr *sechdrs,
 		if (ret < 0)
 			return ret;
 	}
+#ifdef CONFIG_DYNAMIC_FTRACE
+	if (!mod->arch.ftrace_caller_plt) {
+		int ok =3D 1;
+		/* fake a 'struct insn' for get_plt, which is in module core */
+		uint64_t fake_insn =3D (uint64_t)mod->module_init + mod->init_size;
+		mod->arch.ftrace_caller_plt =3D get_plt(mod,
+			(struct insn *)fake_insn, (uint64_t)ftrace_caller, &ok);
+		if (!ok)
+			mod->arch.ftrace_caller_plt =3D 0;
+	}
+#endif
 	return 0;
 }
=20
Index: linux/arch/ia64/kernel/entry.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/entry.S	2008-12-17 =
17:15:20.000000000 +0800
+++ linux/arch/ia64/kernel/entry.S	2008-12-17 17:16:54.000000000 +0800
@@ -1406,6 +1406,42 @@ GLOBAL_ENTRY(unw_init_running)
 END(unw_init_running)
=20
 #ifdef CONFIG_FUNCTION_TRACER
+#ifdef CONFIG_DYNAMIC_FTRACE
+GLOBAL_ENTRY(_mcount)
+	br ftrace_stub
+END(_mcount)
+
+GLOBAL_ENTRY(ftrace_caller)
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
+END(ftrace_caller)
+
+#else
 GLOBAL_ENTRY(_mcount)
 	movl r2 =3D ftrace_stub
 	movl r3 =3D ftrace_trace_function;;
@@ -1435,6 +1471,7 @@ GLOBAL_ENTRY(_mcount)
 	br ftrace_stub
 	;;
 END(_mcount)
+#endif
=20
 GLOBAL_ENTRY(ftrace_stub)
 	mov r3 =3D b0


