From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 31 May 2003 04:03:14 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.21-rc2-cset-1129 hugetlb, unwind fixes
Message-Id: <marc-linux-ia64-105590723706104@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 30 May 2003 18:16:19 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Wed, 28 May 2003 17:17:24 +1000, Keith Owens <kaos@ocs.com.au> said:
>
>  Keith> arch/ia64/kernel/unwind.c: Only call get_scratch_regs() when
>  Keith> pt is really needed.  The premature calls to
>  Keith> get_scratch_regs() would pick up the wrong address for pt if
>  Keith> the register was in switch_stack and pt_regs had not been
>  Keith> reached yet, e.g. unw_access_ar(&info, UNW_AR_BSPSTORE,...)
>  Keith> before pt_regs had been reached.
>
>This looks fine to me.  Can you send me a 2.5 patch?

2.5 only requires the pt_regs changes.  First patch is against
2.5.69-ia64-030521, second does the same thing against 2.5.69 ia64
cset-1.1042.1.187-to-1.1102.

Bjorn, there are several minor differences between the 2.5.69 version
of unwind.c and 2.4.21-rc2-ia64-cset-1.1116.2.93-to-1.1129, AFAICT
there is no reason for the differences.  The 2.5.69 version of unwind.c
plus the first patch below can drop straight into 2.4, replacing the
patch I sent against cset-1129.  The cset 2.5.69 1.1102 version is not
compatible with 2.4 kernels.


Index: 69.3/arch/ia64/kernel/unwind.c
--- 69.3/arch/ia64/kernel/unwind.c Thu, 22 May 2003 13:08:29 +1000 kaos (linux-2.5/t/14_unwind.c 1.1.2.2.1.1.1.5 444)
+++ 69.3(w)/arch/ia64/kernel/unwind.c Sat, 31 May 2003 13:30:33 +1000 kaos (linux-2.5/t/14_unwind.c 1.1.2.2.1.1.1.5 444)
@@ -374,12 +374,11 @@ unw_access_br (struct unw_frame_info *in
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
@@ -412,15 +411,15 @@ unw_access_fr (struct unw_frame_info *in
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
@@ -450,7 +449,6 @@ unw_access_ar (struct unw_frame_info *in
 	unsigned long *addr;
 	struct pt_regs *pt;
 
-	pt = get_scratch_regs(info);
 	switch (regnum) {
 	      case UNW_AR_BSP:
 		addr = info->bsp_loc;
@@ -505,10 +503,12 @@ unw_access_ar (struct unw_frame_info *in
 		break;
 
 	      case UNW_AR_RSC:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_rsc;
 		break;
 
 	      case UNW_AR_CCV:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_ccv;
 		break;
 



Index: 69.4/arch/ia64/kernel/unwind.c
--- 69.4/arch/ia64/kernel/unwind.c Sat, 31 May 2003 13:55:27 +1000 kaos (linux-2.5/t/14_unwind.c 1.1.2.2.1.1.1.6 644)
+++ 69.4(w)/arch/ia64/kernel/unwind.c Sat, 31 May 2003 13:53:14 +1000 kaos (linux-2.5/t/14_unwind.c 1.1.2.2.1.1.1.6 644)
@@ -403,12 +403,11 @@ unw_access_br (struct unw_frame_info *in
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
@@ -441,15 +440,15 @@ unw_access_fr (struct unw_frame_info *in
 		return -1;
 	}
 
-	pt = get_scratch_regs(info);
-
 	if (regnum <= 5) {
 		addr = *(&info->f2_loc + (regnum - 2));
 		if (!addr)
 			addr = &info->sw->f2 + (regnum - 2);
 	} else if (regnum <= 15) {
-		if (regnum <= 11)
+		if (regnum <= 11) {
+			pt = get_scratch_regs(info);
 			addr = &pt->f6  + (regnum - 6);
+		}
 		else
 			addr = &info->sw->f12 + (regnum - 12);
 	} else if (regnum <= 31) {
@@ -479,7 +478,6 @@ unw_access_ar (struct unw_frame_info *in
 	unsigned long *addr;
 	struct pt_regs *pt;
 
-	pt = get_scratch_regs(info);
 	switch (regnum) {
 	      case UNW_AR_BSP:
 		addr = info->bsp_loc;
@@ -534,18 +532,22 @@ unw_access_ar (struct unw_frame_info *in
 		break;
 
 	      case UNW_AR_RSC:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_rsc;
 		break;
 
 	      case UNW_AR_CCV:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_ccv;
 		break;
 
 	      case UNW_AR_CSD:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_csd;
 		break;
 
 	      case UNW_AR_SSD:
+		pt = get_scratch_regs(info);
 		addr = &pt->ar_ssd;
 		break;
 


