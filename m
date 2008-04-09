From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 09 Apr 2008 04:50:18 +0000
Subject: [PATCH 11/23] ia64/xen: detect xen environment and do minimal initialization.
Message-Id: <12077166303487-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Add a hook for xen detection and initialization. It detects
xen environment and does minimal initialization.
For now xen is detected by checking psr.cpl !=3D 0.
It's ok for now, but more abstraction would be needed later like x86.
Presumably extending booting protocol (i.e. extending struct ia64_boot_para=
m)
or multi entry points depending on hypervisor would be necessary.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/head.S    |    6 ++++
 arch/ia64/xen/Makefile     |    3 +-
 arch/ia64/xen/xen_pv_ops.c |   65 ++++++++++++++++++++++++++++++++++++++++=
++++
 arch/ia64/xen/xensetup.S   |   49 +++++++++++++++++++++++++++++++++
 4 files changed, 122 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/xen_pv_ops.c
 create mode 100644 arch/ia64/xen/xensetup.S

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
diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index eb59563..abc356f 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -2,4 +2,5 @@
 # Makefile for Xen components
 #
=20
-obj-y :=3D hypercall.o xencomm.o xcom_hcall.o grant-table.o
+obj-y :=3D hypercall.o xensetup.o xen_pv_ops.o \
+	xencomm.o xcom_hcall.o grant-table.o
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
new file mode 100644
index 0000000..77db214
--- /dev/null
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -0,0 +1,65 @@
+/*************************************************************************=
*****
+ * arch/ia64/xen/xen_pv_ops.c
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ *
+ */
+
+#include <linux/console.h>
+#include <linux/irq.h>
+#include <linux/kernel.h>
+#include <linux/pm.h>
+
+#include <asm/xen/hypervisor.h>
+#include <asm/xen/xencomm.h>
+#include <asm/xen/privop.h>
+
+/*************************************************************************=
**
+ * general info
+ */
+static struct pv_info xen_info __initdata =3D {
+	.kernel_rpl =3D 2,	/* or 1: determin at runtime */
+	.paravirt_enabled =3D 1,
+	.name =3D "Xen/ia64",
+};
+
+#define IA64_RSC_PL_SHIFT	2
+#define IA64_RSC_PL_BIT_SIZE	2
+#define IA64_RSC_PL_MASK	\
+	(((1UL << IA64_RSC_PL_BIT_SIZE) - 1) << IA64_RSC_PL_SHIFT)
+
+static void __init
+xen_info_init(void)
+{
+	/* Xenified Linux/ia64 may run on pl =3D 1 or 2.
+	 * determin at run time. */
+	unsigned long rsc =3D ia64_getreg(_IA64_REG_AR_RSC);
+	unsigned int rpl =3D (rsc & IA64_RSC_PL_MASK) >> IA64_RSC_PL_SHIFT;
+	xen_info.kernel_rpl =3D rpl;
+}
+
+/*************************************************************************=
**
+ * pv_ops initialization
+ */
+
+void __init
+xen_setup_pv_ops(void)
+{
+	xen_info_init();
+	pv_info =3D xen_info;
+}
diff --git a/arch/ia64/xen/xensetup.S b/arch/ia64/xen/xensetup.S
new file mode 100644
index 0000000..43608b2
--- /dev/null
+++ b/arch/ia64/xen/xensetup.S
@@ -0,0 +1,49 @@
+/*
+ * Support routines for Xen
+ *
+ * Copyright (C) 2005 Dan Magenheimer <dan.magenheimer@hp.com>
+ */
+
+#include <asm/processor.h>
+#include <asm/asmmacro.h>
+#include <asm/xen/privop.h>
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
+	/* setup pv_ops */
+(isBP)	mov r4=3Drp
+	;;
+(isBP)	br.call.sptk.many rp=3Dxen_setup_pv_ops
+	;;
+(isBP)	mov rp=3Dr4
+	;;
+
+	br.ret.sptk.many rp
+	;;
+END(early_xen_setup)
--=20
1.5.3

