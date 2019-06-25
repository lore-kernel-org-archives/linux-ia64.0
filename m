From: Christoph Hellwig <hch@lst.de>
Date: Tue, 25 Jun 2019 10:32:32 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <20190625103232.GA2132@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks Frank.

It seems like there is something odd going on with the zonelist
on your system.  Maybe there is not actual ZONE_DMA32, or something
is messed with the numa node setup.  Below is a band aid patch to
try theory number two above:


diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index fcdb23e8d2fc..8e3f7b8bdb33 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -119,7 +119,7 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
 		}
 	}
 	if (!page)
-		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
+		page = alloc_pages(gfp, page_order);
 
 	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
 		__free_pages(page, page_order);
