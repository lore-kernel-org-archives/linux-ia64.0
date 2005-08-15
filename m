From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Mon, 15 Aug 2005 21:46:18 +0000
Subject: [PATCH] fix bte_copy() calling smp_processor_id() while preemptible
Message-Id: <200508152146.j7FLkIRa2014013@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[PATCH] fix bte_copy() calling smp_processor_id() while preemptible

bte_copy() calls calls smp_processor_id(), which will get flagged if
preemption if enabled.  raw_smp_processor_id() is used instead 
because we are just using it to pick a BTE interface and are not 
tied to a specific cpu.

This patch applied on top of Jack Steiner's shub2 patches.

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------

 arch/ia64/sn/kernel/bte.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: test-2.6/arch/ia64/sn/kernel/bte.c
=================================--- test-2.6.orig/arch/ia64/sn/kernel/bte.c	2005-08-15 14:46:12.429921262 -0500
+++ test-2.6/arch/ia64/sn/kernel/bte.c	2005-08-15 16:04:05.655539040 -0500
@@ -105,7 +105,7 @@ bte_result_t bte_copy(u64 src, u64 dest,
 	/*
 	 * Start with interface corresponding to cpu number
 	 */
-	bte_first = get_cpu() % btes_per_node;
+	bte_first = raw_smp_processor_id() % btes_per_node;
 
 	if (mode & BTE_USE_DEST) {
 		/* try remote then local */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
