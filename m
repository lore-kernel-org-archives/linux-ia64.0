From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Fri, 07 Nov 2008 23:00:50 +0000
Subject: [IA64] remove duplicated #include
Message-Id: <20081108065847.CDAC.WEIYI.HUANG@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Removed duplicated #include <asm/iommu.h> in
arch/ia64/kernel/pci-dma.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index dbdb778..2a92f63 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -19,7 +19,6 @@
 #include <linux/kernel.h>

 #include <asm/page.h>
-#include <asm/iommu.h>

 dma_addr_t bad_dma_address __read_mostly;
 EXPORT_SYMBOL(bad_dma_address);

