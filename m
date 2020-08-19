From: Christoph Hellwig <hch@lst.de>
Date: Wed, 19 Aug 2020 06:55:47 +0000
Subject: [PATCH 20/28] sgiwd93: convert from dma_cache_sync to dma_sync_single_for_device
Message-Id: <20200819065555.1802761-21-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819065555.1802761-1-hch@lst.de>
In-Reply-To: <20200819065555.1802761-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mauro Carvalho Chehab <mchehab@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Joonyoung Shim <jy0922.shim@samsung.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Ben Skeggs <bskeggs@redhat.com>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Matt Porter <mporter@kernel.crashing.org>, iommu@lists.linux-foundation.org
Cc: Tom Lendacky <thomas.lendacky@amd.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, nouveau@lists.freedesktop.org, netdev@vger.kernel.org, linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

Use the proper modern API to transfer cache ownership for incoherent DMA.
This also means we can allocate the memory as DMA_TO_DEVICE instead
of bidirectional.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/scsi/sgiwd93.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/scsi/sgiwd93.c b/drivers/scsi/sgiwd93.c
index 133adcf99e9340..1538f65307f22f 100644
--- a/drivers/scsi/sgiwd93.c
+++ b/drivers/scsi/sgiwd93.c
@@ -95,7 +95,7 @@ void fill_hpc_entries(struct ip22_hostdata *hd, struct scsi_cmnd *cmd, int din)
 	 */
 	hcp->desc.pbuf = 0;
 	hcp->desc.cntinfo = HPCDMA_EOX;
-	dma_cache_sync(hd->dev, hd->cpu,
+	dma_sync_single_for_device(hd->dev, hd->dma,
 		       (unsigned long)(hcp + 1) - (unsigned long)hd->cpu,
 		       DMA_TO_DEVICE);
 }
@@ -235,7 +235,7 @@ static int sgiwd93_probe(struct platform_device *pdev)
 	hdata = host_to_hostdata(host);
 	hdata->dev = &pdev->dev;
 	hdata->cpu = dma_alloc_pages(&pdev->dev, HPC_DMA_SIZE, &hdata->dma,
-				     DMA_BIDIRECTIONAL, GFP_KERNEL);
+				     DMA_TO_DEVICE, GFP_KERNEL);
 	if (!hdata->cpu) {
 		printk(KERN_WARNING "sgiwd93: Could not allocate memory for "
 		       "host %d buffer.\n", unit);
@@ -275,7 +275,7 @@ static int sgiwd93_probe(struct platform_device *pdev)
 	free_irq(irq, host);
 out_free:
 	dma_free_pages(&pdev->dev, HPC_DMA_SIZE, hdata->cpu, hdata->dma,
-			DMA_BIDIRECTIONAL);
+			DMA_TO_DEVICE);
 out_put:
 	scsi_host_put(host);
 out:
@@ -292,7 +292,7 @@ static int sgiwd93_remove(struct platform_device *pdev)
 	scsi_remove_host(host);
 	free_irq(pd->irq, host);
 	dma_free_pages(&pdev->dev, HPC_DMA_SIZE, hdata->cpu, hdata->dma,
-			DMA_BIDIRECTIONAL);
+			DMA_TO_DEVICE);
 	scsi_host_put(host);
 	return 0;
 }
-- 
2.28.0
