From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:30:44 +0000
Subject: [PATCH 13/23] ia64/pv_ops/xen: define xen pv_cpu_ops.
Message-Id: <12095586541802-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12077166303849-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12077166303849-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

define xen pv_cpu_ops which implementes xen paravirtualized
privileged instructions.

Signed-off-by: Yaozu (Eddie) Dong <eddie.dong@intel.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xen_pv_ops.c |  114 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 01260a0..aa73942 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -161,6 +161,119 @@ static const struct pv_init_ops xen_init_ops __initdata = {
 };
 
 /***************************************************************************
+ * pv_cpu_ops
+ * intrinsics hooks.
+ */
+
+static void xen_setreg(int regnum, unsigned long val)
+{
+	switch (regnum) {
+	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_KR7:
+		xen_set_kr(regnum - _IA64_REG_AR_KR0, val);
+		break;
+#ifdef CONFIG_IA32_SUPPORT
+	case _IA64_REG_AR_EFLAG:
+		xen_set_eflag(val);
+		break;
+#endif
+	case _IA64_REG_CR_TPR:
+		xen_set_tpr(val);
+		break;
+	case _IA64_REG_CR_ITM:
+		xen_set_itm(val);
+		break;
+	case _IA64_REG_CR_EOI:
+		xen_eoi(val);
+		break;
+	default:
+		ia64_native_setreg_func(regnum, val);
+		break;
+	}
+}
+
+static unsigned long xen_getreg(int regnum)
+{
+	unsigned long res;
+
+	switch (regnum) {
+	case _IA64_REG_PSR:
+		res = xen_get_psr();
+		break;
+#ifdef CONFIG_IA32_SUPPORT
+	case _IA64_REG_AR_EFLAG:
+		res = xen_get_eflag();
+		break;
+#endif
+	case _IA64_REG_CR_IVR:
+		res = xen_get_ivr();
+		break;
+	case _IA64_REG_CR_TPR:
+		res = xen_get_tpr();
+		break;
+	default:
+		res = ia64_native_getreg_func(regnum);
+		break;
+	}
+	return res;
+}
+
+/* turning on interrupts is a bit more complicated.. write to the
+ * memory-mapped virtual psr.i bit first (to avoid race condition),
+ * then if any interrupts were pending, we have to execute a hyperprivop
+ * to ensure the pending interrupt gets delivered; else we're done! */
+static void
+xen_ssm_i(void)
+{
+	int old = xen_get_virtual_psr_i();
+	xen_set_virtual_psr_i(1);
+	barrier();
+	if (!old && xen_get_virtual_pend())
+		xen_hyper_ssm_i();
+}
+
+/* turning off interrupts can be paravirtualized simply by writing
+ * to a memory-mapped virtual psr.i bit (implemented as a 16-bit bool) */
+static void
+xen_rsm_i(void)
+{
+	xen_set_virtual_psr_i(0);
+	barrier();
+}
+
+static unsigned long
+xen_get_psr_i(void)
+{
+	return xen_get_virtual_psr_i() ? IA64_PSR_I : 0;
+}
+
+static void
+xen_intrin_local_irq_restore(unsigned long mask)
+{
+	if (mask & IA64_PSR_I)
+		xen_ssm_i();
+	else
+		xen_rsm_i();
+}
+
+static const struct pv_cpu_ops xen_cpu_ops __initdata = {
+	.fc		= xen_fc,
+	.thash		= xen_thash,
+	.get_cpuid	= xen_get_cpuid,
+	.get_pmd	= xen_get_pmd,
+	.getreg		= xen_getreg,
+	.setreg		= xen_setreg,
+	.ptcga		= xen_ptcga,
+	.get_rr		= xen_get_rr,
+	.set_rr		= xen_set_rr,
+	.set_rr0_to_rr4	= xen_set_rr0_to_rr4,
+	.ssm_i		= xen_ssm_i,
+	.rsm_i		= xen_rsm_i,
+	.get_psr_i	= xen_get_psr_i,
+	.intrin_local_irq_restore
+			= xen_intrin_local_irq_restore,
+};
+
+/***************************************************************************
  * pv_ops initialization
  */
 
@@ -170,4 +283,5 @@ xen_setup_pv_ops(void)
 	xen_info_init();
 	pv_info = xen_info;
 	pv_init_ops = xen_init_ops;
+	pv_cpu_ops = xen_cpu_ops;
 }
-- 
1.5.3

