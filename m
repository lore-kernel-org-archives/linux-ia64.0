From: Keith Owens <kaos@sgi.com>
Date: Tue, 26 Jun 2007 06:25:22 +0000
Subject: [PATCH 2.6.22-rc5] Correct unwind validation code
Message-Id: <6071.1182839122@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Both rp_loc and pfs_loc can be in the register stack area _or_ they can
be in the memory stack area, the latter occurs when a struct pt_regs is
pushed.  Correct the validation check on these fields to check for both
stack areas.  Not allowing for memory stack locations means no
backtrace past ia64_leave_kernel, or any other code that uses
PT_REGS_UNWIND_INFO.

Signed-off-by: Keith Owens <kaos@sgi.com>

---
 arch/ia64/kernel/unwind.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

Index: linux/arch/ia64/kernel/unwind.c
=================================--- linux.orig/arch/ia64/kernel/unwind.c
+++ linux/arch/ia64/kernel/unwind.c
@@ -1856,11 +1856,19 @@ find_save_locs (struct unw_frame_info *i
 	return 0;
 }
 
+static int
+unw_valid(const struct unw_frame_info *info, unsigned long* p)
+{
+	unsigned long loc = (unsigned long)p;
+	return (loc >= info->regstk.limit && loc < info->regstk.top) ||
+	       (loc >= info->memstk.top && loc < info->memstk.limit);
+}
+
 int
 unw_unwind (struct unw_frame_info *info)
 {
 	unsigned long prev_ip, prev_sp, prev_bsp;
-	unsigned long ip, pr, num_regs, rp_loc, pfs_loc;
+	unsigned long ip, pr, num_regs;
 	STAT(unsigned long start, flags;)
 	int retval;
 
@@ -1871,8 +1879,7 @@ unw_unwind (struct unw_frame_info *info)
 	prev_bsp = info->bsp;
 
 	/* validate the return IP pointer */
-	rp_loc = (unsigned long) info->rp_loc;
-	if ((rp_loc < info->regstk.limit) || (rp_loc > info->regstk.top)) {
+	if (!unw_valid(info, info->rp_loc)) {
 		/* FIXME: should really be level 0 but it occurs too often. KAO */
 		UNW_DPRINT(1, "unwind.%s: failed to locate return link (ip=0x%lx)!\n",
 			   __FUNCTION__, info->ip);
@@ -1888,8 +1895,7 @@ unw_unwind (struct unw_frame_info *info)
 	}
 
 	/* validate the previous stack frame pointer */
-	pfs_loc = (unsigned long) info->pfs_loc;
-	if ((pfs_loc < info->regstk.limit) || (pfs_loc > info->regstk.top)) {
+	if (!unw_valid(info, info->pfs_loc)) {
 		UNW_DPRINT(0, "unwind.%s: failed to locate ar.pfs!\n", __FUNCTION__);
 		STAT(unw.stat.api.unwind_time += ia64_get_itc() - start; local_irq_restore(flags));
 		return -1;

