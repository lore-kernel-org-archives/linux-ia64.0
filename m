From: David Howells <dhowells@redhat.com>
Date: Mon, 12 Mar 2012 23:37:56 +0000
Subject: [PATCH 11/35] Disintegrate asm/system.h for IA64 [ver #2]
Message-Id: <20120312233756.13888.98274.stgit@warthog.procyon.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120312233602.13888.27659.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120312233602.13888.27659.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paul.gortmaker@windriver.com, hpa@zytor.com
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, arnd@arndb.de, David Howells <dhowells@redhat.com>, linux-ia64@vger.kernel.org

Disintegrate asm/system.h for IA64.  Not compiled.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: linux-ia64@vger.kernel.org
---

 arch/ia64/dig/setup.c                   |    1 
 arch/ia64/hp/common/sba_iommu.c         |    1 
 arch/ia64/hp/sim/boot/bootloader.c      |    1 
 arch/ia64/hp/sim/simeth.c               |    1 
 arch/ia64/include/asm/acpi.h            |    1 
 arch/ia64/include/asm/atomic.h          |    1 
 arch/ia64/include/asm/auxvec.h          |    2 
 arch/ia64/include/asm/barrier.h         |   68 ++++++++++
 arch/ia64/include/asm/exec.h            |   14 ++
 arch/ia64/include/asm/futex.h           |    1 
 arch/ia64/include/asm/io.h              |    1 
 arch/ia64/include/asm/pci.h             |    8 +
 arch/ia64/include/asm/pgtable.h         |    1 
 arch/ia64/include/asm/processor.h       |    8 +
 arch/ia64/include/asm/sal.h             |    1 
 arch/ia64/include/asm/setup.h           |   28 ++++
 arch/ia64/include/asm/sn/pda.h          |    1 
 arch/ia64/include/asm/spinlock.h        |    1 
 arch/ia64/include/asm/switch_to.h       |   87 +++++++++++++
 arch/ia64/include/asm/system.h          |  207 +------------------------------
 arch/ia64/include/asm/uv/uv.h           |    1 
 arch/ia64/kernel/acpi.c                 |    1 
 arch/ia64/kernel/fsys.S                 |    1 
 arch/ia64/kernel/gate.S                 |    1 
 arch/ia64/kernel/gate.lds.S             |    1 
 arch/ia64/kernel/head.S                 |    1 
 arch/ia64/kernel/iosapic.c              |    1 
 arch/ia64/kernel/irq_ia64.c             |    1 
 arch/ia64/kernel/ivt.S                  |    1 
 arch/ia64/kernel/machvec.c              |    1 
 arch/ia64/kernel/mca.c                  |    1 
 arch/ia64/kernel/mca_drv.c              |    1 
 arch/ia64/kernel/patch.c                |    1 
 arch/ia64/kernel/pci-dma.c              |    1 
 arch/ia64/kernel/perfmon.c              |    1 
 arch/ia64/kernel/ptrace.c               |    1 
 arch/ia64/kernel/setup.c                |    1 
 arch/ia64/kernel/smp.c                  |    1 
 arch/ia64/kernel/smpboot.c              |    1 
 arch/ia64/kernel/time.c                 |    1 
 arch/ia64/kernel/uncached.c             |    1 
 arch/ia64/kernel/unwind.c               |    1 
 arch/ia64/kernel/vmlinux.lds.S          |    1 
 arch/ia64/mm/fault.c                    |    1 
 arch/ia64/mm/init.c                     |    1 
 arch/ia64/oprofile/backtrace.c          |    1 
 arch/ia64/pci/pci.c                     |    1 
 arch/ia64/sn/kernel/setup.c             |    1 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |    1 
 arch/ia64/sn/kernel/sn2/sn2_smp.c       |    1 
 arch/ia64/sn/kernel/sn2/timer.c         |    1 
 arch/ia64/sn/kernel/tiocx.c             |    1 
 arch/ia64/xen/xensetup.S                |    1 
 53 files changed, 219 insertions(+), 248 deletions(-)
 create mode 100644 arch/ia64/include/asm/barrier.h
 create mode 100644 arch/ia64/include/asm/exec.h
 create mode 100644 arch/ia64/include/asm/switch_to.h

diff --git a/arch/ia64/dig/setup.c b/arch/ia64/dig/setup.c
index 9196b33..cdce2e2 100644
--- a/arch/ia64/dig/setup.c
+++ b/arch/ia64/dig/setup.c
@@ -22,7 +22,6 @@
 
 #include <asm/io.h>
 #include <asm/machvec.h>
-#include <asm/system.h>
 
 void __init
 dig_setup (char **cmdline_p)
diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index f5f4ef1..f6ea3a3 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -43,7 +43,6 @@
 #include <asm/io.h>
 #include <asm/page.h>		/* PAGE_OFFSET */
 #include <asm/dma.h>
-#include <asm/system.h>		/* wmb() */
 
 #include <asm/acpi-ext.h>
 
diff --git a/arch/ia64/hp/sim/boot/bootloader.c b/arch/ia64/hp/sim/boot/bootloader.c
index c5e9baa..28f4b23 100644
--- a/arch/ia64/hp/sim/boot/bootloader.c
+++ b/arch/ia64/hp/sim/boot/bootloader.c
@@ -20,7 +20,6 @@ struct task_struct;	/* forward declaration for elf.h */
 #include <asm/pal.h>
 #include <asm/pgtable.h>
 #include <asm/sal.h>
-#include <asm/system.h>
 
 #include "ssc.h"
 
diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 47afcc6..be8ddc5 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -20,7 +20,6 @@
 #include <linux/skbuff.h>
 #include <linux/notifier.h>
 #include <linux/bitops.h>
-#include <asm/system.h>
 #include <asm/irq.h>
 #include <asm/hpsim.h>
 
diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index a06dfb1..301609c 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -32,7 +32,6 @@
 
 #include <linux/init.h>
 #include <linux/numa.h>
-#include <asm/system.h>
 #include <asm/numa.h>
 
 #define COMPILER_DEPENDENT_INT64	long
diff --git a/arch/ia64/include/asm/atomic.h b/arch/ia64/include/asm/atomic.h
index 3fad89e..7d91166 100644
--- a/arch/ia64/include/asm/atomic.h
+++ b/arch/ia64/include/asm/atomic.h
@@ -15,7 +15,6 @@
 #include <linux/types.h>
 
 #include <asm/intrinsics.h>
-#include <asm/system.h>
 
 
 #define ATOMIC_INIT(i)		((atomic_t) { (i) })
diff --git a/arch/ia64/include/asm/auxvec.h b/arch/ia64/include/asm/auxvec.h
index 23cebe5..58277fc 100644
--- a/arch/ia64/include/asm/auxvec.h
+++ b/arch/ia64/include/asm/auxvec.h
@@ -8,4 +8,6 @@
 #define AT_SYSINFO	32
 #define AT_SYSINFO_EHDR	33
 
+#define AT_VECTOR_SIZE_ARCH 2 /* entries in ARCH_DLINFO */
+
 #endif /* _ASM_IA64_AUXVEC_H */
diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
new file mode 100644
index 0000000..516529c
--- /dev/null
+++ b/arch/ia64/include/asm/barrier.h
@@ -0,0 +1,68 @@
+/*
+ * Memory barrier definitions.  This is based on information published
+ * in the Processor Abstraction Layer and the System Abstraction Layer
+ * manual.
+ *
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
+ * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
+ */
+#ifndef _ASM_IA64_BARRIER_H
+#define _ASM_IA64_BARRIER_H
+
+#include <asm/compiler.h>
+
+/*
+ * Macros to force memory ordering.  In these descriptions, "previous"
+ * and "subsequent" refer to program order; "visible" means that all
+ * architecturally visible effects of a memory access have occurred
+ * (at a minimum, this means the memory has been read or written).
+ *
+ *   wmb():	Guarantees that all preceding stores to memory-
+ *		like regions are visible before any subsequent
+ *		stores and that all following stores will be
+ *		visible only after all previous stores.
+ *   rmb():	Like wmb(), but for reads.
+ *   mb():	wmb()/rmb() combo, i.e., all previous memory
+ *		accesses are visible before all subsequent
+ *		accesses and vice versa.  This is also known as
+ *		a "fence."
+ *
+ * Note: "mb()" and its variants cannot be used as a fence to order
+ * accesses to memory mapped I/O registers.  For that, mf.a needs to
+ * be used.  However, we don't want to always use mf.a because (a)
+ * it's (presumably) much slower than mf and (b) mf.a is supported for
+ * sequential memory pages only.
+ */
+#define mb()	ia64_mf()
+#define rmb()	mb()
+#define wmb()	mb()
+#define read_barrier_depends()	do { } while(0)
+
+#ifdef CONFIG_SMP
+# define smp_mb()	mb()
+# define smp_rmb()	rmb()
+# define smp_wmb()	wmb()
+# define smp_read_barrier_depends()	read_barrier_depends()
+#else
+# define smp_mb()	barrier()
+# define smp_rmb()	barrier()
+# define smp_wmb()	barrier()
+# define smp_read_barrier_depends()	do { } while(0)
+#endif
+
+/*
+ * XXX check on this ---I suspect what Linus really wants here is
+ * acquire vs release semantics but we can't discuss this stuff with
+ * Linus just yet.  Grrr...
+ */
+#define set_mb(var, value)	do { (var) = (value); mb(); } while (0)
+
+/*
+ * The group barrier in front of the rsm & ssm are necessary to ensure
+ * that none of the previous instructions in the same group are
+ * affected by the rsm/ssm.
+ */
+
+#endif /* _ASM_IA64_BARRIER_H */
diff --git a/arch/ia64/include/asm/exec.h b/arch/ia64/include/asm/exec.h
new file mode 100644
index 0000000..b262424
--- /dev/null
+++ b/arch/ia64/include/asm/exec.h
@@ -0,0 +1,14 @@
+/*
+ * Process execution defines.
+ *
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
+ * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
+ */
+#ifndef _ASM_IA64_EXEC_H
+#define _ASM_IA64_EXEC_H
+
+#define arch_align_stack(x) (x)
+
+#endif /* _ASM_IA64_EXEC_H */
diff --git a/arch/ia64/include/asm/futex.h b/arch/ia64/include/asm/futex.h
index 8428525..0ab82cc 100644
--- a/arch/ia64/include/asm/futex.h
+++ b/arch/ia64/include/asm/futex.h
@@ -4,7 +4,6 @@
 #include <linux/futex.h>
 #include <linux/uaccess.h>
 #include <asm/errno.h>
-#include <asm/system.h>
 
 #define __futex_atomic_op1(insn, ret, oldval, uaddr, oparg) \
 do {									\
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index e5a6c35..2c26321 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -71,7 +71,6 @@ extern unsigned int num_io_spaces;
 #include <asm/intrinsics.h>
 #include <asm/machvec.h>
 #include <asm/page.h>
-#include <asm/system.h>
 #include <asm-generic/iomap.h>
 
 /*
diff --git a/arch/ia64/include/asm/pci.h b/arch/ia64/include/asm/pci.h
index 279b38a..c5e6da9 100644
--- a/arch/ia64/include/asm/pci.h
+++ b/arch/ia64/include/asm/pci.h
@@ -11,6 +11,14 @@
 #include <asm/scatterlist.h>
 #include <asm/hw_irq.h>
 
+struct pci_vector_struct {
+	__u16 segment;	/* PCI Segment number */
+	__u16 bus;	/* PCI Bus number */
+	__u32 pci_id;	/* ACPI split 16 bits device, 16 bits function (see section 6.1.1) */
+	__u8 pin;	/* PCI PIN (0 = A, 1 = B, 2 = C, 3 = D) */
+	__u32 irq;	/* IRQ assigned */
+};
+
 /*
  * Can be used to override the logic in pci_scan_bus for skipping already-configured bus
  * numbers - to be used for buggy BIOSes or architectures with incomplete PCI setup by the
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 1a97af3..815810c 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -16,7 +16,6 @@
 #include <asm/mman.h>
 #include <asm/page.h>
 #include <asm/processor.h>
-#include <asm/system.h>
 #include <asm/types.h>
 
 #define IA64_MAX_PHYS_BITS	50	/* max. number of physical address bits (architected) */
diff --git a/arch/ia64/include/asm/processor.h b/arch/ia64/include/asm/processor.h
index 691be0b..483f6c6 100644
--- a/arch/ia64/include/asm/processor.h
+++ b/arch/ia64/include/asm/processor.h
@@ -19,6 +19,9 @@
 #include <asm/ptrace.h>
 #include <asm/ustack.h>
 
+#define __ARCH_WANT_UNLOCKED_CTXSW
+#define ARCH_HAS_PREFETCH_SWITCH_STACK
+
 #define IA64_NUM_PHYS_STACK_REG	96
 #define IA64_NUM_DBG_REGS	8
 
@@ -720,6 +723,11 @@ extern unsigned long boot_option_idle_override;
 enum idle_boot_override {IDLE_NO_OVERRIDE=0, IDLE_HALT, IDLE_FORCE_MWAIT,
 			 IDLE_NOMWAIT, IDLE_POLL};
 
+void cpu_idle_wait(void);
+void default_idle(void);
+
+#define ia64_platform_is(x) (strcmp(x, platform_name) = 0)
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_IA64_PROCESSOR_H */
diff --git a/arch/ia64/include/asm/sal.h b/arch/ia64/include/asm/sal.h
index d19ddba..e504f38 100644
--- a/arch/ia64/include/asm/sal.h
+++ b/arch/ia64/include/asm/sal.h
@@ -40,7 +40,6 @@
 #include <linux/efi.h>
 
 #include <asm/pal.h>
-#include <asm/system.h>
 #include <asm/fpu.h>
 
 extern spinlock_t sal_lock;
diff --git a/arch/ia64/include/asm/setup.h b/arch/ia64/include/asm/setup.h
index 4399a44..d2fb458 100644
--- a/arch/ia64/include/asm/setup.h
+++ b/arch/ia64/include/asm/setup.h
@@ -3,4 +3,32 @@
 
 #define COMMAND_LINE_SIZE	2048
 
+#define GATE_ADDR		RGN_BASE(RGN_GATE)
+
+/*
+ * 0xa000000000000000+2*PERCPU_PAGE_SIZE
+ * - 0xa000000000000000+3*PERCPU_PAGE_SIZE remain unmapped (guard page)
+ */
+#define KERNEL_START		 (GATE_ADDR+__IA64_UL_CONST(0x100000000))
+#define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
+#define LOAD_OFFSET		(KERNEL_START - KERNEL_TR_PAGE_SIZE)
+
+extern struct ia64_boot_param {
+	__u64 command_line;		/* physical address of command line arguments */
+	__u64 efi_systab;		/* physical address of EFI system table */
+	__u64 efi_memmap;		/* physical address of EFI memory map */
+	__u64 efi_memmap_size;		/* size of EFI memory map */
+	__u64 efi_memdesc_size;		/* size of an EFI memory map descriptor */
+	__u32 efi_memdesc_version;	/* memory descriptor version */
+	struct {
+		__u16 num_cols;	/* number of columns on console output device */
+		__u16 num_rows;	/* number of rows on console output device */
+		__u16 orig_x;	/* cursor's x position */
+		__u16 orig_y;	/* cursor's y position */
+	} console_info;
+	__u64 fpswa;		/* physical address of the fpswa interface */
+	__u64 initrd_start;
+	__u64 initrd_size;
+} *ia64_boot_param;
+
 #endif
diff --git a/arch/ia64/include/asm/sn/pda.h b/arch/ia64/include/asm/sn/pda.h
index 1c5108d..22ae358 100644
--- a/arch/ia64/include/asm/sn/pda.h
+++ b/arch/ia64/include/asm/sn/pda.h
@@ -10,7 +10,6 @@
 
 #include <linux/cache.h>
 #include <asm/percpu.h>
-#include <asm/system.h>
 
 
 /*
diff --git a/arch/ia64/include/asm/spinlock.h b/arch/ia64/include/asm/spinlock.h
index b77768d..54ff557 100644
--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -15,7 +15,6 @@
 
 #include <linux/atomic.h>
 #include <asm/intrinsics.h>
-#include <asm/system.h>
 
 #define arch_spin_lock_init(x)			((x)->lock = 0)
 
diff --git a/arch/ia64/include/asm/switch_to.h b/arch/ia64/include/asm/switch_to.h
new file mode 100644
index 0000000..cb2412f
--- /dev/null
+++ b/arch/ia64/include/asm/switch_to.h
@@ -0,0 +1,87 @@
+/*
+ * Low-level task switching. This is based on information published in
+ * the Processor Abstraction Layer and the System Abstraction Layer
+ * manual.
+ *
+ * Copyright (C) 1998-2003 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
+ * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
+ */
+#ifndef _ASM_IA64_SWITCH_TO_H
+#define _ASM_IA64_SWITCH_TO_H
+
+#include <linux/percpu.h>
+
+struct task_struct;
+
+/*
+ * Context switch from one thread to another.  If the two threads have
+ * different address spaces, schedule() has already taken care of
+ * switching to the new address space by calling switch_mm().
+ *
+ * Disabling access to the fph partition and the debug-register
+ * context switch MUST be done before calling ia64_switch_to() since a
+ * newly created thread returns directly to
+ * ia64_ret_from_syscall_clear_r8.
+ */
+extern struct task_struct *ia64_switch_to (void *next_task);
+
+extern void ia64_save_extra (struct task_struct *task);
+extern void ia64_load_extra (struct task_struct *task);
+
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+extern void ia64_account_on_switch (struct task_struct *prev, struct task_struct *next);
+# define IA64_ACCOUNT_ON_SWITCH(p,n) ia64_account_on_switch(p,n)
+#else
+# define IA64_ACCOUNT_ON_SWITCH(p,n)
+#endif
+
+#ifdef CONFIG_PERFMON
+  DECLARE_PER_CPU(unsigned long, pfm_syst_info);
+# define PERFMON_IS_SYSWIDE() (__get_cpu_var(pfm_syst_info) & 0x1)
+#else
+# define PERFMON_IS_SYSWIDE() (0)
+#endif
+
+#define IA64_HAS_EXTRA_STATE(t)							\
+	((t)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID)	\
+	 || PERFMON_IS_SYSWIDE())
+
+#define __switch_to(prev,next,last) do {							 \
+	IA64_ACCOUNT_ON_SWITCH(prev, next);							 \
+	if (IA64_HAS_EXTRA_STATE(prev))								 \
+		ia64_save_extra(prev);								 \
+	if (IA64_HAS_EXTRA_STATE(next))								 \
+		ia64_load_extra(next);								 \
+	ia64_psr(task_pt_regs(next))->dfh = !ia64_is_local_fpu_owner(next);			 \
+	(last) = ia64_switch_to((next));							 \
+} while (0)
+
+#ifdef CONFIG_SMP
+/*
+ * In the SMP case, we save the fph state when context-switching away from a thread that
+ * modified fph.  This way, when the thread gets scheduled on another CPU, the CPU can
+ * pick up the state from task->thread.fph, avoiding the complication of having to fetch
+ * the latest fph state from another CPU.  In other words: eager save, lazy restore.
+ */
+# define switch_to(prev,next,last) do {						\
+	if (ia64_psr(task_pt_regs(prev))->mfh && ia64_is_local_fpu_owner(prev)) {				\
+		ia64_psr(task_pt_regs(prev))->mfh = 0;			\
+		(prev)->thread.flags |= IA64_THREAD_FPH_VALID;			\
+		__ia64_save_fpu((prev)->thread.fph);				\
+	}									\
+	__switch_to(prev, next, last);						\
+	/* "next" in old context is "current" in new context */			\
+	if (unlikely((current->thread.flags & IA64_THREAD_MIGRATION) &&	       \
+		     (task_cpu(current) !=				       \
+		      		      task_thread_info(current)->last_cpu))) { \
+		platform_migrate(current);				       \
+		task_thread_info(current)->last_cpu = task_cpu(current);       \
+	}								       \
+} while (0)
+#else
+# define switch_to(prev,next,last)	__switch_to(prev, next, last)
+#endif
+
+#endif /* _ASM_IA64_SWITCH_TO_H */
diff --git a/arch/ia64/include/asm/system.h b/arch/ia64/include/asm/system.h
index 6cca307..5b190b4 100644
--- a/arch/ia64/include/asm/system.h
+++ b/arch/ia64/include/asm/system.h
@@ -1,203 +1,4 @@
-#ifndef _ASM_IA64_SYSTEM_H
-#define _ASM_IA64_SYSTEM_H
-
-/*
- * System defines. Note that this is included both from .c and .S
- * files, so it does only defines, not any C code.  This is based
- * on information published in the Processor Abstraction Layer
- * and the System Abstraction Layer manual.
- *
- * Copyright (C) 1998-2003 Hewlett-Packard Co
- *	David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
- * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
- */
-
-#include <asm/kregs.h>
-#include <asm/page.h>
-#include <asm/pal.h>
-#include <asm/percpu.h>
-
-#define GATE_ADDR		RGN_BASE(RGN_GATE)
-
-/*
- * 0xa000000000000000+2*PERCPU_PAGE_SIZE
- * - 0xa000000000000000+3*PERCPU_PAGE_SIZE remain unmapped (guard page)
- */
-#define KERNEL_START		 (GATE_ADDR+__IA64_UL_CONST(0x100000000))
-#define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
-#define LOAD_OFFSET		(KERNEL_START - KERNEL_TR_PAGE_SIZE)
-
-#ifndef __ASSEMBLY__
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-
-#define AT_VECTOR_SIZE_ARCH 2 /* entries in ARCH_DLINFO */
-
-struct pci_vector_struct {
-	__u16 segment;	/* PCI Segment number */
-	__u16 bus;	/* PCI Bus number */
-	__u32 pci_id;	/* ACPI split 16 bits device, 16 bits function (see section 6.1.1) */
-	__u8 pin;	/* PCI PIN (0 = A, 1 = B, 2 = C, 3 = D) */
-	__u32 irq;	/* IRQ assigned */
-};
-
-extern struct ia64_boot_param {
-	__u64 command_line;		/* physical address of command line arguments */
-	__u64 efi_systab;		/* physical address of EFI system table */
-	__u64 efi_memmap;		/* physical address of EFI memory map */
-	__u64 efi_memmap_size;		/* size of EFI memory map */
-	__u64 efi_memdesc_size;		/* size of an EFI memory map descriptor */
-	__u32 efi_memdesc_version;	/* memory descriptor version */
-	struct {
-		__u16 num_cols;	/* number of columns on console output device */
-		__u16 num_rows;	/* number of rows on console output device */
-		__u16 orig_x;	/* cursor's x position */
-		__u16 orig_y;	/* cursor's y position */
-	} console_info;
-	__u64 fpswa;		/* physical address of the fpswa interface */
-	__u64 initrd_start;
-	__u64 initrd_size;
-} *ia64_boot_param;
-
-/*
- * Macros to force memory ordering.  In these descriptions, "previous"
- * and "subsequent" refer to program order; "visible" means that all
- * architecturally visible effects of a memory access have occurred
- * (at a minimum, this means the memory has been read or written).
- *
- *   wmb():	Guarantees that all preceding stores to memory-
- *		like regions are visible before any subsequent
- *		stores and that all following stores will be
- *		visible only after all previous stores.
- *   rmb():	Like wmb(), but for reads.
- *   mb():	wmb()/rmb() combo, i.e., all previous memory
- *		accesses are visible before all subsequent
- *		accesses and vice versa.  This is also known as
- *		a "fence."
- *
- * Note: "mb()" and its variants cannot be used as a fence to order
- * accesses to memory mapped I/O registers.  For that, mf.a needs to
- * be used.  However, we don't want to always use mf.a because (a)
- * it's (presumably) much slower than mf and (b) mf.a is supported for
- * sequential memory pages only.
- */
-#define mb()	ia64_mf()
-#define rmb()	mb()
-#define wmb()	mb()
-#define read_barrier_depends()	do { } while(0)
-
-#ifdef CONFIG_SMP
-# define smp_mb()	mb()
-# define smp_rmb()	rmb()
-# define smp_wmb()	wmb()
-# define smp_read_barrier_depends()	read_barrier_depends()
-#else
-# define smp_mb()	barrier()
-# define smp_rmb()	barrier()
-# define smp_wmb()	barrier()
-# define smp_read_barrier_depends()	do { } while(0)
-#endif
-
-/*
- * XXX check on this ---I suspect what Linus really wants here is
- * acquire vs release semantics but we can't discuss this stuff with
- * Linus just yet.  Grrr...
- */
-#define set_mb(var, value)	do { (var) = (value); mb(); } while (0)
-
-/*
- * The group barrier in front of the rsm & ssm are necessary to ensure
- * that none of the previous instructions in the same group are
- * affected by the rsm/ssm.
- */
-
-#ifdef __KERNEL__
-
-/*
- * Context switch from one thread to another.  If the two threads have
- * different address spaces, schedule() has already taken care of
- * switching to the new address space by calling switch_mm().
- *
- * Disabling access to the fph partition and the debug-register
- * context switch MUST be done before calling ia64_switch_to() since a
- * newly created thread returns directly to
- * ia64_ret_from_syscall_clear_r8.
- */
-extern struct task_struct *ia64_switch_to (void *next_task);
-
-struct task_struct;
-
-extern void ia64_save_extra (struct task_struct *task);
-extern void ia64_load_extra (struct task_struct *task);
-
-#ifdef CONFIG_VIRT_CPU_ACCOUNTING
-extern void ia64_account_on_switch (struct task_struct *prev, struct task_struct *next);
-# define IA64_ACCOUNT_ON_SWITCH(p,n) ia64_account_on_switch(p,n)
-#else
-# define IA64_ACCOUNT_ON_SWITCH(p,n)
-#endif
-
-#ifdef CONFIG_PERFMON
-  DECLARE_PER_CPU(unsigned long, pfm_syst_info);
-# define PERFMON_IS_SYSWIDE() (__get_cpu_var(pfm_syst_info) & 0x1)
-#else
-# define PERFMON_IS_SYSWIDE() (0)
-#endif
-
-#define IA64_HAS_EXTRA_STATE(t)							\
-	((t)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID)	\
-	 || PERFMON_IS_SYSWIDE())
-
-#define __switch_to(prev,next,last) do {							 \
-	IA64_ACCOUNT_ON_SWITCH(prev, next);							 \
-	if (IA64_HAS_EXTRA_STATE(prev))								 \
-		ia64_save_extra(prev);								 \
-	if (IA64_HAS_EXTRA_STATE(next))								 \
-		ia64_load_extra(next);								 \
-	ia64_psr(task_pt_regs(next))->dfh = !ia64_is_local_fpu_owner(next);			 \
-	(last) = ia64_switch_to((next));							 \
-} while (0)
-
-#ifdef CONFIG_SMP
-/*
- * In the SMP case, we save the fph state when context-switching away from a thread that
- * modified fph.  This way, when the thread gets scheduled on another CPU, the CPU can
- * pick up the state from task->thread.fph, avoiding the complication of having to fetch
- * the latest fph state from another CPU.  In other words: eager save, lazy restore.
- */
-# define switch_to(prev,next,last) do {						\
-	if (ia64_psr(task_pt_regs(prev))->mfh && ia64_is_local_fpu_owner(prev)) {				\
-		ia64_psr(task_pt_regs(prev))->mfh = 0;			\
-		(prev)->thread.flags |= IA64_THREAD_FPH_VALID;			\
-		__ia64_save_fpu((prev)->thread.fph);				\
-	}									\
-	__switch_to(prev, next, last);						\
-	/* "next" in old context is "current" in new context */			\
-	if (unlikely((current->thread.flags & IA64_THREAD_MIGRATION) &&	       \
-		     (task_cpu(current) !=				       \
-		      		      task_thread_info(current)->last_cpu))) { \
-		platform_migrate(current);				       \
-		task_thread_info(current)->last_cpu = task_cpu(current);       \
-	}								       \
-} while (0)
-#else
-# define switch_to(prev,next,last)	__switch_to(prev, next, last)
-#endif
-
-#define __ARCH_WANT_UNLOCKED_CTXSW
-#define ARCH_HAS_PREFETCH_SWITCH_STACK
-#define ia64_platform_is(x) (strcmp(x, platform_name) = 0)
-
-void cpu_idle_wait(void);
-
-#define arch_align_stack(x) (x)
-
-void default_idle(void);
-
-#endif /* __KERNEL__ */
-
-#endif /* __ASSEMBLY__ */
-
-#endif /* _ASM_IA64_SYSTEM_H */
+/* FILE TO BE DELETED. DO NOT ADD STUFF HERE! */
+#include <asm/barrier.h>
+#include <asm/exec.h>
+#include <asm/switch_to.h>
diff --git a/arch/ia64/include/asm/uv/uv.h b/arch/ia64/include/asm/uv/uv.h
index 61b5bdf..8f6cbaa 100644
--- a/arch/ia64/include/asm/uv/uv.h
+++ b/arch/ia64/include/asm/uv/uv.h
@@ -1,7 +1,6 @@
 #ifndef _ASM_IA64_UV_UV_H
 #define _ASM_IA64_UV_UV_H
 
-#include <asm/system.h>
 #include <asm/sn/simulator.h>
 
 static inline int is_uv_system(void)
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 5207035..93c6488 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -50,7 +50,6 @@
 #include <asm/iosapic.h>
 #include <asm/machvec.h>
 #include <asm/page.h>
-#include <asm/system.h>
 #include <asm/numa.h>
 #include <asm/sal.h>
 #include <asm/cyclone.h>
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 331d42b..f15d860 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -21,7 +21,6 @@
 #include <asm/thread_info.h>
 #include <asm/sal.h>
 #include <asm/signal.h>
-#include <asm/system.h>
 #include <asm/unistd.h>
 
 #include "entry.h"
diff --git a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
index 245d3e1..d3b33c9 100644
--- a/arch/ia64/kernel/gate.S
+++ b/arch/ia64/kernel/gate.S
@@ -11,7 +11,6 @@
 #include <asm/errno.h>
 #include <asm/asm-offsets.h>
 #include <asm/sigcontext.h>
-#include <asm/system.h>
 #include <asm/unistd.h>
 #include "paravirt_inst.h"
 
diff --git a/arch/ia64/kernel/gate.lds.S b/arch/ia64/kernel/gate.lds.S
index d32b085..5f90a86 100644
--- a/arch/ia64/kernel/gate.lds.S
+++ b/arch/ia64/kernel/gate.lds.S
@@ -6,7 +6,6 @@
  */
 
 
-#include <asm/system.h>
 #include "paravirt_patchlist.h"
 
 SECTIONS
diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
index 17a9fba..629a250 100644
--- a/arch/ia64/kernel/head.S
+++ b/arch/ia64/kernel/head.S
@@ -30,7 +30,6 @@
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
-#include <asm/system.h>
 #include <asm/mca_asm.h>
 #include <linux/init.h>
 #include <linux/linkage.h>
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index b0f9afe..ef4b5d8 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -98,7 +98,6 @@
 #include <asm/machvec.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
-#include <asm/system.h>
 
 #undef DEBUG_INTERRUPT_ROUTING
 
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 782c3a35..08113b1 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -39,7 +39,6 @@
 #include <asm/hw_irq.h>
 #include <asm/machvec.h>
 #include <asm/pgtable.h>
-#include <asm/system.h>
 #include <asm/tlbflush.h>
 
 #ifdef CONFIG_PERFMON
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index d93e396..fa25689 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -54,7 +54,6 @@
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
-#include <asm/system.h>
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
 #include <asm/errno.h>
diff --git a/arch/ia64/kernel/machvec.c b/arch/ia64/kernel/machvec.c
index d41a40e..f5a1e52 100644
--- a/arch/ia64/kernel/machvec.c
+++ b/arch/ia64/kernel/machvec.c
@@ -1,7 +1,6 @@
 #include <linux/module.h>
 #include <linux/dma-mapping.h>
 #include <asm/machvec.h>
-#include <asm/system.h>
 
 #ifdef CONFIG_IA64_GENERIC
 
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 84fb405..9198a79 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -92,7 +92,6 @@
 #include <asm/meminit.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
-#include <asm/system.h>
 #include <asm/sal.h>
 #include <asm/mca.h>
 #include <asm/kexec.h>
diff --git a/arch/ia64/kernel/mca_drv.c b/arch/ia64/kernel/mca_drv.c
index 09b4d68..1c2e894 100644
--- a/arch/ia64/kernel/mca_drv.c
+++ b/arch/ia64/kernel/mca_drv.c
@@ -28,7 +28,6 @@
 #include <asm/machvec.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
-#include <asm/system.h>
 #include <asm/sal.h>
 #include <asm/mca.h>
 
diff --git a/arch/ia64/kernel/patch.c b/arch/ia64/kernel/patch.c
index 68a1311..1cf0917 100644
--- a/arch/ia64/kernel/patch.c
+++ b/arch/ia64/kernel/patch.c
@@ -11,7 +11,6 @@
 #include <asm/patch.h>
 #include <asm/processor.h>
 #include <asm/sections.h>
-#include <asm/system.h>
 #include <asm/unistd.h>
 
 /*
diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index eb11757..7cdc89b 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -12,7 +12,6 @@
 #include <asm/machvec.h>
 #include <linux/dma-mapping.h>
 
-#include <asm/system.h>
 
 #ifdef CONFIG_INTEL_IOMMU
 
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index b2c65e0..9d0fd7d 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -49,7 +49,6 @@
 #include <asm/perfmon.h>
 #include <asm/processor.h>
 #include <asm/signal.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/delay.h>
 
diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index dad9166..4265ff6 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -26,7 +26,6 @@
 #include <asm/processor.h>
 #include <asm/ptrace_offsets.h>
 #include <asm/rse.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/unwind.h>
 #ifdef CONFIG_PERFMON
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index cd57d73..c45e6dd 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -59,7 +59,6 @@
 #include <asm/sections.h>
 #include <asm/setup.h>
 #include <asm/smp.h>
-#include <asm/system.h>
 #include <asm/tlbflush.h>
 #include <asm/unistd.h>
 #include <asm/hpsim.h>
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 0bd537b..e27f925 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -44,7 +44,6 @@
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 #include <asm/sal.h>
-#include <asm/system.h>
 #include <asm/tlbflush.h>
 #include <asm/unistd.h>
 #include <asm/mca.h>
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 5590979..fb7927b 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -55,7 +55,6 @@
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 #include <asm/sal.h>
-#include <asm/system.h>
 #include <asm/tlbflush.h>
 #include <asm/unistd.h>
 #include <asm/sn/arch.h>
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 43920de..aa94bdd 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -29,7 +29,6 @@
 #include <asm/ptrace.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
-#include <asm/system.h>
 
 #include "fsyscall_gtod_data.h"
 
diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index 6a867dc..a96bcf8 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -23,7 +23,6 @@
 #include <linux/gfp.h>
 #include <asm/page.h>
 #include <asm/pal.h>
-#include <asm/system.h>
 #include <asm/pgtable.h>
 #include <linux/atomic.h>
 #include <asm/tlbflush.h>
diff --git a/arch/ia64/kernel/unwind.c b/arch/ia64/kernel/unwind.c
index fed6afa..8f66195 100644
--- a/arch/ia64/kernel/unwind.c
+++ b/arch/ia64/kernel/unwind.c
@@ -41,7 +41,6 @@
 #include <asm/ptrace_offsets.h>
 #include <asm/rse.h>
 #include <asm/sections.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
 
 #include "entry.h"
diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
index 53c0ba0..0ccb28f 100644
--- a/arch/ia64/kernel/vmlinux.lds.S
+++ b/arch/ia64/kernel/vmlinux.lds.S
@@ -1,7 +1,6 @@
 
 #include <asm/cache.h>
 #include <asm/ptrace.h>
-#include <asm/system.h>
 #include <asm/pgtable.h>
 
 #include <asm-generic/vmlinux.lds.h>
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 20b3593..02d29c2 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -14,7 +14,6 @@
 
 #include <asm/pgtable.h>
 #include <asm/processor.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
 
 extern int die(char *, struct pt_regs *, long);
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 13df239d..0eab454 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -30,7 +30,6 @@
 #include <asm/pgalloc.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
-#include <asm/system.h>
 #include <asm/tlb.h>
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
diff --git a/arch/ia64/oprofile/backtrace.c b/arch/ia64/oprofile/backtrace.c
index f7b7989..6a219a9 100644
--- a/arch/ia64/oprofile/backtrace.c
+++ b/arch/ia64/oprofile/backtrace.c
@@ -14,7 +14,6 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 #include <asm/ptrace.h>
-#include <asm/system.h>
 
 /*
  * For IA64 we need to perform a complex little dance to get both
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index f82f5d4..9462792 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -24,7 +24,6 @@
 
 #include <asm/machvec.h>
 #include <asm/page.h>
-#include <asm/system.h>
 #include <asm/io.h>
 #include <asm/sal.h>
 #include <asm/smp.h>
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 77db0b5..cc2667e 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -33,7 +33,6 @@
 #include <asm/io.h>
 #include <asm/sal.h>
 #include <asm/machvec.h>
-#include <asm/system.h>
 #include <asm/processor.h>
 #include <asm/vga.h>
 #include <asm/sn/arch.h>
diff --git a/arch/ia64/sn/kernel/sn2/prominfo_proc.c b/arch/ia64/sn/kernel/sn2/prominfo_proc.c
index e633288..20b88cb 100644
--- a/arch/ia64/sn/kernel/sn2/prominfo_proc.c
+++ b/arch/ia64/sn/kernel/sn2/prominfo_proc.c
@@ -12,7 +12,6 @@
 #include <linux/slab.h>
 #include <linux/proc_fs.h>
 #include <linux/nodemask.h>
-#include <asm/system.h>
 #include <asm/io.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/sn_cpuid.h>
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index e884ba4..68c8454 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -26,7 +26,6 @@
 #include <asm/processor.h>
 #include <asm/irq.h>
 #include <asm/sal.h>
-#include <asm/system.h>
 #include <asm/delay.h>
 #include <asm/io.h>
 #include <asm/smp.h>
diff --git a/arch/ia64/sn/kernel/sn2/timer.c b/arch/ia64/sn/kernel/sn2/timer.c
index 0f8844e..abab8f9 100644
--- a/arch/ia64/sn/kernel/sn2/timer.c
+++ b/arch/ia64/sn/kernel/sn2/timer.c
@@ -14,7 +14,6 @@
 #include <linux/clocksource.h>
 
 #include <asm/hw_irq.h>
-#include <asm/system.h>
 #include <asm/timex.h>
 
 #include <asm/sn/leds.h>
diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
index c1bd1cf..26aeccb 100644
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -14,7 +14,6 @@
 #include <linux/capability.h>
 #include <linux/device.h>
 #include <linux/delay.h>
-#include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/addrs.h>
diff --git a/arch/ia64/xen/xensetup.S b/arch/ia64/xen/xensetup.S
index b820ed0..e29519e 100644
--- a/arch/ia64/xen/xensetup.S
+++ b/arch/ia64/xen/xensetup.S
@@ -7,7 +7,6 @@
 #include <asm/processor.h>
 #include <asm/asmmacro.h>
 #include <asm/pgtable.h>
-#include <asm/system.h>
 #include <asm/paravirt.h>
 #include <asm/xen/privop.h>
 #include <linux/elfnote.h>

