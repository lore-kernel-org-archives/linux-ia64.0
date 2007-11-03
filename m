From: Roel Kluin <12o3l@tiscali.nl>
Date: Sat, 03 Nov 2007 23:36:50 +0000
Subject: [PATCH] iounmap after ioremap in error path: arch/ia64/pci/pci.c
Message-Id: <472D0612.30301@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do iounmap when too many IO port spaces were encountered

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 488e48a..13a05d7 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -154,6 +154,7 @@ new_space (u64 phys_base, int sparse)
 			return i;
 
 	if (num_io_spaces = MAX_IO_SPACES) {
+		iounmap(mmio_base);
 		printk(KERN_ERR "PCI: Too many IO port spaces "
 			"(MAX_IO_SPACES=%lu)\n", MAX_IO_SPACES);
 		return ~0;
