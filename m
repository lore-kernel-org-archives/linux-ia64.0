From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:31 +0000
Subject: [PATCH 12/31] mn10300: handle page-less SG entries
Message-Id: <1439363150-8661-13-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Just remove a BUG_ON, the code handles them just fine as-is.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/mn10300/include/asm/dma-mapping.h | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/mn10300/include/asm/dma-mapping.h b/arch/mn10300/include/asm/dma-mapping.h
index a18abfc..b1b1050 100644
--- a/arch/mn10300/include/asm/dma-mapping.h
+++ b/arch/mn10300/include/asm/dma-mapping.h
@@ -57,11 +57,8 @@ int dma_map_sg(struct device *dev, struct scatterlist *sglist, int nents,
 	BUG_ON(!valid_dma_direction(direction));
 	WARN_ON(nents = 0 || sglist[0].length = 0);
 
-	for_each_sg(sglist, sg, nents, i) {
-		BUG_ON(!sg_page(sg));
-
+	for_each_sg(sglist, sg, nents, i)
 		sg->dma_address = sg_phys(sg);
-	}
 
 	mn10300_dcache_flush_inv();
 	return nents;
-- 
1.9.1

