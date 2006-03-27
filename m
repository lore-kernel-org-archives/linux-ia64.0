From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Mon, 27 Mar 2006 08:13:46 +0000
Subject: [PATCH 2/2] simplify some condition checks
Message-Id: <87d5g8fgp1.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87mzfgfieg.wl%takeuchi_satoru@jp.fujitsu.com>
In-Reply-To: <87mzfgfieg.wl%takeuchi_satoru@jp.fujitsu.com>
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
=================================--- linux-2.6.16.orig/arch/ia64/kernel/iosapic.c	2006-03-27 10:37:09.000000000 +0900
+++ linux-2.6.16/arch/ia64/kernel/iosapic.c	2006-03-27 15:13:08.000000000 +0900
@@ -1057,10 +1057,7 @@
 		base = iosapic_lists[index].gsi_base;
 		end  = base + iosapic_lists[index].num_rte - 1;
 
-		if (gsi_base < base && gsi_end < base)
-			continue;/* OK */
-
-		if (gsi_base > end && gsi_end > end)
+		if (gsi_end < base || end < gsi_base)
 			continue; /* OK */
 
 		return -EBUSY;
