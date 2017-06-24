From: Palmer Dabbelt <palmer@dabbelt.com>
Date: Sat, 24 Jun 2017 01:50:42 +0000
Subject: [PATCH 1/3] pci: Add a generic, weakly-linked pcibios_fixup_bus
Message-Id: <20170624015044.16746-2-palmer@dabbelt.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170624015044.16746-1-palmer@dabbelt.com>
In-Reply-To: <20170624015044.16746-1-palmer@dabbelt.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org

Multiple architectures define this as an empty function, and I'm adding
another one as part of the RISC-V port.  This adds a __weak version of
pci_fixup_bios and deletes the now obselete ones in a handful of ports.

The only functional change should be that microblaze used to export
pcibios_fixup_bus.  None of the other architectures export this, so I
just dropped it.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
---
 arch/arc/kernel/pcibios.c             |  4 ----
 arch/arm64/kernel/pci.c               |  8 --------
 arch/cris/arch-v32/drivers/pci/bios.c |  4 ----
 arch/microblaze/pci/pci-common.c      |  6 ------
 arch/s390/pci/pci.c                   |  4 ----
 arch/sh/drivers/pci/pci.c             |  8 --------
 arch/sparc/kernel/pci.c               |  4 ----
 arch/tile/kernel/pci.c                |  8 --------
 arch/tile/kernel/pci_gx.c             |  5 -----
 drivers/pci/probe.c                   | 10 ++++++++++
 10 files changed, 10 insertions(+), 51 deletions(-)

diff --git a/arch/arc/kernel/pcibios.c b/arch/arc/kernel/pcibios.c
index 72e1d73d0bd6..1c8df8fd5fed 100644
--- a/arch/arc/kernel/pcibios.c
+++ b/arch/arc/kernel/pcibios.c
@@ -16,7 +16,3 @@ resource_size_t pcibios_align_resource(void *data, const struct resource *res,
 {
 	return res->start;
 }
-
-void pcibios_fixup_bus(struct pci_bus *bus)
-{
-}
diff --git a/arch/arm64/kernel/pci.c b/arch/arm64/kernel/pci.c
index c7e3e6387a49..4c7f451aca05 100644
--- a/arch/arm64/kernel/pci.c
+++ b/arch/arm64/kernel/pci.c
@@ -23,14 +23,6 @@
 #include <linux/slab.h>
 
 /*
- * Called after each bus is probed, but before its children are examined
- */
-void pcibios_fixup_bus(struct pci_bus *bus)
-{
-	/* nothing to do, expected to be removed in the future */
-}
-
-/*
  * We don't have to worry about legacy ISA devices, so nothing to do here
  */
 resource_size_t pcibios_align_resource(void *data, const struct resource *res,
diff --git a/arch/cris/arch-v32/drivers/pci/bios.c b/arch/cris/arch-v32/drivers/pci/bios.c
index 394c2a73d5e2..5cc622c0225e 100644
--- a/arch/cris/arch-v32/drivers/pci/bios.c
+++ b/arch/cris/arch-v32/drivers/pci/bios.c
@@ -2,10 +2,6 @@
 #include <linux/kernel.h>
 #include <hwregs/intr_vect.h>
 
-void pcibios_fixup_bus(struct pci_bus *b)
-{
-}
-
 void pcibios_set_master(struct pci_dev *dev)
 {
 	u8 lat;
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index 404fb38d06b7..940f266e5d5c 100644
--- a/arch/microblaze/pci/pci-common.c
+++ b/arch/microblaze/pci/pci-common.c
@@ -810,12 +810,6 @@ void pcibios_setup_bus_devices(struct pci_bus *bus)
 	}
 }
 
-void pcibios_fixup_bus(struct pci_bus *bus)
-{
-	/* nothing to do */
-}
-EXPORT_SYMBOL(pcibios_fixup_bus);
-
 /*
  * We need to avoid collisions with `mirrored' VGA ports
  * and other strange ISA hardware, so we always want the
diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index 8051df109db3..98a54dd63483 100644
--- a/arch/s390/pci/pci.c
+++ b/arch/s390/pci/pci.c
@@ -234,10 +234,6 @@ static int zpci_cfg_store(struct zpci_dev *zdev, int offset, u32 val, u8 len)
 	return rc;
 }
 
-void pcibios_fixup_bus(struct pci_bus *bus)
-{
-}
-
 resource_size_t pcibios_align_resource(void *data, const struct resource *res,
 				       resource_size_t size,
 				       resource_size_t align)
diff --git a/arch/sh/drivers/pci/pci.c b/arch/sh/drivers/pci/pci.c
index c99ee286b69f..749642e1272e 100644
--- a/arch/sh/drivers/pci/pci.c
+++ b/arch/sh/drivers/pci/pci.c
@@ -155,14 +155,6 @@ static int __init pcibios_init(void)
 subsys_initcall(pcibios_init);
 
 /*
- *  Called after each bus is probed, but before its children
- *  are examined.
- */
-void pcibios_fixup_bus(struct pci_bus *bus)
-{
-}
-
-/*
  * We need to avoid collisions with `mirrored' VGA ports
  * and other strange ISA hardware, so we always want the
  * addresses to be allocated in the 0x000-0x0ff region
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 7eceaa10836f..78d3dc25e126 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -690,10 +690,6 @@ struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 	return bus;
 }
 
-void pcibios_fixup_bus(struct pci_bus *pbus)
-{
-}
-
 resource_size_t pcibios_align_resource(void *data, const struct resource *res,
 				resource_size_t size, resource_size_t align)
 {
diff --git a/arch/tile/kernel/pci.c b/arch/tile/kernel/pci.c
index bc6656b5708b..3113d4d5c329 100644
--- a/arch/tile/kernel/pci.c
+++ b/arch/tile/kernel/pci.c
@@ -369,14 +369,6 @@ int __init pcibios_init(void)
 }
 subsys_initcall(pcibios_init);
 
-/*
- * No bus fixups needed.
- */
-void pcibios_fixup_bus(struct pci_bus *bus)
-{
-	/* Nothing needs to be done. */
-}
-
 void pcibios_set_master(struct pci_dev *dev)
 {
 	/* No special bus mastering setup handling. */
diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
index b554a68eea1b..b89172b592cc 100644
--- a/arch/tile/kernel/pci_gx.c
+++ b/arch/tile/kernel/pci_gx.c
@@ -1038,11 +1038,6 @@ int __init pcibios_init(void)
 }
 subsys_initcall(pcibios_init);
 
-/* No bus fixups needed. */
-void pcibios_fixup_bus(struct pci_bus *bus)
-{
-}
-
 /* Process any "pci=" kernel boot arguments. */
 char *__init pcibios_setup(char *str)
 {
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 19c8950c6c38..1ff44dde7164 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2227,6 +2227,16 @@ void pcie_bus_configure_settings(struct pci_bus *bus)
 }
 EXPORT_SYMBOL_GPL(pcie_bus_configure_settings);
 
+/*
+ * Called after each bus is probed, but before its children are examined.  This
+ * is marked as __weak because multiple architectures define it
+ */
+__attribute__ ((weak))
+void pcibios_fixup_bus(struct pci_bus *bus)
+{
+       /* nothing to do, expected to be removed in the future */
+}
+
 unsigned int pci_scan_child_bus(struct pci_bus *bus)
 {
 	unsigned int devfn, pass, max = bus->busn_res.start;
-- 
2.13.0

