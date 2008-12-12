From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 12 Dec 2008 06:39:02 +0000
Subject: [PATCH 13/15] ia64/pv_ops: move down __kernel_syscall_via_epc.
Message-Id: <1229063944-27462-14-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Move down __kernel_syscall_via_epc to the end of the page.
We want to paravirtualize only __kernel_syscall_via_epc because
it includes privileged instructions. Its paravirtualization increases
its symbols size.

On the other hand, each paravirtualized gate must have e symbols of
same value and size to native's because the page is mapped to GATE_ADDR
and GATE_ADDR + PERCPU_PAGE_SIZE and vmlinux is linked to those symbols.
Later to have the same symbol size, we pads NOPs at the end of
__kernel_syscall_via_epc. Move it after other functions to keep
symbols of other functions have same values and sizes.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/gate.S |  162 +++++++++++++++++++++++-----------------------
 1 files changed, 81 insertions(+), 81 deletions(-)

diff --git a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
index 74b1ccc..c957228 100644
--- a/arch/ia64/kernel/gate.S
+++ b/arch/ia64/kernel/gate.S
@@ -48,87 +48,6 @@ GLOBAL_ENTRY(__kernel_syscall_via_break)
 }
 END(__kernel_syscall_via_break)
 
-/*
- * On entry:
- *	r11 = saved ar.pfs
- *	r15 = system call #
- *	b0  = saved return address
- *	b6  = return address
- * On exit:
- *	r11 = saved ar.pfs
- *	r15 = system call #
- *	b0  = saved return address
- *	all other "scratch" registers:	undefined
- *	all "preserved" registers:	same as on entry
- */
-
-GLOBAL_ENTRY(__kernel_syscall_via_epc)
-	.prologue
-	.altrp b6
-	.body
-{
-	/*
-	 * Note: the kernel cannot assume that the first two instructions in this
-	 * bundle get executed.  The remaining code must be safe even if
-	 * they do not get executed.
-	 */
-	adds r17=-1024,r15			// A
-	mov r10=0				// A    default to successful syscall execution
-	epc					// B	causes split-issue
-}
-	;;
-	rsm psr.be | psr.i			// M2 (5 cyc to srlz.d)
-	LOAD_FSYSCALL_TABLE(r14)		// X
-	;;
-	mov r16=IA64_KR(CURRENT)		// M2 (12 cyc)
-	shladd r18=r17,3,r14			// A
-	mov r19=NR_syscalls-1			// A
-	;;
-	lfetch [r18]				// M0|1
-	mov r29=psr				// M2 (12 cyc)
-	// If r17 is a NaT, p6 will be zero
-	cmp.geu p6,p7=r19,r17			// A    (sysnr > 0 && sysnr < 1024+NR_syscalls)?
-	;;
-	mov r21=ar.fpsr				// M2 (12 cyc)
-	tnat.nz p10,p9=r15			// I0
-	mov.i r26=ar.pfs			// I0 (would stall anyhow due to srlz.d...)
-	;;
-	srlz.d					// M0 (forces split-issue) ensure PSR.BE=0
-(p6)	ld8 r18=[r18]				// M0|1
-	nop.i 0
-	;;
-	nop.m 0
-(p6)	tbit.z.unc p8,p0=r18,0			// I0 (dual-issues with "mov b7=r18"!)
-	nop.i 0
-	;;
-(p8)	ssm psr.i
-(p6)	mov b7=r18				// I0
-(p8)	br.dptk.many b7				// B
-
-	mov r27=ar.rsc				// M2 (12 cyc)
-/*
- * brl.cond doesn't work as intended because the linker would convert this branch
- * into a branch to a PLT.  Perhaps there will be a way to avoid this with some
- * future version of the linker.  In the meantime, we just use an indirect branch
- * instead.
- */
-#ifdef CONFIG_ITANIUM
-(p6)	add r14=-8,r14				// r14 <- addr of fsys_bubble_down entry
-	;;
-(p6)	ld8 r14=[r14]				// r14 <- fsys_bubble_down
-	;;
-(p6)	mov b7=r14
-(p6)	br.sptk.many b7
-#else
-	BRL_COND_FSYS_BUBBLE_DOWN(p6)
-#endif
-	ssm psr.i
-	mov r10=-1
-(p10)	mov r8=EINVAL
-(p9)	mov r8=ENOSYS
-	FSYS_RETURN
-END(__kernel_syscall_via_epc)
-
 #	define ARG0_OFF		(16 + IA64_SIGFRAME_ARG0_OFFSET)
 #	define ARG1_OFF		(16 + IA64_SIGFRAME_ARG1_OFFSET)
 #	define ARG2_OFF		(16 + IA64_SIGFRAME_ARG2_OFFSET)
@@ -374,3 +293,84 @@ restore_rbs:
 	// invala not necessary as that will happen when returning to user-mode
 	br.cond.sptk back_from_restore_rbs
 END(__kernel_sigtramp)
+
+/*
+ * On entry:
+ *	r11 = saved ar.pfs
+ *	r15 = system call #
+ *	b0  = saved return address
+ *	b6  = return address
+ * On exit:
+ *	r11 = saved ar.pfs
+ *	r15 = system call #
+ *	b0  = saved return address
+ *	all other "scratch" registers:	undefined
+ *	all "preserved" registers:	same as on entry
+ */
+
+GLOBAL_ENTRY(__kernel_syscall_via_epc)
+	.prologue
+	.altrp b6
+	.body
+{
+	/*
+	 * Note: the kernel cannot assume that the first two instructions in this
+	 * bundle get executed.  The remaining code must be safe even if
+	 * they do not get executed.
+	 */
+	adds r17=-1024,r15			// A
+	mov r10=0				// A    default to successful syscall execution
+	epc					// B	causes split-issue
+}
+	;;
+	rsm psr.be | psr.i			// M2 (5 cyc to srlz.d)
+	LOAD_FSYSCALL_TABLE(r14)		// X
+	;;
+	mov r16=IA64_KR(CURRENT)		// M2 (12 cyc)
+	shladd r18=r17,3,r14			// A
+	mov r19=NR_syscalls-1			// A
+	;;
+	lfetch [r18]				// M0|1
+	mov r29=psr				// M2 (12 cyc)
+	// If r17 is a NaT, p6 will be zero
+	cmp.geu p6,p7=r19,r17			// A    (sysnr > 0 && sysnr < 1024+NR_syscalls)?
+	;;
+	mov r21=ar.fpsr				// M2 (12 cyc)
+	tnat.nz p10,p9=r15			// I0
+	mov.i r26=ar.pfs			// I0 (would stall anyhow due to srlz.d...)
+	;;
+	srlz.d					// M0 (forces split-issue) ensure PSR.BE=0
+(p6)	ld8 r18=[r18]				// M0|1
+	nop.i 0
+	;;
+	nop.m 0
+(p6)	tbit.z.unc p8,p0=r18,0			// I0 (dual-issues with "mov b7=r18"!)
+	nop.i 0
+	;;
+(p8)	ssm psr.i
+(p6)	mov b7=r18				// I0
+(p8)	br.dptk.many b7				// B
+
+	mov r27=ar.rsc				// M2 (12 cyc)
+/*
+ * brl.cond doesn't work as intended because the linker would convert this branch
+ * into a branch to a PLT.  Perhaps there will be a way to avoid this with some
+ * future version of the linker.  In the meantime, we just use an indirect branch
+ * instead.
+ */
+#ifdef CONFIG_ITANIUM
+(p6)	add r14=-8,r14				// r14 <- addr of fsys_bubble_down entry
+	;;
+(p6)	ld8 r14=[r14]				// r14 <- fsys_bubble_down
+	;;
+(p6)	mov b7=r14
+(p6)	br.sptk.many b7
+#else
+	BRL_COND_FSYS_BUBBLE_DOWN(p6)
+#endif
+	ssm psr.i
+	mov r10=-1
+(p10)	mov r8=EINVAL
+(p9)	mov r8=ENOSYS
+	FSYS_RETURN
+END(__kernel_syscall_via_epc)
-- 
1.6.0.2

