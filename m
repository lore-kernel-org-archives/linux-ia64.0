From: Jack Steiner <steiner@sgi.com>
Date: Mon, 18 Aug 2003 17:46:41 +0000
Subject: 2.4.21+ Patch for non-identity mapped kernel (SGI SN)
Message-Id: <marc-linux-ia64-106122911803891@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Attached is a patch that makes arch/ia64/kernel/head.S work on the
SGI SN system. The patch consists mostly of a backport of portions
of the same file from 2.6. 

I tried to minimized differences between the new file & 2.6 as 
opposed to minimizing differences between the new file & 2.4.21. 
This makes the patch somewhat larger than needed but (I think) is 
correct for the long term.


The changes add support for non-identity mapped kernels. This patch
does NOT change the kernel load address - it just adds support for the
case where it was loaded into non-identity mapped memory.






--- linux_base/arch/ia64/kernel/head.S	Fri Aug 15 15:28:17 2003
+++ linux/arch/ia64/kernel/head.S	Mon Aug 18 10:29:23 2003
@@ -5,7 +5,7 @@
  * to set up the kernel's global pointer and jump to the kernel
  * entry point.
  *
- * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001, 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
@@ -15,6 +15,7 @@
  * Copyright (C) 1999 Don Dugger <Don.Dugger@intel.com>
  * Copyright (C) 2002 Fenghua Yu <fenghua.yu@intel.com>
  *   -Optimize __ia64_save_fpu() and __ia64_load_fpu() for Itanium 2.
+ * Copyright (C) 2003 Silicon Graphics, Inc.
  */
 
 #include <linux/config.h>
@@ -65,17 +66,29 @@
 	 * that maps the kernel's text and data:
 	 */
 	rsm psr.i | psr.ic
-	mov r16=((ia64_rid(IA64_REGION_ID_KERNEL, PAGE_OFFSET) << 8) | (IA64_GRANULE_SHIFT << 2))
 	;;
 	srlz.i
+	;;
+	mov r20=((ia64_rid(IA64_REGION_ID_KERNEL, (7<<61)) << 8) | (IA64_GRANULE_SHIFT << 2))
+	movl r21=(7<<61)
+	;;
+	mov rr[r21]=r20
+	;;
+	/*
+	 * Now pin mappings into the TLB for kernel text and data
+	 */
 	mov r18=KERNEL_TR_PAGE_SHIFT<<2
 	movl r17=KERNEL_START
 	;;
-	mov rr[r17]=r16
 	mov cr.itir=r18
 	mov cr.ifa=r17
 	mov r16=IA64_TR_KERNEL
-	movl r18=((1 << KERNEL_TR_PAGE_SHIFT) | PAGE_KERNEL)
+	mov r3=ip
+	movl r18=PAGE_KERNEL
+	;;
+	dep r2=0,r3,0,KERNEL_TR_PAGE_SHIFT
+	;;
+	or r18=r2,r18
 	;;
 	srlz.i
 	;;
@@ -134,28 +147,63 @@
 	movl r3=cpucount
  	;;
 	ld4 r3=[r3]		// r3 <- smp_processor_id()
-	movl r2=init_tasks
-	;;
-	shladd r2=r3,3,r2
-	;;
-	ld8 r2=[r2]
 #else
 	mov r3=0
-	movl r2=init_task_union
-	;;
 #endif
+	;;
 	cmp4.ne isAP,isBP=r3,r0
-	;;			// RAW on r2
-	extr r3=r2,0,61		// r3 = phys addr of task struct
-	mov r16=KERNEL_TR_PAGE_NUM
+
+	/*
+	 * Make task struct pointer in init_tasks an identity mapped pointer.
+	 * The value that is compiled into the array may not be identity mapped.
+	 */
+	movl r18=init_tasks
+	;;
+	shladd r18=r3,3,r18
+	;;
+	ld8 r8=[r18]
+	;;
+	tpa r3=r8		// r3 = phys addr of task struct
+	;;
+	dep r2=-1,r3,61,3	// IMVA of task
+	;;
+	st8 [r18]=r2		// and save it back in init_tasks[thiscpu]
+
+	// load mapping for stack (virtaddr in r2, physaddr in r3)
+	// load dtr[2] only if the va for current (r2) isn't covered by the dtr[0] 
+	shr.u r18=r2,KERNEL_TR_PAGE_SHIFT               /* va of current in units of kernel-pages */
+	movl r17=KERNEL_START>>KERNEL_TR_PAGE_SHIFT     /* va of kernel-start in units of kernel-pages */
+	;;
+	cmp.eq p0,p6=r17,r18
+	rsm psr.ic
+	movl r17=PAGE_KERNEL
+	;;
+	srlz.d
+	dep r18=0,r3,0,12
+	;;
+	or r18=r17,r18
+	;;
+	mov r17=rr[r2]
+	shr.u r16=r3,IA64_GRANULE_SHIFT
+	;;
+	dep r17=0,r17,8,24
+	;;
+	mov cr.itir=r17
+	mov cr.ifa=r2
+
+	mov r19=IA64_TR_CURRENT_STACK
+	;;
+(p6)	itr.d dtr[r19]=r18
+	;;
+	ssm psr.ic
+	srlz.d
 	;;
 
 	// load the "current" pointer (r13) and ar.k6 with the current task
-	mov r13=r2
 	mov IA64_KR(CURRENT)=r3		// Physical address
-
-	// initialize k4 to a safe value (64-128MB is mapped by TR_KERNEL)
 	mov IA64_KR(CURRENT_STACK)=r16
+	mov r13=r2
+
 	/*
 	 * Reserve space at the top of the stack for "struct pt_regs".  Kernel threads
 	 * don't store interesting values in that structure, but the space still needs
-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

