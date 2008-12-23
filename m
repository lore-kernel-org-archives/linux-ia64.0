From: Shaohua Li <shaohua.li@intel.com>
Date: Tue, 23 Dec 2008 06:07:58 +0000
Subject: [PATCH 1/5] IA64 static ftrace support
Message-Id: <1230012478.10933.98.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

IA64 ftrace suppport. In IA64, below code will be added in each function
if -pg is enabled.

alloc r40=3Dar.pfs,12,8,0
mov r43=3Dr0;;
mov r42=B0
mov r41=3Dr1
nop.i 0x0
br.call.sptk.many b0 =3D _mcount;;

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/Kconfig              |    1=20
 arch/ia64/include/asm/ftrace.h |   15 ++++++++++++
 arch/ia64/kernel/entry.S       |   49 ++++++++++++++++++++++++++++++++++++=
+++++
 arch/ia64/kernel/ia64_ksyms.c  |    6 +++++
 4 files changed, 71 insertions(+)

Index: linux/arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/Kconfig	2008-12-23 13:11:2=
9.000000000 +0800
+++ linux/arch/ia64/Kconfig	2008-12-23 13:13:17.000000000 +0800
@@ -21,6 +21,7 @@ config IA64
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
+	select HAVE_FUNCTION_TRACER
 	select HAVE_DMA_ATTRS
 	select HAVE_KVM
 	select HAVE_ARCH_TRACEHOOK
Index: linux/arch/ia64/include/asm/ftrace.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/include/asm/ftrace.h	2008-12-23 13:13:17.000000000 +0800
@@ -0,0 +1,15 @@
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
+#endif
+
+#endif /* CONFIG_FUNCTION_TRACER */
+
+#endif /* _ASM_IA64_FTRACE_H */
Index: linux/arch/ia64/kernel/entry.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/entry.S	2008-12-23 =
13:11:29.000000000 +0800
+++ linux/arch/ia64/kernel/entry.S	2008-12-23 13:13:17.000000000 +0800
@@ -47,6 +47,7 @@
 #include <asm/processor.h>
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
+#include <asm/ftrace.h>
=20
 #include "minstate.h"
=20
@@ -1404,6 +1405,54 @@ GLOBAL_ENTRY(unw_init_running)
 	br.ret.sptk.many rp
 END(unw_init_running)
=20
+#ifdef CONFIG_FUNCTION_TRACER
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
Index: linux/arch/ia64/kernel/ia64_ksyms.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig/arch/ia64/kernel/ia64_ksyms.c	2008-1=
2-23 13:11:29.000000000 +0800
+++ linux/arch/ia64/kernel/ia64_ksyms.c	2008-12-23 13:13:17.000000000 +0800
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


