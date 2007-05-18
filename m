From: Robin Holt <holt@sgi.com>
Date: Fri, 18 May 2007 18:46:23 +0000
Subject: [PATCH 1/2] Improve unwind checking.
Message-Id: <20070518184623.GB9217@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch adds some sanity checks to keep register and memory stack
pointers in the unw_frame_info structure within the tasks stack address
range.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: linux-tot-20070517/arch/ia64/kernel/unwind.c
=================================--- linux-tot-20070517.orig/arch/ia64/kernel/unwind.c	2007-05-18 11:23:10.772996962 -0500
+++ linux-tot-20070517/arch/ia64/kernel/unwind.c	2007-05-18 11:23:19.450056538 -0500
@@ -1860,7 +1860,7 @@ int
 unw_unwind (struct unw_frame_info *info)
 {
 	unsigned long prev_ip, prev_sp, prev_bsp;
-	unsigned long ip, pr, num_regs;
+	unsigned long ip, pr, num_regs, rp_loc, pfs_loc;
 	STAT(unsigned long start, flags;)
 	int retval;
 
@@ -1870,14 +1870,16 @@ unw_unwind (struct unw_frame_info *info)
 	prev_sp = info->sp;
 	prev_bsp = info->bsp;
 
-	/* restore the ip */
-	if (!info->rp_loc) {
+	/* validate the return IP pointer */
+	rp_loc = (unsigned long) info->rp_loc;
+	if ((rp_loc < info->regstk.limit) || (rp_loc > info->regstk.top)) {
 		/* FIXME: should really be level 0 but it occurs too often. KAO */
 		UNW_DPRINT(1, "unwind.%s: failed to locate return link (ip=0x%lx)!\n",
 			   __FUNCTION__, info->ip);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
+	/* restore the ip */
 	ip = info->ip = *info->rp_loc;
 	if (ip < GATE_ADDR) {
 		UNW_DPRINT(2, "unwind.%s: reached user-space (ip=0x%lx)\n", __FUNCTION__, ip);
@@ -1885,12 +1887,14 @@ unw_unwind (struct unw_frame_info *info)
 		return -1;
 	}
 
-	/* restore the cfm: */
-	if (!info->pfs_loc) {
+	/* validate the previous stack frame pointer */
+	pfs_loc = (unsigned long) info->pfs_loc;
+	if ((pfs_loc < info->regstk.limit) || (pfs_loc > info->regstk.top)) {
 		UNW_DPRINT(0, "unwind.%s: failed to locate ar.pfs!\n", __FUNCTION__);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;
 	}
+	/* restore the cfm: */
 	info->cfm_loc = info->pfs_loc;
 
 	/* restore the bsp: */
@@ -1992,13 +1996,16 @@ init_frame_info (struct unw_frame_info *
 	memset(info, 0, sizeof(*info));
 
 	rbslimit = (unsigned long) t + IA64_RBS_OFFSET;
+	stklimit = (unsigned long) t + IA64_STK_OFFSET;
+
 	rbstop   = sw->ar_bspstore;
-	if (rbstop - (unsigned long) t >= IA64_STK_OFFSET)
+	if (rbstop > stklimit || rbstop < rbslimit)
 		rbstop = rbslimit;
 
-	stklimit = (unsigned long) t + IA64_STK_OFFSET;
 	if (stktop <= rbstop)
 		stktop = rbstop;
+	if (stktop > stklimit)
+		stktop = stklimit;
 
 	info->regstk.limit = rbslimit;
 	info->regstk.top   = rbstop;
