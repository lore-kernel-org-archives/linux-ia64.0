From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:38:51 +0000
Subject: [PATCH 02/15] __initdata and const cannot be always a happy pair, as gcc-4.3.3 gives
Message-Id: <1229063944-27462-3-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  arch/ia64/xen/xen_pv_ops.c:156: error: xen_init_ops causes a section type conflict
  arch/ia64/xen/xen_pv_ops.c:340: error: xen_iosapic_ops causes a section type conflict

This patch simply removes const from data with __initdata.

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 arch/ia64/xen/xen_pv_ops.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/xen/xen_pv_ops.c b/arch/ia64/xen/xen_pv_ops.c
index 04cd123..5d491d9 100644
--- a/arch/ia64/xen/xen_pv_ops.c
+++ b/arch/ia64/xen/xen_pv_ops.c
@@ -153,7 +153,7 @@ xen_post_smp_prepare_boot_cpu(void)
 	xen_setup_vcpu_info_placement();
 }
 
-static const struct pv_init_ops xen_init_ops __initdata = {
+static struct pv_init_ops xen_init_ops __initdata = {
 	.banner = xen_banner,
 
 	.reserve_memory = xen_reserve_memory,
@@ -260,7 +260,7 @@ xen_intrin_local_irq_restore(unsigned long mask)
 		xen_rsm_i();
 }
 
-static const struct pv_cpu_ops xen_cpu_ops __initdata = {
+static struct pv_cpu_ops xen_cpu_ops __initdata = {
 	.fc		= xen_fc,
 	.thash		= xen_thash,
 	.get_cpuid	= xen_get_cpuid,
@@ -337,7 +337,7 @@ xen_iosapic_write(char __iomem *iosapic, unsigned int reg, u32 val)
 	HYPERVISOR_physdev_op(PHYSDEVOP_apic_write, &apic_op);
 }
 
-static const struct pv_iosapic_ops xen_iosapic_ops __initdata = {
+static struct pv_iosapic_ops xen_iosapic_ops __initdata = {
 	.pcat_compat_init = xen_pcat_compat_init,
 	.__get_irq_chip = xen_iosapic_get_irq_chip,
 
-- 
1.6.0.2

