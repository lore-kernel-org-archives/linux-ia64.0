From: Kazuto MIYOSHI <miyoshi@linux.bs1.fc.nec.co.jp>
Date: Wed, 09 Jun 2004 14:40:41 +0000
Subject: Re: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <20040609234041K.miyoshi@linux.bs1.fc.nec.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi all, 

> 2) We tried to set the current (r13) of cpu_idle to region 5 address.
>    But it paniced and I could not grab the cause of the panic.
>    Is there any reason we must put init_task in region 5?

Please find the attached patch to make swapper to run on region 5.
It needs extra 2 instructions in ia64_switch_to() to stop mapping of
task stack if we are switching to idle, to avoid TLB entry duplication
caused by kernel text/data mapping and CURRENT_STACK mapping.

I believe swapper (init_task) should be consistent for its all members,
not only for wait_chldexit, and the patch will solve other potential
list_head/current in-consistency raised by swapper initialization,
though I am not so sure if it justifies extra instructions and
complication in context switch.

Best Regards,


--- linux-2.6.6/arch/ia64/kernel/head.S.org	2004-06-09 10:37:40.000000000 +0900
+++ linux-2.6.6/arch/ia64/kernel/head.S	2004-06-09 20:33:55.234192256 +0900
@@ -155,6 +155,10 @@
 #endif
 	;;
 	tpa r3=r2		// r3 = phys addr of task struct
+	;;
+	shr.u r16=r3,IA64_GRANULE_SHIFT
+(isBP)	br.cond.dpnt .load_current	// BP stack is on region 5 and no need to map it
+
 	// load mapping for stack (virtaddr in r2, physaddr in r3)
 	rsm psr.ic
 	movl r17=PAGE_KERNEL
@@ -166,7 +170,6 @@
 	dep r2=-1,r3,61,3	// IMVA of task
 	;;
 	mov r17=rr[r2]
-	shr.u r16=r3,IA64_GRANULE_SHIFT
 	;;
 	dep r17=0,r17,8,24
 	;;
@@ -181,6 +184,7 @@
 	srlz.d
   	;;
 
+.load_current:
 	// load the "current" pointer (r13) and ar.k6 with the current task
 	mov IA64_KR(CURRENT)=r2		// virtual address
 	mov IA64_KR(CURRENT_STACK)=r16


--- linux-2.6.6/arch/ia64/kernel/entry.S.org	2004-06-09 11:47:03.000000000 +0900
+++ linux-2.6.6/arch/ia64/kernel/entry.S	2004-06-09 14:28:21.000000000 +0900
@@ -178,6 +178,9 @@
 	DO_SAVE_SWITCH_STACK
 	.body
 
+	movl r25=init_task
+	;;
+	cmp.eq p7,p6=r25,in0
 	adds r22=IA64_TASK_THREAD_KSP_OFFSET,r13
 	mov r27=IA64_KR(CURRENT_STACK)
 	dep r20=0,in0,61,3		// physical address of "current"
@@ -189,7 +192,7 @@
 	/*
 	 * If we've already mapped this task's page, we can skip doing it again.
 	 */
-	cmp.eq p7,p6=r26,r27
+(p6)	cmp.eq p7,p6=r26,r27
 (p6)	br.cond.dpnt .map
 	;;
 .done:
