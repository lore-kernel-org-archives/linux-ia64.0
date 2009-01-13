From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 13 Jan 2009 06:11:15 +0000
Subject: [PATCH 5/9] ftrace, ia64: IA64 static ftrace support
Message-Id: <20090113061147.944289231@goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090113061110.856268617@goodmis.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Shaohua Li <shaohua.li@intel.com>, ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Sam Ravnborg <sam@ravnborg.org>, u.kleine-koenig@pengutronix.de, Steven Rostedt <srostedt@redhat.com>

From: Shaohua Li <shaohua.li@intel.com>

IA64 ftrace suppport. In IA64, below code will be added in each function
if -pg is enabled.

alloc r40=3Dar.pfs,12,8,0
mov r43=3Dr0;;
mov r42=B0
mov r41=3Dr1
nop.i 0x0
br.call.sptk.many b0 =3D _mcount;;

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Steven Rostedt <srostedt@redhat.com>
---
 arch/ia64/Kconfig              |    1 +
 arch/ia64/include/asm/ftrace.h |   15 ++++++++++++
 arch/ia64/kernel/entry.S       |   49 ++++++++++++++++++++++++++++++++++++=
++++
 arch/ia64/kernel/ia64_ksyms.c  |    6 +++++
 4 files changed, 71 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/include/asm/ftrace.h

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 3d31636..b992ba4 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -21,6 +21,7 @@ config IA64
 	select HAVE_OPROFILE
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
+	select HAVE_FUNCTION_TRACER
 	select HAVE_DMA_ATTRS
 	select HAVE_KVM
 	select HAVE_ARCH_TRACEHOOK
diff --git a/arch/ia64/include/asm/ftrace.h b/arch/ia64/include/asm/ftrace.h
new file mode 100644
index 0000000..48694b3
--- /dev/null
+++ b/arch/ia64/include/asm/ftrace.h
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
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index d435f4a..c2f7d79 100644
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
--=20
1.5.6.5

--=20
