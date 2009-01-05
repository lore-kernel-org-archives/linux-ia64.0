From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:10 +0000
Subject: [PATCH 05/13] add dma_mapping_ops for SGI Altix
Message-Id: <1231166178-20050-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-5-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This is for IA64_SGI_SN2.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/sn/pci/pci_dma.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 53ebb64..4ad13ff 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -11,6 +11,7 @@
 
 #include <linux/module.h>
 #include <linux/dma-attrs.h>
+#include <linux/dma-mapping.h>
 #include <asm/dma.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/pcibus_provider_defs.h>
@@ -465,3 +466,18 @@ int sn_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
  out:
 	return ret;
 }
+
+struct dma_mapping_ops sn_dma_ops = {
+	.alloc_coherent		= sn_dma_alloc_coherent,
+	.free_coherent		= sn_dma_free_coherent,
+	.map_single_attrs	= sn_dma_map_single_attrs,
+	.unmap_single_attrs	= sn_dma_unmap_single_attrs,
+	.map_sg_attrs		= sn_dma_map_sg_attrs,
+	.unmap_sg_attrs		= sn_dma_unmap_sg_attrs,
+	.sync_single_for_cpu 	= sn_dma_sync_single_for_cpu,
+	.sync_sg_for_cpu	= sn_dma_sync_sg_for_cpu,
+	.sync_single_for_device = sn_dma_sync_single_for_device,
+	.sync_sg_for_device	= sn_dma_sync_sg_for_device,
+	.mapping_error		= sn_dma_mapping_error,
+	.dma_supported_op	= sn_dma_supported,
+};
-- 
1.6.0.6

