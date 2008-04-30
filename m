From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:30:50 +0000
Subject: [PATCH 19/23] ia64/pv_ops/xen: define the nubmer of irqs which xen needs.
Message-Id: <12095586543985-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716630655-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716630655-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define include/asm-ia64/xen/irq.h to define the number of
irqs which xen needs.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/nr-irqs.c |    1 +
 include/asm-ia64/xen/irq.h |   44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)
 create mode 100644 include/asm-ia64/xen/irq.h

diff --git a/arch/ia64/kernel/nr-irqs.c b/arch/ia64/kernel/nr-irqs.c
index 1ae0491..bf89a8f 100644
--- a/arch/ia64/kernel/nr-irqs.c
+++ b/arch/ia64/kernel/nr-irqs.c
@@ -10,6 +10,7 @@
 #include <linux/kbuild.h>
 #include <linux/threads.h>
 #include <asm-ia64/native/irq.h>
+#include <asm-ia64/xen/irq.h>
 
 void foo(void)
 {
diff --git a/include/asm-ia64/xen/irq.h b/include/asm-ia64/xen/irq.h
new file mode 100644
index 0000000..3a5a15c
--- /dev/null
+++ b/include/asm-ia64/xen/irq.h
@@ -0,0 +1,44 @@
+/******************************************************************************
+ * include/asm-ia64/xen/irq.h
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
+#ifndef _ASM_IA64_XEN_IRQ_H
+#define _ASM_IA64_XEN_IRQ_H
+
+/*
+ * The flat IRQ space is divided into two regions:
+ *  1. A one-to-one mapping of real physical IRQs. This space is only used
+ *     if we have physical device-access privilege. This region is at the
+ *     start of the IRQ space so that existing device drivers do not need
+ *     to be modified to translate physical IRQ numbers into our IRQ space.
+ *  3. A dynamic mapping of inter-domain and Xen-sourced virtual IRQs. These
+ *     are bound using the provided bind/unbind functions.
+ */
+
+#define XEN_PIRQ_BASE		0
+#define XEN_NR_PIRQS		256
+
+#define XEN_DYNIRQ_BASE		(XEN_PIRQ_BASE + XEN_NR_PIRQS)
+#define XEN_NR_DYNIRQS		(NR_CPUS * 8)
+
+#define XEN_NR_IRQS		(XEN_NR_PIRQS + XEN_NR_DYNIRQS)
+
+#endif /* _ASM_IA64_XEN_IRQ_H */
-- 
1.5.3

