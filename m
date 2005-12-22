From: Jack Steiner <steiner@sgi.com>
Date: Thu, 22 Dec 2005 19:45:41 +0000
Subject: Possibly hole in IA64 TLB flushing from system threads
Message-Id: <20051222194541.GA27329@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I originally thought this was an bug only in the SN code, but I think I
also see a hole in the generic IA64 tlb code. (Separate patch was sent 
for the SN problem).

It looks like there is a bug in the TLB flushing code. During context switch,
kernel threads (kswapd, for example) inherit the mm of the task that was 
previously running on the cpu. Normally, this is ok because the previous context
is still loaded into the RR registers. However, if the owner of the mm
migrates to another cpu, changes it's context number, and references a
page before kswapd issues a tlb_purge for that same page, the purge will be 
done with a stale context number (& RR registers).

Am I overlooking something????



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
