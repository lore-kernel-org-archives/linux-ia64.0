From: Christoph Hellwig <hch@lst.de>
Date: Mon, 14 Mar 2022 07:31:19 +0000
Subject: [PATCH 05/15] arm/xen: don't check for xen_initial_domain() in xen_create_contiguous_region
Message-Id: <20220314073129.1862284-6-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
In-Reply-To: <20220314073129.1862284-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-hyperv@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, Stefano Stabellini <sstabellini@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, tboot-devel@lists.sourceforge.net, xen-devel@lists.xenproject.org, Stefano Stabellini <stefano.stabellini@xilinx.com>, David Woodhouse <dwmw2@infradead.org>, Tom Lendacky <thomas.lendacky@amd.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-arm-kernel@lists.infradead.org, Juergen Gross <jgross@suse.com>, linuxppc-dev@lists.ozlabs.org, linux-mips@vger.kernel.org, Robin Murphy <robin.murphy@arm.com>

From: Stefano Stabellini <sstabellini@kernel.org>

It used to be that Linux enabled swiotlb-xen when running a dom0 on ARM.
Since f5079a9a2a31 "xen/arm: introduce XENFEAT_direct_mapped and
XENFEAT_not_direct_mapped", Linux detects whether to enable or disable
swiotlb-xen based on the new feature flags: XENFEAT_direct_mapped and
XENFEAT_not_direct_mapped.

However, there is still a leftover xen_initial_domain() check in
xen_create_contiguous_region. Remove the check as
xen_create_contiguous_region is only called by swiotlb-xen during
initialization. If xen_create_contiguous_region is called, we know Linux
is running 1:1 mapped so there is no need for additional checks.

Also update the in-code comment.

Signed-off-by: Stefano Stabellini <stefano.stabellini@xilinx.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/xen/mm.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/arch/arm/xen/mm.c b/arch/arm/xen/mm.c
index a7e54a087b802..28c2070602535 100644
--- a/arch/arm/xen/mm.c
+++ b/arch/arm/xen/mm.c
@@ -122,10 +122,7 @@ int xen_create_contiguous_region(phys_addr_t pstart, unsigned int order,
 				 unsigned int address_bits,
 				 dma_addr_t *dma_handle)
 {
-	if (!xen_initial_domain())
-		return -EINVAL;
-
-	/* we assume that dom0 is mapped 1:1 for now */
+	/* the domain is 1:1 mapped to use swiotlb-xen */
 	*dma_handle = pstart;
 	return 0;
 }
-- 
2.30.2
