From: Jack Steiner <steiner@sgi.com>
Date: Thu, 15 Dec 2005 17:45:25 +0000
Subject: [PATCH] - Missed TLB flush
Message-Id: <20051215174525.GA28885@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It looks like there is a bug in the TLB flushing code. During context switch,
kernel threads inherit the mm of the task that was previously running on the
cpu. This confuses the code in ia64_global_tlb_purge() &
sn2_global_tlb_purge().

The result is a missed TLB purge for the task that owns the "borrowed" mm.

(I hit the problem running heavy stress where kswapd was purging code pages of
the user task that woke kswapd. The user task eventually took a SIGILL fault
trying to execute code in the page that had been ripped out from underneath it).

Am I overlooking something???? AFAICT, this problem has existed for a long time.


	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/mm/tlb.c
=================================--- linux.orig/arch/ia64/mm/tlb.c	2005-12-08 12:11:15.271472386 -0600
+++ linux/arch/ia64/mm/tlb.c	2005-12-15 11:24:51.009417801 -0600
@@ -90,7 +90,7 @@ ia64_global_tlb_purge (struct mm_struct 
 {
 	static DEFINE_SPINLOCK(ptcg_lock);
 
-	if (mm != current->active_mm) {
+	if (mm != current->active_mm || !current->mm) {
 		flush_tlb_all();
 		return;
 	}
Index: linux/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c	2005-12-15 11:20:49.192339703 -0600
+++ linux/arch/ia64/sn/kernel/sn2/sn2_smp.c	2005-12-15 11:33:28.163678685 -0600
@@ -202,7 +202,7 @@ sn2_global_tlb_purge(struct mm_struct *m
 		     unsigned long end, unsigned long nbits)
 {
 	int i, opt, shub1, cnode, mynasid, cpu, lcpu = 0, nasid, flushed = 0;
-	int mymm = (mm = current->active_mm);
+	int mymm = (mm = current->active_mm && current->mm);
 	volatile unsigned long *ptc0, *ptc1;
 	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value;
 	short nasids[MAX_NUMNODES], nix;
