From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 16 Oct 2007 13:40:58 +0000
Subject: [PATCH 8/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <4714BF6A.4020805@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> [8/9] ia64_acct_gate_on_leave.patch

This is last patch for check point building.

 - kernel exit (stack switching from kernel to user)

In contrast, there is only one codes that switches
stack from kernel to user. It is ia64_leave_kernel().

Following patch builds check point on this exit, including
fetching ar.itc, cumulate cycles for stime and stamp updating.

Thanks,
H.Seto

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

---
 arch/ia64/kernel/entry.S |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+)

Index: linux-2.6.23/arch/ia64/kernel/entry.S
=================================--- linux-2.6.23.orig/arch/ia64/kernel/entry.S
+++ linux-2.6.23/arch/ia64/kernel/entry.S
@@ -995,6 +995,26 @@
 	shladd in0=loc1,3,r17
 	mov in1=0
 	;;
+#ifdef CONFIG_VIRT_CPU_ACCOUNTING
+account_sys_leave:
+	alloc loc0=ar.pfs,2,7,0,0	// keep in0,in1
+	mov loc1=IA64_KR(CURRENT)	// M2 (12 cycle read latency)
+	mov loc6=ar.itc
+	;;
+	add loc2=TI_AC_STAMP+IA64_TASK_SIZE,loc1
+	add loc3=TI_AC_STIME+IA64_TASK_SIZE,loc1
+	;;
+	ld8 loc4=[loc2]			// get last stamp
+	ld8 loc5=[loc3]			// cumulated stime
+	;;
+	sub loc4=loc6,loc4		// elapsed time
+	;;
+	add loc5=loc5,loc4		// sum
+	;;
+	st8 [loc2]=loc6			// update stamp
+	st8 [loc3]=loc5			// update stime
+	;;
+#endif
 	TEXT_ALIGN(32)
 rse_clear_invalid:
 #ifdef CONFIG_ITANIUM


