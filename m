From: Brent Casavant <bcasavan@sgi.com>
Date: Tue, 24 Jan 2006 00:33:39 +0000
Subject: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060123180530.N74549@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Take 2.

On SN2, MMIO writes which are issued from separate processors are not
guaranteed to arrive in any particular order at the IO hardware.  When
performing such writes from the kernel this is not a problem, as a
kernel thread will not migrate to another CPU during execution, and
mmiowb() calls can guarantee write ordering when control of the IO
resource is allowed to move between threads.

However, when MMIO writes can be performed from user space (e.g. DRM)
there are no such guarantees and mechanisms, as the process may
context-switch at any time, and may migrate to a different CPU as part
of the switch.  For such programs/hardware to operate correctly, it is
required that the MMIO writes from the old CPU be accepted by the IO
hardware before subsequent writes from the new CPU can be issued.

The following patch implements this behavior on SN2 by waiting for a
Shub register to indicate that these writes have been accepted (the
non-SN2 case is a no-op).  This is placed in the context switch-in
path, and only performs the wait when the newly scheduled task changes
CPUs.

Signed-off-by: Brent Casavant <bcasavan@sgi.com>

 arch/ia64/sn/kernel/setup.c       |    8 +++++---
 arch/ia64/sn/kernel/sn2/sn2_smp.c |   33 ++++++++++++++++++++++++++++++++-
 include/asm-ia64/machvec.h        |   12 ++++++++++++
 include/asm-ia64/machvec_sn2.h    |    4 +++-
 include/asm-ia64/system.h         |    1 +
 include/asm-ia64/thread_info.h    |   10 ++++++++++
 6 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index e510dce..9a52dfa 100644
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
@@ -654,8 +654,10 @@ void __init sn_cpu_init(void)
 			SH2_PIO_WRITE_STATUS_1, SH2_PIO_WRITE_STATUS_3};
 		u64 *pio;
 		pio = is_shub1() ? pio1 : pio2;
-		pda->pio_write_status_addr = (volatile unsigned long *) LOCAL_MMR_ADDR(pio[slice]);
-		pda->pio_write_status_val = is_shub1() ? SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK : 0;
+		pda->pio_write_status_addr = (volatile unsigned long *)
+			GLOBAL_MMR_ADDR(nasid, pio[slice]);
+		pda->pio_write_status_val = is_shub1() ?
+			SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK : 0;
 	}
 
 	/*
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 471bbaa..1cca3f2 100644
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
@@ -169,6 +169,37 @@ static inline unsigned long wait_piowc(v
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
+	__u32 *piowr_cpu = &task_thread_info(task)->sn2_piowr_cpu;
+	__u32 this_cpu = task_cpu(task);
+	pda_t *piowr_pda;
+	volatile unsigned long *adr;
+	unsigned long val;
+
+	if (likely(this_cpu = *piowr_cpu))
+		return;
+
+	/* Drain PIO writes from old CPU's Shub */
+	piowr_pda = pdacpu(*piowr_cpu);
+	adr = piowr_pda->pio_write_status_addr;
+	val = piowr_pda->pio_write_status_val;
+	while ((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val)
+		cpu_relax();
+
+	/* Next time drain this CPU's Shub */
+	*piowr_cpu = this_cpu;
+}
+
 void sn_tlb_migrate_finish(struct mm_struct *mm)
 {
 	if (mm = current->mm)
diff --git a/include/asm-ia64/machvec.h b/include/asm-ia64/machvec.h
index ca5ea99..9b54073 100644
--- a/include/asm-ia64/machvec.h
+++ b/include/asm-ia64/machvec.h
@@ -34,6 +34,7 @@ typedef int ia64_mv_pci_legacy_read_t (s
 				       u8 size);
 typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
 					u8 size);
+typedef void ia64_mv_switch_from_t(struct task_struct * task);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
@@ -85,6 +86,11 @@ machvec_noop_mm (struct mm_struct *mm)
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
@@ -146,6 +152,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_readw_relaxed        ia64_mv.readw_relaxed
 #  define platform_readl_relaxed        ia64_mv.readl_relaxed
 #  define platform_readq_relaxed        ia64_mv.readq_relaxed
+#  define platform_switch_from		ia64_mv.switch_from
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
@@ -194,6 +201,7 @@ struct ia64_machine_vector {
 	ia64_mv_readw_relaxed_t *readw_relaxed;
 	ia64_mv_readl_relaxed_t *readl_relaxed;
 	ia64_mv_readq_relaxed_t *readq_relaxed;
+	ia64_mv_switch_from_t *switch_from;
 } __attribute__((__aligned__(16))); /* align attrib? see above comment */
 
 #define MACHVEC_INIT(name)			\
@@ -238,6 +246,7 @@ struct ia64_machine_vector {
 	platform_readw_relaxed,			\
 	platform_readl_relaxed,			\
 	platform_readq_relaxed,			\
+	platform_switch_from,			\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -386,5 +395,8 @@ extern ia64_mv_dma_supported		swiotlb_dm
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
index 80c5a23..0508327 100644
--- a/include/asm-ia64/system.h
+++ b/include/asm-ia64/system.h
@@ -243,6 +243,7 @@ extern void ia64_load_extra (struct task
 		(prev)->thread.flags |= IA64_THREAD_FPH_VALID;			\
 		__ia64_save_fpu((prev)->thread.fph);				\
 	}									\
+	platform_switch_from(next);						\
 	__switch_to(prev, next, last);						\
 } while (0)
 #else
diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
index 1d6518f..c63494d 100644
--- a/include/asm-ia64/thread_info.h
+++ b/include/asm-ia64/thread_info.h
@@ -36,10 +36,19 @@ struct thread_info {
 		unsigned long start_time;
 		pid_t pid;
 	} sigdelayed;			/* Saved information for TIF_SIGDELAYED */
+#if defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_GENERIC)
+	__u32	sn2_piowr_cpu;		/* CPU needing PIO write drain */
+#endif
 };
 
 #define THREAD_SIZE			KERNEL_STACK_SIZE
 
+#if defined(CONFIG_IA64_SGI_SN2) || defined(CONFIG_IA64_GENERIC)
+#define INIT_TI_SN2_PIOWR_CPU .sn2_piowr_cpu = 0,
+#else
+#define INIT_TI_SN2_PIOWR_CPU
+#endif
+
 #define INIT_THREAD_INFO(tsk)			\
 {						\
 	.task		= &tsk,			\
@@ -51,6 +60,7 @@ struct thread_info {
 	.restart_block = {			\
 		.fn = do_no_restart_syscall,	\
 	},					\
+	INIT_TI_SN2_PIOWR_CPU			\
 }
 
 #ifndef ASM_OFFSETS_C
