From: Christoph Hellwig <hch@lst.de>
Date: Wed, 12 Aug 2015 07:05:44 +0000
Subject: [PATCH 25/31] frv: handle page-less SG entries
Message-Id: <1439363150-8661-26-git-send-email-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de>
In-Reply-To: <1439363150-8661-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, axboe@kernel.dk
Cc: dan.j.williams@intel.com, vgupta@synopsys.com, hskinnemoen@gmail.com, egtvedt@samfundet.no, realmz6@gmail.com, dhowells@redhat.com, monstr@monstr.eu, x86@kernel.org, dwmw2@infradead.org, alex.williamson@redhat.com, grundler@parisc-linux.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-nvdimm@ml01.01.org, linux-media@vger.kernel.org

Only call kmap_atomic_primary when the SG entry is mapped into
kernel virtual space.

XXX: the code already looks odd due to the lack of pairing between
kmap_atomic_primary and kunmap_atomic_primary.  Does it work either
before or after this patch?

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/frv/mb93090-mb00/pci-dma.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/frv/mb93090-mb00/pci-dma.c b/arch/frv/mb93090-mb00/pci-dma.c
index 4d1f01d..77b3a1c 100644
--- a/arch/frv/mb93090-mb00/pci-dma.c
+++ b/arch/frv/mb93090-mb00/pci-dma.c
@@ -63,6 +63,9 @@ int dma_map_sg(struct device *dev, struct scatterlist *sglist, int nents,
 	dampr2 = __get_DAMPR(2);
 
 	for_each_sg(sglist, sg, nents, i) {
+		if (!sg_has_page(sg))
+			continue;
+
 		vaddr = kmap_atomic_primary(sg_page(sg));
 
 		frv_dcache_writeback((unsigned long) vaddr,
-- 
1.9.1

