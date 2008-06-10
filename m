From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 10 Jun 2008 07:47:16 +0000
Subject: [PATCH 20/27] ia64/pv_ops/xen: implement xen pv_iosapic_ops.
Message-Id: <12130840443987-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

implement xen pv_iosapic_ops for xen paravirtualized
iosapic.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xen_pv_ops.c |   52 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 1ba4617..6978131 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -292,6 +292,57 @@ const struct pv_cpu_asm_switch xen_cpu_asm_switch = {
 };
 
 /***************************************************************************
+ * pv_iosapic_ops
+ * iosapic read/write hooks.
+ */
+static void
+xen_pcat_compat_init(void)
+{
+	/* nothing */
+}
+
+static struct irq_chip*
+xen_iosapic_get_irq_chip(unsigned long trigger)
+{
+	return NULL;
+}
+
+static unsigned int
+xen_iosapic_read(char __iomem *iosapic, unsigned int reg)
+{
+	struct physdev_apic apic_op;
+	int ret;
+
+	apic_op.apic_physbase = (unsigned long)iosapic -
+					__IA64_UNCACHED_OFFSET;
+	apic_op.reg = reg;
+	ret = HYPERVISOR_physdev_op(PHYSDEVOP_apic_read, &apic_op);
+	if (ret)
+		return ret;
+	return apic_op.value;
+}
+
+static void
+xen_iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
+{
+	struct physdev_apic apic_op;
+
+	apic_op.apic_physbase = (unsigned long)iosapic -
+					__IA64_UNCACHED_OFFSET;
+	apic_op.reg = reg;
+	apic_op.value = val;
+	HYPERVISOR_physdev_op(PHYSDEVOP_apic_write, &apic_op);
+}
+
+static const struct pv_iosapic_ops xen_iosapic_ops __initdata = {
+	.pcat_compat_init = xen_pcat_compat_init,
+	.get_irq_chip = xen_iosapic_get_irq_chip,
+
+	.__read = xen_iosapic_read,
+	.__write = xen_iosapic_write,
+};
+
+/***************************************************************************
  * pv_ops initialization
  */
 
@@ -302,6 +353,7 @@ xen_setup_pv_ops(void)
 	pv_info = xen_info;
 	pv_init_ops = xen_init_ops;
 	pv_cpu_ops = xen_cpu_ops;
+	pv_iosapic_ops = xen_iosapic_ops;
 
 	paravirt_cpu_asm_init(&xen_cpu_asm_switch);
 }
-- 
1.5.3

