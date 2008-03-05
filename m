From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:19:02 +0000
Subject: [PATCH 47/50] ia64/pv_ops/xen: define xen pv_info.
Message-Id: <12047411462067-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/Makefile     |    2 +
 arch/ia64/xen/xen_pv_ops.c |   69 ++++++++++++++++++++++++++++++++++++++++++++
 arch/ia64/xen/xensetup.S   |   10 ++++++
 3 files changed, 81 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/xen_pv_ops.c

diff --git a/arch/ia64/xen/Makefile b/arch/ia64/xen/Makefile
index c219358..4b1db56 100644
--- a/arch/ia64/xen/Makefile
+++ b/arch/ia64/xen/Makefile
@@ -2,6 +2,8 @@
 # Makefile for Xen components
 #
 
+obj-y := xen_pv_ops.o
+
 obj-$(CONFIG_PARAVIRT_ALT) += paravirt_xen.o privops_asm.o privops_c.o
 obj-$(CONFIG_PARAVIRT_NOP_B_PATCH) += paravirt_xen.o
 obj-$(CONFIG_PARAVIRT_ENTRY) += paravirt_xen.o
diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
new file mode 100644
index 0000000..18aa2f6
--- /dev/null
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -0,0 +1,69 @@
+/******************************************************************************
+ * arch/ia64/xen/xen_pv_ops.c
+ *
+ * Copyright (c) 2006 Isaku Yamahata <yamahata at valinux co jp>
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
+#include <linux/kernel.h>
+#include <linux/notifier.h>
+#include <linux/pm.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+
+#include <asm/paravirt.h>
+#include <asm/unwind.h>
+
+#include <xen/features.h>
+#include <asm/xen/hypervisor.h>
+#include <asm/xen/xencomm.h>
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
+#define IA64_RSC_PL_MASK	((1UL << (IA64_RSC_PL_BIT_SIZE - 1)) << IA64_RSC_PL_SHIFT)
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
index 2d3d5d4..cb3432b 100644
--- a/arch/ia64/xen/xensetup.S
+++ b/arch/ia64/xen/xensetup.S
@@ -35,6 +35,16 @@ GLOBAL_ENTRY(early_xen_setup)
 (isBP)	movl r28=XSI_BASE;;
 (isBP)	break 0x1000;;
 
+#ifdef CONFIG_PARAVIRT_GUEST
+	/* patch privops */
+(isBP)	mov r4=rp
+	;;
+(isBP)	br.call.sptk.many rp=xen_setup_pv_ops
+	;;
+(isBP)	mov rp=r4
+	;;
+#endif
+
 #ifdef CONFIG_PARAVIRT
 	/* patch privops */
 (isBP)	mov r4=rp
-- 
1.5.3

