From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 09 May 2008 06:26:51 +0000
Subject: [PATCH] ia64: trivial cleanup for entry.S
Message-Id: <4823EEAB.10607@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch does:
 - make comment at next to resched check more robust
 - move "re-check" comments to next to where change predicate regs

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/entry.S |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index ef6b031..ca2bb95 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1167,7 +1167,7 @@ skip_rbs_switch:
 	st8 [r2]=r8
 	st8 [r3]=r10
 .work_pending:
-	tbit.z p6,p0=r31,TIF_NEED_RESCHED		// current_thread_info()->need_resched=0?
+	tbit.z p6,p0=r31,TIF_NEED_RESCHED	// is resched not needed?
 (p6)	br.cond.sptk.few .notify
 #ifdef CONFIG_PREEMPT
 (pKStk) dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
@@ -1176,7 +1176,7 @@ skip_rbs_switch:
 #endif
 	ssm psr.i		// enable interrupts
 	br.call.spnt.many rp=schedule
-.ret9:	cmp.eq p6,p0=r0,r0				// p6 <- 1
+.ret9:	cmp.eq p6,p0=r0,r0	// p6 <- 1 (re-check)
 	rsm psr.i		// disable interrupts
 	;;
 #ifdef CONFIG_PREEMPT
@@ -1185,13 +1185,13 @@ skip_rbs_switch:
 (pKStk)	st4 [r20]=r0		// preempt_count() <- 0
 #endif
 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
-	br.cond.sptk.many .work_processed_kernel	// re-check
+	br.cond.sptk.many .work_processed_kernel
 
 .notify:
 (pUStk)	br.call.spnt.many rp=notify_resume_user
-.ret10:	cmp.ne p6,p0=r0,r0				// p6 <- 0
+.ret10:	cmp.ne p6,p0=r0,r0	// p6 <- 0 (don't re-check)
 (pLvSys)br.cond.sptk.few  .work_pending_syscall_end
-	br.cond.sptk.many .work_processed_kernel	// don't re-check
+	br.cond.sptk.many .work_processed_kernel
 
 .work_pending_syscall_end:
 	adds r2=PT(R8)+16,r12
@@ -1199,7 +1199,7 @@ skip_rbs_switch:
 	;;
 	ld8 r8=[r2]
 	ld8 r10=[r3]
-	br.cond.sptk.many .work_processed_syscall	// re-check
+	br.cond.sptk.many .work_processed_syscall
 
 END(ia64_leave_kernel)
 

