From: Matt Fleming <matt@codeblueprint.co.uk>
Date: Wed, 04 May 2016 11:17:46 +0000
Subject: [PATCH 1/5] ia64/PCI: Fix incorrect PCI resource end address
Message-Id: <1462360670-27993-2-git-send-email-matt@codeblueprint.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
In-Reply-To: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>

commit f976721e826e ("ia64/PCI: Use ioremap() instead of open-coded
equivalent") introduced the following compiler warning,

  arch/ia64/sn/kernel/io_init.c: In function 'sn_io_slot_fixup':
  arch/ia64/sn/kernel/io_init.c:189:19: warning: 'addr' may be used uninitialized in this function [-Wmaybe-uninitialized]
     res->end = addr + size;
                   ^

'addr' is indeed uninitialised and the correct value to use is
res->start.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>
Signed-off-by: Matt Fleming <matt@codeblueprint.co.uk>
---
 arch/ia64/sn/kernel/io_init.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index c15a41e2d1f2..d63809a6adfa 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -151,7 +151,7 @@ sn_io_slot_fixup(struct pci_dev *dev)
 {
 	int idx;
 	struct resource *res;
-	unsigned long addr, size;
+	unsigned long size;
 	struct pcidev_info *pcidev_info;
 	struct sn_irq_info *sn_irq_info;
 	int status;
@@ -186,7 +186,7 @@ sn_io_slot_fixup(struct pci_dev *dev)
 			continue;
 
 		res->start = pcidev_info->pdi_pio_mapped_addr[idx];
-		res->end = addr + size;
+		res->end = res->start + size;
 
 		/*
 		 * if it's already in the device structure, remove it before
-- 
2.7.3

