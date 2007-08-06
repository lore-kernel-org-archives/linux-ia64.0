From: John Keller <jpk@sgi.com>
Date: Mon, 06 Aug 2007 13:59:39 +0000
Subject: Re: [RFC][PATCH 0/2] SN platform needs platform_irq_to_vector?
Message-Id: <200708061359.l76DxeBm447857@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1186028871.3875.12.camel@kane-linux>
In-Reply-To: <1186028871.3875.12.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> > Thanks for the info.
> > Your patch looks good to me, along with the other change to
> > sn_irq_to_vector().
> 
> Sounds like an Ack ... can one of you fold the changes into a new
> patch please.
> 
> -Tony

This is the patch as I was running it.



Add base support for implementing platform_irq_to_vector().

Acked-by: John Keller <jpk@sgi.com>

---
 arch/ia64/kernel/irq.c          |    5 +++++
 arch/ia64/sn/kernel/irq.c       |    7 +++++++
 include/asm-ia64/hw_irq.h       |    7 ++++++-
 include/asm-ia64/machvec.h      |    7 +++++++
 include/asm-ia64/machvec_init.h |    1 +
 include/asm-ia64/machvec_sn2.h  |    2 ++
 6 files changed, 28 insertions(+), 1 deletion(-)

Index: linux-2.6/arch/ia64/kernel/irq.c
=================================--- linux-2.6.orig/arch/ia64/kernel/irq.c	2007-08-04 18:45:15.705972596 -0500
+++ linux-2.6/arch/ia64/kernel/irq.c	2007-08-04 18:45:43.197343168 -0500
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
Index: linux-2.6/include/asm-ia64/hw_irq.h
=================================--- linux-2.6.orig/include/asm-ia64/hw_irq.h	2007-08-04 18:45:15.705972596 -0500
+++ linux-2.6/include/asm-ia64/hw_irq.h	2007-08-04 18:45:43.217345621 -0500
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
Index: linux-2.6/include/asm-ia64/machvec.h
=================================--- linux-2.6.orig/include/asm-ia64/machvec.h	2007-08-04 18:45:15.709973086 -0500
+++ linux-2.6/include/asm-ia64/machvec.h	2007-08-04 18:45:43.237348073 -0500
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
@@ -366,6 +370,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_dma_supported
 # define  platform_dma_supported	swiotlb_dma_supported
 #endif
+#ifndef platform_irq_to_vector
+# define platform_irq_to_vector		__ia64_irq_to_vector
+#endif
 #ifndef platform_local_vector_to_irq
 # define platform_local_vector_to_irq	__ia64_local_vector_to_irq
 #endif
Index: linux-2.6/include/asm-ia64/machvec_init.h
=================================--- linux-2.6.orig/include/asm-ia64/machvec_init.h	2007-08-04 18:45:15.709973086 -0500
+++ linux-2.6/include/asm-ia64/machvec_init.h	2007-08-04 18:45:43.253350035 -0500
@@ -2,6 +2,7 @@
 
 extern ia64_mv_send_ipi_t ia64_send_ipi;
 extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
+extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
 extern ia64_mv_pci_legacy_read_t ia64_pci_legacy_read;
Index: linux-2.6/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/irq.c	2007-08-04 18:45:15.705972596 -0500
+++ linux-2.6/arch/ia64/sn/kernel/irq.c	2007-08-04 18:45:43.273352487 -0500
@@ -256,6 +256,13 @@ struct irq_chip irq_type_sn = {
 	.set_affinity	= sn_set_affinity_irq
 };
 
+ia64_vector sn_irq_to_vector(int irq)
+{
+	if (irq >= IA64_NUM_VECTORS)
+		return 0;
+	return (ia64_vector)irq;
+}
+
 unsigned int sn_local_vector_to_irq(u8 vector)
 {
 	return (CPU_VECTOR_TO_IRQ(smp_processor_id(), vector));
Index: linux-2.6/include/asm-ia64/machvec_sn2.h
=================================--- linux-2.6.orig/include/asm-ia64/machvec_sn2.h	2007-08-04 18:45:15.709973086 -0500
+++ linux-2.6/include/asm-ia64/machvec_sn2.h	2007-08-04 18:45:43.289354449 -0500
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
