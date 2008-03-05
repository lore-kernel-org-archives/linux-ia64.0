From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:48 +0000
Subject: [PATCH 33/50] ia64/xen: detect xen environment at early boot time and do minimal initialization.
Message-Id: <12047411463625-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Currently it detects by checking psr.cpl !=3D 0.
It's ok for now, but more abstraction would be needed later like x86.
Presumably extending booting protocol (i.e. extending struct ia64_boot_para=
m)
or multi entry points depending on hypervisor would be necessary.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/head.S           |    6 ++++
 arch/ia64/xen/xensetup.S          |   40 +++++++++++++++++++++++++++
 include/asm-ia64/xen/hypervisor.h |   55 +++++++++++++++++++++++++++++++++=
++++
 3 files changed, 101 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/xensetup.S
 create mode 100644 include/asm-ia64/xen/hypervisor.h

diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index d3a41d5..2f8d770 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -367,6 +367,12 @@ start_ap:
 	;;
 (isBP)	st8 [r2]=3Dr28		// save the address of the boot param area passed b=
y the bootloader
=20
+#ifdef CONFIG_XEN
+	//  Note: isBP is used by the subprogram.
+	br.call.sptk.many rp=EArly_xen_setup
+	;;
+#endif
+
 #ifdef CONFIG_SMP
 (isAP)	br.call.sptk.many rp=3Dstart_secondary
 .ret0:
diff --git a/arch/ia64/xen/xensetup.S b/arch/ia64/xen/xensetup.S
new file mode 100644
index 0000000..17ad297
--- /dev/null
+++ b/arch/ia64/xen/xensetup.S
@@ -0,0 +1,40 @@
+/*
+ * Support routines for Xen
+ *
+ * Copyright (C) 2005 Dan Magenheimer <dan.magenheimer@hp.com>
+ */
+
+#include <asm/processor.h>
+#include <asm/asmmacro.h>
+
+	.section .data.read_mostly
+	.align 8
+	.global running_on_xen
+running_on_xen:
+	data4 0
+	.previous
+
+#define isBP	p3	// are we the Bootstrap Processor?
+
+	.text
+GLOBAL_ENTRY(early_xen_setup)
+	mov r8=3Dar.rsc		// Initialized in head.S
+(isBP)	movl r9=3Drunning_on_xen;;
+	extr.u r8=3Dr8,2,2;;	// Extract pl fields
+	cmp.eq p7,p0=3Dr8,r0	// p7: !running on xen
+	mov r8=3D1		// booleanize.
+(p7)	br.ret.sptk.many rp;;
+(isBP)	st4 [r9]=3Dr8
+	movl r10=3Dxen_ivt;;
+
+	mov cr.iva=3Dr10
+
+	/* Set xsi base.  */
+#define FW_HYPERCALL_SET_SHARED_INFO_VA			0x600
+(isBP)	mov r2=3DFW_HYPERCALL_SET_SHARED_INFO_VA
+(isBP)	movl r28=3DXSI_BASE;;
+(isBP)	break 0x1000;;
+
+	br.ret.sptk.many rp
+	;;
+END(early_xen_setup)
diff --git a/include/asm-ia64/xen/hypervisor.h b/include/asm-ia64/xen/hyper=
visor.h
new file mode 100644
index 0000000..78c5635
--- /dev/null
+++ b/include/asm-ia64/xen/hypervisor.h
@@ -0,0 +1,55 @@
+/*************************************************************************=
*****
+ * hypervisor.h
+ *
+ * Linux-specific hypervisor handling.
+ *
+ * Copyright (c) 2002-2004, K A Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a=
 copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modi=
fy,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Softw=
are,
+ * and to permit persons to whom the Software is furnished to do so, subje=
ct to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included=
 in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS=
 OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL=
 THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEA=
LINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef _ASM_IA64_XEN_HYPERVISOR_H
+#define _ASM_IA64_XEN_HYPERVISOR_H
+
+#ifdef CONFIG_XEN
+/* running_on_xen is set before executing any C code by early_xen_setup */
+extern const int running_on_xen;
+#define is_running_on_xen()			(running_on_xen)
+#else /* CONFIG_XEN */
+# ifdef CONFIG_VMX_GUEST
+#  define is_running_on_xen()			(1)
+# else /* CONFIG_VMX_GUEST */
+#  define is_running_on_xen()			(0)
+# endif /* CONFIG_VMX_GUEST */
+#endif /* CONFIG_XEN */
+
+#ifdef CONFIG_XEN_PRIVILEGED_GUEST
+#define is_initial_xendomain()						\
+	(is_running_on_xen() ? xen_start_info->flags & SIF_INITDOMAIN : 0)
+#else
+#define is_initial_xendomain() 0
+#endif
+
+#endif /* _ASM_IA64_XEN_HYPERVISOR_H */
--=20
1.5.3

