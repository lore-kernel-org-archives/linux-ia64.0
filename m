From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 20 Oct 2008 03:55:08 +0000
Subject: [PATCH 06/13] ia64/pv_ops: paravirtualize mov = ar.itc.
Message-Id: <1224474915-17171-7-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize mov reg = ar.itc.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/native/inst.h |    5 +++++
 arch/ia64/kernel/entry.S            |    4 ++--
 arch/ia64/kernel/fsys.S             |    4 ++--
 arch/ia64/kernel/ivt.S              |    2 +-
 4 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/include/asm/native/inst.h b/arch/ia64/include/asm/native/inst.h
index 5e4e151..ad59fc6 100644
--- a/arch/ia64/include/asm/native/inst.h
+++ b/arch/ia64/include/asm/native/inst.h
@@ -77,6 +77,11 @@
 (pred)	mov reg = psr			\
 	CLOBBER(clob)
 
+#define MOV_FROM_ITC(pred, pred_clob, reg, clob)	\
+(pred)	mov reg = ar.itc				\
+	CLOBBER(clob)					\
+	CLOBBER_PRED(pred_clob)
+
 #define MOV_TO_IFA(reg, clob)	\
 	mov cr.ifa = reg	\
 	CLOBBER(clob)
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 7ef0c59..d8462bd 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -734,7 +734,7 @@ GLOBAL_ENTRY(__paravirt_leave_syscall)
 __paravirt_work_processed_syscall:
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	adds r2=PT(LOADRS)+16,r12
-(pUStk)	mov.m r22=ar.itc			// fetch time at leave
+	MOV_FROM_ITC(pUStk, p9, r22, r19)	// fetch time at leave
 	adds r18=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
 (p6)	ld4 r31=[r18]				// load current_thread_info()->flags
@@ -983,7 +983,7 @@ GLOBAL_ENTRY(__paravirt_leave_kernel)
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	.pred.rel.mutex pUStk,pKStk
 	MOV_FROM_PSR(pKStk, r22, r29)	// M2 read PSR now that interrupts are disabled
-(pUStk)	mov.m r22=ar.itc	// M  fetch time at leave
+	MOV_FROM_ITC(pUStk, p9, r22, r29)	// M  fetch time at leave
 	nop.i 0
 	;;
 #else
diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 3544d75..3567d54 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -280,7 +280,7 @@ ENTRY(fsys_gettimeofday)
 (p9)	cmp.eq p13,p0 = 0,r30	// if mmio_ptr, clear p13 jitter control
 	;;
 	.pred.rel.mutex p8,p9
-(p8)	mov r2 = ar.itc		// CPU_TIMER. 36 clocks latency!!!
+	MOV_FROM_ITC(p8, p6, r2, r10)	// CPU_TIMER. 36 clocks latency!!!
 (p9)	ld8 r2 = [r30]		// MMIO_TIMER. Could also have latency issues..
 (p13)	ld8 r25 = [r19]		// get itc_lastcycle value
 	ld8 r9 = [r22],IA64_TIMESPEC_TV_NSEC_OFFSET	// tv_sec
@@ -684,7 +684,7 @@ GLOBAL_ENTRY(paravirt_fsys_bubble_down)
 	;;
 	mov ar.rsc=0				// M2   set enforced lazy mode, pl 0, LE, loadrs=0
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
-	mov.m r30=ar.itc			// M    get cycle for accounting
+	MOV_FROM_ITC(p0, p6, r30, r23)		// M    get cycle for accounting
 #else
 	nop.m 0
 #endif
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index f675d8e..ec9a5fd 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -804,7 +804,7 @@ ENTRY(break_fault)
 ///////////////////////////////////////////////////////////////////////
 	st1 [r16]=r0				// M2|3 clear current->thread.on_ustack flag
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
-	mov.m r30=ar.itc			// M    get cycle for accounting
+	MOV_FROM_ITC(p0, p14, r30, r18)		// M    get cycle for accounting
 #else
 	mov b6=r30				// I0   setup syscall handler branch reg early
 #endif
-- 
1.6.0.2

