From: Keith Owens <kaos@sgi.com>
Date: Thu, 10 Mar 2005 09:02:08 +0000
Subject: [patch 2.6.11] Tighten up unw_unwind_to_user check
Message-Id: <17263.1110445328@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Detect user space by the unwind frame with predicate PRED_USER_STACK
set, instead of a user space IP.  Tighten up the last ditch check for
running off the top of the kernel stack.

Based on a suggestion by David Mosberger, reworked to fit the current
tree.  This survives my stress test which used to break 2.6.9 kernels.
Unlike 2.6.11, the stress test now unwinds to the correct point, so
gdb can get the user space registers.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/kernel/unwind.c
=================================--- linux.orig/arch/ia64/kernel/unwind.c	2005-03-02 18:38:34.000000000 +1100
+++ linux/arch/ia64/kernel/unwind.c	2005-03-10 19:56:48.000000000 +1100
@@ -1943,23 +1943,30 @@ EXPORT_SYMBOL(unw_unwind);
 int
 unw_unwind_to_user (struct unw_frame_info *info)
 {
-	unsigned long ip, sp;
+	unsigned long ip, sp, pr = 0;
 
 	while (unw_unwind(info) >= 0) {
-		if (unw_get_rp(info, &ip) < 0) {
-			unw_get_ip(info, &ip);
-			UNW_DPRINT(0, "unwind.%s: failed to read return pointer (ip=0x%lx)\n",
-				   __FUNCTION__, ip);
-			return -1;
-		}
 		unw_get_sp(info, &sp);
-		if (sp >= (unsigned long)info->task + IA64_STK_OFFSET)
+		if ((long)((unsigned long)info->task + IA64_STK_OFFSET - sp)
+		    < IA64_PT_REGS_SIZE) {
+			UNW_DPRINT(0, "unwind.%s: ran off the top of the kernel stack\n",
+				   __FUNCTION__);
 			break;
-		if (ip < FIXADDR_USER_END)
+		}
+		if (unw_is_intr_frame(info) &&
+		    (pr & (1UL << PRED_USER_STACK)))
 			return 0;
+		if (unw_get_pr (info, &pr) < 0) {
+			unw_get_rp(info, &ip);
+			UNW_DPRINT(0, "unwind.%s: failed to read "
+				   "predicate register (ip=0x%lx)\n",
+				__FUNCTION__, ip);
+			return -1;
+		}
 	}
 	unw_get_ip(info, &ip);
-	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n", __FUNCTION__, ip);
+	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=0x%lx)\n",
+		   __FUNCTION__, ip);
 	return -1;
 }
 EXPORT_SYMBOL(unw_unwind_to_user);

