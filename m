From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:27 +0000
Subject: [PATCH 08/31] c6x: handle page-less SG entries
Message-Id: <1439363150-8661-9-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Use sg_phys() instead of virt_to_phys(sg_virt(sg)) so that we don't
require a kernel virtual address.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/c6x/kernel/dma.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/c6x/kernel/dma.c b/arch/c6x/kernel/dma.c
index ab7b12d..79cae03 100644
--- a/arch/c6x/kernel/dma.c
+++ b/arch/c6x/kernel/dma.c
@@ -68,8 +68,7 @@ int dma_map_sg(struct device *dev, struct scatterlist *sglist,
 	int i;
 
 	for_each_sg(sglist, sg, nents, i)
-		sg->dma_address = dma_map_single(dev, sg_virt(sg), sg->length,
-						 dir);
+		sg->dma_address = sg_phys(sg);
 
 	debug_dma_map_sg(dev, sglist, nents, nents, dir);
 
-- 
1.9.1

