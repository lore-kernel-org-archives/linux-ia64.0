From: Peter Keilty <peter.keilty@hp.com>
Date: Thu, 26 Apr 2007 20:26:32 +0000
Subject: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: John Stultz <johnstul@us.ibm.com>, Peter Keilty <peter.keilty@hp.com>, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

From: Peter Keilty <peter.keilty@hp.com>

Initial ia64 conversion to the generic timekeeping/clocksource code.

Signed-off-by: Peter Keilty <peter.keilty@hp.com>
Signed-off-by: John Stultz <johnstul@us.ibm.com>

---

 arch/ia64/Kconfig                     |    6 +-
 arch/ia64/configs/bigsur_defconfig    |    2 
 arch/ia64/configs/gensparse_defconfig |    2 
 arch/ia64/configs/sim_defconfig       |    2 
 arch/ia64/configs/sn2_defconfig       |    2 
 arch/ia64/configs/tiger_defconfig     |    2 
 arch/ia64/configs/zx1_defconfig       |    2 
 arch/ia64/defconfig                   |    2 
 arch/ia64/kernel/asm-offsets.c        |   18 ++----
 arch/ia64/kernel/cyclone.c            |   45 +++++++++++-----
 arch/ia64/kernel/fsys.S               |   93 ++++++++++++++--------------------
 arch/ia64/kernel/time.c               |   70 ++++++++++++++++++++++---
 arch/ia64/sn/kernel/sn2/timer.c       |   28 +++++++---
 drivers/acpi/processor_idle.c         |    4 +
 drivers/char/hpet.c                   |   68 +++++++++++++-----------
 include/linux/clocksource.h           |    3 +
 16 files changed, 214 insertions(+), 135 deletions(-)

linux-2.6.21-rc1_timeofday-arch-ia64_C7.patch
======================
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index d51f0f1..9a7260a 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -56,7 +56,11 @@ config GENERIC_CALIBRATE_DELAY
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
index 9d1cffb..5bd072a 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -86,7 +86,7 @@ CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index 949dc46..17bdfc8 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -84,7 +84,7 @@ CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
diff --git a/arch/ia64/defconfig b/arch/ia64/defconfig
index 9001b3f..61ad76a 100644
--- a/arch/ia64/defconfig
+++ b/arch/ia64/defconfig
@@ -86,7 +86,7 @@ CONFIG_MMU=y
 CONFIG_SWIOTLB=y
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_GENERIC_CALIBRATE_DELAY=y
-CONFIG_TIME_INTERPOLATION=y
+CONFIG_GENERIC_TIME=y
 CONFIG_EFI=y
 CONFIG_GENERIC_IOMAP=y
 CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
diff --git a/arch/ia64/kernel/asm-offsets.c b/arch/ia64/kernel/asm-offsets.c
index 75a2a2c..3e4039e 100644
--- a/arch/ia64/kernel/asm-offsets.c
+++ b/arch/ia64/kernel/asm-offsets.c
@@ -7,6 +7,7 @@
 #define ASM_OFFSETS_C 1
 
 #include <linux/sched.h>
+#include <linux/clocksource.h>
 
 #include <asm-ia64/processor.h>
 #include <asm-ia64/ptrace.h>
@@ -255,17 +256,10 @@ #endif
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
 	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
+	DEFINE(IA64_CLOCKSOURCE_MASK_OFFSET, offsetof (struct clocksource, mask));
+	DEFINE(IA64_CLOCKSOURCE_MULT_OFFSET, offsetof (struct clocksource, mult));
+	DEFINE(IA64_CLOCKSOURCE_SHIFT_OFFSET, offsetof (struct clocksource, shift));
+	DEFINE(IA64_CLOCKSOURCE_MMIO_PTR_OFFSET, offsetof (struct clocksource, fsys_mmio_ptr));
+	DEFINE(IA64_CLOCKSOURCE_CYCLE_LAST_OFFSET, offsetof (struct clocksource, cycle_last));
 }
diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index e00b215..280383b 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -3,6 +3,7 @@ #include <linux/smp.h>
 #include <linux/time.h>
 #include <linux/errno.h>
 #include <linux/timex.h>
+#include <linux/clocksource.h>
 #include <asm/io.h>
 
 /* IBM Summit (EXA) Cyclone counter code*/
@@ -18,13 +19,21 @@ void __init cyclone_setup(void)
 	use_cyclone = 1;
 }
 
+static void __iomem *cyclone_mc_ptr;
 
-struct time_interpolator cyclone_interpolator = {
-	.source =	TIME_SOURCE_MMIO64,
-	.shift =	16,
-	.frequency =	CYCLONE_TIMER_FREQ,
-	.drift =	-100,
-	.mask =		(1LL << 40) - 1
+static cycle_t read_cyclone(void)
+{
+	return (cycle_t)readq((void __iomem *)cyclone_mc_ptr);
+}
+
+static struct clocksource clocksource_cyclone = {
+        .name           = "cyclone",
+        .rating         = 300,
+        .read           = read_cyclone,
+        .mask           = (1LL << 40) - 1,
+        .mult           = 0, /*to be caluclated*/
+        .shift          = 16,
+        .is_continuous  = 1,
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
@@ -101,8 +116,10 @@ int __init init_cyclone_clock(void)
 		}
 	}
 	/* initialize last tick */
-	cyclone_interpolator.addr = cyclone_timer;
-	register_time_interpolator(&cyclone_interpolator);
+	clocksource_cyclone.fsys_mmio_ptr = cyclone_mc_ptr = cyclone_timer;
+	clocksource_cyclone.mult = clocksource_hz2mult(CYCLONE_TIMER_FREQ,
+						clocksource_cyclone.shift);
+	clocksource_register(&clocksource_cyclone);
 
 	return 0;
 }
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 7a05b1c..778ca5f 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -145,13 +145,6 @@ (p8)	br.spnt.many fsys_fallback_syscall
 	FSYS_RETURN
 END(fsys_set_tid_address)
 
-/*
- * Ensure that the time interpolator structure is compatible with the asm code
- */
-#if IA64_TIME_INTERPOLATOR_SOURCE_OFFSET !=0 || IA64_TIME_INTERPOLATOR_SHIFT_OFFSET != 2 \
-	|| IA64_TIME_INTERPOLATOR_JITTER_OFFSET != 3 || IA64_TIME_INTERPOLATOR_NSEC_OFFSET != 4
-#error fsys_gettimeofday incompatible with changes to struct time_interpolator
-#endif
 #define CLOCK_REALTIME 0
 #define CLOCK_MONOTONIC 1
 #define CLOCK_DIVIDE_BY_1000 0x4000
@@ -177,19 +170,18 @@ (p6)    br.cond.spnt.few .fail_einval
 	// r11 = preserved: saved ar.pfs
 	// r12 = preserved: memory stack
 	// r13 = preserved: thread pointer
-	// r14 = address of mask / mask
+	// r14 = address of mask / mask value
 	// r15 = preserved: system call number
 	// r16 = preserved: current task pointer
 	// r17 = wall to monotonic use
-	// r18 = time_interpolator->offset
-	// r19 = address of wall_to_monotonic
-	// r20 = pointer to struct time_interpolator / pointer to time_interpolator->address
-	// r21 = shift factor
-	// r22 = address of time interpolator->last_counter
-	// r23 = address of time_interpolator->last_cycle
-	// r24 = adress of time_interpolator->offset
-	// r25 = last_cycle value
-	// r26 = last_counter value
+	// r19 = address of itc_lastcycle
+	// r20 = struct clocksource / address of first element
+	// r21 = shift value
+	// r22 = address of itc_jitter/ wall_to_monotonic
+	// r23 = address of shift
+	// r24 = address mult factor / cycle_last value
+	// r25 = itc_lastcycle value
+	// r26 = address clocksource cycle_last
 	// r27 = pointer to xtime
 	// r28 = sequence number at the beginning of critcal section
 	// r29 = address of seqlock
@@ -199,9 +191,9 @@ (p6)    br.cond.spnt.few .fail_einval
 	// p6,p7 short term use
 	// p8 = timesource ar.itc
 	// p9 = timesource mmio64
-	// p10 = timesource mmio32
+	// p10 = timesource mmio32 - not used
 	// p11 = timesource not to be handled by asm code
-	// p12 = memory time source ( = p9 | p10)
+	// p12 = memory time source ( = p9 | p10) - not used
 	// p13 = do cmpxchg with time_interpolator_last_cycle
 	// p14 = Divide by 1000
 	// p15 = Add monotonic
@@ -212,61 +204,55 @@ (p6)    br.cond.spnt.few .fail_einval
 	tnat.nz p6,p0 = r31	// branch deferred since it does not fit into bundle structure
 	mov pr = r30,0xc000	// Set predicates according to function
 	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
-	movl r20 = time_interpolator
+	movl r20 = fsyscall_clock // load fsyscall clocksource address
 	;;
-	ld8 r20 = [r20]		// get pointer to time_interpolator structure
+	add r10 = IA64_CLOCKSOURCE_MMIO_PTR_OFFSET,r20
 	movl r29 = xtime_lock
 	ld4 r2 = [r2]		// process work pending flags
 	movl r27 = xtime
 	;;	// only one bundle here
-	ld8 r21 = [r20]		// first quad with control information
+	add r14 = IA64_CLOCKSOURCE_MASK_OFFSET,r20
+	movl r22 = itc_jitter
+	add r24 = IA64_CLOCKSOURCE_MULT_OFFSET,r20
 	and r2 = TIF_ALLWORK_MASK,r2
 (p6)    br.cond.spnt.few .fail_einval	// deferred branch
 	;;
-	add r10 = IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET,r20
-	extr r3 = r21,32,32	// time_interpolator->nsec_per_cyc
-	extr r8 = r21,0,16	// time_interpolator->source
+	ld8 r30 = [r10]		// clocksource->mmio_ptr
+	movl r19 = itc_lastcycle
+	add r23 = IA64_CLOCKSOURCE_SHIFT_OFFSET,r20
 	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
 (p6)    br.cond.spnt.many fsys_fallback_syscall
 	;;
-	cmp.eq p8,p12 = 0,r8	// Check for cpu timer
-	cmp.eq p9,p0 = 1,r8	// MMIO64 ?
-	extr r2 = r21,24,8	// time_interpolator->jitter
-	cmp.eq p10,p0 = 2,r8	// MMIO32 ?
-	cmp.ltu p11,p0 = 2,r8	// function or other clock
-(p11)	br.cond.spnt.many fsys_fallback_syscall
+	ld8 r14 = [r14]         // clocksource mask value
+	ld4 r2 = [r22]		// itc_jitter value
+	add r26 = IA64_CLOCKSOURCE_CYCLE_LAST_OFFSET,r20 // clock fsyscall_cycle_last
+	ld4 r3 = [r24]		// clocksource->mult value
+	cmp.eq p8,p9 = 0,r30	// Check for cpu timer, no mmio_ptr, set p8, clear p9
 	;;
-	setf.sig f7 = r3	// Setup for scaling of counter
-(p15)	movl r19 = wall_to_monotonic
-(p12)	ld8 r30 = [r10]
-	cmp.ne p13,p0 = r2,r0	// need jitter compensation?
-	extr r21 = r21,16,8	// shift factor
+	setf.sig f7 = r3	// Setup for mult scaling of counter
+(p15)	movl r22 = wall_to_monotonic
+	ld4 r21 = [r23]		// shift value
+(p8)	cmp.ne p13,p0 = r2,r0	// need jitter compensation, set p13
+(p9)	cmp.eq p13,p0 = 0,r30	// if mmio_ptr, clear p13 jitter control
 	;;
 .time_redo:
 	.pred.rel.mutex p8,p9,p10
 	ld4.acq r28 = [r29]	// xtime_lock.sequence. Must come first for locking purposes
 (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
-	add r22 = IA64_TIME_INTERPOLATOR_LAST_COUNTER_OFFSET,r20
 (p9)	ld8 r2 = [r30]		// readq(ti->address). Could also have latency issues..
-(p10)	ld4 r2 = [r30]		// readw(ti->address)
-(p13)	add r23 = IA64_TIME_INTERPOLATOR_LAST_CYCLE_OFFSET,r20
+(p13)	ld8 r25 = [r19]		// get itc_lastcycle value
 	;;			// could be removed by moving the last add upward
-	ld8 r26 = [r22]		// time_interpolator->last_counter
-(p13)	ld8 r25 = [r23]		// time interpolator->last_cycle
-	add r24 = IA64_TIME_INTERPOLATOR_OFFSET_OFFSET,r20
-(p15)	ld8 r17 = [r19],IA64_TIMESPEC_TV_NSEC_OFFSET
  	ld8 r9 = [r27],IA64_TIMESPEC_TV_NSEC_OFFSET
-	add r14 = IA64_TIME_INTERPOLATOR_MASK_OFFSET, r20
+	ld8 r24 = [r26]		// get fsyscall_cycle_last value
+(p15)	ld8 r17 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET
 	;;
-	ld8 r18 = [r24]		// time_interpolator->offset
 	ld8 r8 = [r27],-IA64_TIMESPEC_TV_NSEC_OFFSET	// xtime.tv_nsec
-(p13)	sub r3 = r25,r2	// Diff needed before comparison (thanks davidm)
+(p13)	sub r3 = r25,r2		// Diff needed before comparison (thanks davidm)
 	;;
-	ld8 r14 = [r14]		// time_interpolator->mask
-(p13)	cmp.gt.unc p6,p7 = r3,r0	// check if it is less than last. p6,p7 cleared
-	sub r10 = r2,r26	// current_counter - last_counter
+(p13)	cmp.gt.unc p6,p7 = r3,r0 // check if it is less than last. p6,p7 cleared
+	sub r10 = r2,r24	// current_counter - last_counter
 	;;
-(p6)	sub r10 = r25,r26	// time we got was less than last_cycle
+(p6)	sub r10 = r25,r24	// time we got was less than last_cycle
 (p7)	mov ar.ccv = r25	// more than last_cycle. Prep for cmpxchg
 	;;
 	and r10 = r10,r14	// Apply mask
@@ -274,22 +260,21 @@ (p7)	mov ar.ccv = r25	// more than last_
 	setf.sig f8 = r10
 	nop.i 123
 	;;
-(p7)	cmpxchg8.rel r3 = [r23],r2,ar.ccv
+(p7)	cmpxchg8.rel r3 = [r19],r2,ar.ccv
 EX(.fail_efault, probe.w.fault r31, 3)	// This takes 5 cycles and we have spare time
 	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
 (p15)	add r9 = r9,r17		// Add wall to monotonic.secs to result secs
 	;;
-(p15)	ld8 r17 = [r19],-IA64_TIMESPEC_TV_NSEC_OFFSET
+(p15)	ld8 r17 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET
 (p7)	cmp.ne p7,p0 = r25,r3	// if cmpxchg not successful redo
 	// simulate tbit.nz.or p7,p0 = r28,0
 	and r28 = ~1,r28	// Make sequence even to force retry if odd
 	getf.sig r2 = f8
 	mf
-	add r8 = r8,r18		// Add time interpolator offset
 	;;
 	ld4 r10 = [r29]		// xtime_lock.sequence
 (p15)	add r8 = r8, r17	// Add monotonic.nsecs to nsecs
-	shr.u r2 = r2,r21
+	shr.u r2 = r2,r21	// shift by factor
 	;;		// overloaded 3 bundles!
 	// End critical section.
 	add r8 = r8,r2		// Add xtime.nsecs
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 39e0cd3..dc52c98 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -20,6 +20,7 @@ #include <linux/interrupt.h>
 #include <linux/efi.h>
 #include <linux/profile.h>
 #include <linux/timex.h>
+#include <linux/clocksource.h>
 
 #include <asm/machvec.h>
 #include <asm/delay.h>
@@ -29,6 +30,10 @@ #include <asm/sal.h>
 #include <asm/sections.h>
 #include <asm/system.h>
 
+static cycle_t itc_get_cycles(void);
+cycle_t	itc_lastcycle __attribute__((aligned(L1_CACHE_BYTES)));
+int	itc_jitter __attribute__((aligned(L1_CACHE_BYTES)));
+
 volatile int time_keeper_id = 0; /* smp_processor_id() of time-keeper */
 
 #ifdef CONFIG_IA64_DEBUG_IRQ
@@ -38,11 +43,16 @@ EXPORT_SYMBOL(last_cli_ip);
 
 #endif
 
-static struct time_interpolator itc_interpolator = {
-	.shift = 16,
-	.mask = 0xffffffffffffffffLL,
-	.source = TIME_SOURCE_CPU
+static struct clocksource clocksource_itc = {
+        .name           = "itc",
+        .rating         = 350,
+        .read           = itc_get_cycles,
+        .mask           = 0xffffffffffffffffLL,
+        .mult           = 0, /*to be caluclated*/
+        .shift          = 16,
+        .is_continuous  = 1,
 };
+static struct clocksource *clocksource_itc_p;
 
 static irqreturn_t
 timer_interrupt (int irq, void *dev_id)
@@ -211,8 +221,6 @@ ia64_init_itm (void)
 					+ itc_freq/2)/itc_freq;
 
 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
-		itc_interpolator.frequency = local_cpu_data->itc_freq;
-		itc_interpolator.drift = itc_drift;
 #ifdef CONFIG_SMP
 		/* On IA64 in an SMP configuration ITCs are never accurately synchronized.
 		 * Jitter compensation requires a cmpxchg which may limit
@@ -224,15 +232,54 @@ #ifdef CONFIG_SMP
 		 * even going backward) if the ITC offsets between the individual CPUs
 		 * are too large.
 		 */
-		if (!nojitter) itc_interpolator.jitter = 1;
+		if (!nojitter) itc_jitter = 1;
 #endif
-		register_time_interpolator(&itc_interpolator);
 	}
 
 	/* Setup the CPU local timer tick */
 	ia64_cpu_local_tick();
+
+	if (!clocksource_itc_p) {
+        	/* Sort out mult/shift values: */
+		clocksource_itc.mult = clocksource_hz2mult(local_cpu_data->itc_freq,
+						   clocksource_itc.shift);
+        	clocksource_register(&clocksource_itc);
+		clocksource_itc_p = &clocksource_itc;
+	}
+}
+
+
+static cycle_t itc_get_cycles()
+{
+	if (itc_jitter) {
+		u64 lcycle;
+		u64 now;
+
+		do {
+			lcycle = itc_lastcycle;
+			now = get_cycles();
+			if (lcycle && time_after(lcycle, now))
+				return lcycle;
+
+			/* When holding the xtime write lock, there's no need
+			 * to add the overhead of the cmpxchg.  Readers are
+			 * force to retry until the write lock is released.
+			 */
+			if (spin_is_locked(&xtime_lock.lock)) {
+				itc_lastcycle = now;
+				return now;
+			}
+			/* Keep track of the last timer value returned.
+			 * The use of cmpxchg here will cause contention in
+			 * an SMP environment.
+			 */
+		} while (unlikely(cmpxchg(&itc_lastcycle, lcycle, now) != lcycle));
+		return now;
+	} else
+		return get_cycles();
 }
 
+
 static struct irqaction timer_irqaction = {
 	.handler =	timer_interrupt,
 	.flags =	IRQF_DISABLED,
@@ -308,3 +355,10 @@ ia64_setup_printk_clock(void)
 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT))
 		ia64_printk_clock = ia64_itc_printk_clock;
 }
+
+struct clocksource fsyscall_clock __attribute__((aligned(L1_CACHE_BYTES)));
+
+void update_vsyscall(struct timespec *wall, struct clocksource *c)
+{
+	fsyscall_clock = *c;
+}
diff --git a/arch/ia64/sn/kernel/sn2/timer.c b/arch/ia64/sn/kernel/sn2/timer.c
index 56a88b6..f6a160b 100644
--- a/arch/ia64/sn/kernel/sn2/timer.c
+++ b/arch/ia64/sn/kernel/sn2/timer.c
@@ -11,6 +11,7 @@ #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/time.h>
 #include <linux/interrupt.h>
+#include <linux/clocksource.h>
 
 #include <asm/hw_irq.h>
 #include <asm/system.h>
@@ -22,11 +23,21 @@ #include <asm/sn/clksupport.h>
 
 extern unsigned long sn_rtc_cycles_per_second;
 
-static struct time_interpolator sn2_interpolator = {
-	.drift = -1,
-	.shift = 10,
-	.mask = (1LL << 55) - 1,
-	.source = TIME_SOURCE_MMIO64
+static void __iomem *sn2_mc_ptr;
+
+static cycle_t read_sn2(void)
+{
+	return (cycle_t)readq(sn2_mc_ptr);
+}
+
+static struct clocksource clocksource_sn2 = {
+        .name           = "sn2_rtc",
+        .rating         = 300,
+        .read           = read_sn2,
+        .mask           = (1LL << 55) - 1,
+        .mult           = 0,
+        .shift          = 10,
+        .is_continuous  = 1,
 };
 
 /*
@@ -47,9 +58,10 @@ ia64_sn_udelay (unsigned long usecs)
 
 void __init sn_timer_init(void)
 {
-	sn2_interpolator.frequency = sn_rtc_cycles_per_second;
-	sn2_interpolator.addr = RTC_COUNTER_ADDR;
-	register_time_interpolator(&sn2_interpolator);
+	clocksource_sn2.fsys_mmio_ptr = sn2_mc_ptr = RTC_COUNTER_ADDR;
+	clocksource_sn2.mult = clocksource_hz2mult(sn_rtc_cycles_per_second,
+							clocksource_sn2.shift);
+	clocksource_register(&clocksource_sn2);
 
 	ia64_udelay = &ia64_sn_udelay;
 }
diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index 6077300..35ad71f 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -480,10 +480,12 @@ #endif
 		/* Get end time (ticks) */
 		t2 = inl(acpi_gbl_FADT.xpm_timer_block.address);
 
+#ifndef CONFIG_IA64
 #ifdef CONFIG_GENERIC_TIME
 		/* TSC halts in C2, so notify users */
 		mark_tsc_unstable();
 #endif
+#endif
 		/* Re-enable interrupts */
 		local_irq_enable();
 		current_thread_info()->status |= TS_POLLING;
@@ -522,10 +524,12 @@ #endif
 			acpi_set_register(ACPI_BITREG_ARB_DISABLE, 0);
 		}
 
+#ifndef CONFIG_IA64
 #ifdef CONFIG_GENERIC_TIME
 		/* TSC halts in C3, so notify users */
 		mark_tsc_unstable();
 #endif
+#endif
 		/* Re-enable interrupts */
 		local_irq_enable();
 		current_thread_info()->status |= TS_POLLING;
diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index 0be700f..5ea7d3e 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -29,6 +29,7 @@ #include <linux/wait.h>
 #include <linux/bcd.h>
 #include <linux/seq_file.h>
 #include <linux/bitops.h>
+#include <linux/clocksource.h>
 
 #include <asm/current.h>
 #include <asm/uaccess.h>
@@ -51,8 +52,34 @@ #define	HPET_DRIFT	(500)
 
 #define HPET_RANGE_SIZE		1024	/* from HPET spec */
 
+#if BITS_PER_LONG = 64
+#define	write_counter(V, MC)	writeq(V, MC)
+#define	read_counter(MC)	readq(MC)
+#else
+#define	write_counter(V, MC) 	writel(V, MC)
+#define	read_counter(MC)	readl(MC)
+#endif
+
 static u32 hpet_nhpet, hpet_max_freq = HPET_USER_FREQ;
 
+static void __iomem *hpet_mc_ptr;
+
+static cycle_t read_hpet(void)
+{
+	return (cycle_t)read_counter((void __iomem *)hpet_mc_ptr);
+}
+
+static struct clocksource clocksource_hpet = {
+        .name           = "hpet",
+        .rating         = 300,
+        .read           = read_hpet,
+        .mask           = 0xffffffffffffffffLL,
+        .mult           = 0, /*to be caluclated*/
+        .shift          = 10,
+        .is_continuous  = 1,
+};
+static struct clocksource *hpet_clocksource_p;
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
@@ -94,13 +121,6 @@ #define	HPET_IE			0x0002	/* interrupt en
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
@@ -909,7 +908,14 @@ int hpet_alloc(struct hpet_data *hdp)
 	}
 
 	hpetp->hp_delta = hpet_calibrate(hpetp);
-	hpet_register_interpolator(hpetp);
+
+	if (!hpet_clocksource_p) {
+        	clocksource_hpet.fsys_mmio_ptr = hpet_mc_ptr = &hpetp->hp_hpet->hpet_mc;
+        	clocksource_hpet.mult = clocksource_hz2mult(hpetp->hp_tick_freq,
+						clocksource_hpet.shift);
+        	clocksource_register(&clocksource_hpet);
+		hpet_clocksource_p = hpetp->hp_clocksource = &clocksource_hpet;
+	}
 
 	return 0;
 }
@@ -995,7 +1001,7 @@ static int hpet_acpi_add(struct acpi_dev
 
 static int hpet_acpi_remove(struct acpi_device *device, int type)
 {
-	/* XXX need to unregister interpolator, dealloc mem, etc */
+	/* XXX need to unregister clocksource, dealloc mem, etc */
 	return -EINVAL;
 }
 
diff --git a/include/linux/clocksource.h b/include/linux/clocksource.h
index daa4940..a20b4d6 100644
--- a/include/linux/clocksource.h
+++ b/include/linux/clocksource.h
@@ -61,6 +61,9 @@ struct clocksource {
 	u32 shift;
 	unsigned long flags;
 	cycle_t (*vread)(void);
+#ifdef CONFIG_IA64
+	void *fsys_mmio_ptr;	/* used by fsyscall asm code */
+#endif
 
 	/* timekeeping specific data, ignore */
 	cycle_t cycle_last, cycle_interval;
