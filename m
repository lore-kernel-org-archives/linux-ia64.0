From: Jack Steiner <steiner@sgi.com>
Date: Sat, 22 May 2004 12:11:59 +0000
Subject: Re: [PATCH]  Reduce TLB flushing during process migration
Message-Id: <20040522121159.GB19454@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 12, 2004 at 03:08:36PM -0700, Andrew Morton wrote:
> David Mosberger <davidm@napali.hpl.hp.com> wrote:
> >
> > Please remove it until a proper solution exists.
> 
> I'll submit this on Friday, when bugalugs returns.
> 

Here is an updated patch for flushing the TLB on SN2 after a process
migration. The patch is based on the latest "//linux.bkbits.net/linux-2.5"
bitkeeper tree.

-------------------------------------

--- linuxbase/kernel/sched.c	2004-05-21 20:47:33.000000000 -0500
+++ linux/kernel/sched.c	2004-05-21 22:42:39.000000000 -0500
@@ -40,6 +40,7 @@
 #include <linux/cpu.h>
 #include <linux/percpu.h>
 #include <linux/kthread.h>
+#include <asm/tlb.h>
 
 #ifdef CONFIG_NUMA
 #define cpu_to_node_mask(cpu) node_to_cpumask(cpu_to_node(cpu))
@@ -1311,6 +1312,7 @@
 		wake_up_process(mt);
 		put_task_struct(mt);
 		wait_for_completion(&req.done);
+		tlb_migrate_finish(p->mm);
 		return;
 	}
 out:
@@ -3317,6 +3319,7 @@
 		task_rq_unlock(rq, &flags);
 		wake_up_process(rq->migration_thread);
 		wait_for_completion(&req.done);
+		tlb_migrate_finish(p->mm);
 		return 0;
 	}
 out:
--- linuxbase/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-05-21 20:47:20.000000000 -0500
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2004-05-21 20:48:25.000000000 -0500
@@ -27,6 +27,7 @@
 #include <asm/delay.h>
 #include <asm/io.h>
 #include <asm/smp.h>
+#include <asm/tlb.h>
 #include <asm/numa.h>
 #include <asm/bitops.h>
 #include <asm/hw_irq.h>
@@ -60,6 +61,13 @@
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
@@ -114,6 +122,13 @@
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
--- linuxbase/arch/ia64/kernel/machvec.c	2004-05-21 20:47:20.000000000 -0500
+++ linux/arch/ia64/kernel/machvec.c	2004-05-21 20:48:25.000000000 -0500
@@ -62,6 +62,12 @@
 EXPORT_SYMBOL(machvec_timer_interrupt);
 
 void
+machvec_tlb_migrate_finish (struct mm_struct *mm)
+{
+}
+EXPORT_SYMBOL(machvec_tlb_migrate_finish);
+
+void
 machvec_dma_sync_single (struct device *hwdev, dma_addr_t dma_handle, size_t size, int dir)
 {
 	mb();
--- linuxbase/include/asm-generic/tlb.h	2004-05-21 20:47:28.000000000 -0500
+++ linux/include/asm-generic/tlb.h	2004-05-21 20:48:25.000000000 -0500
@@ -146,4 +146,6 @@
 		__pmd_free_tlb(tlb, pmdp);			\
 	} while (0)
 
+#define tlb_migrate_finish(mm) flush_tlb_mm(mm)
+
 #endif /* _ASM_GENERIC__TLB_H */
--- linuxbase/include/asm-ia64/tlb.h	2004-05-21 20:47:29.000000000 -0500
+++ linux/include/asm-ia64/tlb.h	2004-05-21 20:48:25.000000000 -0500
@@ -44,6 +44,7 @@
 #include <asm/pgalloc.h>
 #include <asm/processor.h>
 #include <asm/tlbflush.h>
+#include <asm/machvec.h>
 
 #ifdef CONFIG_SMP
 # define FREE_PTE_NR		2048
@@ -211,6 +212,8 @@
 	tlb->end_addr = address + PAGE_SIZE;
 }
 
+#define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
+
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
 
--- linuxbase/include/asm-ia64/machvec.h	2004-05-21 20:47:29.000000000 -0500
+++ linux/include/asm-ia64/machvec.h	2004-05-21 20:48:25.000000000 -0500
@@ -19,6 +19,7 @@
 struct scatterlist;
 struct irq_desc;
 struct page;
+struct mm_struct;
 
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t (void);
@@ -26,6 +27,7 @@
 typedef void ia64_mv_send_ipi_t (int, int, int, int);
 typedef void ia64_mv_timer_interrupt_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
+typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
 typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
 typedef u8 ia64_mv_irq_to_vector (u8);
 typedef unsigned int ia64_mv_local_vector_to_irq (u8 vector);
@@ -72,6 +74,7 @@
 extern void machvec_noop (void);
 extern void machvec_setup (char **);
 extern void machvec_timer_interrupt (int, void *, struct pt_regs *);
+extern void machvec_tlb_migrate_finish (struct mm_struct *);
 extern void machvec_dma_sync_single (struct device *, dma_addr_t, size_t, int);
 extern void machvec_dma_sync_sg (struct device *, struct scatterlist *, int, int);
 
@@ -95,6 +98,7 @@
 #  define platform_send_ipi	ia64_mv.send_ipi
 #  define platform_timer_interrupt	ia64_mv.timer_interrupt
 #  define platform_global_tlb_purge	ia64_mv.global_tlb_purge
+#  define platform_tlb_migrate_finish	ia64_mv.tlb_migrate_finish
 #  define platform_dma_init		ia64_mv.dma_init
 #  define platform_dma_alloc_coherent	ia64_mv.dma_alloc_coherent
 #  define platform_dma_free_coherent	ia64_mv.dma_free_coherent
@@ -140,6 +144,7 @@
 	ia64_mv_send_ipi_t *send_ipi;
 	ia64_mv_timer_interrupt_t *timer_interrupt;
 	ia64_mv_global_tlb_purge_t *global_tlb_purge;
+	ia64_mv_tlb_migrate_finish_t *tlb_migrate_finish;
 	ia64_mv_dma_init *dma_init;
 	ia64_mv_dma_alloc_coherent *dma_alloc_coherent;
 	ia64_mv_dma_free_coherent *dma_free_coherent;
@@ -181,6 +186,7 @@
 	platform_send_ipi,			\
 	platform_timer_interrupt,		\
 	platform_global_tlb_purge,		\
+	platform_tlb_migrate_finish,		\
 	platform_dma_init,			\
 	platform_dma_alloc_coherent,		\
 	platform_dma_free_coherent,		\
@@ -260,6 +266,9 @@
 #ifndef platform_global_tlb_purge
 # define platform_global_tlb_purge	ia64_global_tlb_purge /* default to architected version */
 #endif
+#ifndef platform_tlb_migrate_finish
+# define platform_tlb_migrate_finish machvec_tlb_migrate_finish
+#endif
 #ifndef platform_dma_init
 # define platform_dma_init		swiotlb_init
 #endif
--- linuxbase/include/asm-ia64/machvec_sn2.h	2004-05-21 20:47:29.000000000 -0500
+++ linux/include/asm-ia64/machvec_sn2.h	2004-05-21 20:48:25.000000000 -0500
@@ -39,6 +39,7 @@
 extern ia64_mv_send_ipi_t sn2_send_IPI;
 extern ia64_mv_timer_interrupt_t sn_timer_interrupt;
 extern ia64_mv_global_tlb_purge_t sn2_global_tlb_purge;
+extern ia64_mv_tlb_migrate_finish_t	sn_tlb_migrate_finish;
 extern ia64_mv_irq_desc sn_irq_desc;
 extern ia64_mv_irq_to_vector sn_irq_to_vector;
 extern ia64_mv_local_vector_to_irq sn_local_vector_to_irq;
@@ -83,6 +84,7 @@
 #define platform_send_ipi		sn2_send_IPI
 #define platform_timer_interrupt	sn_timer_interrupt
 #define platform_global_tlb_purge       sn2_global_tlb_purge
+#define platform_tlb_migrate_finish	sn_tlb_migrate_finish
 #define platform_pci_fixup		sn_pci_fixup
 #define platform_inb			__sn_inb
 #define platform_inw			__sn_inw
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


