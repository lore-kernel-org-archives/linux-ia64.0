From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 24 Mar 2005 00:51:33 +0000
Subject: syscall improvement patch [10/12]
Message-Id: <200503240051.j2O0pXah022316@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Annotate __kernel_syscall_via_epc() with McKinley dispatch info.

Two other very minor changes: use "mov.i" instead of "mov" for reading
ar.pfs (for clarity; doesn't affect the code at all).  Also, predicate
the load of r14 for consistency.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff -Nru a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
--- a/arch/ia64/kernel/gate.S	2005-03-23 15:37:01 -08:00
+++ b/arch/ia64/kernel/gate.S	2005-03-23 15:37:01 -08:00
@@ -72,41 +72,41 @@
 	 * bundle get executed.  The remaining code must be safe even if
 	 * they do not get executed.
 	 */
-	adds r17=-1024,r15
-	mov r10=0				// default to successful syscall execution
-	epc
+	adds r17=-1024,r15			// A
+	mov r10=0				// A    default to successful syscall execution
+	epc					// B	causes split-issue
 }
 	;;
-	rsm psr.be // note: on McKinley "rsm psr.be/srlz.d" is slightly faster than "rum psr.be"
-	LOAD_FSYSCALL_TABLE(r14)
+	rsm psr.be				// M2 (5 cyc to srlz.d)
+	LOAD_FSYSCALL_TABLE(r14)		// X
 	;;
-	mov r16=IA64_KR(CURRENT)		// 12 cycle read latency
-	shladd r18=r17,3,r14
-	mov r19=NR_syscalls-1
+	mov r16=IA64_KR(CURRENT)		// M2 (12 cyc)
+	shladd r18=r17,3,r14			// A
+	mov r19=NR_syscalls-1			// A
 	;;
 	lfetch [r18]				// M0|1
-	mov r29=psr				// read psr (12 cyc load latency)
-	/* Note: if r17 is a NaT, p6 will be set to zero.  */
-	cmp.geu p6,p7=r19,r17			// (syscall > 0 && syscall < 1024+NR_syscalls)?
-	;;
-	mov r21=ar.fpsr
-	tnat.nz p10,p9=r15
-	mov r26=ar.pfs
+	mov r29=psr				// M2 (12 cyc)
+	// If r17 is a NaT, p6 will be zero
+	cmp.geu p6,p7=r19,r17			// A    (sysnr > 0 && sysnr < 1024+NR_syscalls)?
+	;;
+	mov r21=ar.fpsr				// M2 (12 cyc)
+	tnat.nz p10,p9=r15			// I0
+	mov.i r26=ar.pfs			// I0 (would stall anyhow due to srlz.d...)
 	;;
-	srlz.d
-(p6)	ld8 r18=[r18]
+	srlz.d					// M0 (forces split-issue) ensure PSR.BE=0
+(p6)	ld8 r18=[r18]				// M0|1
 	nop.i 0
 	;;
 	nop.m 0
-(p6)	mov b7=r18
-(p6)	tbit.z.unc p8,p0=r18,0
+(p6)	mov b7=r18				// I0
+(p6)	tbit.z.unc p8,p0=r18,0			// I0 (dual-issues with "mov b7=r18"!)
 
 	nop.m 0
 	nop.i 0
-(p8)	br.dptk.many b7
+(p8)	br.dptk.many b7				// B
 
-	mov r27=ar.rsc
-(p6)	rsm psr.i
+	mov r27=ar.rsc				// M2 (12 cyc)
+(p6)	rsm psr.i				// M2
 /*
  * brl.cond doesn't work as intended because the linker would convert this branch
  * into a branch to a PLT.  Perhaps there will be a way to avoid this with some
@@ -114,7 +114,7 @@
  * instead.
  */
 #ifdef CONFIG_ITANIUM
-	add r14=-8,r14				// r14 <- addr of fsys_bubble_down entry
+(p6)	add r14=-8,r14				// r14 <- addr of fsys_bubble_down entry
 	;;
 (p6)	ld8 r14=[r14]				// r14 <- fsys_bubble_down
 	;;
