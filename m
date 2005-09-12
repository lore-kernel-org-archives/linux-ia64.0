From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 12 Sep 2005 19:53:56 +0000
Subject: [patch 2.6.13] swiotlb: BUG() for DMA_NONE in sync_single
Message-Id: <20050912195356.GD19644@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104851.31056@bilbo.tuxdriver.com> <09122005104851.31120@bilbo.tuxdriver.com> <20050912185120.GD21820@esmail.cup.hp.com> <20050912195110.GC19644@tuxdriver.com>
In-Reply-To: <20050912195110.GC19644@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: linux-kernel@vger.kernel.org, discuss@x86-64.org, linux-ia64@vger.kernel.org, ak@suse.de, tony.luck@intel.com, Asit.K.Mallick@intel.com

Call BUG() if DMA_NONE is passed-in as direction for sync_single.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 lib/swiotlb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -315,13 +315,13 @@ sync_single(struct device *hwdev, char *
 	case SYNC_FOR_CPU:
 		if (likely(dir = DMA_FROM_DEVICE || dma = DMA_BIDIRECTIONAL))
 			memcpy(buffer, dma_addr, size);
-		else if (dir != DMA_TO_DEVICE && dir != DMA_NONE)
+		else if (dir != DMA_TO_DEVICE)
 			BUG();
 		break;
 	case SYNC_FOR_DEVICE:
 		if (likely(dir = DMA_TO_DEVICE || dma = DMA_BIDIRECTIONAL))
 			memcpy(dma_addr, buffer, size);
-		else if (dir != DMA_FROM_DEVICE && dir != DMA_NONE)
+		else if (dir != DMA_FROM_DEVICE)
 			BUG();
 		break;
 	default:
-- 
John W. Linville
linville@tuxdriver.com
