From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 21 Dec 2005 22:21:36 +0000
Subject: [PATCH] incorrect return from ia64_pci_legacy_write()
Message-Id: <1135203696.4180.12.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

   Maybe there's time for one more push to Linus?  The function
ia64_pci_legacy_write() returns 0 for everything except errors.  This
return value gets sent back to the user from pci_write_legacy_io(),
making it look like every write fails.  The trivial patch below copies
the behavior of the SGI sn machvec and does what would be expected from
something implementing a write() function.  Please apply, Thanks,

	Alex

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

diff -r 513446906e2e arch/ia64/pci/pci.c
--- a/arch/ia64/pci/pci.c	Wed Dec 21 19:05:15 2005
+++ b/arch/ia64/pci/pci.c	Wed Dec 21 14:52:44 2005
@@ -700,7 +700,7 @@
  */
 int ia64_pci_legacy_write(struct pci_dev *bus, u16 port, u32 val, u8 size)
 {
-	int ret = 0;
+	int ret = size;
 
 	switch (size) {
 	case 1:




