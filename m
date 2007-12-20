From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 20 Dec 2007 16:13:46 +0000
Subject: [PATCH] ia64: cleanup and improve fsys_gettimeofday
Message-Id: <476A94BA.4060805@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No one really cares?

This patch does:

 - Remove outdated comments (which someday I marked with "?").
 - Reassemble instructions to fit them in fewer bundles.
 - If McKinley Errata 9 workaround is not needed, the workaround
   bundles will be patched out with NOPs. However it also not
   needed to have a totally NOP bundle (nop * 3) before branch.

As a result, this makes the code path 3 (or 2) bundles shorter
(and remove 1 unnecessary stop bit). It seems to be 1% faster.

(10sec loop test, with nojitter @ Madison 1.5GHz x 4)
Before:
 CPU  0:  0.14 (usecs) (0 errors / 69598875 iterations)
 CPU  1:  0.14 (usecs) (0 errors / 69630721 iterations)
 CPU  2:  0.14 (usecs) (0 errors / 69607850 iterations)
 CPU  3:  0.14 (usecs) (0 errors / 69619832 iterations)

After:
 CPU  0:  0.14 (usecs) (0 errors / 70257728 iterations)
 CPU  1:  0.14 (usecs) (0 errors / 70309498 iterations)
 CPU  2:  0.14 (usecs) (0 errors / 70280639 iterations)
 CPU  3:  0.14 (usecs) (0 errors / 70260682 iterations)

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/fsys.S  |   28 ++++++++++++----------------
 arch/ia64/kernel/patch.c |    8 ++++----
 2 files changed, 16 insertions(+), 20 deletions(-)

Index: linux-2.6.24-rc5/arch/ia64/kernel/fsys.S
=================================--- linux-2.6.24-rc5.orig/arch/ia64/kernel/fsys.S
+++ linux-2.6.24-rc5/arch/ia64/kernel/fsys.S
@@ -210,27 +210,25 @@
 	// Note that instructions are optimized for McKinley. McKinley can
 	// process two bundles simultaneously and therefore we continuously
 	// try to feed the CPU two bundles and then a stop.
-	//
-	// Additional note that code has changed a lot. Optimization is TBD.
-	// Comments begin with "?" are maybe outdated.
-	tnat.nz p6,p0 = r31	// ? branch deferred to fit later bundle
-	mov pr = r30,0xc000	// Set predicates according to function
+
 	add r2 = TI_FLAGS+IA64_TASK_SIZE,r16
+	tnat.nz p6,p0 = r31		// guard against Nat argument
+(p6)	br.cond.spnt.few .fail_einval
 	movl r20 = fsyscall_gtod_data // load fsyscall gettimeofday data address
 	;;
+	ld4 r2 = [r2]			// process work pending flags
 	movl r29 = itc_jitter_data	// itc_jitter
 	add r22 = IA64_GTOD_WALL_TIME_OFFSET,r20	// wall_time
-	ld4 r2 = [r2]		// process work pending flags
-	;;
-(p15)	add r22 = IA64_GTOD_MONO_TIME_OFFSET,r20	// monotonic_time
 	add r21 = IA64_CLKSRC_MMIO_OFFSET,r20
-	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r29
+	mov pr = r30,0xc000	// Set predicates according to function
+	;;
 	and r2 = TIF_ALLWORK_MASK,r2
-(p6)    br.cond.spnt.few .fail_einval	// ? deferred branch
+	add r19 = IA64_ITC_LASTCYCLE_OFFSET,r29
+(p15)	add r22 = IA64_GTOD_MONO_TIME_OFFSET,r20	// monotonic_time
 	;;
-	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20 // clksrc_cycle_last
+	add r26 = IA64_CLKSRC_CYCLE_LAST_OFFSET,r20	// clksrc_cycle_last
 	cmp.ne p6, p0 = 0, r2	// Fallback if work is scheduled
-(p6)    br.cond.spnt.many fsys_fallback_syscall
+(p6)	br.cond.spnt.many fsys_fallback_syscall
 	;;
 	// Begin critical section
 .time_redo:
@@ -258,7 +256,6 @@
 (p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
 (p9)	ld8 r2 = [r30]		// MMIO_TIMER. Could also have latency issues..
 (p13)	ld8 r25 = [r19]		// get itc_lastcycle value
-	;;		// ? could be removed by moving the last add upward
 	ld8 r9 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_sec
 	;;
 	ld8 r8 = [r22],-IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_nsec
@@ -285,13 +282,12 @@
 EX(.fail_efault, probe.w.fault r31, 3)
 	xmpy.l f8 = f8,f7	// nsec_per_cyc*(counter-last_counter)
 	;;
-	// ? simulate tbit.nz.or p7,p0 = r28,0
 	getf.sig r2 = f8
 	mf
 	;;
 	ld4 r10 = [r20]		// gtod_lock.sequence
 	shr.u r2 = r2,r23	// shift by factor
-	;;		// ? overloaded 3 bundles!
+	;;
 	add r8 = r8,r2		// Add xtime.nsecs
 	cmp4.ne p7,p0 = r28,r10
 (p7)	br.cond.dpnt.few .time_redo	// sequence number changed, redo
@@ -319,9 +315,9 @@
 EX(.fail_efault, probe.w.fault r23, 3)	// This also costs 5 cycles
 (p14)	xmpy.hu f8 = f8, f7		// xmpy has 5 cycles latency so use it
 	;;
-	mov r8 = r0
 (p14)	getf.sig r2 = f8
 	;;
+	mov r8 = r0
 (p14)	shr.u r21 = r2, 4
 	;;
 EX(.fail_efault, st8 [r31] = r9)
Index: linux-2.6.24-rc5/arch/ia64/kernel/patch.c
=================================--- linux-2.6.24-rc5.orig/arch/ia64/kernel/patch.c
+++ linux-2.6.24-rc5/arch/ia64/kernel/patch.c
@@ -135,10 +135,10 @@

 	while (offp < (s32 *) end) {
 		wp = (u64 *) ia64_imva((char *) offp + *offp);
-		wp[0] = 0x0000000100000000UL; /* nop.m 0; nop.i 0; nop.i 0 */
-		wp[1] = 0x0004000000000200UL;
-		wp[2] = 0x0000000100000011UL; /* nop.m 0; nop.i 0; br.ret.sptk.many b6 */
-		wp[3] = 0x0084006880000200UL;
+		wp[0] = 0x0000000100000011UL; /* nop.m 0; nop.i 0; br.ret.sptk.many b6 */
+		wp[1] = 0x0084006880000200UL;
+		wp[2] = 0x0000000100000000UL; /* nop.m 0; nop.i 0; nop.i 0 */
+		wp[3] = 0x0004000000000200UL;
 		ia64_fc(wp); ia64_fc(wp + 2);
 		++offp;
 	}

