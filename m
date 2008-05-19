From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 19 May 2008 13:13:32 +0000
Subject: [PATCH 05/17] ia64/pv_ops: introduce pv_info which describes some random info.
Message-Id: <12112028251117-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

introduce pv_info which describes some randome info about
underlying execution environment.

Cc: Jes Sorensen <jes@sgi.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile   |    2 +
 arch/ia64/kernel/paravirt.c |   41 ++++++++++++++++++++++++++++
 include/asm-ia64/paravirt.h |   62 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kernel/paravirt.c
 create mode 100644 include/asm-ia64/paravirt.h

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 13fd10e..10a4ddb 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -36,6 +36,8 @@ obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
 
+obj-$(CONFIG_PARAVIRT)		+= paravirt.o
+
 obj-$(CONFIG_IA64_ESI)		+= esi.o
 ifneq ($(CONFIG_IA64_ESI),)
 obj-y				+= esi_stub.o	# must be in kernel proper
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
new file mode 100644
index 0000000..d295ea5
--- /dev/null
+++ b/arch/ia64/kernel/paravirt.c
@@ -0,0 +1,41 @@
+/******************************************************************************
+ * arch/ia64/kernel/paravirt.c
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *     Yaozu (Eddie) Dong <eddie.dong@intel.com>
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
+#include <linux/init.h>
+
+#include <linux/compiler.h>
+#include <linux/io.h>
+#include <linux/irq.h>
+#include <linux/types.h>
+
+#include <asm/iosapic.h>
+#include <asm/paravirt.h>
+
+/***************************************************************************
+ * general info
+ */
+struct pv_info pv_info = {
+	.kernel_rpl = 0,
+	.paravirt_enabled = 0,
+	.name = "bare hardware"
+};
diff --git a/include/asm-ia64/paravirt.h b/include/asm-ia64/paravirt.h
new file mode 100644
index 0000000..26b4334
--- /dev/null
+++ b/include/asm-ia64/paravirt.h
@@ -0,0 +1,62 @@
+/******************************************************************************
+ * include/asm-ia64/paravirt.h
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
+
+#ifndef __ASM_PARAVIRT_H
+#define __ASM_PARAVIRT_H
+
+#ifdef CONFIG_PARAVIRT_GUEST
+
+#ifndef __ASSEMBLY__
+
+#include <asm/hw_irq.h>
+#include <asm/meminit.h>
+
+/******************************************************************************
+ * general info
+ */
+struct pv_info {
+	unsigned int kernel_rpl;
+	int paravirt_enabled;
+	const char *name;
+};
+
+extern struct pv_info pv_info;
+
+static inline int paravirt_enabled(void)
+{
+	return pv_info.paravirt_enabled;
+}
+
+static inline unsigned int get_kernel_rpl(void)
+{
+	return pv_info.kernel_rpl;
+}
+
+#endif /* !__ASSEMBLY__ */
+
+#else
+/* fallback for native case */
+
+#endif /* CONFIG_PARAVIRT_GUEST */
+
+#endif /* __ASM_PARAVIRT_H */
-- 
1.5.3

