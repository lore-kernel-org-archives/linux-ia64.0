From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 29 Jun 2004 23:18:19 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <16609.63675.603591.926470@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 29 Jun 2004 11:19:34 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> Looks like there are more places where kernel does "virt ->
  Ken> phys -> virt".  And conversion from phys to virt is setting 3
  Ken> msb to 1.

Your fixes work fine on the machines I have tried so far (variety of
Itanium 2 boxen and a Big Sur Merced box).

Jesse, do you know if unapplying the "move current to region 5" patch
fixes your boot-problem?  For convenience, I attached the (original)
patch below.

	--david

# arch/ia64/kernel/head.S
#   2004/06/16 18:09:33-07:00 davidm@tiger.hpl.hp.com +5 -1
#   (_start): Initialize "current" pointer for init-task to be in
#   	region 5, not 7.
# 
# arch/ia64/kernel/entry.S
#   2004/06/16 18:09:33-07:00 davidm@tiger.hpl.hp.com +4 -2
#   (ia64_switch_to): Don't try to map "current"-pointers which are
#   	inside region 5.
# 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	Tue Jun 29 16:11:13 2004
+++ b/arch/ia64/kernel/entry.S	Tue Jun 29 16:11:13 2004
@@ -179,17 +179,19 @@
 	.body
 
 	adds r22=IA64_TASK_THREAD_KSP_OFFSET,r13
+	movl r25=init_task
 	mov r27=IA64_KR(CURRENT_STACK)
+	adds r21=IA64_TASK_THREAD_KSP_OFFSET,in0
 	dep r20=0,in0,61,3		// physical address of "current"
 	;;
 	st8 [r22]=sp			// save kernel stack pointer of old task
 	shr.u r26=r20,IA64_GRANULE_SHIFT
-	adds r21=IA64_TASK_THREAD_KSP_OFFSET,in0
+	cmp.eq p7,p6=r25,in0
 	;;
 	/*
 	 * If we've already mapped this task's page, we can skip doing it again.
 	 */
-	cmp.eq p7,p6=r26,r27
+(p6)	cmp.eq p7,p6=r26,r27
 (p6)	br.cond.dpnt .map
 	;;
 .done:
diff -Nru a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
--- a/arch/ia64/kernel/head.S	Tue Jun 29 16:11:13 2004
+++ b/arch/ia64/kernel/head.S	Tue Jun 29 16:11:13 2004
@@ -154,6 +154,10 @@
 #endif
 	;;
 	tpa r3=r2		// r3 = phys addr of task struct
+	;;
+	shr.u r16=r3,IA64_GRANULE_SHIFT
+(isBP)	br.cond.dpnt .load_current // BP stack is on region 5 --- no need to map it
+
 	// load mapping for stack (virtaddr in r2, physaddr in r3)
 	rsm psr.ic
 	movl r17=PAGE_KERNEL
@@ -165,7 +169,6 @@
 	dep r2=-1,r3,61,3	// IMVA of task
 	;;
 	mov r17=rr[r2]
-	shr.u r16=r3,IA64_GRANULE_SHIFT
 	;;
 	dep r17=0,r17,8,24
 	;;
@@ -180,6 +183,7 @@
 	srlz.d
   	;;
 
+.load_current:
 	// load the "current" pointer (r13) and ar.k6 with the current task
 	mov IA64_KR(CURRENT)=r2		// virtual address
 	mov IA64_KR(CURRENT_STACK)=r16
