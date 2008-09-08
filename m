From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 08 Sep 2008 09:10:14 +0000
Subject: [PATCH 5/5] swiotlb: remove GFP_DMA hack in swiotlb_alloc_coherent
Message-Id: <1220865014-1169-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1220865014-1169-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1220865014-1169-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1220865014-1169-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1220865014-1169-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1220865014-1169-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1220865014-1169-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, joerg.roedel@amd.com, tony.luck@intel.com, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, fujita.tomonori@lab.ntt.co.jp

The callers are supposed to set up the gfp flags appropriately.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 lib/swiotlb.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 977edbd..3066ffe 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -467,13 +467,6 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 	void *ret;
 	int order = get_order(size);
 
-	/*
-	 * XXX fix me: the DMA API should pass us an explicit DMA mask
-	 * instead, or use ZONE_DMA32 (ia64 overloads ZONE_DMA to be a ~32
-	 * bit range instead of a 16MB one).
-	 */
-	flags |= GFP_DMA;
-
 	ret = (void *)__get_free_pages(flags, order);
 	if (ret && address_needs_mapping(hwdev, virt_to_bus(ret))) {
 		/*
-- 
1.5.5.GIT

