From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 11 Jun 2004 00:15:17 +0000
Subject: Random fp register corruption due to race in fast system call
Message-Id: <200406110014.i5B0ErY22055@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We recently spent endless hours on chasing a random data corruption in
high floating point register on a series of 2.6 kernels.  It turns out
that the fall back path of fast system call has a race.  What happed
was a staled version of psr value is being stored into pt_regs and causes
inconsistent lazy FPH state.  For example, the following sequence of
event can happen:

App (owns FPH) -> system call

	epc
	takes fallback path
	cached_psr = read psr	// psr.dfh is 0

		<--------- interrupt
				preemption->context switch (changed FPH owner)
		<---------- context switch back
	real psr.dfh = 1 (hardware)
	disable interrupt (mov psr.l = r9)

	pt_regs = cached_psr | psr_one_bits // this will have psr.dfh=0

At this point pt_regs(ipsr)->dfh is inconsistent with FPH state.  This
process doesn't own the FPH, but it has permission to access.  Subsequently,
data corruption occurs in the fp register.

To prevent this race from happening, psr.i needs to be off before
reading psr.  Special thanks to Kevin Tian who spent many hours on
chasing all the random failures and Asit Mallick for inspirational
discovery, and of course many other people behind the scene.


diff -Nur linux-2.6.5.orig/arch/ia64/kernel/fsys.S linux-2.6.5/arch/ia64/kernel/fsys.S
--- linux-2.6.5.orig/arch/ia64/kernel/fsys.S	2004-06-04 05:13:38.000000000 -0700
+++ linux-2.6.5/arch/ia64/kernel/fsys.S	2004-06-09 05:11:54.000000000 -0700
@@ -510,6 +510,7 @@
 	adds r17=-1024,r15
 	movl r14=sys_call_table
 	;;
+	rsm psr.i
 	shladd r18=r17,3,r14
 	;;
 	ld8 r18=[r18]				// load normal (heavy-weight) syscall entry-point
@@ -550,7 +551,7 @@
 	 * to synthesize.
 	 */
 #	define PSR_ONE_BITS		((3 << IA64_PSR_CPL0_BIT) | (0x1 << IA64_PSR_RI_BIT) \
-					 | IA64_PSR_BN)
+					 | IA64_PSR_BN | IA64_PSR_I)

 	invala
 	movl r8=PSR_ONE_BITS
diff -Nur linux-2.6.5.orig/arch/ia64/kernel/gate.S linux-2.6.5/arch/ia64/kernel/gate.S
--- linux-2.6.5.orig/arch/ia64/kernel/gate.S	2004-04-03 19:37:44.000000000 -0800
+++ linux-2.6.5/arch/ia64/kernel/gate.S	2004-06-09 05:36:21.306618017 -0700
@@ -91,16 +91,18 @@
 	cmp.geu p6,p7=r19,r17			// (syscall > 0 && syscall < 1024+NR_syscalls)?
 	;;
 (p6)	ld8 r18=[r18]
-	mov r29=psr				// read psr (12 cyc load latency)
+	mov r21=ar.fpsr
 	add r14=-8,r14				// r14 <- addr of fsys_bubble_down entry
 	;;
 (p6)	mov b7=r18
 (p6)	tbit.z p8,p0=r18,0
 (p8)	br.dptk.many b7

+(p6)	rsm psr.i
 	mov r27=ar.rsc
-	mov r21=ar.fpsr
 	mov r26=ar.pfs
+	;;
+	mov r29=psr				// read psr (12 cyc load latency)
 /*
  * brl.cond doesn't work as intended because the linker would convert this branch
  * into a branch to a PLT.  Perhaps there will be a way to avoid this with some




