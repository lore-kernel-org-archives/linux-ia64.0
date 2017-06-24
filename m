From: Palmer Dabbelt <palmer@dabbelt.com>
Date: Sat, 24 Jun 2017 01:50:43 +0000
Subject: [PATCH 2/3] pci: Add a generic, weakly-linked pcibios_align_resource
Message-Id: <20170624015044.16746-3-palmer@dabbelt.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170624015044.16746-1-palmer@dabbelt.com>
In-Reply-To: <20170624015044.16746-1-palmer@dabbelt.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-snps-arc@lists.infradead.org

Multiple architectures define this as trivial function, and I'm adding
another one as part of the RISC-V port.  This adds a __weak version of
pcibios_align_resource and deletes the now obselete ones in a handful of
ports.

The only functional change should be that a handful of ports used to
export pcibios_fixup_bus.  Only some architectures export this, so I
just dropped it.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
---
 arch/arc/kernel/pcibios.c        |  9 ---------
 arch/arm64/kernel/pci.c          |  9 ---------
 arch/ia64/pci/pci.c              |  7 -------
 arch/microblaze/pci/pci-common.c |  7 -------
 arch/sparc/kernel/leon_pci.c     |  6 ------
 arch/sparc/kernel/pci.c          |  6 ------
 arch/sparc/kernel/pcic.c         |  6 ------
 arch/tile/kernel/pci.c           | 10 ----------
 arch/tile/kernel/pci_gx.c        |  9 ---------
 drivers/pci/setup-res.c          | 12 ++++++++++++
 10 files changed, 12 insertions(+), 69 deletions(-)

diff --git a/arch/arc/kernel/pcibios.c b/arch/arc/kernel/pcibios.c
index 1c8df8fd5fed..05aba5a7b5d2 100644
--- a/arch/arc/kernel/pcibios.c
+++ b/arch/arc/kernel/pcibios.c
@@ -7,12 +7,3 @@
  */
 
 #include <linux/pci.h>
-
-/*
- * We don't have to worry about legacy ISA devices, so nothing to do here
- */
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-				resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
diff --git a/arch/arm64/kernel/pci.c b/arch/arm64/kernel/pci.c
index 4c7f451aca05..9753ca23cfa1 100644
--- a/arch/arm64/kernel/pci.c
+++ b/arch/arm64/kernel/pci.c
@@ -23,15 +23,6 @@
 #include <linux/slab.h>
 
 /*
- * We don't have to worry about legacy ISA devices, so nothing to do here
- */
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-				resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
-
-/*
  * Try to assign the IRQ number when probing a new device
  */
 int pcibios_alloc_irq(struct pci_dev *dev)
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 4068bde623dc..f5ec736100ee 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -411,13 +411,6 @@ pcibios_disable_device (struct pci_dev *dev)
 		acpi_pci_irq_disable(dev);
 }
 
-resource_size_t
-pcibios_align_resource (void *data, const struct resource *res,
-		        resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
-
 /**
  * ia64_pci_get_legacy_mem - generic legacy mem routine
  * @bus: bus to get legacy memory base address for
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index 940f266e5d5c..5835c09c6e26 100644
--- a/arch/microblaze/pci/pci-common.c
+++ b/arch/microblaze/pci/pci-common.c
@@ -823,13 +823,6 @@ void pcibios_setup_bus_devices(struct pci_bus *bus)
  * but we want to try to avoid allocating at 0x2900-0x2bff
  * which might have be mirrored at 0x0100-0x03ff..
  */
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-				resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
-EXPORT_SYMBOL(pcibios_align_resource);
-
 int pcibios_add_device(struct pci_dev *dev)
 {
 	dev->irq = of_irq_parse_and_map_pci(dev, 0, 0);
diff --git a/arch/sparc/kernel/leon_pci.c b/arch/sparc/kernel/leon_pci.c
index 4371f72ff025..0eafdf3d036d 100644
--- a/arch/sparc/kernel/leon_pci.c
+++ b/arch/sparc/kernel/leon_pci.c
@@ -94,9 +94,3 @@ void pcibios_fixup_bus(struct pci_bus *pbus)
 		}
 	}
 }
-
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-				resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 78d3dc25e126..3f8670c92951 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -690,12 +690,6 @@ struct pci_bus *pci_scan_one_pbm(struct pci_pbm_info *pbm,
 	return bus;
 }
 
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-				resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
-
 int pcibios_enable_device(struct pci_dev *dev, int mask)
 {
 	u16 cmd, oldcmd;
diff --git a/arch/sparc/kernel/pcic.c b/arch/sparc/kernel/pcic.c
index a38787b84322..e038e343f2c1 100644
--- a/arch/sparc/kernel/pcic.c
+++ b/arch/sparc/kernel/pcic.c
@@ -746,12 +746,6 @@ static void watchdog_reset() {
 }
 #endif
 
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-				resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
-
 int pcibios_enable_device(struct pci_dev *pdev, int mask)
 {
 	return 0;
diff --git a/arch/tile/kernel/pci.c b/arch/tile/kernel/pci.c
index 3113d4d5c329..8999a20ed9d1 100644
--- a/arch/tile/kernel/pci.c
+++ b/arch/tile/kernel/pci.c
@@ -67,16 +67,6 @@ static struct pci_ops tile_cfg_ops;
 
 
 /*
- * We don't need to worry about the alignment of resources.
- */
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-			    resource_size_t size, resource_size_t align)
-{
-	return res->start;
-}
-EXPORT_SYMBOL(pcibios_align_resource);
-
-/*
  * Open a FD to the hypervisor PCI device.
  *
  * controller_id is the controller number, config type is 0 or 1 for
diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
index b89172b592cc..0a7642184a9a 100644
--- a/arch/tile/kernel/pci_gx.c
+++ b/arch/tile/kernel/pci_gx.c
@@ -108,15 +108,6 @@ static struct pci_ops tile_cfg_ops;
 /* Mask of CPUs that should receive PCIe interrupts. */
 static struct cpumask intr_cpus_map;
 
-/* We don't need to worry about the alignment of resources. */
-resource_size_t pcibios_align_resource(void *data, const struct resource *res,
-				       resource_size_t size,
-				       resource_size_t align)
-{
-	return res->start;
-}
-EXPORT_SYMBOL(pcibios_align_resource);
-
 /*
  * Pick a CPU to receive and handle the PCIe interrupts, based on the IRQ #.
  * For now, we simply send interrupts to non-dataplane CPUs.
diff --git a/drivers/pci/setup-res.c b/drivers/pci/setup-res.c
index 85774b7a316a..597ed1f8b15c 100644
--- a/drivers/pci/setup-res.c
+++ b/drivers/pci/setup-res.c
@@ -234,6 +234,18 @@ static int pci_revert_fw_address(struct resource *res, struct pci_dev *dev,
 	return 0;
 }
 
+/*
+ * We don't have to worry about legacy ISA devices, so nothing to do here.
+ * This is marked as __weak because multiple architectures define it, it should
+ * eventually go away.
+ */
+__attribute__ ((weak))
+resource_size_t pcibios_align_resource(void *data, const struct resource *res,
+                                      resource_size_t size, resource_size_t align)
+{
+       return res->start;
+}
+
 static int __pci_assign_resource(struct pci_bus *bus, struct pci_dev *dev,
 		int resno, resource_size_t size, resource_size_t align)
 {
-- 
2.13.0

