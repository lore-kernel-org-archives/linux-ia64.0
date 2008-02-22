From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:45 +0000
Subject: [PATCH 26/28] ia64/xen: fsys paravirtualization.
Message-Id: <1203657048840-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/fsys.S |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/kernel/fsys.S b/arch/ia64/kernel/fsys.S
index 4484197..7d97e37 100644
--- a/arch/ia64/kernel/fsys.S
+++ b/arch/ia64/kernel/fsys.S
@@ -570,11 +570,34 @@ ENTRY(fsys_fallback_syscall)
 	adds r17=-1024,r15
 	movl r14=sys_call_table
 	;;
+#ifdef CONFIG_XEN
+	movl r18=running_on_xen;;
+	ld4 r18=[r18];;
+	// p14 = running_on_xen
+	// p15 = !running_on_xen
+	cmp.ne p14,p15=r0,r18
+	;;
+(p14)	movl r18=XSI_PSR_I_ADDR;;
+(p14)	ld8 r18=[r18]
+(p14)	mov r29=1;;
+(p14)	st1 [r18]=r29
+(p15)	rsm psr.i
+#else
 	rsm psr.i
+#endif
 	shladd r18=r17,3,r14
 	;;
 	ld8 r18=[r18]				// load normal (heavy-weight) syscall entry-point
+#ifdef CONFIG_XEN
+(p14)	mov r27=r8
+(p14)	XEN_HYPER_GET_PSR
+	;;
+(p14)	mov r29=r8
+(p14)	mov r8=r27
+(p15)	mov r29=psr				// read psr (12 cyc load latency)
+#else
 	mov r29=psr				// read psr (12 cyc load latency)
+#endif
 	mov r27=ar.rsc
 	mov r21=ar.fpsr
 	mov r26=ar.pfs
@@ -686,7 +709,25 @@ GLOBAL_ENTRY(fsys_bubble_down)
 	mov rp=r14				// I0   set the real return addr
 	and r3=_TIF_SYSCALL_TRACEAUDIT,r3	// A
 	;;
+#ifdef CONFIG_XEN
+	movl r14=running_on_xen;;
+	ld4 r14=[r14];;
+	// p14 = running_on_xen
+	// p15 = !running_on_xen
+	cmp.ne p14,p15=r0,r14
+	;;
+(p14)	movl r28=XSI_PSR_I_ADDR;;
+(p14)	ld8 r28=[r28];;
+(p14)	adds r28=-1,r28;;			// event_pending
+(p14)	ld1 r14=[r28];;
+(p14)	cmp.ne.unc p13,p14=r14,r0;;
+(p13)	XEN_HYPER_SSM_I
+(p14)	adds r28=1,r28;;			// event_mask
+(p14)	st1 [r28]=r0;;
+(p15)	ssm psr.i
+#else
 	ssm psr.i				// M2   we're on kernel stacks now, reenable irqs
+#endif
 	cmp.eq p8,p0=r3,r0			// A
 (p10)	br.cond.spnt.many ia64_ret_from_syscall	// B    return if bad call-frame or r15 is a NaT
 
-- 
1.5.3

