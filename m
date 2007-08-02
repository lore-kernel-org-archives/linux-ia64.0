From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 02 Aug 2007 04:29:11 +0000
Subject: [RFC][PATCH 1/2] Add base support for platform_irq_to_vector()
Message-Id: <1186028952.3875.14.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add base support for implementing platform_irq_to_vector().

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

---
 arch/ia64/kernel/irq.c          |    5 +++++
 include/asm-ia64/hw_irq.h       |    7 ++++++-
 include/asm-ia64/machvec.h      |    7 +++++++
 include/asm-ia64/machvec_init.h |    1 +
 4 files changed, 19 insertions(+), 1 deletion(-)

Index: linux-2.6.23-rc1/arch/ia64/kernel/irq.c
=================================--- linux-2.6.23-rc1.orig/arch/ia64/kernel/irq.c
+++ linux-2.6.23-rc1/arch/ia64/kernel/irq.c
@@ -33,6 +33,11 @@ void ack_bad_irq(unsigned int irq)
 }
 
 #ifdef CONFIG_IA64_GENERIC
+ia64_vector __ia64_irq_to_vector(int irq)
+{
+	return irq_cfg[irq].vector;
+}
+
 unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
 {
 	return __get_cpu_var(vector_irq)[vec];
Index: linux-2.6.23-rc1/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.23-rc1.orig/include/asm-ia64/hw_irq.h
+++ linux-2.6.23-rc1/include/asm-ia64/hw_irq.h
@@ -124,6 +124,11 @@ static inline void ia64_resend_irq(unsig
 extern irq_desc_t irq_desc[NR_IRQS];
 
 #ifndef CONFIG_IA64_GENERIC
+static inline ia64_vector __ia64_irq_to_vector(int irq)
+{
+	return irq_cfg[irq].vector;
+}
+
 static inline unsigned int
 __ia64_local_vector_to_irq (ia64_vector vec)
 {
@@ -145,7 +150,7 @@ __ia64_local_vector_to_irq (ia64_vector 
 static inline ia64_vector
 irq_to_vector (int irq)
 {
-	return irq_cfg[irq].vector;
+	return platform_irq_to_vector(irq);
 }
 
 /*
Index: linux-2.6.23-rc1/include/asm-ia64/machvec.h
=================================--- linux-2.6.23-rc1.orig/include/asm-ia64/machvec.h
+++ linux-2.6.23-rc1/include/asm-ia64/machvec.h
@@ -30,6 +30,7 @@ typedef void ia64_mv_send_ipi_t (int, in
 typedef void ia64_mv_timer_interrupt_t (int, void *);
 typedef void ia64_mv_global_tlb_purge_t (struct mm_struct *, unsigned long, unsigned long, unsigned long);
 typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
+typedef u8 ia64_mv_irq_to_vector (int);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8);
 typedef char *ia64_mv_pci_get_legacy_mem_t (struct pci_bus *);
 typedef int ia64_mv_pci_legacy_read_t (struct pci_bus *, u16 port, u32 *val,
@@ -145,6 +146,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_dma_sync_sg_for_device ia64_mv.dma_sync_sg_for_device
 #  define platform_dma_mapping_error		ia64_mv.dma_mapping_error
 #  define platform_dma_supported	ia64_mv.dma_supported
+#  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
 #  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
 #  define platform_pci_legacy_read	ia64_mv.pci_legacy_read
@@ -198,6 +200,7 @@ struct ia64_machine_vector {
 	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
 	ia64_mv_dma_mapping_error *dma_mapping_error;
 	ia64_mv_dma_supported *dma_supported;
+	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
 	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
 	ia64_mv_pci_legacy_read_t *pci_legacy_read;
@@ -247,6 +250,7 @@ struct ia64_machine_vector {
 	platform_dma_sync_sg_for_device,	\
 	platform_dma_mapping_error,			\
 	platform_dma_supported,			\
+	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
 	platform_pci_get_legacy_mem,		\
 	platform_pci_legacy_read,		\
@@ -365,6 +369,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_dma_supported
 # define  platform_dma_supported	swiotlb_dma_supported
 #endif
+#ifndef platform_irq_to_vector
+# define platform_irq_to_vector		__ia64_irq_to_vector
+#endif
 #ifndef platform_local_vector_to_irq
 # define platform_local_vector_to_irq	__ia64_local_vector_to_irq
 #endif
Index: linux-2.6.23-rc1/include/asm-ia64/machvec_init.h
=================================--- linux-2.6.23-rc1.orig/include/asm-ia64/machvec_init.h
+++ linux-2.6.23-rc1/include/asm-ia64/machvec_init.h
@@ -2,6 +2,7 @@
 
 extern ia64_mv_send_ipi_t ia64_send_ipi;
 extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
+extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
 extern ia64_mv_pci_legacy_read_t ia64_pci_legacy_read;


