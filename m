From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 28 May 2003 07:17:24 +0000
Subject: [Linux-ia64] [patch] 2.4.21-rc2-cset-1129 hugetlb, unwind fixes
Message-Id: <marc-linux-ia64-105590723706053@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.4.21-rc2-cset-1129 is 9 days old so some of these may have been fixed
already.

fs/proc/proc_misc.c:
  Allow build with CONFIG_HUGETLB_PAGE=n.

arch/ia64/kernel/unwind.c:
  Only call get_scratch_regs() when pt is really needed.  The premature
  calls to get_scratch_regs() would pick up the wrong address for pt if
  the register was in switch_stack and pt_regs had not been reached
  yet, e.g. unw_access_ar(&info, UNW_AR_BSPSTORE,...) before pt_regs
  had been reached.

  Correct debugging code that had the wrong the number of parameters
  and referred to non-existent variables.  Only shows up with
    CFLAGS_unwind.o += -DUNW_DEBUG=<number>.


Index: 21-rc2.3/fs/proc/proc_misc.c
--- 21-rc2.3/fs/proc/proc_misc.c Wed, 28 May 2003 16:39:56 +1000 kaos (linux-2.4/o/b/48_proc_misc. 1.1.1.1.1.1.1.17 644)
+++ 21-rc2.3(w)/fs/proc/proc_misc.c Wed, 28 May 2003 16:57:30 +1000 kaos (linux-2.4/o/b/48_proc_misc. 1.1.1.1.1.1.1.17 644)
@@ -208,7 +208,9 @@ static int meminfo_read_proc(char *page,
 		K(i.totalswap),
 		K(i.freeswap));
 
+#ifdef CONFIG_HUGETLB_PAGE
 	len += hugetlb_report_meminfo(page + len);
+#endif
 
 	return proc_calc_metrics(page, start, off, count, eof, len);
 #undef B
Index: 21-rc2.3/arch/ia64/kernel/unwind.c
--- 21-rc2.3/arch/ia64/kernel/unwind.c Sun, 18 May 2003 15:06:40 +1000 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.4 644)
+++ 21-rc2.3(w)/arch/ia64/kernel/unwind.c Wed, 28 May 2003 17:05:42 +1000 kaos (linux-2.4/r/c/42_unwind.c 1.1.2.1.1.2.3.1.1.1.1.4 644)
@@ -371,12 +371,11 @@ unw_access_br (struct unw_frame_info *in
 	unsigned long *addr;
 	struct pt_regs *pt;
 
-	pt = get_scratch_regs(info);
 	switch (regnum) {
 		/* scratch: */
-	      case 0: addr = &pt->b0; break;
-	      case 6: addr = &pt->b6; break;
-	      case 7: addr = &pt->b7; break;
+	      case 0: pt = get_scratch_regs(info); addr = &pt->b0; break;
+	      case 6: pt = get_scratch_regs(info); addr = &pt->b6; break;
+	      case 7: pt = get_scratch_regs(info); addr = &pt->b7; break;
 
 		/* preserved: */
 	      case 1: case 2: case 3: case 4: case 5:
@@ -409,15 +408,15 @@ unw_access_fr (struct unw_frame_info *in
 		return -1;
 	}
 
-	pt = get_scratch_regs(info);
-
 	if (regnum <= 5) {
 		addr = *(&info->f2_loc + (regnum - 2));
 		if (!addr)
 			addr = &info->sw->f2 + (regnum - 2);
 	} else if (regnum <= 15) {
-		if (regnum <= 9)
+		if (regnum <= 9) {
+			pt = get_scratch_regs(info);
 			addr = &pt->f6  + (regnum - 6);
+		}
 		else
 			addr = &info->sw->f10 + (regnum - 10);
 	} else if (regnum <= 31) {
@@ -447,7 +446,6 @@ unw_access_ar (struct unw_frame_info *in
 	unsigned long *addr;
 	struct pt_regs *pt;
 
-	pt = get_scratch_regs(info);
 	switch (regnum) {
 	      case UNW_AR_BSP:
 		addr = info->bsp_loc;
@@ -502,10 +500,12 @@ unw_access_ar (struct unw_frame_info *in
 		break;
 
 	      case UNW_AR_RSC:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_rsc;
 		break;
 
 	      case UNW_AR_CCV:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_ccv;
 		break;
 
@@ -1931,7 +1931,7 @@ init_frame_info (struct unw_frame_info *
 		   "  pr     0x%lx\n"
 		   "  sw     0x%lx\n"
 		   "  sp     0x%lx\n",
-		   __FUNCTION__, (unsigned long) task, rbslimit, rbstop, stktop, stklimit,
+		   __FUNCTION__, (unsigned long) t, rbslimit, rbstop, stktop, stklimit,
 		   info->pr, (unsigned long) info->sw, info->sp);
 	STAT(unw.stat.api.init_time += ia64_get_itc() - start; local_irq_restore(flags));
 }
@@ -1952,7 +1952,7 @@ unw_init_from_interruption (struct unw_f
 		   "  bsp    0x%lx\n"
 		   "  sof    0x%lx\n"
 		   "  ip     0x%lx\n",
-		   info->bsp, sof, info->ip);
+		   __FUNCTION__, info->bsp, sof, info->ip);
 	find_save_locs(info);
 }
 
@@ -1970,7 +1970,7 @@ unw_init_frame_info (struct unw_frame_in
 		   "  bsp    0x%lx\n"
 		   "  sol    0x%lx\n"
 		   "  ip     0x%lx\n",
-		   info->bsp, sol, info->ip);
+		   __FUNCTION__, info->bsp, sol, info->ip);
 	find_save_locs(info);
 }
 


