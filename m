From: Christoph Hellwig <hch@lst.de>
Date: Fri, 21 Jan 2005 16:27:09 +0000
Subject: [PATCH] ia64: irq handling cleanup
Message-Id: <20050121162709.GA26096@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

 - irq_desc and irq_to_vector machvecs.  SN2 has it's own versions,
    but they're the same as the generic ones
 - kill do do_IRQ and use __do_IRQ directly everywhere
 - kill dead X86 ifdefs
 - move some variable declarations around in irq.c to recuce # of ifdefs


--- 1.54/arch/ia64/kernel/irq.c	2005-01-18 21:06:18 +01:00
+++ edited/arch/ia64/kernel/irq.c	2005-01-20 17:34:07 +01:00
@@ -32,35 +32,7 @@
 	printk(KERN_ERR "Unexpected irq vector 0x%x on CPU %u!\n", irq, smp_processor_id());
 }
 
-/*
- * do_IRQ handles all normal device IRQ's (the special
- * SMP cross-CPU interrupts have their own specific
- * handlers).
- */
-unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs)
-{
-	return __do_IRQ(irq, regs);
-}
-
-#ifdef CONFIG_SMP
-/*
- * This is updated when the user sets irq affinity via /proc
- */
-cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
-static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
-#endif
-
 #ifdef CONFIG_IA64_GENERIC
-irq_desc_t * __ia64_irq_desc (unsigned int irq)
-{
-	return irq_desc + irq;
-}
-
-ia64_vector __ia64_irq_to_vector (unsigned int irq)
-{
-	return (ia64_vector) irq;
-}
-
 unsigned int __ia64_local_vector_to_irq (ia64_vector vec)
 {
 	return (unsigned int) vec;
@@ -113,27 +85,19 @@
 		seq_putc(p, '\n');
 skip:
 		spin_unlock_irqrestore(&irq_desc[i].lock, flags);
-	} else if (i = NR_IRQS) {
-#if defined(CONFIG_X86_LOCAL_APIC)
-		seq_puts(p, "LOC: ");
-		for (j = 0; j < NR_CPUS; j++)
-			if (cpu_online(j))
-				seq_printf(p, "%10u ",
-					   irq_stat[j].apic_timer_irqs);
-		seq_putc(p, '\n');
-#endif
+	} else if (i = NR_IRQS)
 		seq_printf(p, "ERR: %10u\n", atomic_read(&irq_err_count));
-#if defined(CONFIG_X86_IO_APIC)
-		seq_printf(p, "MIS: %10u\n", atomic_read(&irq_mis_count));
-#endif
-	}
 	return 0;
 }
 
 #ifdef CONFIG_SMP
+/*
+ * This is updated when the user sets irq affinity via /proc
+ */
+cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
+static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
 
 static cpumask_t irq_affinity [NR_IRQS] = { [0 ... NR_IRQS-1] = CPU_MASK_ALL };
-
 static char irq_redir [NR_IRQS]; // = { [0 ... NR_IRQS-1] = 1 };
 
 void set_irq_affinity_info (unsigned int irq, int hwid, int redir)
@@ -250,7 +214,7 @@
 	for (irq=0; irq < NR_IRQS; irq++) {
 		if (vectors_in_migration[irq]) {
 			vectors_in_migration[irq]=0;
-			do_IRQ(irq, NULL);
+			__do_IRQ(irq, NULL);
 		}
 	}
 
=== arch/ia64/kernel/irq_ia64.c 1.24 vs edited ==--- 1.24/arch/ia64/kernel/irq_ia64.c	2005-01-18 21:27:58 +01:00
+++ edited/arch/ia64/kernel/irq_ia64.c	2005-01-20 17:33:08 +01:00
@@ -90,8 +90,6 @@
 		printk(KERN_WARNING "%s: double free!\n", __FUNCTION__);
 }
 
-extern unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs);
-
 #ifdef CONFIG_SMP
 #	define IS_RESCHEDULE(vec)	(vec = IA64_IPI_RESCHEDULE)
 #else
@@ -150,7 +148,7 @@
 			ia64_setreg(_IA64_REG_CR_TPR, vector);
 			ia64_srlz_d();
 
-			do_IRQ(local_vector_to_irq(vector), regs);
+			__do_IRQ(local_vector_to_irq(vector), regs);
 
 			/*
 			 * Disable interrupts and send EOI:
@@ -201,7 +199,7 @@
 			 * Probably could shared code.
 			 */
 			vectors_in_migration[local_vector_to_irq(vector)]=0;
-			do_IRQ(local_vector_to_irq(vector), NULL);
+			__do_IRQ(local_vector_to_irq(vector), NULL);
 
 			/*
 			 * Disable interrupts and send EOI
=== arch/ia64/sn/kernel/irq.c 1.29 vs edited ==--- 1.29/arch/ia64/sn/kernel/irq.c	2004-11-24 00:45:34 +01:00
+++ edited/arch/ia64/sn/kernel/irq.c	2005-01-20 17:29:46 +01:00
@@ -202,16 +202,6 @@
 	sn_set_affinity_irq
 };
 
-struct irq_desc *sn_irq_desc(unsigned int irq)
-{
-	return (irq_desc + irq);
-}
-
-u8 sn_irq_to_vector(unsigned int irq)
-{
-	return irq;
-}
-
 unsigned int sn_local_vector_to_irq(u8 vector)
 {
 	return (CPU_VECTOR_TO_IRQ(smp_processor_id(), vector));
=== include/asm-ia64/hw_irq.h 1.14 vs edited ==--- 1.14/include/asm-ia64/hw_irq.h	2005-01-18 21:06:19 +01:00
+++ edited/include/asm-ia64/hw_irq.h	2005-01-20 17:30:45 +01:00
@@ -99,18 +99,6 @@
 extern irq_desc_t irq_desc[NR_IRQS];
 
 #ifndef CONFIG_IA64_GENERIC
-static inline irq_desc_t *
-__ia64_irq_desc (unsigned int irq)
-{
-	return irq_desc + irq;
-}
-
-static inline ia64_vector
-__ia64_irq_to_vector (unsigned int irq)
-{
-	return (ia64_vector) irq;
-}
-
 static inline unsigned int
 __ia64_local_vector_to_irq (ia64_vector vec)
 {
@@ -132,14 +120,14 @@
 static inline irq_desc_t *
 irq_descp (int irq)
 {
-	return platform_irq_desc(irq);
+	return irq_desc + irq;
 }
 
 /* Extract the IA-64 vector that corresponds to IRQ.  */
 static inline ia64_vector
 irq_to_vector (int irq)
 {
-	return platform_irq_to_vector(irq);
+	return (ia64_vector) irq;
 }
 
 /*
=== include/asm-ia64/machvec.h 1.31 vs edited ==--- 1.31/include/asm-ia64/machvec.h	2005-01-10 23:04:10 +01:00
+++ edited/include/asm-ia64/machvec.h	2005-01-20 17:31:00 +01:00
@@ -17,7 +17,6 @@
 struct device;
 struct pt_regs;
 struct scatterlist;
-struct irq_desc;
 struct page;
 struct mm_struct;
 struct pci_bus;
@@ -29,8 +28,6 @@
 typedef void ia64_mv_timer_interrupt_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
 typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
-typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
-typedef u8 ia64_mv_irq_to_vector (unsigned int);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8);
 typedef char *ia64_mv_pci_get_legacy_mem_t (struct pci_bus *);
 typedef int ia64_mv_pci_legacy_read_t (struct pci_bus *, u16 port, u32 *val,
@@ -130,8 +127,6 @@
 #  define platform_dma_sync_sg_for_device ia64_mv.dma_sync_sg_for_device
 #  define platform_dma_mapping_error		ia64_mv.dma_mapping_error
 #  define platform_dma_supported	ia64_mv.dma_supported
-#  define platform_irq_desc		ia64_mv.irq_desc
-#  define platform_irq_to_vector	ia64_mv.irq_to_vector
 #  define platform_local_vector_to_irq	ia64_mv.local_vector_to_irq
 #  define platform_pci_get_legacy_mem	ia64_mv.pci_get_legacy_mem
 #  define platform_pci_legacy_read	ia64_mv.pci_legacy_read
@@ -180,8 +175,6 @@
 	ia64_mv_dma_sync_sg_for_device *dma_sync_sg_for_device;
 	ia64_mv_dma_mapping_error *dma_mapping_error;
 	ia64_mv_dma_supported *dma_supported;
-	ia64_mv_irq_desc *irq_desc;
-	ia64_mv_irq_to_vector *irq_to_vector;
 	ia64_mv_local_vector_to_irq *local_vector_to_irq;
 	ia64_mv_pci_get_legacy_mem_t *pci_get_legacy_mem;
 	ia64_mv_pci_legacy_read_t *pci_legacy_read;
@@ -226,8 +219,6 @@
 	platform_dma_sync_sg_for_device,	\
 	platform_dma_mapping_error,			\
 	platform_dma_supported,			\
-	platform_irq_desc,			\
-	platform_irq_to_vector,			\
 	platform_local_vector_to_irq,		\
 	platform_pci_get_legacy_mem,		\
 	platform_pci_legacy_read,		\
@@ -337,12 +328,6 @@
 #endif
 #ifndef platform_dma_supported
 # define  platform_dma_supported	swiotlb_dma_supported
-#endif
-#ifndef platform_irq_desc
-# define platform_irq_desc		__ia64_irq_desc
-#endif
-#ifndef platform_irq_to_vector
-# define platform_irq_to_vector		__ia64_irq_to_vector
 #endif
 #ifndef platform_local_vector_to_irq
 # define platform_local_vector_to_irq	__ia64_local_vector_to_irq
=== include/asm-ia64/machvec_init.h 1.9 vs edited ==--- 1.9/include/asm-ia64/machvec_init.h	2005-01-10 23:04:16 +01:00
+++ edited/include/asm-ia64/machvec_init.h	2005-01-20 17:31:04 +01:00
@@ -2,8 +2,6 @@
 
 extern ia64_mv_send_ipi_t ia64_send_ipi;
 extern ia64_mv_global_tlb_purge_t ia64_global_tlb_purge;
-extern ia64_mv_irq_desc __ia64_irq_desc;
-extern ia64_mv_irq_to_vector __ia64_irq_to_vector;
 extern ia64_mv_local_vector_to_irq __ia64_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t ia64_pci_get_legacy_mem;
 extern ia64_mv_pci_legacy_read_t ia64_pci_legacy_read;
=== include/asm-ia64/machvec_sn2.h 1.17 vs edited ==--- 1.17/include/asm-ia64/machvec_sn2.h	2005-01-10 23:04:23 +01:00
+++ edited/include/asm-ia64/machvec_sn2.h	2005-01-20 17:30:06 +01:00
@@ -40,8 +40,6 @@
 extern ia64_mv_timer_interrupt_t sn_timer_interrupt;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
 extern ia64_mv_tlb_migrate_finish_t	sn_tlb_migrate_finish;
-extern ia64_mv_irq_desc sn_irq_desc;
-extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
 extern ia64_mv_pci_get_legacy_mem_t sn_pci_get_legacy_mem;
 extern ia64_mv_pci_legacy_read_t sn_pci_legacy_read;
@@ -105,8 +103,6 @@
 #define platform_readw_relaxed		__sn_readw_relaxed
 #define platform_readl_relaxed		__sn_readl_relaxed
 #define platform_readq_relaxed		__sn_readq_relaxed
-#define platform_irq_desc		sn_irq_desc
-#define platform_irq_to_vector		sn_irq_to_vector
 #define platform_local_vector_to_irq	sn_local_vector_to_irq
 #define platform_pci_get_legacy_mem	sn_pci_get_legacy_mem
 #define platform_pci_legacy_read	sn_pci_legacy_read
