From: Jack Steiner <steiner@sgi.com>
Date: Sun, 11 Jul 2004 13:47:27 +0000
Subject: [PATCH] - Reduce TLB flushing during process migration
Message-Id: <20040711134727.GA8966@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is the updated "Reduce TLB flushing during process migration" patch.

The patch is essentially the same as the previous - only updated to
fit on top of the recent machvec changes.



Signed-off-by: Jack Steiner <steiner@sgi.com>


--- linux_base/include/asm-ia64/machvec_sn2.h	2004-07-10 17:12:14.000000000 -0500
+++ linux/include/asm-ia64/machvec_sn2.h	2004-07-10 19:14:00.000000000 -0500
@@ -39,6 +39,7 @@ extern ia64_mv_irq_init_t sn_irq_init;
 extern ia64_mv_send_ipi_t sn2_send_IPI;
 extern ia64_mv_timer_interrupt_t sn_timer_interrupt;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
+extern ia64_mv_tlb_migrate_finish_t	sn_tlb_migrate_finish;
 extern ia64_mv_irq_desc sn_irq_desc;
 extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
@@ -83,6 +84,7 @@ extern ia64_mv_dma_supported		sn_dma_sup
 #define platform_send_ipi		sn2_send_IPI
 #define platform_timer_interrupt	sn_timer_interrupt
 #define platform_global_tlb_purge       sn2_global_tlb_purge
+#define platform_tlb_migrate_finish	sn_tlb_migrate_finish
 #define platform_pci_fixup		sn_pci_fixup
 #define platform_inb			__sn_inb
 #define platform_inw			__sn_inw
--- linux_base/include/asm-generic/tlb.h	2004-07-10 17:12:13.000000000 -0500
+++ linux/include/asm-generic/tlb.h	2004-07-10 19:14:00.000000000 -0500
@@ -147,4 +147,6 @@ static inline void tlb_remove_page(struc
 		__pmd_free_tlb(tlb, pmdp);			\
 	} while (0)
 
+#define tlb_migrate_finish(mm) do {} while (0)
+
 #endif /* _ASM_GENERIC__TLB_H */
--- linux_base/Documentation/cachetlb.txt	2004-07-10 17:12:03.000000000 -0500
+++ linux/Documentation/cachetlb.txt	2004-07-10 19:14:00.000000000 -0500
@@ -132,6 +132,17 @@ changes occur:
 	translations for software managed TLB configurations.
 	The sparc64 port currently does this.
 
+7) void tlb_migrate_finish(struct mm_struct *mm)
+
+	This interface is called at the end of an explicit
+	process migration. This interface provides a hook 
+	to allow a platform to update TLB or context-specific 
+	information for the address space.
+
+	The ia64 sn2 platform is one example of a platform
+	that uses this interface.
+
+
 Next, we have the cache flushing interfaces.  In general, when Linux
 is changing an existing virtual-->physical mapping to a new value,
 the sequence will be in one of the following forms:
--- linux_base/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-07-10 17:12:04.000000000 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-07-10 19:14:00.000000000 -0500
@@ -27,6 +27,7 @@
 #include <asm/delay.h>
 #include <asm/io.h>
 #include <asm/smp.h>
+#include <asm/tlb.h>
 #include <asm/numa.h>
 #include <asm/bitops.h>
 #include <asm/hw_irq.h>
@@ -60,6 +61,13 @@ wait_piowc(void)
 }
 
 
+void
+sn_tlb_migrate_finish(struct mm_struct *mm)
+{
+	if (mm = current->mm)
+		flush_tlb_mm(mm);
+}
+
 
 /**
  * sn2_global_tlb_purge - globally purge translation cache of virtual address range
@@ -114,6 +122,13 @@ sn2_global_tlb_purge (unsigned long star
 		return;
 	}
 
+	if (atomic_read(&mm->mm_users) = 1) {
+		flush_tlb_mm(mm);
+		preempt_enable();
+		return;
+	}
+
+
 	nix = 0;
 	for (cnode=find_first_bit(&nodes_flushed, NR_NODES); cnode < NR_NODES; 
 			cnode=find_next_bit(&nodes_flushed, NR_NODES, ++cnode))
--- linux_base/kernel/sched.c	2004-07-10 17:12:17.000000000 -0500
+++ linux/kernel/sched.c	2004-07-10 19:14:00.000000000 -0500
@@ -40,6 +40,7 @@
 #include <linux/cpu.h>
 #include <linux/percpu.h>
 #include <linux/kthread.h>
+#include <asm/tlb.h>
 
 #include <asm/unistd.h>
 
@@ -3349,6 +3350,7 @@ int set_cpus_allowed(task_t *p, cpumask_
 		task_rq_unlock(rq, &flags);
 		wake_up_process(rq->migration_thread);
 		wait_for_completion(&req.done);
+		tlb_migrate_finish(p->mm);
 		return 0;
 	}
 out:
--- linux_base/include/asm-ia64/tlb.h	2004-07-10 17:12:14.000000000 -0500
+++ linux/include/asm-ia64/tlb.h	2004-07-10 19:14:00.000000000 -0500
@@ -44,6 +44,7 @@
 #include <asm/pgalloc.h>
 #include <asm/processor.h>
 #include <asm/tlbflush.h>
+#include <asm/machvec.h>
 
 #ifdef CONFIG_SMP
 # define FREE_PTE_NR		2048
@@ -211,6 +212,8 @@ __tlb_remove_tlb_entry (struct mmu_gathe
 	tlb->end_addr = address + PAGE_SIZE;
 }
 
+#define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
+
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
 
--- linux_base/include/asm-ia64/machvec.h	2004-07-10 17:12:14.000000000 -0500
+++ linux/include/asm-ia64/machvec.h	2004-07-10 19:14:00.000000000 -0500
@@ -19,6 +19,7 @@ struct pt_regs;
 struct scatterlist;
 struct irq_desc;
 struct page;
+struct mm_struct;
 
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t (void);
@@ -26,6 +27,7 @@ typedef void ia64_mv_irq_init_t (void);
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
 typedef void ia64_mv_timer_interrupt_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
+typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
 typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
 typedef u8 ia64_mv_irq_to_vector (u8);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8 vector);
@@ -74,10 +76,16 @@ machvec_noop (void)
 {
 }
 
+static inline void
+machvec_noop_mm (struct mm_struct *mm)
+{
+}
+
 extern void machvec_setup (char **);
 extern void machvec_timer_interrupt (int, void *, struct pt_regs *);
 extern void machvec_dma_sync_single (struct device *, dma_addr_t, size_t, int);
 extern void machvec_dma_sync_sg (struct device *, struct scatterlist *, int, int);
+extern void machvec_tlb_migrate_finish (struct mm_struct *);
 
 # if defined (CONFIG_IA64_HP_SIM)
 #  include <asm/machvec_hpsim.h>
@@ -99,6 +107,7 @@ extern void machvec_dma_sync_sg (struct 
 #  define platform_send_ipi	ia64_mv.send_ipi
 #  define platform_timer_interrupt	ia64_mv.timer_interrupt
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
+#  define platform_tlb_migrate_finish	ia64_mv.tlb_migrate_finish
 #  define platform_dma_init		ia64_mv.dma_init
 #  define platform_dma_alloc_coherent	ia64_mv.dma_alloc_coherent
 #  define platform_dma_free_coherent	ia64_mv.dma_free_coherent
@@ -144,6 +153,7 @@ struct ia64_machine_vector {
 	ia64_mv_send_ipi_t *send_ipi;
 	ia64_mv_timer_interrupt_t *timer_interrupt;
 	ia64_mv_global_tlb_purge_t *global_tlb_purge;
+	ia64_mv_tlb_migrate_finish_t *tlb_migrate_finish;
 	ia64_mv_dma_init *dma_init;
 	ia64_mv_dma_alloc_coherent *dma_alloc_coherent;
 	ia64_mv_dma_free_coherent *dma_free_coherent;
@@ -185,6 +195,7 @@ struct ia64_machine_vector {
 	platform_send_ipi,			\
 	platform_timer_interrupt,		\
 	platform_global_tlb_purge,		\
+	platform_tlb_migrate_finish,		\
 	platform_dma_init,			\
 	platform_dma_alloc_coherent,		\
 	platform_dma_free_coherent,		\
@@ -264,6 +275,9 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_global_tlb_purge
 # define platform_global_tlb_purge	ia64_global_tlb_purge /* default to architected version */
 #endif
+#ifndef platform_tlb_migrate_finish
+# define platform_tlb_migrate_finish	machvec_noop_mm
+#endif
 #ifndef platform_dma_init
 # define platform_dma_init		swiotlb_init
 #endif
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


