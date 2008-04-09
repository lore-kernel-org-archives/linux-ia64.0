From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 09 Apr 2008 04:49:06 +0000
Subject: [PATCH 13/15] ia64/pv_ops: add hooks, pv_iosapic_ops, to paravirtualize iosapic.
Message-Id: <12077165494047-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

add hooks to paravirtualize iosapic which is a real hardware resource.
On virtualized environment it may be replaced something virtualized
friendly.
Define pv_iosapic_ops and add the hooks.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/iosapic.c  |   45 +++++++++++++++++++++++++++---------------
 arch/ia64/kernel/paravirt.c |   25 +++++++++++++++++++++++
 include/asm-ia64/iosapic.h  |   18 +++++++++++++++-
 include/asm-ia64/paravirt.h |   40 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 110 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 082c31d..587196d 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -587,6 +587,15 @@ static inline int irq_is_shared (int irq)
 	return (iosapic_intr_info[irq].count > 1);
 }
 
+struct irq_chip*
+ia64_native_iosapic_get_irq_chip(unsigned long trigger)
+{
+	if (trigger = IOSAPIC_EDGE)
+		return &irq_type_iosapic_edge;
+	else
+		return &irq_type_iosapic_level;
+}
+
 static int
 register_intr (unsigned int gsi, int irq, unsigned char delivery,
 	       unsigned long polarity, unsigned long trigger)
@@ -637,13 +646,10 @@ register_intr (unsigned int gsi, int irq, unsigned char delivery,
 	iosapic_intr_info[irq].dmode    = delivery;
 	iosapic_intr_info[irq].trigger  = trigger;
 
-	if (trigger = IOSAPIC_EDGE)
-		irq_type = &irq_type_iosapic_edge;
-	else
-		irq_type = &irq_type_iosapic_level;
+	irq_type = iosapic_get_irq_chip(trigger);
 
 	idesc = irq_desc + irq;
-	if (idesc->chip != irq_type) {
+	if (irq_type != NULL && idesc->chip != irq_type) {
 		if (idesc->chip != &no_irq_type)
 			printk(KERN_WARNING
 			       "%s: changing vector %d from %s to %s\n",
@@ -976,6 +982,22 @@ iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 }
 
 void __init
+ia64_native_iosapic_pcat_compat_init(void)
+{
+	if (pcat_compat) {
+		/*
+		 * Disable the compatibility mode interrupts (8259 style),
+		 * needs IN/OUT support enabled.
+		 */
+		printk(KERN_INFO
+		       "%s: Disabling PC-AT compatible 8259 interrupts\n",
+		       __func__);
+		outb(0xff, 0xA1);
+		outb(0xff, 0x21);
+	}
+}
+
+void __init
 iosapic_system_init (int system_pcat_compat)
 {
 	int irq;
@@ -989,17 +1011,8 @@ iosapic_system_init (int system_pcat_compat)
 	}
 
 	pcat_compat = system_pcat_compat;
-	if (pcat_compat) {
-		/*
-		 * Disable the compatibility mode interrupts (8259 style),
-		 * needs IN/OUT support enabled.
-		 */
-		printk(KERN_INFO
-		       "%s: Disabling PC-AT compatible 8259 interrupts\n",
-		       __func__);
-		outb(0xff, 0xA1);
-		outb(0xff, 0x21);
-	}
+	if (pcat_compat)
+		iosapic_pcat_compat_init();
 }
 
 static inline int
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index 0b57a8d..4c54319 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -310,3 +310,28 @@ paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch)
 		cpu_asm_switch->work_processed_syscall;
 	paravirt_leave_kernel_targ = cpu_asm_switch->leave_kernel;
 }
+
+/***************************************************************************
+ * pv_iosapic_ops
+ * iosapic read/write hooks.
+ */
+
+static unsigned int
+ia64_native_iosapic_read(char __iomem *iosapic, unsigned int reg)
+{
+	return __ia64_native_iosapic_read(iosapic, reg);
+}
+
+static void
+ia64_native_iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
+{
+	__ia64_native_iosapic_write(iosapic, reg, val);
+}
+
+struct pv_iosapic_ops pv_iosapic_ops = {
+	.pcat_compat_init = ia64_native_iosapic_pcat_compat_init,
+	.get_irq_chip = ia64_native_iosapic_get_irq_chip,
+
+	.__read = ia64_native_iosapic_read,
+	.__write = ia64_native_iosapic_write,
+};
diff --git a/include/asm-ia64/iosapic.h b/include/asm-ia64/iosapic.h
index a3a4288..b9c102e 100644
--- a/include/asm-ia64/iosapic.h
+++ b/include/asm-ia64/iosapic.h
@@ -55,13 +55,27 @@
 
 #define NR_IOSAPICS			256
 
-static inline unsigned int __iosapic_read(char __iomem *iosapic, unsigned int reg)
+#ifdef CONFIG_PARAVIRT_GUEST
+#include <asm/paravirt.h>
+#else
+#define iosapic_pcat_compat_init	ia64_native_iosapic_pcat_compat_init
+#define __iosapic_read			__ia64_native_iosapic_read
+#define __iosapic_write			__ia64_native_iosapic_write
+#define iosapic_get_irq_chip		ia64_native_iosapic_get_irq_chip
+#endif
+
+extern void __init ia64_native_iosapic_pcat_compat_init(void);
+extern struct irq_chip *ia64_native_iosapic_get_irq_chip(unsigned long trigger);
+
+static inline unsigned int
+__ia64_native_iosapic_read(char __iomem *iosapic, unsigned int reg)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
 	return readl(iosapic + IOSAPIC_WINDOW);
 }
 
-static inline void __iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
+static inline void
+__ia64_native_iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 {
 	writel(reg, iosapic + IOSAPIC_REG_SELECT);
 	writel(val, iosapic + IOSAPIC_WINDOW);
diff --git a/include/asm-ia64/paravirt.h b/include/asm-ia64/paravirt.h
index 8778e8b..48887a4 100644
--- a/include/asm-ia64/paravirt.h
+++ b/include/asm-ia64/paravirt.h
@@ -109,6 +109,46 @@ static inline void paravirt_post_smp_prepare_boot_cpu(void)
 		pv_init_ops.post_smp_prepare_boot_cpu();
 }
 
+/******************************************************************************
+ * replacement of iosapic operations.
+ */
+
+struct pv_iosapic_ops {
+	void (*pcat_compat_init)(void);
+
+	struct irq_chip *(*get_irq_chip)(unsigned long trigger);
+
+	unsigned int (*__read)(char __iomem *iosapic, unsigned int reg);
+	void (*__write)(char __iomem *iosapic, unsigned int reg, u32 val);
+};
+
+extern struct pv_iosapic_ops pv_iosapic_ops;
+
+static inline void
+iosapic_pcat_compat_init(void)
+{
+	if (pv_iosapic_ops.pcat_compat_init)
+		pv_iosapic_ops.pcat_compat_init();
+}
+
+static inline struct irq_chip*
+iosapic_get_irq_chip(unsigned long trigger)
+{
+	return pv_iosapic_ops.get_irq_chip(trigger);
+}
+
+static inline unsigned int
+__iosapic_read(char __iomem *iosapic, unsigned int reg)
+{
+	return pv_iosapic_ops.__read(iosapic, reg);
+}
+
+static inline void
+__iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
+{
+	return pv_iosapic_ops.__write(iosapic, reg, val);
+}
+
 #endif /* !__ASSEMBLY__ */
 
 #else
-- 
1.5.3

