From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 28 Jun 2004 17:42:51 +0000
Subject: [PATCH] comment typos
Message-Id: <200406281142.51280.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a couple comment typos.

=== arch/ia64/kernel/entry.S 1.61 vs edited ==--- 1.61/arch/ia64/kernel/entry.S	2004-06-16 19:09:33 -06:00
+++ edited/arch/ia64/kernel/entry.S	2004-06-28 11:35:35 -06:00
@@ -182,7 +182,7 @@
 	movl r25=init_task
 	mov r27=IA64_KR(CURRENT_STACK)
 	adds r21=IA64_TASK_THREAD_KSP_OFFSET,in0
-	dep r20=0,in0,61,3		// physical address of "current"
+	dep r20=0,in0,61,3		// physical address of "next"
 	;;
 	st8 [r22]=sp			// save kernel stack pointer of old task
 	shr.u r26=r20,IA64_GRANULE_SHIFT
@@ -195,7 +195,7 @@
 (p6)	br.cond.dpnt .map
 	;;
 .done:
-(p6)	ssm psr.ic			// if we we had to map, renable the psr.ic bit FIRST!!!
+(p6)	ssm psr.ic			// if we had to map, reenable the psr.ic bit FIRST!!!
 	;;
 (p6)	srlz.d
 	ld8 sp=[r21]			// load kernel stack pointer of new task
=== arch/ia64/kernel/head.S 1.24 vs edited ==--- 1.24/arch/ia64/kernel/head.S	2004-06-16 19:09:33 -06:00
+++ edited/arch/ia64/kernel/head.S	2004-06-28 11:35:35 -06:00
@@ -67,7 +67,7 @@
 	 * Initialize kernel region registers:
 	 *	rr[5]: VHPT enabled, page size = PAGE_SHIFT
 	 *	rr[6]: VHPT disabled, page size = IA64_GRANULE_SHIFT
-	 *	rr[5]: VHPT disabled, page size = IA64_GRANULE_SHIFT
+	 *	rr[7]: VHPT disabled, page size = IA64_GRANULE_SHIFT
 	 */
 	mov r16=((ia64_rid(IA64_REGION_ID_KERNEL, (5<<61)) << 8) | (PAGE_SHIFT << 2) | 1)
 	movl r17=(5<<61)
