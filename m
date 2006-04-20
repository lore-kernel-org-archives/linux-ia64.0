From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Thu, 20 Apr 2006 09:49:48 +0000
Subject: [PATCH 2/2] eliminate compile time warnings
Message-Id: <87d5fc37b7.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch removes following compile time warnings:

(snip)
drivers/pci/pci-sysfs.c: In function `pci_read_legacy_io':
drivers/pci/pci-sysfs.c:257: warning: implicit declaration of function `ia64_pci_legacy_read'
drivers/pci/pci-sysfs.c: In function `pci_write_legacy_io':
drivers/pci/pci-sysfs.c:280: warning: implicit declaration of function `ia64_pci_legacy_write'
(snip)

It also fixes wrong definition of ia64_pci_legacy_write (type of `bus' is not
`pci_dev', but `pci_bus').

Signed-Off-By: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

---
 arch/ia64/pci/pci.c        |    3 +--
 include/asm-ia64/machvec.h |    2 ++
 2 files changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.17-rc2/arch/ia64/pci/pci.c
=================================--- linux-2.6.17-rc2.orig/arch/ia64/pci/pci.c	2006-03-20 14:53:29.000000000 +0900
+++ linux-2.6.17-rc2/arch/ia64/pci/pci.c	2006-04-20 12:24:02.000000000 +0900
@@ -31,7 +31,6 @@
 #include <asm/irq.h>
 #include <asm/hw_irq.h>
 
-
 /*
  * Low-level SAL-based PCI configuration access functions. Note that SAL
  * calls are already serialized (via sal_lock), so we don't need another
@@ -707,7 +706,7 @@ int ia64_pci_legacy_read(struct pci_bus 
  *
  * Simply writes @size bytes of @val to @port.
  */
-int ia64_pci_legacy_write(struct pci_dev *bus, u16 port, u32 val, u8 size)
+int ia64_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size)
 {
 	int ret = size;
 
Index: linux-2.6.17-rc2/include/asm-ia64/machvec.h
=================================--- linux-2.6.17-rc2.orig/include/asm-ia64/machvec.h	2006-04-20 08:44:11.000000000 +0900
+++ linux-2.6.17-rc2/include/asm-ia64/machvec.h	2006-04-20 12:24:02.000000000 +0900
@@ -347,9 +347,11 @@ extern ia64_mv_dma_supported		swiotlb_dm
 #endif
 #ifndef platform_pci_legacy_read
 # define platform_pci_legacy_read	ia64_pci_legacy_read
+extern int ia64_pci_legacy_read(struct pci_bus *bus, u16 port, u32 *val, u8 size);
 #endif
 #ifndef platform_pci_legacy_write
 # define platform_pci_legacy_write	ia64_pci_legacy_write
+extern int ia64_pci_legacy_write(struct pci_bus *bus, u16 port, u32 val, u8 size);
 #endif
 #ifndef platform_inb
 # define platform_inb		__ia64_inb
