From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:22 +0000
Subject: [PATCH 03/31] dma-debug: handle page-less SG entries
Message-Id: <1439363150-8661-4-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Use sg_pfn to get a the PFN and skip checks that require a kernel
virtual address.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 lib/dma-debug.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index dace71f..a215a80 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -1368,7 +1368,7 @@ void debug_dma_map_sg(struct device *dev, struct scatterlist *sg,
 
 		entry->type           = dma_debug_sg;
 		entry->dev            = dev;
-		entry->pfn	      = page_to_pfn(sg_page(s));
+		entry->pfn	      = sg_pfn(s);
 		entry->offset	      = s->offset,
 		entry->size           = sg_dma_len(s);
 		entry->dev_addr       = sg_dma_address(s);
@@ -1376,7 +1376,7 @@ void debug_dma_map_sg(struct device *dev, struct scatterlist *sg,
 		entry->sg_call_ents   = nents;
 		entry->sg_mapped_ents = mapped_ents;
 
-		if (!PageHighMem(sg_page(s))) {
+		if (sg_has_page(s) && !PageHighMem(sg_page(s))) {
 			check_for_stack(dev, sg_virt(s));
 			check_for_illegal_area(dev, sg_virt(s), sg_dma_len(s));
 		}
@@ -1419,7 +1419,7 @@ void debug_dma_unmap_sg(struct device *dev, struct scatterlist *sglist,
 		struct dma_debug_entry ref = {
 			.type           = dma_debug_sg,
 			.dev            = dev,
-			.pfn		= page_to_pfn(sg_page(s)),
+			.pfn		= sg_pfn(s),
 			.offset		= s->offset,
 			.dev_addr       = sg_dma_address(s),
 			.size           = sg_dma_len(s),
@@ -1580,7 +1580,7 @@ void debug_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 		struct dma_debug_entry ref = {
 			.type           = dma_debug_sg,
 			.dev            = dev,
-			.pfn		= page_to_pfn(sg_page(s)),
+			.pfn		= sg_pfn(s),
 			.offset		= s->offset,
 			.dev_addr       = sg_dma_address(s),
 			.size           = sg_dma_len(s),
@@ -1613,7 +1613,7 @@ void debug_dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 		struct dma_debug_entry ref = {
 			.type           = dma_debug_sg,
 			.dev            = dev,
-			.pfn		= page_to_pfn(sg_page(s)),
+			.pfn		= sg_pfn(s),
 			.offset		= s->offset,
 			.dev_addr       = sg_dma_address(s),
 			.size           = sg_dma_len(s),
-- 
1.9.1

