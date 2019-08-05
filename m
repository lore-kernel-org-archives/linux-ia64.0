From: Christoph Hellwig <hch@lst.de>
Date: Mon, 05 Aug 2019 07:10:12 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <20190805071012.GA15366@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Seems like we dropped the ball on this..

Did I give you a patch like this (for 5.2 and probably earlier, won't
apply to 5.3-rc) to test before as that is anther idea?

diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 2c2772e9702a..e471158c7c6e 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -119,7 +119,8 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
 		}
 	}
 	if (!page)
-		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
+		page = alloc_pages_node(local_memory_node(dev_to_node(dev)),
+				gfp, page_order);
 
 	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
 		__free_pages(page, page_order);
