From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 20 Jul 2007 16:33:43 +0000
Subject: RE: [PATCH 0/3] fix ia64 clocksource
Message-Id: <617E1C2C70743745A92448908E030B2A01FA46DF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <469E2AAF.30705@jp.fujitsu.com>
In-Reply-To: <469E2AAF.30705@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I need to make the cleanups Tony identified. After that how would you like to
> proceed? Combining your patch 1/3 and my 1/2 seems logical.

I've done the cleanup, and merged Seto-san's parts 1,2,3 with your part 1, and
updated it all for the tip of Linus' tree.  Result is below.

Part 2 stayed the same, except that I also deleted Documentation/time_interpolators.txt

I'm going to send both to Linus later today ... so read fast and shout if
I botched the merge.

Time taken for a single gettimeofday() call via the fsys.S path has increased
by about 8 cycles, but this would only be significant for applications doing
> 1,000,000 gettimeofday calls per second.  The scalability problems are so
bad that I can't even get close to that rate on 4 cpus (peak cumulative rate
is about 600,000).  The patched system still has problems, but scalabilty is
better (4 cpus can get to 1,100,000 cumulative calls per second).

-Tony

commit 89f8d0677c72742767f98b9f5fcfbd575e73d0ae
Author: Tony Luck <tony.luck@intel.com>
Date:   Wed Jul 18 15:38:51 2007 -0700

    [IA64] Convert to generic timekeeping/clocksource
    
    This is a merge of Peter Keilty's initial patch for this with
    Hidetoshi Seto's fixes and scaling improvements.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 9a54148..68115d7 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1154,6 +1154,8 @@ and is between 256 and 4096 characters. It is defined in the file
 
 	nointroute	[IA-64]
 
+	nojitter	[IA64] Disables jitter checking for ITC timers.
+
 	nolapic		[IA-32,APIC] Do not enable or use the local APIC.
 
 	nolapic_timer	[IA-32,APIC] Do not use the local APIC timer.
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 616c96e..36c7b96 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -62,7 +62,11 @@ config GENERIC_CALIBRATE_DELAY
 	bool
 	default y
 
-config TIME_INTERPOLATION
+config GENERIC_TIME
+	bool
+	default y
+
+config GENERIC_TIME_VSYSCALL
 	bool
 	default y
 
diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index 90e9c2e..9eb48c0 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -85,7 +85,7 @@ CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index 0d29aa2..3a9ed95 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -86,7 +86,7 @@ CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
diff --git a/arch/ia64/configs/sim_defconfig b/arch/ia64/configs/sim_defconfig
index d9146c3..c420d9f 100644
--- a/arch/ia64/configs/sim_defconfig
+++ b/arch/ia64/configs/sim_defconfig
@@ -86,7 +86,7 @@ CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index 64e951d..4c9ffc4 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -93,7 +93,7 @@ CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index a144693..e208747 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -98,7 +98,7 @@ CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 # CONFIG_ARCH_HAS_ILOG2_U64 is not set
 CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index 1c7955c..4a060fc 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -96,7 +96,7 @@ CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 # CONFIG_ARCH_HAS_ILOG2_U64 is not set
 CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
diff --git a/arch/ia64/defconfig b/arch/ia64/defconfig
index 90bd960..461f8ee 100644
--- a/arch/ia64/defconfig
+++ b/arch/ia64/defconfig
@@ -98,7 +98,7 @@ CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 # CONFIG_ARCH_HAS_ILOG2_U64 is not set
 CONFIG_GENERIC_FIND_NEXT_BIT=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_DMI=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 2236fab..0aebc6f 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -7,6 +7,7 @@
 #define ASM_OFFSETS_C 1
 
 #include <linux/sched.h>
+#include <linux/clocksource.h>
 
 #include <asm-ia64/processor.h>
 #include <asm-ia64/ptrace.h>
@@ -15,6 +16,7 @@
 #include <asm-ia64/mca.h>
 
 #include "../kernel/sigframe.h"
+#include "../kernel/fsyscall_gtod_data.h"
 
 #define DEFINE(sym, val) \
         asm volatile("\n->" #sym " %0 " #val : : "i" (val))
@@ -256,17 +258,24 @@ void foo(void)
 	BLANK();
 
 	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
-	DEFINE(IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET, offsetof (struct time_interpolator, addr));
-	DEFINE(IA64_TIME_INTERPOLATOR_SOURCE_OFFSET, offsetof (struct time_interpolator, source));
-	DEFINE(IA64_TIME_INTERPOLATOR_SHIFT_OFFSET, offsetof (struct time_interpolator, shift));
-	DEFINE(IA64_TIME_INTERPOLATOR_NSEC_OFFSET, offsetof (struct time_interpolator, nsec_per_cyc));
-	DEFINE(IA64_TIME_INTERPOLATOR_OFFSET_OFFSET, offsetof (struct time_interpolator, offset));
-	DEFINE(IA64_TIME_INTERPOLATOR_LAST_CYCLE_OFFSET, offsetof (struct time_interpolator, last_cycle));
-	DEFINE(IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET, offsetof (struct time_interpolator, last_counter));
-	DEFINE(IA64_TIME_INTERPOLATOR_JITTER_OFFSET, offsetof (struct time_interpolator, jitter));
-	DEFINE(IA64_TIME_INTERPOLATOR_MASK_OFFSET, offsetof (struct time_interpolator, mask));
-	DEFINE(IA64_TIME_SOURCE_CPU, TIME_SOURCE_CPU);
-	DEFINE(IA64_TIME_SOURCE_MMIO64, TIME_SOURCE_MMIO64);
-	DEFINE(IA64_TIME_SOURCE_MMIO32, TIME_SOURCE_MMIO32);
-	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
+	DEFINE(IA64_GTOD_LOCK_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, lock));
+	DEFINE(IA64_GTOD_WALL_TIME_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, wall_time));
+	DEFINE(IA64_GTOD_MONO_TIME_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, monotonic_time));
+	DEFINE(IA64_CLKSRC_MASK_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_mask));
+	DEFINE(IA64_CLKSRC_MULT_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_mult));
+	DEFINE(IA64_CLKSRC_SHIFT_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_shift));
+	DEFINE(IA64_CLKSRC_MMIO_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_fsys_mmio));
+	DEFINE(IA64_CLKSRC_CYCLE_LAST_OFFSET,
+		offsetof (struct fsyscall_gtod_data_t, clk_cycle_last));
+	DEFINE(IA64_ITC_JITTER_OFFSET,
+		offsetof (struct itc_jitter_data_t, itc_jitter));
+	DEFINE(IA64_ITC_LASTCYCLE_OFFSET,
+		offsetof (struct itc_jitter_data_t, itc_lastcycle));
 }
diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index e00b215..2fd96d9 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -3,6 +3,7 @@
 #include <linux/time.h>
 #include <linux/errno.h>
 #include <linux/timex.h>
+#include <linux/clocksource.h>
 #include <asm/io.h>
 
 /* IBM Summit (EXA) Cyclone counter code*/
@@ -18,13 +19,21 @@ void __init cyclone_setup(void)
 	use_cyclone = 1;
 }
 
+static void __iomem *cyclone_mc;
 
-struct time_interpolator cyclone_interpolator = {
-	.source =	TIME_SOURCE_MMIO64,
-	.shift =	16,
-	.frequency =	CYCLONE_TIMER_FREQ,
-	.drift =	-100,
-	.mask =		(1LL << 40) - 1
+static cycle_t read_cyclone(void)
+{
+	return (cycle_t)readq((void __iomem *)cyclone_mc);
+}
+
+static struct clocksource clocksource_cyclone = {
+        .name           = "cyclone",
+        .rating         = 300,
+        .read           = read_cyclone,
+        .mask           = (1LL << 40) - 1,
+        .mult           = 0, /*to be caluclated*/
+        .shift          = 16,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
 };
 
 int __init init_cyclone_clock(void)
@@ -44,13 +53,15 @@ int __init init_cyclone_clock(void)
 	offset = (CYCLONE_CBAR_ADDR);
 	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
 	if(!reg){
-		printk(KERN_ERR "Summit chipset: Could not find valid CBAR register.\n");
+		printk(KERN_ERR "Summit chipset: Could not find valid CBAR"
+				" register.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
 	base = readq(reg);
 	if(!base){
-		printk(KERN_ERR "Summit chipset: Could not find valid CBAR value.\n");
+		printk(KERN_ERR "Summit chipset: Could not find valid CBAR"
+				" value.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
@@ -60,7 +71,8 @@ int __init init_cyclone_clock(void)
 	offset = (base + CYCLONE_PMCC_OFFSET);
 	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
 	if(!reg){
-		printk(KERN_ERR "Summit chipset: Could not find valid PMCC register.\n");
+		printk(KERN_ERR "Summit chipset: Could not find valid PMCC"
+				" register.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
@@ -71,7 +83,8 @@ int __init init_cyclone_clock(void)
 	offset = (base + CYCLONE_MPCS_OFFSET);
 	reg = (u64*)ioremap_nocache(offset, sizeof(u64));
 	if(!reg){
-		printk(KERN_ERR "Summit chipset: Could not find valid MPCS register.\n");
+		printk(KERN_ERR "Summit chipset: Could not find valid MPCS"
+				" register.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
@@ -82,7 +95,8 @@ int __init init_cyclone_clock(void)
 	offset = (base + CYCLONE_MPMC_OFFSET);
 	cyclone_timer = (u32*)ioremap_nocache(offset, sizeof(u32));
 	if(!cyclone_timer){
-		printk(KERN_ERR "Summit chipset: Could not find valid MPMC register.\n");
+		printk(KERN_ERR "Summit chipset: Could not find valid MPMC"
+				" register.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
@@ -93,7 +107,8 @@ int __init init_cyclone_clock(void)
 		int stall = 100;
 		while(stall--) barrier();
 		if(readl(cyclone_timer) = old){
-			printk(KERN_ERR "Summit chipset: Counter not counting! DISABLED\n");
+			printk(KERN_ERR "Summit chipset: Counter not counting!"
+					" DISABLED\n");
 			iounmap(cyclone_timer);
 			cyclone_timer = 0;
 			use_cyclone = 0;
@@ -101,8 +116,11 @@ int __init init_cyclone_clock(void)
 		}
 	}
 	/* initialize last tick */
-	cyclone_interpolator.addr = cyclone_timer;
-	register_time_interpolator(&cyclone_interpolator);
+	cyclone_mc = cyclone_timer;
+	clocksource_cyclone.fsys_mmio = cyclone_timer;
+	clocksource_cyclone.mult = clocksource_hz2mult(CYCLONE_TIMER_FREQ,
+						clocksource_cyclone.shift);
+	clocksource_register(&clocksource_cyclone);
 
 	return 0;
 }
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 3f926c2..4484197 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -147,12 +147,11 @@ ENTRY(fsys_set_tid_address)
 	FSYS_RETURN
 END(fsys_set_tid_address)
 
-/*
- * Ensure that the time interpolator structure is compatible with the asm code
- */
-#if IA64_TIME_INTERPOLATOR_SOURCE_OFFSET !=0 || IA64_TIME_INTERPOLATOR_SHIFT_OFFSET != 2 \
-	|| IA64_TIME_INTERPOLATOR_JITTER_OFFSET != 3 || IA64_TIME_INTERPOLATOR_NSEC_OFFSET != 4
-#error fsys_gettimeofday incompatible with changes to struct time_interpolator
+#if IA64_GTOD_LOCK_OFFSET !=0
+#error fsys_gettimeofday incompatible with changes to struct fsyscall_gtod_data_t
+#endif
+#if IA64_ITC_JITTER_OFFSET !=0
+#error fsys_gettimeofday incompatible with changes to struct itc_jitter_data_t
 #endif
 #define CLOCK_REALTIME 0
 #define CLOCK_MONOTONIC 1
@@ -179,126 +178,124 @@ ENTRY(fsys_gettimeofday)
 	// r11 = preserved: saved ar.pfs
 	// r12 = preserved: memory stack
 	// r13 = preserved: thread pointer
-	// r14 = address of mask / mask
+	// r14 = address of mask / mask value
 	// r15 = preserved: system call number
 	// r16 = preserved: current task pointer
-	// r17 = wall to monotonic use
-	// r18 = time_interpolator->offset
-	// r19 = address of wall_to_monotonic
-	// r20 = pointer to struct time_interpolator / pointer to time_interpolator->address
-	// r21 = shift factor
-	// r22 = address of time interpolator->last_counter
-	// r23 = address of time_interpolator->last_cycle
-	// r24 = adress of time_interpolator->offset
-	// r25 = last_cycle value
-	// r26 = last_counter value
-	// r27 = pointer to xtime
+	// r17 = (not used)
+	// r18 = (not used)
+	// r19 = address of itc_lastcycle
+	// r20 = struct fsyscall_gtod_data (= address of gtod_lock.sequence)
+	// r21 = address of mmio_ptr
+	// r22 = address of wall_time or monotonic_time
+	// r23 = address of shift / value
+	// r24 = address mult factor / cycle_last value
+	// r25 = itc_lastcycle value
+	// r26 = address clocksource cycle_last
+	// r27 = (not used)
 	// r28 = sequence number at the beginning of critcal section
-	// r29 = address of seqlock
+	// r29 = address of itc_jitter
 	// r30 = time processing flags / memory address
 	// r31 = pointer to result
 	// Predicates
 	// p6,p7 short term use
 	// p8 = timesource ar.itc
 	// p9 = timesource mmio64
-	// p10 = timesource mmio32
+	// p10 = timesource mmio32 - not used
 	// p11 = timesource not to be handled by asm code
-	// p12 = memory time source ( = p9 | p10)
-	// p13 = do cmpxchg with time_interpolator_last_cycle
+	// p12 = memory time source ( = p9 | p10) - not used
+	// p13 = do cmpxchg with itc_lastcycle
 	// p14 = Divide by 1000
 	// p15 = Add monotonic
 	//
-	// Note that instructions are optimized for McKinley. McKinley can process two
-	// bundles simultaneously and therefore we continuously try to feed the CPU
-	// two bundles and then a stop.
-	tnat.nz p6,p0 = r31	// branch deferred since it does not fit into bundle structure
+	// Note that instructions are optimized for McKinley. McKinley can
+	// process two bundles simultaneously and therefore we continuously
+	// try to feed the CPU two bundles and then a stop.
+	//
+	// Additional note that code has changed a lot. Optimization is TBD.
+	// Comments begin with "?" are maybe outdated.
+	tnat.nz p6,p0 = r31	// ? branch deferred to fit later bundle
 	mov pr = r30,0xc000	// Set predicates according to function
 	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
-	movl r20 = time_interpolator
+	movl r20 = fsyscall_gtod_data // load fsyscall gettimeofday data address
 	;;
-	ld8 r20 = [r20]		// get pointer to time_interpolator structure
-	movl r29 = xtime_lock
+	movl r29 = itc_jitter_data	// itc_jitter
+	add r22 = IA64_GTOD_WALL_TIME_OFFSET,r20	// wall_time
 	ld4 r2 = [r2]		// process work pending flags
-	movl r27 = xtime
-	;;	// only one bundle here
-	ld8 r21 = [r20]		// first quad with control information
+	;;
+(p15)	add r22 = IA64_GTOD_MONO_TIME_OFFSET,r20	// monotonic_time
+	add r21 = IA64_CLKSRC_MMIO_OFFSET,r20
+	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r29
 	and r2 = TIF_ALLWORK_MASK,r2
-(p6)    br.cond.spnt.few .fail_einval	// deferred branch
+(p6)    br.cond.spnt.few .fail_einval	// ? deferred branch
 	;;
-	add r10 = IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET,r20
-	extr r3 = r21,32,32	// time_interpolator->nsec_per_cyc
-	extr r8 = r21,0,16	// time_interpolator->source
+	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20 // clksrc_cycle_last
 	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
 (p6)    br.cond.spnt.many fsys_fallback_syscall
 	;;
-	cmp.eq p8,p12 = 0,r8	// Check for cpu timer
-	cmp.eq p9,p0 = 1,r8	// MMIO64 ?
-	extr r2 = r21,24,8	// time_interpolator->jitter
-	cmp.eq p10,p0 = 2,r8	// MMIO32 ?
-	cmp.ltu p11,p0 = 2,r8	// function or other clock
-(p11)	br.cond.spnt.many fsys_fallback_syscall
+	// Begin critical section
+.time_redo:
+	ld4.acq r28 = [r20]	// gtod_lock.sequence, Must take first
+	;;
+	and r28 = ~1,r28	// And make sequence even to force retry if odd
 	;;
-	setf.sig f7 = r3	// Setup for scaling of counter
-(p15)	movl r19 = wall_to_monotonic
-(p12)	ld8 r30 = [r10]
-	cmp.ne p13,p0 = r2,r0	// need jitter compensation?
-	extr r21 = r21,16,8	// shift factor
+	ld8 r30 = [r21]		// clocksource->mmio_ptr
+	add r24 = IA64_CLKSRC_MULT_OFFSET,r20
+	ld4 r2 = [r29]		// itc_jitter value
+	add r23 = IA64_CLKSRC_SHIFT_OFFSET,r20
+	add r14 = IA64_CLKSRC_MASK_OFFSET,r20
 	;;
-.time_redo:
-	.pred.rel.mutex p8,p9,p10
-	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
+	ld4 r3 = [r24]		// clocksource mult value
+	ld8 r14 = [r14]         // clocksource mask value
+	cmp.eq p8,p9 = 0,r30	// use cpu timer if no mmio_ptr
 	;;
-	and r28 = ~1,r28	// Make sequence even to force retry if odd
+	setf.sig f7 = r3	// Setup for mult scaling of counter
+(p8)	cmp.ne p13,p0 = r2,r0	// need itc_jitter compensation, set p13
+	ld4 r23 = [r23]		// clocksource shift value
+	ld8 r24 = [r26]		// get clksrc_cycle_last value
+(p9)	cmp.eq p13,p0 = 0,r30	// if mmio_ptr, clear p13 jitter control
 	;;
+	.pred.rel.mutex p8,p9
 (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
-	add r22 = IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
-(p9)	ld8 r2 = [r30]		// readq(ti->address). Could also have latency issues..
-(p10)	ld4 r2 = [r30]		// readw(ti->address)
-(p13)	add r23 = IA64_TIME_INTERPOLATOR_LAST_CYCLE_OFFSET,r20
-	;;			// could be removed by moving the last add upward
-	ld8 r26 = [r22]		// time_interpolator->last_counter
-(p13)	ld8 r25 = [r23]		// time interpolator->last_cycle
-	add r24 = IA64_TIME_INTERPOLATOR_OFFSET_OFFSET,r20
-(p15)	ld8 r17 = [r19],IA64_TIMESPEC_TV_NSEC_OFFSET
- 	ld8 r9 = [r27],IA64_TIMESPEC_TV_NSEC_OFFSET
-	add r14 = IA64_TIME_INTERPOLATOR_MASK_OFFSET, r20
-	;;
-	ld8 r18 = [r24]		// time_interpolator->offset
-	ld8 r8 = [r27],-IA64_TIMESPEC_TV_NSEC_OFFSET	// xtime.tv_nsec
-(p13)	sub r3 = r25,r2	// Diff needed before comparison (thanks davidm)
-	;;
-	ld8 r14 = [r14]		// time_interpolator->mask
-(p13)	cmp.gt.unc p6,p7 = r3,r0	// check if it is less than last. p6,p7 cleared
-	sub r10 = r2,r26	// current_counter - last_counter
-	;;
-(p6)	sub r10 = r25,r26	// time we got was less than last_cycle
+(p9)	ld8 r2 = [r30]		// MMIO_TIMER. Could also have latency issues..
+(p13)	ld8 r25 = [r19]		// get itc_lastcycle value
+	;;		// ? could be removed by moving the last add upward
+	ld8 r9 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_sec
+	;;
+	ld8 r8 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_nsec
+(p13)	sub r3 = r25,r2		// Diff needed before comparison (thanks davidm)
+	;;
+(p13)	cmp.gt.unc p6,p7 = r3,r0 // check if it is less than last. p6,p7 cleared
+	sub r10 = r2,r24	// current_cycle - last_cycle
+	;;
+(p6)	sub r10 = r25,r24	// time we got was less than last_cycle
 (p7)	mov ar.ccv = r25	// more than last_cycle. Prep for cmpxchg
 	;;
+(p7)	cmpxchg8.rel r3 = [r19],r2,ar.ccv
+	;;
+(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful
+	;;
+(p7)	sub r10 = r3,r24	// then use new last_cycle instead
+	;;
 	and r10 = r10,r14	// Apply mask
 	;;
 	setf.sig f8 = r10
 	nop.i 123
 	;;
-(p7)	cmpxchg8.rel r3 = [r23],r2,ar.ccv
-EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have spare time
+	// fault check takes 5 cycles and we have spare time
+EX(.fail_efault, probe.w.fault r31, 3)
 	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
-(p15)	add r9 = r9,r17		// Add wall to monotonic.secs to result secs
 	;;
-(p15)	ld8 r17 = [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
-(p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
-	// simulate tbit.nz.or p7,p0 = r28,0
+	// ? simulate tbit.nz.or p7,p0 = r28,0
 	getf.sig r2 = f8
 	mf
-	add r8 = r8,r18		// Add time interpolator offset
 	;;
-	ld4 r10 = [r29]		// xtime_lock.sequence
-(p15)	add r8 = r8, r17	// Add monotonic.nsecs to nsecs
-	shr.u r2 = r2,r21
-	;;		// overloaded 3 bundles!
-	// End critical section.
+	ld4 r10 = [r20]		// gtod_lock.sequence
+	shr.u r2 = r2,r23	// shift by factor
+	;;		// ? overloaded 3 bundles!
 	add r8 = r8,r2		// Add xtime.nsecs
-	cmp4.ne.or p7,p0 = r28,r10
-(p7)	br.cond.dpnt.few .time_redo	// sequence number changed ?
+	cmp4.ne p7,p0 = r28,r10
+(p7)	br.cond.dpnt.few .time_redo	// sequence number changed, redo
+	// End critical section.
 	// Now r8=tv->tv_nsec and r9=tv->tv_sec
 	mov r10 = r0
 	movl r2 = 1000000000
@@ -308,19 +305,19 @@ EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have spare
 .time_normalize:
 	mov r21 = r8
 	cmp.ge p6,p0 = r8,r2
-(p14)	shr.u r20 = r8, 3		// We can repeat this if necessary just wasting some time
+(p14)	shr.u r20 = r8, 3 // We can repeat this if necessary just wasting time
 	;;
 (p14)	setf.sig f8 = r20
 (p6)	sub r8 = r8,r2
-(p6)	add r9 = 1,r9			// two nops before the branch.
-(p14)	setf.sig f7 = r3		// Chances for repeats are 1 in 10000 for gettod
+(p6)	add r9 = 1,r9		// two nops before the branch.
+(p14)	setf.sig f7 = r3	// Chances for repeats are 1 in 10000 for gettod
 (p6)	br.cond.dpnt.few .time_normalize
 	;;
 	// Divided by 8 though shift. Now divide by 125
 	// The compiler was able to do that with a multiply
 	// and a shift and we do the same
-EX(.fail_efault, probe.w.fault r23, 3)		// This also costs 5 cycles
-(p14)	xmpy.hu f8 = f8, f7			// xmpy has 5 cycles latency so use it...
+EX(.fail_efault, probe.w.fault r23, 3)	// This also costs 5 cycles
+(p14)	xmpy.hu f8 = f8, f7		// xmpy has 5 cycles latency so use it
 	;;
 	mov r8 = r0
 (p14)	getf.sig r2 = f8
diff --git a/arch/ia64/kernel/fsyscall_gtod_data.h b/arch/ia64/kernel/fsyscall_gtod_data.h
new file mode 100644
index 0000000..490dab5
--- /dev/null
+++ b/arch/ia64/kernel/fsyscall_gtod_data.h
@@ -0,0 +1,23 @@
+/*
+ * (c) Copyright 2007 Hewlett-Packard Development Company, L.P.
+ *        Contributed by Peter Keilty <peter.keilty@hp.com>
+ *
+ * fsyscall gettimeofday data
+ */
+
+struct fsyscall_gtod_data_t {
+	seqlock_t	lock;
+	struct timespec	wall_time;
+	struct timespec monotonic_time;
+	cycle_t		clk_mask;
+	u32		clk_mult;
+	u32		clk_shift;
+	void		*clk_fsys_mmio;
+	cycle_t		clk_cycle_last;
+} __attribute__ ((aligned (L1_CACHE_BYTES)));
+
+struct itc_jitter_data_t {
+	int		itc_jitter;
+	cycle_t		itc_lastcycle;
+} __attribute__ ((aligned (L1_CACHE_BYTES)));
+
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 3486fe7..627785c 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -19,6 +19,7 @@
 #include <linux/interrupt.h>
 #include <linux/efi.h>
 #include <linux/timex.h>
+#include <linux/clocksource.h>
 
 #include <asm/machvec.h>
 #include <asm/delay.h>
@@ -28,6 +29,16 @@
 #include <asm/sections.h>
 #include <asm/system.h>
 
+#include "fsyscall_gtod_data.h"
+
+static cycle_t itc_get_cycles(void);
+
+struct fsyscall_gtod_data_t fsyscall_gtod_data = {
+	.lock = SEQLOCK_UNLOCKED,
+};
+
+struct itc_jitter_data_t itc_jitter_data;
+
 volatile int time_keeper_id = 0; /* smp_processor_id() of time-keeper */
 
 #ifdef CONFIG_IA64_DEBUG_IRQ
@@ -37,11 +48,16 @@ EXPORT_SYMBOL(last_cli_ip);
 
 #endif
 
-static struct time_interpolator itc_interpolator = {
-	.shift = 16,
-	.mask = 0xffffffffffffffffLL,
-	.source = TIME_SOURCE_CPU
+static struct clocksource clocksource_itc = {
+        .name           = "itc",
+        .rating         = 350,
+        .read           = itc_get_cycles,
+        .mask           = 0xffffffffffffffff,
+        .mult           = 0, /*to be caluclated*/
+        .shift          = 16,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
 };
+static struct clocksource *itc_clocksource;
 
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id)
@@ -210,8 +226,6 @@ ia64_init_itm (void)
 					+ itc_freq/2)/itc_freq;
 
 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
-		itc_interpolator.frequency = local_cpu_data->itc_freq;
-		itc_interpolator.drift = itc_drift;
 #ifdef CONFIG_SMP
 		/* On IA64 in an SMP configuration ITCs are never accurately synchronized.
 		 * Jitter compensation requires a cmpxchg which may limit
@@ -223,15 +237,50 @@ ia64_init_itm (void)
 		 * even going backward) if the ITC offsets between the individual CPUs
 		 * are too large.
 		 */
-		if (!nojitter) itc_interpolator.jitter = 1;
+		if (!nojitter)
+			itc_jitter_data.itc_jitter = 1;
 #endif
-		register_time_interpolator(&itc_interpolator);
 	}
 
 	/* Setup the CPU local timer tick */
 	ia64_cpu_local_tick();
+
+	if (!itc_clocksource) {
+		/* Sort out mult/shift values: */
+		clocksource_itc.mult +			clocksource_hz2mult(local_cpu_data->itc_freq,
+						clocksource_itc.shift);
+		clocksource_register(&clocksource_itc);
+		itc_clocksource = &clocksource_itc;
+	}
 }
 
+static cycle_t itc_get_cycles()
+{
+	u64 lcycle, now, ret;
+
+	if (!itc_jitter_data.itc_jitter)
+		return get_cycles();
+
+	lcycle = itc_jitter_data.itc_lastcycle;
+	now = get_cycles();
+	if (lcycle && time_after(lcycle, now))
+		return lcycle;
+
+	/*
+	 * Keep track of the last timer value returned.
+	 * In an SMP environment, you could lose out in contention of
+	 * cmpxchg. If so, your cmpxchg returns new value which the
+	 * winner of contention updated to. Use the new value instead.
+	 */
+	ret = cmpxchg(&itc_jitter_data.itc_lastcycle, lcycle, now);
+	if (unlikely(ret != lcycle))
+		return ret;
+
+	return now;
+}
+
+
 static struct irqaction timer_irqaction = {
 	.handler =	timer_interrupt,
 	.flags =	IRQF_DISABLED | IRQF_IRQPOLL,
@@ -307,3 +356,34 @@ ia64_setup_printk_clock(void)
 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT))
 		ia64_printk_clock = ia64_itc_printk_clock;
 }
+
+void update_vsyscall(struct timespec *wall, struct clocksource *c)
+{
+        unsigned long flags;
+
+        write_seqlock_irqsave(&fsyscall_gtod_data.lock, flags);
+
+        /* copy fsyscall clock data */
+        fsyscall_gtod_data.clk_mask = c->mask;
+        fsyscall_gtod_data.clk_mult = c->mult;
+        fsyscall_gtod_data.clk_shift = c->shift;
+        fsyscall_gtod_data.clk_fsys_mmio = c->fsys_mmio;
+        fsyscall_gtod_data.clk_cycle_last = c->cycle_last;
+
+	/* copy kernel time structures */
+        fsyscall_gtod_data.wall_time.tv_sec = wall->tv_sec;
+        fsyscall_gtod_data.wall_time.tv_nsec = wall->tv_nsec;
+        fsyscall_gtod_data.monotonic_time.tv_sec = wall_to_monotonic.tv_sec
+							+ wall->tv_sec;
+        fsyscall_gtod_data.monotonic_time.tv_nsec = wall_to_monotonic.tv_nsec
+							+ wall->tv_nsec;
+
+	/* normalize */
+	while (fsyscall_gtod_data.monotonic_time.tv_nsec >= NSEC_PER_SEC) {
+		fsyscall_gtod_data.monotonic_time.tv_nsec -= NSEC_PER_SEC;
+		fsyscall_gtod_data.monotonic_time.tv_sec++;
+	}
+
+        write_sequnlock_irqrestore(&fsyscall_gtod_data.lock, flags);
+}
+
diff --git a/arch/ia64/sn/kernel/sn2/timer.c b/arch/ia64/sn/kernel/sn2/timer.c
index 56a88b6..19e25d2 100644
--- a/arch/ia64/sn/kernel/sn2/timer.c
+++ b/arch/ia64/sn/kernel/sn2/timer.c
@@ -11,6 +11,7 @@
 #include <linux/sched.h>
 #include <linux/time.h>
 #include <linux/interrupt.h>
+#include <linux/clocksource.h>
 
 #include <asm/hw_irq.h>
 #include <asm/system.h>
@@ -22,11 +23,21 @@
 
 extern unsigned long sn_rtc_cycles_per_second;
 
-static struct time_interpolator sn2_interpolator = {
-	.drift = -1,
-	.shift = 10,
-	.mask = (1LL << 55) - 1,
-	.source = TIME_SOURCE_MMIO64
+static void __iomem *sn2_mc;
+
+static cycle_t read_sn2(void)
+{
+	return (cycle_t)readq(sn2_mc);
+}
+
+static struct clocksource clocksource_sn2 = {
+        .name           = "sn2_rtc",
+        .rating         = 300,
+        .read           = read_sn2,
+        .mask           = (1LL << 55) - 1,
+        .mult           = 0,
+        .shift          = 10,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
 };
 
 /*
@@ -47,9 +58,11 @@ ia64_sn_udelay (unsigned long usecs)
 
 void __init sn_timer_init(void)
 {
-	sn2_interpolator.frequency = sn_rtc_cycles_per_second;
-	sn2_interpolator.addr = RTC_COUNTER_ADDR;
-	register_time_interpolator(&sn2_interpolator);
+	sn2_mc = RTC_COUNTER_ADDR;
+	clocksource_sn2.fsys_mmio = RTC_COUNTER_ADDR;
+	clocksource_sn2.mult = clocksource_hz2mult(sn_rtc_cycles_per_second,
+							clocksource_sn2.shift);
+	clocksource_register(&clocksource_sn2);
 
 	ia64_udelay = &ia64_sn_udelay;
 }
diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index 80ffc78..bb5d23b 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -475,7 +475,7 @@ static void acpi_processor_idle(void)
 		/* Get end time (ticks) */
 		t2 = inl(acpi_gbl_FADT.xpm_timer_block.address);
 
-#ifdef CONFIG_GENERIC_TIME
+#if defined (CONFIG_GENERIC_TIME) && defined (CONFIG_X86_TSC)
 		/* TSC halts in C2, so notify users */
 		mark_tsc_unstable("possible TSC halt in C2");
 #endif
@@ -517,7 +517,7 @@ static void acpi_processor_idle(void)
 			acpi_set_register(ACPI_BITREG_ARB_DISABLE, 0);
 		}
 
-#ifdef CONFIG_GENERIC_TIME
+#if defined (CONFIG_GENERIC_TIME) && defined (CONFIG_X86_TSC)
 		/* TSC halts in C3, so notify users */
 		mark_tsc_unstable("TSC halts in C3");
 #endif
diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index 0be700f..ba0e74a 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -29,6 +29,7 @@
 #include <linux/bcd.h>
 #include <linux/seq_file.h>
 #include <linux/bitops.h>
+#include <linux/clocksource.h>
 
 #include <asm/current.h>
 #include <asm/uaccess.h>
@@ -51,8 +52,34 @@
 
 #define HPET_RANGE_SIZE		1024	/* from HPET spec */
 
+#if BITS_PER_LONG = 64
+#define	write_counter(V, MC)	writeq(V, MC)
+#define	read_counter(MC)	readq(MC)
+#else
+#define	write_counter(V, MC)	writel(V, MC)
+#define	read_counter(MC)	readl(MC)
+#endif
+
 static u32 hpet_nhpet, hpet_max_freq = HPET_USER_FREQ;
 
+static void __iomem *hpet_mctr;
+
+static cycle_t read_hpet(void)
+{
+	return (cycle_t)read_counter((void __iomem *)hpet_mctr);
+}
+
+static struct clocksource clocksource_hpet = {
+        .name           = "hpet",
+        .rating         = 250,
+        .read           = read_hpet,
+        .mask           = 0xffffffffffffffff,
+        .mult           = 0, /*to be caluclated*/
+        .shift          = 10,
+        .flags          = CLOCK_SOURCE_IS_CONTINUOUS,
+};
+static struct clocksource *hpet_clocksource;
+
 /* A lock for concurrent access by app and isr hpet activity. */
 static DEFINE_SPINLOCK(hpet_lock);
 /* A lock for concurrent intermodule access to hpet and isr hpet activity. */
@@ -79,7 +106,7 @@ struct hpets {
 	struct hpets *hp_next;
 	struct hpet __iomem *hp_hpet;
 	unsigned long hp_hpet_phys;
-	struct time_interpolator *hp_interpolator;
+	struct clocksource *hp_clocksource;
 	unsigned long long hp_tick_freq;
 	unsigned long hp_delta;
 	unsigned int hp_ntimer;
@@ -94,13 +121,6 @@ static struct hpets *hpets;
 #define	HPET_PERIODIC		0x0004
 #define	HPET_SHARED_IRQ		0x0008
 
-#if BITS_PER_LONG = 64
-#define	write_counter(V, MC)	writeq(V, MC)
-#define	read_counter(MC)	readq(MC)
-#else
-#define	write_counter(V, MC) 	writel(V, MC)
-#define	read_counter(MC)	readl(MC)
-#endif
 
 #ifndef readq
 static inline unsigned long long readq(void __iomem *addr)
@@ -737,27 +757,6 @@ static ctl_table dev_root[] = {
 
 static struct ctl_table_header *sysctl_header;
 
-static void hpet_register_interpolator(struct hpets *hpetp)
-{
-#ifdef	CONFIG_TIME_INTERPOLATION
-	struct time_interpolator *ti;
-
-	ti = kzalloc(sizeof(*ti), GFP_KERNEL);
-	if (!ti)
-		return;
-
-	ti->source = TIME_SOURCE_MMIO64;
-	ti->shift = 10;
-	ti->addr = &hpetp->hp_hpet->hpet_mc;
-	ti->frequency = hpetp->hp_tick_freq;
-	ti->drift = HPET_DRIFT;
-	ti->mask = -1;
-
-	hpetp->hp_interpolator = ti;
-	register_time_interpolator(ti);
-#endif
-}
-
 /*
  * Adjustment for when arming the timer with
  * initial conditions.  That is, main counter
@@ -909,7 +908,16 @@ int hpet_alloc(struct hpet_data *hdp)
 	}
 
 	hpetp->hp_delta = hpet_calibrate(hpetp);
-	hpet_register_interpolator(hpetp);
+
+	if (!hpet_clocksource) {
+		hpet_mctr = (void __iomem *)&hpetp->hp_hpet->hpet_mc;
+		CLKSRC_FSYS_MMIO_SET(clocksource_hpet.fsys_mmio, hpet_mctr);
+		clocksource_hpet.mult = clocksource_hz2mult(hpetp->hp_tick_freq,
+						clocksource_hpet.shift);
+		clocksource_register(&clocksource_hpet);
+		hpetp->hp_clocksource = &clocksource_hpet;
+		hpet_clocksource = &clocksource_hpet;
+	}
 
 	return 0;
 }
@@ -995,7 +1003,7 @@ static int hpet_acpi_add(struct acpi_device *device)
 
 static int hpet_acpi_remove(struct acpi_device *device, int type)
 {
-	/* XXX need to unregister interpolator, dealloc mem, etc */
+	/* XXX need to unregister clocksource, dealloc mem, etc */
 	return -EINVAL;
 }
 
diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index bf297b0..562c86a 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -67,6 +67,12 @@ struct clocksource {
 	unsigned long flags;
 	cycle_t (*vread)(void);
 	void (*resume)(void);
+#ifdef CONFIG_IA64
+	void *fsys_mmio;        /* used by fsyscall asm code */
+#define CLKSRC_FSYS_MMIO_SET(mmio, addr)      ((mmio) = (addr))
+#else
+#define CLKSRC_FSYS_MMIO_SET(mmio, addr)      (0)
+#endif
 
 	/* timekeeping specific data, ignore */
 	cycle_t cycle_interval;
