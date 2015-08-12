From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:23 +0000
Subject: [PATCH 04/31] x86/pci-nommu: handle page-less SG entries
Message-Id: <1439363150-8661-5-git-send-email-hch@lst.de>
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
 arch/x86/kernel/pci-nommu.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index da15918..a218059 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -63,7 +63,6 @@ static int nommu_map_sg(struct device *hwdev, struct scatterlist *sg,
 	WARN_ON(nents = 0 || sg[0].length = 0);
 
 	for_each_sg(sg, s, nents, i) {
-		BUG_ON(!sg_page(s));
 		s->dma_address = sg_phys(s);
 		if (!check_addr("map_sg", hwdev, s->dma_address, s->length))
 			return 0;
-- 
1.9.1

