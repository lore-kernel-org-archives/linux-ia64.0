From: Jeff Mahoney <jeffm@suse.com>
Date: Thu, 24 Feb 2011 20:33:24 +0000
Subject: [PATCH] tioca: Fix assignment from incompatible pointer warnings
Message-Id: <4D66C094.4050800@suse.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>

 The prototype for sn_pci_provider->{dma_map,dma_map_consistent} expects
 an unsigned long instead of a u64.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 arch/ia64/sn/pci/tioca_provider.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -509,7 +509,7 @@ tioca_dma_unmap(struct pci_dev *pdev, dm
  * use the GART mapped mode.
  */
 static u64
-tioca_dma_map(struct pci_dev *pdev, u64 paddr, size_t byte_count, int dma_flags)
+tioca_dma_map(struct pci_dev *pdev, unsigned long paddr, size_t byte_count, int dma_flags)
 {
 	u64 mapaddr;
 
-- 
Jeff Mahoney
SUSE Labs
