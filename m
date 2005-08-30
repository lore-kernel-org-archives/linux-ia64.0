From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Aug 2005 05:04:52 +0000
Subject: [PATCH 2.6.13 7/7] MCA/INIT: remove obsolete unwind code
Message-Id: <20050830050452.7997.99392.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Delete the special case unwind code that was only used by the old
MCA/INIT handler.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 arch/ia64/kernel/unwind.c |   22 ----------------------
 include/asm-ia64/unwind.h |    7 -------
 2 files changed, 29 deletions(-)

Index: linux/arch/ia64/kernel/unwind.c
=================================--- linux.orig/arch/ia64/kernel/unwind.c	2005-08-12 17:19:20.903916664 +1000
+++ linux/arch/ia64/kernel/unwind.c	2005-08-12 17:22:26.545613275 +1000
@@ -2020,28 +2020,6 @@ init_frame_info (struct unw_frame_info *
 }
 
 void
-unw_init_from_interruption (struct unw_frame_info *info, struct task_struct *t,
-			    struct pt_regs *pt, struct switch_stack *sw)
-{
-	unsigned long sof;
-
-	init_frame_info(info, t, sw, pt->r12);
-	info->cfm_loc = &pt->cr_ifs;
-	info->unat_loc = &pt->ar_unat;
-	info->pfs_loc = &pt->ar_pfs;
-	sof = *info->cfm_loc & 0x7f;
-	info->bsp = (unsigned long) ia64_rse_skip_regs((unsigned long *) info->regstk.top, -sof);
-	info->ip = pt->cr_iip + ia64_psr(pt)->ri;
-	info->pt = (unsigned long) pt;
-	UNW_DPRINT(3, "unwind.%s:\n"
-		   "  bsp    0x%lx\n"
-		   "  sof    0x%lx\n"
-		   "  ip     0x%lx\n",
-		   __FUNCTION__, info->bsp, sof, info->ip);
-	find_save_locs(info);
-}
-
-void
 unw_init_frame_info (struct unw_frame_info *info, struct task_struct *t, struct switch_stack *sw)
 {
 	unsigned long sol;
Index: linux/include/asm-ia64/unwind.h
=================================--- linux.orig/include/asm-ia64/unwind.h	2005-08-12 17:19:20.900986975 +1000
+++ linux/include/asm-ia64/unwind.h	2005-08-12 17:22:32.848350877 +1000
@@ -114,13 +114,6 @@ extern void unw_remove_unwind_table (voi
  */
 extern void unw_init_from_blocked_task (struct unw_frame_info *info, struct task_struct *t);
 
-/*
- * Prepare to unwind from interruption.  The pt-regs and switch-stack structures must have
- * be "adjacent" (no state modifications between pt-regs and switch-stack).
- */
-extern void unw_init_from_interruption (struct unw_frame_info *info, struct task_struct *t,
-					struct pt_regs *pt, struct switch_stack *sw);
-
 extern void unw_init_frame_info (struct unw_frame_info *info, struct task_struct *t,
 				 struct switch_stack *sw);
 
