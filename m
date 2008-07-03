From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 03 Jul 2008 06:54:49 +0000
Subject: [PATCH] ia64/xen: add definitions necessary for xen event channel.
Message-Id: <12150681062277-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Xen paravirtualizes interrupt as event channel.
This patch defines arch specific part of xen event channel.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/xen/events.h |   50 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 50 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/xen/events.h

diff --git a/include/asm-ia64/xen/events.h b/include/asm-ia64/xen/events.h
new file mode 100644
index 0000000..42bb0b5
--- /dev/null
+++ b/include/asm-ia64/xen/events.h
@@ -0,0 +1,50 @@
+/******************************************************************************
+ * include/asm-ia64/xen/events.h
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
+#ifndef _ASM_IA64_XEN_EVENTS_H
+#define _ASM_IA64_XEN_EVENTS_H
+
+enum ipi_vector {
+	XEN_RESCHEDULE_VECTOR,
+	XEN_IPI_VECTOR,
+	XEN_CMCP_VECTOR,
+	XEN_CPEP_VECTOR,
+
+	XEN_NR_IPIS,
+};
+
+static inline int xen_irqs_disabled(struct pt_regs *regs)
+{
+	return !(ia64_psr(regs)->i);
+}
+
+static inline void xen_do_IRQ(int irq, struct pt_regs *regs)
+{
+	struct pt_regs *old_regs;
+	old_regs = set_irq_regs(regs);
+	irq_enter();
+	__do_IRQ(irq);
+	irq_exit();
+	set_irq_regs(old_regs);
+}
+#define irq_ctx_init(cpu)	do { } while (0)
+
+#endif /* _ASM_IA64_XEN_EVENTS_H */
-- 
1.5.3

