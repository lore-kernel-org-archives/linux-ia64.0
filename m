From: Christoph Hellwig <hch@lst.de>
Date: Mon, 14 Mar 2022 07:31:16 +0000
Subject: [PATCH 02/15] swiotlb: make swiotlb_exit a no-op if SWIOTLB_FORCE is set
Message-Id: <20220314073129.1862284-3-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
In-Reply-To: <20220314073129.1862284-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Juergen Gross <jgross@suse.com>, Tom Lendacky <thomas.lendacky@amd.com>, linux-s390@vger.kernel.org, Stefano Stabellini <sstabellini@kernel.org>, linux-ia64@vger.kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, tboot-devel@lists.sourceforge.net, linux-hyperv@vger.kernel.org, linux-pci@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Woodhouse <dwmw2@infradead.org>, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org

If force bouncing is enabled we can't release the buffers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 kernel/dma/swiotlb.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 908eac2527cb1..af9d257501a64 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -369,6 +369,9 @@ void __init swiotlb_exit(void)
 	unsigned long tbl_vaddr;
 	size_t tbl_size, slots_size;
 
+	if (swiotlb_force = SWIOTLB_FORCE)
+		return;
+
 	if (!mem->nslabs)
 		return;
 
-- 
2.30.2
