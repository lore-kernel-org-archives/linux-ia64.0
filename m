From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:40 +0000
Subject: [PATCH 25/50] ia64/pv_ops: introduce pv_info
Message-Id: <12047411462778-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile   |    2 +
 arch/ia64/kernel/paravirt.c |   34 ++++++++++++++++++++++++
 include/asm-ia64/paravirt.h |   61 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 97 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/kernel/paravirt.c
 create mode 100644 include/asm-ia64/paravirt.h

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 185e0e2..7849bc3 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -41,6 +41,8 @@ obj-$(CONFIG_PARAVIRT_ALT)	+= paravirt_alt.o
 obj-$(CONFIG_PARAVIRT_ENTRY)	+= paravirt_entry.o paravirtentry.o
 obj-$(CONFIG_PARAVIRT_NOP_B_PATCH) += paravirt_nop.o
 
+obj-$(CONFIG_PARAVIRT_GUEST)	+= paravirt.o
+
 obj-$(CONFIG_IA64_ESI)		+= esi.o
 ifneq ($(CONFIG_IA64_ESI),)
 obj-y				+= esi_stub.o	# must be in kernel proper
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
new file mode 100644
index 0000000..b31fa91
--- /dev/null
+++ b/arch/ia64/kernel/paravirt.c
@@ -0,0 +1,34 @@
+/******************************************************************************
+ * arch/ia64/kernel/paravirt.c
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
+#include <linux/init.h>
+
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
index 0000000..c2d4809
--- /dev/null
+++ b/include/asm-ia64/paravirt.h
@@ -0,0 +1,61 @@
+/******************************************************************************
+ * include/asm-ia64/paravirt.h
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
+
+#ifndef __ASM_PARAVIRT_H
+#define __ASM_PARAVIRT_H
+
+#ifdef CONFIG_PARAVIRT_GUEST
+
+#ifndef __ASSEMBLY__
+
+/******************************************************************************
+ * general info
+ */
+struct pv_info {
+	unsigned int kernel_rpl;
+        int paravirt_enabled;
+        const char *name;
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
+#endif /* __ASSEMBLY__ */
+
+#else
+/* fallback for native case */
+
+/* XXX: TODO */
+
+#endif /* CONFIG_PARAVIRT_GUEST */
+
+#endif /* __ASM_PARAVIRT_H */
-- 
1.5.3

