From: Andrew Morton <akpm@osdl.org>
Date: Sat, 12 Mar 2005 10:26:18 +0000
Subject: ia64 msi warnings
Message-Id: <20050312022618.505ec72b.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The patch plugs a couple of warnings, but I'm wondering if it's simply
hiding 64-bit bugs?



drivers/pci/msi.c: In function `msi_set_mask_bit':
drivers/pci/msi.c:70: warning: cast from pointer to integer of different size
drivers/pci/msi.c: In function `msi_capability_init':
drivers/pci/msi.c:558: warning: cast to pointer from integer of different size


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/pci/msi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/pci/msi.c~ia64-msi-warning-fixes drivers/pci/msi.c
--- 25/drivers/pci/msi.c~ia64-msi-warning-fixes	Sat Mar 12 18:17:29 2005
+++ 25-akpm/drivers/pci/msi.c	Sat Mar 12 18:17:53 2005
@@ -67,7 +67,7 @@ static void msi_set_mask_bit(unsigned in
 		int		pos;
 		u32		mask_bits;
 
-		pos = (int)entry->mask_base;
+		pos = (long)entry->mask_base;
 		pci_read_config_dword(entry->dev, pos, &mask_bits);
 		mask_bits &= ~(1);
 		mask_bits |= flag;
@@ -555,7 +555,7 @@ static int msi_capability_init(struct pc
 	dev->irq = vector;
 	entry->dev = dev;
 	if (is_mask_bit_support(control)) {
-		entry->mask_base = (void __iomem *)msi_mask_bits_reg(pos,
+		entry->mask_base = (void __iomem *)(long)msi_mask_bits_reg(pos,
 				is_64bit_address(control));
 	}
 	/* Replace with MSI handler */
_

