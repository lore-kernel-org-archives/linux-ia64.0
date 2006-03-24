From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Fri, 24 Mar 2006 06:47:51 +0000
Subject: [PATCH 2/2] simplify some condition checks
Message-Id: <87mzfgfieg.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some condition checks on iosapic_check_gsi_range() can be omitted
because always `base <= end' is assured. This patch simplifies that
ckecks.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)

Index: linux-2.6.16/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.16.orig/arch/ia64/kernel/iosapic.c	2006-03-24 14:42:44.000000000 +0900
+++ linux-2.6.16/arch/ia64/kernel/iosapic.c	2006-03-24 14:42:55.000000000 +0900
@@ -994,10 +994,7 @@
 		base = iosapic_lists[index].gsi_base;
 		end  = base + iosapic_lists[index].num_rte - 1;
 
-		if (gsi_base < base && gsi_end < base)
-			continue;/* OK */
-
-		if (gsi_base > end && gsi_end > end)
+		if (gsi_end < base || end < gsi_base)
 			continue; /* OK */
 
 		return -EBUSY;
