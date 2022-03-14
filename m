From: Christoph Hellwig <hch@lst.de>
Date: Mon, 14 Mar 2022 07:31:15 +0000
Subject: [PATCH 01/15] dma-direct: use is_swiotlb_active in dma_direct_map_page
Message-Id: <20220314073129.1862284-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
In-Reply-To: <20220314073129.1862284-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Juergen Gross <jgross@suse.com>, Tom Lendacky <thomas.lendacky@amd.com>, linux-s390@vger.kernel.org, Stefano Stabellini <sstabellini@kernel.org>, linux-ia64@vger.kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, tboot-devel@lists.sourceforge.net, linux-hyperv@vger.kernel.org, linux-pci@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Woodhouse <dwmw2@infradead.org>, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org

Use the more specific is_swiotlb_active check instead of checking the
global swiotlb_force variable.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 kernel/dma/direct.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/dma/direct.h b/kernel/dma/direct.h
index 4632b0f4f72eb..4dc16e08c7e1a 100644
--- a/kernel/dma/direct.h
+++ b/kernel/dma/direct.h
@@ -91,7 +91,7 @@ static inline dma_addr_t dma_direct_map_page(struct device *dev,
 		return swiotlb_map(dev, phys, size, dir, attrs);
 
 	if (unlikely(!dma_capable(dev, dma_addr, size, true))) {
-		if (swiotlb_force != SWIOTLB_NO_FORCE)
+		if (is_swiotlb_active(dev))
 			return swiotlb_map(dev, phys, size, dir, attrs);
 
 		dev_WARN_ONCE(dev, 1,
-- 
2.30.2
