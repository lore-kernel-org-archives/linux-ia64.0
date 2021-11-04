From: davidcomponentone@gmail.com
Date: Thu, 04 Nov 2021 00:19:08 +0000
Subject: [PATCH] ia64: use swap() to make code cleaner
Message-Id: <20211104001908.695110-1-yang.guang5@zte.com.cn>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: geert+renesas@glider.be
Cc: davidcomponentone@gmail.com, akpm@linux-foundation.org, yang.guang5@zte.com.cn, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Zeal Robot <zealci@zte.com.cn>

From: Yang Guang <yang.guang5@zte.com.cn>

Use the macro 'swap()' defined in 'include/linux/minmax.h' to avoid
opencoding it.

Signed-off-by: Yang Guang <yang.guang5@zte.com.cn>
Reported-by: Zeal Robot <zealci@zte.com.cn>
---
 arch/ia64/kernel/setup.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 31fb84de2d21..5010348fa21b 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -208,10 +208,7 @@ sort_regions (struct rsvd_region *rsvd_region, int max)
 	while (max--) {
 		for (j = 0; j < max; ++j) {
 			if (rsvd_region[j].start > rsvd_region[j+1].start) {
-				struct rsvd_region tmp;
-				tmp = rsvd_region[j];
-				rsvd_region[j] = rsvd_region[j + 1];
-				rsvd_region[j + 1] = tmp;
+				swap(rsvd_region[j], rsvd_region[j + 1]);
 			}
 		}
 	}
-- 
2.30.2
