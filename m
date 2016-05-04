From: Matt Fleming <matt@codeblueprint.co.uk>
Date: Wed, 04 May 2016 11:17:47 +0000
Subject: [PATCH 2/5] ia64/PCI: Remove unused 'addr' and fix build warning
Message-Id: <1462360670-27993-3-git-send-email-matt@codeblueprint.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
In-Reply-To: <1462360670-27993-1-git-send-email-matt@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>

Ever since commit 240504adaf07 ("ia64/PCI: Keep CPU physical (not
virtual) addresses in shadow ROM resource") 'addr' has been unused,
resulting in the following compiler warning,

  arch/ia64/sn/kernel/io_acpi_init.c: In function 'sn_acpi_slot_fixup':
  arch/ia64/sn/kernel/io_acpi_init.c:429:16: warning: unused variable 'addr' [-Wunused-variable]
    void __iomem *addr;
                ^

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <helgaas@kernel.org>
Signed-off-by: Matt Fleming <matt@codeblueprint.co.uk>
---
 arch/ia64/sn/kernel/io_acpi_init.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/io_acpi_init.c b/arch/ia64/sn/kernel/io_acpi_init.c
index 231234c8d113..c31fe637b0b4 100644
--- a/arch/ia64/sn/kernel/io_acpi_init.c
+++ b/arch/ia64/sn/kernel/io_acpi_init.c
@@ -426,7 +426,6 @@ sn_acpi_get_pcidev_info(struct pci_dev *dev, struct pcidev_info **pcidev_info,
 void
 sn_acpi_slot_fixup(struct pci_dev *dev)
 {
-	void __iomem *addr;
 	struct pcidev_info *pcidev_info = NULL;
 	struct sn_irq_info *sn_irq_info = NULL;
 	struct resource *res;
-- 
2.7.3

