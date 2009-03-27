From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 27 Mar 2009 06:10:33 +0000
Subject: [PATCH] ia64/xen: fix the link error.
Message-Id: <20090327061033.GJ13054%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes the following link error with xen_domu_defconfig.
Depending on compiler version, it doesn't link as follows.
So remove const and use __initdata for xen_iosapic_ops.

> arch/ia64/xen/xen_pv_ops.c:878: error: xen_iosapic_ops causes a section type conflict

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xen_pv_ops.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 6c44225..bf3c74c 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -875,7 +875,7 @@ xen_iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 	HYPERVISOR_physdev_op(PHYSDEVOP_apic_write, &apic_op);
 }
 
-static const struct pv_iosapic_ops xen_iosapic_ops __initconst = {
+static struct pv_iosapic_ops xen_iosapic_ops __initdata = {
 	.pcat_compat_init = xen_pcat_compat_init,
 	.__get_irq_chip = xen_iosapic_get_irq_chip,
 
-- 
1.6.0.2
