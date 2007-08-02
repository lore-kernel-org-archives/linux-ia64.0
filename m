From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 02 Aug 2007 04:30:46 +0000
Subject: [RFC][PATCH 2/2] Implement platform_irq_to_vector() for SN
Message-Id: <1186029046.3875.17.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Implement platform_irq_to_vector() for SN platform.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/sn/kernel/irq.c      |    5 +++++
 include/asm-ia64/machvec_sn2.h |    2 ++
 2 files changed, 7 insertions(+)

Index: linux-2.6.23-rc1/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6.23-rc1/arch/ia64/sn/kernel/irq.c
@@ -256,6 +256,11 @@ struct irq_chip irq_type_sn = {
 	.set_affinity	= sn_set_affinity_irq
 };
 
+ia64_vector sn_irq_to_vector(int irq)
+{
+	return (ia64_vector)irq;
+}
+
 unsigned int sn_local_vector_to_irq(u8 vector)
 {
 	return (CPU_VECTOR_TO_IRQ(smp_processor_id(), vector));
Index: linux-2.6.23-rc1/include/asm-ia64/machvec_sn2.h
=================================--- linux-2.6.23-rc1.orig/include/asm-ia64/machvec_sn2.h
+++ linux-2.6.23-rc1/include/asm-ia64/machvec_sn2.h
@@ -35,6 +35,7 @@ extern ia64_mv_send_ipi_t sn2_send_IPI;
 extern ia64_mv_timer_interrupt_t sn_timer_interrupt;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
 extern ia64_mv_tlb_migrate_finish_t	sn_tlb_migrate_finish;
+extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t sn_pci_get_legacy_mem;
 extern ia64_mv_pci_legacy_read_t sn_pci_legacy_read;
@@ -104,6 +105,7 @@ extern ia64_mv_pci_fixup_bus_t		sn_pci_f
 #define platform_readw_relaxed		__sn_readw_relaxed
 #define platform_readl_relaxed		__sn_readl_relaxed
 #define platform_readq_relaxed		__sn_readq_relaxed
+#define platform_irq_to_vector		sn_irq_to_vector
 #define platform_local_vector_to_irq	sn_local_vector_to_irq
 #define platform_pci_get_legacy_mem	sn_pci_get_legacy_mem
 #define platform_pci_legacy_read	sn_pci_legacy_read


