From: Colin Ngam <cngam@sgi.com>
Date: Fri, 04 Mar 2005 17:02:37 +0000
Subject: [PATCH 2.6.11-rc3 0/0] Altix: Fix TIO DMA Macro to support both Shub1 and Shub2
Message-Id: <20050304170237.25191.39562.36431@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch enables our TIO IO chipset to support variable length nasids in 
Shub2 chipset.

Signed-off-by: Colin Ngam <cngam@sgi.com>

=== include/asm-ia64/sn/addrs.h 1.11 vs edited ==--- 1.11/include/asm-ia64/sn/addrs.h	2004-12-10 14:10:33 -06:00
+++ edited/include/asm-ia64/sn/addrs.h	2005-03-03 15:20:37 -06:00
@@ -153,8 +153,9 @@
  *           the chiplet id is zero.  If we implement TIO-TIO dma, we might need
  *           to insert a chiplet id into this macro.  However, it is our belief
  *           right now that this chiplet id will be ICE, which is also zero.
+ *           Nasid starts on bit 40.
  */
-#define PHYS_TO_TIODMA(x)	( (((u64)(x) & NASID_MASK) << 2) | NODE_OFFSET(x))
+#define PHYS_TO_TIODMA(x)	( (((u64)(NASID_GET(x))) << 40) | NODE_OFFSET(x))
 #define PHYS_TO_DMA(x)          ( (((u64)(x) & NASID_MASK) >> 2) | NODE_OFFSET(x))
 
 
