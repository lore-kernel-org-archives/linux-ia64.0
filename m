From: Ian Campbell <ian.campbell@citrix.com>
Date: Fri, 29 May 2009 08:43:55 +0000
Subject: [PATCH 1/9] ia64: introduce arch-specific dma-mapping interfaces
Message-Id: <1243586643-5554-2-git-send-email-ian.campbell@citrix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1243586643-5554-1-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1243586643-5554-1-git-send-email-ian.campbell@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Ian Campbell <ian.campbell@citrix.com>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

dma_map_range is intended to replace usage of both
swiotlb_arch_range_needs_mapping and
swiotlb_arch_address_needs_mapping as __weak functions as well as
replacing is_buffer_dma_capable.

phys_to_dma and dma_to_phys are intended to replace
swiotlb_phys_to_bus and swiotlb_bus_to_phys.  I choose to use dma
rather than bus since a) it matches the parameters and b) avoids
confusion on x86 with the existing (but deprecated) virt_to_bus
function which relates to ISA device DMA.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/dma-mapping.h |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index 36c0009..7250e1a 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -174,4 +174,27 @@ dma_cache_sync (struct device *dev, void *vaddr, size_t size,
 
 #define dma_is_consistent(d, h)	(1)	/* all we do is coherent memory... */
 
+static inline dma_addr_t phys_to_dma(struct device *hwdev, phys_addr_t paddr)
+{
+        return paddr;
+}
+
+static inline phys_addr_t dma_to_phys(struct device *hwdev, dma_addr_t daddr)
+{
+        return daddr;
+}
+
+static inline bool dma_map_range(struct device *dev, u64 mask,
+				       phys_addr_t addr, size_t size,
+				       dma_addr_t *dma_addr_p)
+{
+	dma_addr_t dma_addr = phys_to_dma(dev, addr);
+
+	if (dma_addr + size > mask)
+		return false;
+
+	*dma_addr_p = dma_addr;
+	return true;
+}
+
 #endif /* _ASM_IA64_DMA_MAPPING_H */
-- 
1.5.6.5

