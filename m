From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 21:12:48 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060124113508.U90635@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 24 Jan 2006, Luck, Tony wrote:

> As coded the comparison wasn't inline, it was inside the machvec function,
> so we'd have to make an indirect function call in order to make the
> comparison and then do nothing most of the time.  I'd be happier with:

Yeah, sorry about that.  Should have occurred to me.

>     if (unlikely(foo != bar)) /* migration */
> 	platform_switch_from(next);

The new patch below implements pretty much exactly that.  I'm not
thrilled about carrying around the thread_info.last_cpu field even
on non-SN2, but making the presence/updating of the field conditional
led to huge headaches in the "should we call platform_switch_from"
conditionals/logic.

> But I'd also like to see how invasive a "task has migrated" bit in
> thread_info.flags (as suggested elsewhere in this thread) gets to
> be.

I'll be happy to do this if you really want.  That said, having stared
at this code enough now, I don't believe it would be a better solution.
The migrated bit is useful only if we don't track the last CPU the thread
ran on (which we need to do anyway, in order to know which Shub needs
to be drained of PIO writes).

Implementing the migrated bit would require an arch hook in the main
scheduler to set the bit in most places that set_task_cpu() is called.
The bit would then be tested and acted upon in close to the same place
the patch below.  The patch below is optimal with respect to how often
it calls platfrom_switch_from(), short of going through the complexity
of adding a "user MMIO mappings" counter to the mm struct and managing
the counter in relevant drivers.

So, does this look better?

Brent

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index e510dce..a687260 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1999,2001-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1999,2001-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/config.h>
@@ -654,7 +654,8 @@ void __init sn_cpu_init(void)
 			SH2_PIO_WRITE_STATUS_1, SH2_PIO_WRITE_STATUS_3};
 		u64 *pio;
 		pio = is_shub1() ? pio1 : pio2;
-		pda->pio_write_status_addr = (volatile unsigned long *) LOCAL_MMR_ADDR(pio[slice]);
+		pda->pio_write_status_addr = (volatile unsigned long *)
+			GLOBAL_MMR_ADDR(nasid, pio[slice]);
 		pda->pio_write_status_val = is_shub1() ? SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK : 0;
 	}
 
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 471bbaa..e8addd4 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/init.h>
@@ -169,6 +169,26 @@ static inline unsigned long wait_piowc(v
 	return ws;
 }
 
+/**
+ * sn_switch_from - SN-specific migrate-from actions
+ * @task: Task being switched to new CPU
+ * 
+ * SN2 PIO writes from separate CPUs are not guaranteed to arrive in order.
+ * Context switching user threads which have memory-mapped MMIO may cause
+ * PIOs to issue from seperate CPUs, thus the PIO writes must be drained
+ * from the previous CPU's Shub before execution resumes on the new CPU.
+ */
+void sn_switch_from(struct task_struct *task)
+{
+	pda_t *last_pda = pdacpu(task_thread_info(task)->last_cpu);
+	volatile unsigned long *adr = last_pda->pio_write_status_addr;
+	unsigned long val = last_pda->pio_write_status_val;
+
+	/* Drain PIO writes from old CPU's Shub */
+	while ((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val)
+		cpu_relax();
+}
+
 void sn_tlb_migrate_finish(struct mm_struct *mm)
 {
 	if (mm = current->mm)
diff --git a/include/asm-ia64/machvec.h b/include/asm-ia64/machvec.h
index ca5ea99..a739a08 100644
--- a/include/asm-ia64/machvec.h
+++ b/include/asm-ia64/machvec.h
@@ -20,6 +20,7 @@ struct scatterlist;
 struct page;
 struct mm_struct;
 struct pci_bus;
+struct task_struct;
 
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_cpu_init_t (void);
@@ -34,6 +35,7 @@ typedef int ia64_mv_pci_legacy_read_t (s
 				       u8 size);
 typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
 					u8 size);
+typedef void ia64_mv_switch_from_t(struct task_struct * task);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
@@ -85,6 +87,11 @@ machvec_noop_mm (struct mm_struct *mm)
 {
 }
 
+static inline void
+machvec_noop_task (struct task_struct *task)
+{
+}
+
 extern void machvec_setup (char **);
 extern void machvec_timer_interrupt (int, void *, struct pt_regs *);
 extern void machvec_dma_sync_single (struct device *, dma_addr_t, size_t, int);
@@ -146,6 +153,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_readw_relaxed        ia64_mv.readw_relaxed
 #  define platform_readl_relaxed        ia64_mv.readl_relaxed
 #  define platform_readq_relaxed        ia64_mv.readq_relaxed
+#  define platform_switch_from		ia64_mv.switch_from
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
@@ -194,6 +202,7 @@ struct ia64_machine_vector {
 	ia64_mv_readw_relaxed_t *readw_relaxed;
 	ia64_mv_readl_relaxed_t *readl_relaxed;
 	ia64_mv_readq_relaxed_t *readq_relaxed;
+	ia64_mv_switch_from_t *switch_from;
 } __attribute__((__aligned__(16))); /* align attrib? see above comment */
 
 #define MACHVEC_INIT(name)			\
@@ -238,6 +247,7 @@ struct ia64_machine_vector {
 	platform_readw_relaxed,			\
 	platform_readl_relaxed,			\
 	platform_readq_relaxed,			\
+	platform_switch_from,			\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -386,5 +396,8 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #ifndef platform_readq_relaxed
 # define platform_readq_relaxed	__ia64_readq_relaxed
 #endif
+#ifndef platform_switch_from
+# define platform_switch_from machvec_noop_task
+#endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
diff --git a/include/asm-ia64/machvec_sn2.h b/include/asm-ia64/machvec_sn2.h
index e1b6cd6..110dc54 100644
--- a/include/asm-ia64/machvec_sn2.h
+++ b/include/asm-ia64/machvec_sn2.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2002-2003,2006 Silicon Graphics, Inc.  All Rights Reserved.
  * 
  * This program is free software; you can redistribute it and/or modify it 
  * under the terms of version 2 of the GNU General Public License 
@@ -71,6 +71,7 @@ extern ia64_mv_dma_sync_single_for_devic
 extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
 extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
+extern ia64_mv_switch_from_t		sn_switch_from;
 
 /*
  * This stuff has dual use!
@@ -120,6 +121,7 @@ extern ia64_mv_dma_supported		sn_dma_sup
 #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
 #define platform_dma_mapping_error		sn_dma_mapping_error
 #define platform_dma_supported		sn_dma_supported
+#define platform_switch_from		sn_switch_from
 
 #include <asm/sn/io.h>
 
diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
index 80c5a23..da8728d 100644
--- a/include/asm-ia64/system.h
+++ b/include/asm-ia64/system.h
@@ -243,6 +243,10 @@ extern void ia64_load_extra (struct task
 		(prev)->thread.flags |= IA64_THREAD_FPH_VALID;			\
 		__ia64_save_fpu((prev)->thread.fph);				\
 	}									\
+	if (unlikely(task_cpu(next) != task_thread_info(next)->last_cpu)) {	\
+		platform_switch_from(next);					\
+		task_thread_info(next)->last_cpu = task_cpu(next);		\
+	}									\
 	__switch_to(prev, next, last);						\
 } while (0)
 #else
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index 1d6518f..02692b3 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -36,6 +36,7 @@ struct thread_info {
 		unsigned long start_time;
 		pid_t pid;
 	} sigdelayed;			/* Saved information for TIF_SIGDELAYED */
+	__u32	last_cpu;		/* Last CPU thread ran on */
 };
 
 #define THREAD_SIZE			KERNEL_STACK_SIZE
@@ -51,6 +52,7 @@ struct thread_info {
 	.restart_block = {			\
 		.fn = do_no_restart_syscall,	\
 	},					\
+	.last_cpu	= 0,			\
 }
 
 #ifndef ASM_OFFSETS_C
