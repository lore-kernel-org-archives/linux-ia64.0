From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 10 Jun 2008 07:47:09 +0000
Subject: [PATCH 13/27] ia64/pv_ops/xen: elf note based xen startup.
Message-Id: <12130840443459-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch enables elf note based xen startup for IA-64, which gives the
kernel an early hint for running on xen like x86 case.
In order to avoid the multi entry point, presumably extending booting
protocol(i.e. extending struct ia64_boot_param) would be necessary.
It probably means that elilo also needs modification.

Signed-off-by: Qing He <qing.he@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile     |    3 +-
 arch/ia64/xen/xen_pv_ops.c |   65 ++++++++++++++++++++++++++++++++++
 arch/ia64/xen/xensetup.S   |   83 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 150 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/xen_pv_ops.c
 create mode 100644 arch/ia64/xen/xensetup.S

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index eb59563..abc356f 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -2,4 +2,5 @@
 # Makefile for Xen components
 #
 
-obj-y := hypercall.o xencomm.o xcom_hcall.o grant-table.o
+obj-y := hypercall.o xensetup.o xen_pv_ops.o \
+	xencomm.o xcom_hcall.o grant-table.o
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
new file mode 100644
index 0000000..77db214
--- /dev/null
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -0,0 +1,65 @@
+/******************************************************************************
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
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
+/***************************************************************************
+ * general info
+ */
+static struct pv_info xen_info __initdata = {
+	.kernel_rpl = 2,	/* or 1: determin at runtime */
+	.paravirt_enabled = 1,
+	.name = "Xen/ia64",
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
+	/* Xenified Linux/ia64 may run on pl = 1 or 2.
+	 * determin at run time. */
+	unsigned long rsc = ia64_getreg(_IA64_REG_AR_RSC);
+	unsigned int rpl = (rsc & IA64_RSC_PL_MASK) >> IA64_RSC_PL_SHIFT;
+	xen_info.kernel_rpl = rpl;
+}
+
+/***************************************************************************
+ * pv_ops initialization
+ */
+
+void __init
+xen_setup_pv_ops(void)
+{
+	xen_info_init();
+	pv_info = xen_info;
+}
diff --git a/arch/ia64/xen/xensetup.S b/arch/ia64/xen/xensetup.S
new file mode 100644
index 0000000..7d71333
--- /dev/null
+++ b/arch/ia64/xen/xensetup.S
@@ -0,0 +1,83 @@
+/*
+ * Support routines for Xen
+ *
+ * Copyright (C) 2005 Dan Magenheimer <dan.magenheimer@hp.com>
+ */
+
+#include <asm/processor.h>
+#include <asm/asmmacro.h>
+#include <asm/pgtable.h>
+#include <asm/system.h>
+#include <asm/paravirt.h>
+#include <asm/xen/privop.h>
+#include <linux/elfnote.h>
+#include <linux/init.h>
+#include <xen/interface/elfnote.h>
+
+	.section .data.read_mostly
+	.align 8
+	.global running_on_xen
+running_on_xen:
+	data4 0
+	.previous
+
+	__INIT
+ENTRY(startup_xen)
+	// Calculate load offset.
+	// The constant, LOAD_OFFSET, can't be used because the boot
+	// loader doesn't always load to the LMA specified by the vmlinux.lds.
+	mov r9=ip	// must be the first instruction to make sure
+			// that r9 = the physical address of startup_xen.
+			// Usually r9 = startup_xen - LOAD_OFFSET
+	movl r8=startup_xen
+	;;
+	sub r9=r9,r8	// Usually r9 = -LOAD_OFFSET.
+
+	mov r10=PARAVIRT_HYPERVISOR_TYPE_XEN
+	movl r11=_start
+	;;
+	add r11=r11,r9
+	movl r8=hypervisor_type
+	;;
+	add r8=r8,r9
+	mov b0=r11
+	;;
+	st8 [r8]=r10
+	br.cond.sptk.many b0
+	;;
+END(startup_xen)
+
+	ELFNOTE(Xen, XEN_ELFNOTE_GUEST_OS,	.asciz "linux")
+	ELFNOTE(Xen, XEN_ELFNOTE_GUEST_VERSION,	.asciz "2.6")
+	ELFNOTE(Xen, XEN_ELFNOTE_XEN_VERSION,	.asciz "xen-3.0")
+	ELFNOTE(Xen, XEN_ELFNOTE_ENTRY,		data8.ua startup_xen - LOAD_OFFSET)
+
+#define isBP	p3	// are we the Bootstrap Processor?
+
+	.text
+
+GLOBAL_ENTRY(xen_setup_hook)
+	mov r8=1		// booleanize.
+(isBP)	movl r9=running_on_xen;;
+(isBP)	st4 [r9]=r8
+	movl r10=xen_ivt;;
+
+	mov cr.iva=r10
+
+	/* Set xsi base.  */
+#define FW_HYPERCALL_SET_SHARED_INFO_VA			0x600
+(isBP)	mov r2=FW_HYPERCALL_SET_SHARED_INFO_VA
+(isBP)	movl r28=XSI_BASE;;
+(isBP)	break 0x1000;;
+
+	/* setup pv_ops */
+(isBP)	mov r4=rp
+	;;
+(isBP)	br.call.sptk.many rp=xen_setup_pv_ops
+	;;
+(isBP)	mov rp=r4
+	;;
+
+	br.ret.sptk.many rp
+	;;
+END(xen_setup_hook)
-- 
1.5.3

