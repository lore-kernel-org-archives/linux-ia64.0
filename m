From: Shaohua Li <shaohua.li@intel.com>
Date: Thu, 18 Dec 2008 03:17:18 +0000
Subject: [RFC 1/2] ftrace porting of ia64
Message-Id: <1229570238.28616.31.camel@sli10-desk.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ftrace porting of IA64.
TBD:
1. I don't how to add unwind info to the assemble code, so please
advise.
2. The generic ftrace ring buffer code doesn't handle alignment well.
With the patch, kernel will report a lot of unalignment. This is still
under investigation.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 arch/ia64/Kconfig              |    1 
 arch/ia64/include/asm/ftrace.h |   14 +++++++++++
 arch/ia64/kernel/entry.S       |   49 +++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/ia64_ksyms.c  |    6 +++++
 4 files changed, 70 insertions(+)

Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2008-12-17 11:13:49.000000000 +0800
+++ linux/arch/ia64/Kconfig	2008-12-17 17:14:49.000000000 +0800
@@ -21,6 +21,7 @@ config IA64
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
+	select HAVE_FUNCTION_TRACER
 	select HAVE_DMA_ATTRS
 	select HAVE_KVM
 	select HAVE_ARCH_TRACEHOOK
Index: linux/arch/ia64/include/asm/ftrace.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/include/asm/ftrace.h	2008-12-17 17:14:49.000000000 +0800
@@ -0,0 +1,15 @@
+#ifndef _ASM_IA64_FTRACE_H
+#define _ASM_IA64_FTRACE_H
+
+#ifdef CONFIG_FUNCTION_TRACER
+#define MCOUNT_INSN_SIZE        32 /* sizeof mcount call */
+
+#ifndef __ASSEMBLY__
+extern void _mcount(unsigned long pfs, unsigned long r1, unsigned long b0, unsigned long r0);
+#define mcount _mcount
+
+#endif
+
+#endif /* CONFIG_FUNCTION_TRACER */
+
+#endif /* _ASM_IA64_FTRACE_H */
Index: linux/arch/ia64/kernel/entry.S
=================================--- linux.orig/arch/ia64/kernel/entry.S	2008-12-17 11:13:49.000000000 +0800
+++ linux/arch/ia64/kernel/entry.S	2008-12-17 17:14:45.000000000 +0800
@@ -47,6 +47,7 @@
 #include <asm/processor.h>
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
+#include <asm/ftrace.h>
 
 #include "minstate.h"
 
@@ -1404,6 +1405,54 @@ GLOBAL_ENTRY(unw_init_running)
 	br.ret.sptk.many rp
 END(unw_init_running)
 
+#ifdef CONFIG_FUNCTION_TRACER
+GLOBAL_ENTRY(_mcount)
+	movl r2 = ftrace_stub
+	movl r3 = ftrace_trace_function;;
+	ld8 r3 = [r3];;
+	ld8 r3 = [r3];;
+	cmp.eq p7,p0 = r2, r3
+(p7)	br.sptk.many ftrace_stub
+	;;
+
+	alloc loc0 = ar.pfs, 4, 4, 2, 0
+	;;
+	mov loc1 = b0
+	mov out0 = b0
+	mov loc2 = r8
+	mov loc3 = r15
+	;;
+	adds out0 = -MCOUNT_INSN_SIZE, out0
+	mov out1 = in2
+	mov b6 = r3
+
+	br.call.sptk.many b0 = b6
+	;;
+	mov ar.pfs = loc0
+	mov b0 = loc1
+	mov r8 = loc2
+	mov r15 = loc3
+	br ftrace_stub
+	;;
+END(_mcount)
+
+GLOBAL_ENTRY(ftrace_stub)
+	mov r3 = b0
+	movl r2 = _mcount_ret_helper
+	;;
+	mov b6 = r2
+	mov b7 = r3
+	br.ret.sptk.many b6
+
+_mcount_ret_helper:
+	mov b0 = r42
+	mov r1 = r41
+	mov ar.pfs = r40
+	br b7
+END(ftrace_stub)
+
+#endif /* CONFIG_FUNCTION_TRACER */
+
 	.rodata
 	.align 8
 	.globl sys_call_table
Index: linux/arch/ia64/kernel/ia64_ksyms.c
=================================--- linux.orig/arch/ia64/kernel/ia64_ksyms.c	2008-12-17 11:13:49.000000000 +0800
+++ linux/arch/ia64/kernel/ia64_ksyms.c	2008-12-17 13:16:51.000000000 +0800
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


