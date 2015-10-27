From: Yinghai Lu <yinghai@kernel.org>
Date: Tue, 27 Oct 2015 20:55:51 +0000
Subject: [PATCH v8 59/61] PCI: Introduce resource_disabled()
Message-Id: <1445979353-1728-60-git-send-email-yinghai@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1445979353-1728-1-git-send-email-yinghai@kernel.org>
In-Reply-To: <1445979353-1728-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, David Miller <davem@davemloft.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, TJ <linux@iam.tj>, Yijing Wang <wangyijing@huawei.com>, Khalid Aziz <khalid.aziz@oracle.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, iommu@lists.linux-foundation.org, linux-sh@vger.kernel.org

Current is using !flags, and we are going to use
IORESOURCE_DISABLED instead of clearing resource flags.

Let's convert all !flags to helper function resource_disabled().
resource_disabled will check !flags and IORESOURCE_DISABLED both.

Cc: linux-alpha@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: linux-am33-list@redhat.com
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: iommu@lists.linux-foundation.org
Cc: linux-sh@vger.kernel.org
Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Acked-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/alpha/kernel/pci.c                   |  2 +-
 arch/ia64/pci/pci.c                       |  4 ++--
 arch/microblaze/pci/pci-common.c          | 15 ++++++++-------
 arch/mn10300/unit-asb2305/pci-asb2305.c   |  4 ++--
 arch/mn10300/unit-asb2305/pci.c           |  4 ++--
 arch/powerpc/kernel/pci-common.c          | 16 +++++++++-------
 arch/powerpc/platforms/powernv/pci-ioda.c | 12 ++++++------
 arch/s390/pci/pci.c                       |  2 +-
 arch/sparc/kernel/pci.c                   |  2 +-
 arch/x86/pci/i386.c                       |  4 ++--
 arch/xtensa/kernel/pci.c                  |  4 ++--
 drivers/iommu/intel-iommu.c               |  3 ++-
 drivers/pci/host/pcie-rcar.c              |  2 +-
 drivers/pci/iov.c                         |  2 +-
 drivers/pci/probe.c                       |  2 +-
 drivers/pci/quirks.c                      |  4 ++--
 drivers/pci/rom.c                         |  2 +-
 drivers/pci/setup-bus.c                   |  8 ++++----
 drivers/pci/setup-res.c                   |  2 +-
 include/linux/ioport.h                    |  4 ++++
 20 files changed, 53 insertions(+), 45 deletions(-)

diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
index 5f387ee..c89c8ef 100644
--- a/arch/alpha/kernel/pci.c
+++ b/arch/alpha/kernel/pci.c
@@ -282,7 +282,7 @@ pcibios_claim_one_bus(struct pci_bus *b)
 		for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 			struct resource *r = &dev->resource[i];
 
-			if (r->parent || !r->start || !r->flags)
+			if (r->parent || !r->start || resource_disabled(r))
 				continue;
 			if (pci_has_flag(PCI_PROBE_ONLY) ||
 			    (r->flags & IORESOURCE_PCI_FIXED)) {
diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 7cc3be9..cc293ea 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -501,7 +501,7 @@ void pcibios_fixup_device_resources(struct pci_dev *dev)
 	for (idx = 0; idx < PCI_BRIDGE_RESOURCES; idx++) {
 		struct resource *r = &dev->resource[idx];
 
-		if (!r->flags || r->parent || !r->start)
+		if (resource_disabled(r) || r->parent || !r->start)
 			continue;
 
 		pci_claim_resource(dev, idx);
@@ -519,7 +519,7 @@ static void pcibios_fixup_bridge_resources(struct pci_dev *dev)
 	for (idx = PCI_BRIDGE_RESOURCES; idx < PCI_NUM_RESOURCES; idx++) {
 		struct resource *r = &dev->resource[idx];
 
-		if (!r->flags || r->parent || !r->start)
+		if (resource_disabled(r) || r->parent || !r->start)
 			continue;
 
 		pci_claim_bridge_resource(dev, idx);
diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
index 09b1af6..c123d3c 100644
--- a/arch/microblaze/pci/pci-common.c
+++ b/arch/microblaze/pci/pci-common.c
@@ -705,7 +705,7 @@ static void pcibios_fixup_resources(struct pci_dev *dev)
 	}
 	for (i = 0; i < DEVICE_COUNT_RESOURCE; i++) {
 		struct resource *res = dev->resource + i;
-		if (!res->flags)
+		if (resource_disabled(res))
 			continue;
 		if (res->start = 0) {
 			pr_debug("PCI:%s Resource %d %016llx-%016llx [%x]",
@@ -806,7 +806,7 @@ static void pcibios_fixup_bridge(struct pci_bus *bus)
 	pci_bus_for_each_resource(bus, res, i) {
 		if (!res)
 			continue;
-		if (!res->flags)
+		if (resource_disabled(res))
 			continue;
 		if (i >= 3 && bus->self->transparent)
 			continue;
@@ -985,7 +985,7 @@ static void pcibios_allocate_bus_resources(struct pci_bus *bus)
 		 pci_domain_nr(bus), bus->number);
 
 	pci_bus_for_each_resource(bus, res, i) {
-		if (!res || !res->flags
+		if (!res || resource_disabled(res)
 		    || res->start > res->end || res->parent)
 			continue;
 		if (bus->parent = NULL)
@@ -1087,7 +1087,8 @@ static void __init pcibios_allocate_resources(int pass)
 			r = &dev->resource[idx];
 			if (r->parent)		/* Already allocated */
 				continue;
-			if (!r->flags || (r->flags & IORESOURCE_UNSET))
+			if (resource_disabled(r) ||
+			    (r->flags & IORESOURCE_UNSET))
 				continue;	/* Not assigned at all */
 			/* We only allocate ROMs on pass 1 just in case they
 			 * have been screwed up by firmware
@@ -1218,7 +1219,7 @@ void pcibios_claim_one_bus(struct pci_bus *bus)
 		for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 			struct resource *r = &dev->resource[i];
 
-			if (r->parent || !r->start || !r->flags)
+			if (r->parent || !r->start || resource_disabled(r))
 				continue;
 
 			pr_debug("PCI: Claiming %s: ", pci_name(dev));
@@ -1278,7 +1279,7 @@ static void pcibios_setup_phb_resources(struct pci_controller *hose,
 	res->start = (res->start + io_offset) & 0xffffffffu;
 	res->end = (res->end + io_offset) & 0xffffffffu;
 
-	if (!res->flags) {
+	if (resource_disabled(res)) {
 		pr_warn("PCI: I/O resource not set for host ");
 		pr_cont("bridge %s (domain %d)\n",
 			hose->dn->full_name, hose->global_number);
@@ -1298,7 +1299,7 @@ static void pcibios_setup_phb_resources(struct pci_controller *hose,
 	/* Hookup PHB Memory resources */
 	for (i = 0; i < 3; ++i) {
 		res = &hose->mem_resources[i];
-		if (!res->flags) {
+		if (resource_disabled(res)) {
 			if (i > 0)
 				continue;
 			pr_err("PCI: Memory resource 0 not set for ");
diff --git a/arch/mn10300/unit-asb2305/pci-asb2305.c b/arch/mn10300/unit-asb2305/pci-asb2305.c
index b7ab837..7e70e51 100644
--- a/arch/mn10300/unit-asb2305/pci-asb2305.c
+++ b/arch/mn10300/unit-asb2305/pci-asb2305.c
@@ -103,7 +103,7 @@ static void __init pcibios_allocate_bus_resources(struct list_head *bus_list)
 			     idx < PCI_NUM_RESOURCES;
 			     idx++) {
 				r = &dev->resource[idx];
-				if (!r->flags)
+				if (resource_disabled(r))
 					continue;
 				if (!r->start ||
 				    pci_claim_bridge_resource(dev, idx) < 0) {
@@ -188,7 +188,7 @@ static int __init pcibios_assign_resources(void)
 	   addresses. */
 	for_each_pci_dev(dev) {
 		r = &dev->resource[PCI_ROM_RESOURCE];
-		if (!r->flags || !r->start)
+		if (resource_disabled(r) || !r->start)
 			continue;
 		if (pci_claim_resource(dev, PCI_ROM_RESOURCE) < 0) {
 			r->end -= r->start;
diff --git a/arch/mn10300/unit-asb2305/pci.c b/arch/mn10300/unit-asb2305/pci.c
index 3dfe2d3..ad77b18 100644
--- a/arch/mn10300/unit-asb2305/pci.c
+++ b/arch/mn10300/unit-asb2305/pci.c
@@ -291,7 +291,7 @@ static void pcibios_fixup_device_resources(struct pci_dev *dev)
 	for (idx = 0; idx < PCI_BRIDGE_RESOURCES; idx++) {
 		struct resource *r = &dev->resource[idx];
 
-		if (!r->flags || r->parent || !r->start)
+		if (resource_disabled(r) || r->parent || !r->start)
 			continue;
 
 		pci_claim_resource(dev, idx);
@@ -308,7 +308,7 @@ static void pcibios_fixup_bridge_resources(struct pci_dev *dev)
 	for (idx = PCI_BRIDGE_RESOURCES; idx < PCI_NUM_RESOURCES; idx++) {
 		struct resource *r = &dev->resource[idx];
 
-		if (!r->flags || r->parent || !r->start)
+		if (resource_disabled(r) || r->parent || !r->start)
 			continue;
 
 		pci_claim_bridge_resource(dev, idx);
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 8853667..a830e0c 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -810,7 +810,7 @@ static void pcibios_fixup_resources(struct pci_dev *dev)
 	for (i = 0; i < DEVICE_COUNT_RESOURCE; i++) {
 		struct resource *res = dev->resource + i;
 		struct pci_bus_region reg;
-		if (!res->flags)
+		if (resource_disabled(res))
 			continue;
 
 		/* If we're going to re-assign everything, we mark all resources
@@ -919,7 +919,7 @@ static void pcibios_fixup_bridge(struct pci_bus *bus)
 	struct pci_dev *dev = bus->self;
 
 	pci_bus_for_each_resource(bus, res, i) {
-		if (!res || !res->flags)
+		if (!res || resource_disabled(res))
 			continue;
 		if (i >= 3 && bus->self->transparent)
 			continue;
@@ -1160,7 +1160,8 @@ static void pcibios_allocate_bus_resources(struct pci_bus *bus)
 		 pci_domain_nr(bus), bus->number);
 
 	pci_bus_for_each_resource(bus, res, i) {
-		if (!res || !res->flags || res->start > res->end || res->parent)
+		if (!res || resource_disabled(res) ||
+		    res->start > res->end || res->parent)
 			continue;
 
 		/* If the resource was left unset at this point, we clear it */
@@ -1255,7 +1256,8 @@ static void __init pcibios_allocate_resources(int pass)
 			r = &dev->resource[idx];
 			if (r->parent)		/* Already allocated */
 				continue;
-			if (!r->flags || (r->flags & IORESOURCE_UNSET))
+			if (resource_disabled(r) ||
+			    (r->flags & IORESOURCE_UNSET))
 				continue;	/* Not assigned at all */
 			/* We only allocate ROMs on pass 1 just in case they
 			 * have been screwed up by firmware
@@ -1393,7 +1395,7 @@ void pcibios_claim_one_bus(struct pci_bus *bus)
 		for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 			struct resource *r = &dev->resource[i];
 
-			if (r->parent || !r->start || !r->flags)
+			if (r->parent || !r->start || resource_disabled(r))
 				continue;
 
 			pr_debug("PCI: Claiming %s: Resource %d: %pR\n",
@@ -1474,7 +1476,7 @@ static void pcibios_setup_phb_resources(struct pci_controller *hose,
 	/* Hookup PHB IO resource */
 	res = &hose->io_resource;
 
-	if (!res->flags) {
+	if (resource_disabled(res)) {
 		pr_info("PCI: I/O resource not set for host"
 		       " bridge %s (domain %d)\n",
 		       hose->dn->full_name, hose->global_number);
@@ -1489,7 +1491,7 @@ static void pcibios_setup_phb_resources(struct pci_controller *hose,
 	/* Hookup PHB Memory resources */
 	for (i = 0; i < 3; ++i) {
 		res = &hose->mem_resources[i];
-		if (!res->flags) {
+		if (resource_disabled(res)) {
 			if (i = 0)
 				printk(KERN_ERR "PCI: Memory resource 0 not set for "
 				       "host bridge %s (domain %d)\n",
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index 414fd1a..81484c1 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -874,7 +874,7 @@ static int pnv_pci_vf_resource_shift(struct pci_dev *dev, int offset)
 	num_vfs = pdn->num_vfs;
 	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
 		res = &dev->resource[i + PCI_IOV_RESOURCES];
-		if (!res->flags || !res->parent)
+		if (resource_disabled(res) || !res->parent)
 			continue;
 
 		if (!pnv_pci_is_mem_pref_64(res->flags))
@@ -905,7 +905,7 @@ static int pnv_pci_vf_resource_shift(struct pci_dev *dev, int offset)
 	 */
 	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
 		res = &dev->resource[i + PCI_IOV_RESOURCES];
-		if (!res->flags || !res->parent)
+		if (resource_disabled(res) || !res->parent)
 			continue;
 
 		if (!pnv_pci_is_mem_pref_64(res->flags))
@@ -1188,7 +1188,7 @@ static int pnv_pci_vf_assign_m64(struct pci_dev *pdev, u16 num_vfs)
 
 	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
 		res = &pdev->resource[i + PCI_IOV_RESOURCES];
-		if (!res->flags || !res->parent)
+		if (resource_disabled(res) || !res->parent)
 			continue;
 
 		if (!pnv_pci_is_mem_pref_64(res->flags))
@@ -2757,7 +2757,7 @@ static void pnv_pci_ioda_fixup_iov_resources(struct pci_dev *pdev)
 
 	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
 		res = &pdev->resource[i + PCI_IOV_RESOURCES];
-		if (!res->flags || res->parent)
+		if (resource_disabled(res) || res->parent)
 			continue;
 		if (!pnv_pci_is_mem_pref_64(res->flags)) {
 			dev_warn(&pdev->dev, " non M64 VF BAR%d: %pR\n",
@@ -2779,7 +2779,7 @@ static void pnv_pci_ioda_fixup_iov_resources(struct pci_dev *pdev)
 
 	for (i = 0; i < PCI_SRIOV_NUM_BARS; i++) {
 		res = &pdev->resource[i + PCI_IOV_RESOURCES];
-		if (!res->flags || res->parent)
+		if (resource_disabled(res) || res->parent)
 			continue;
 		if (!pnv_pci_is_mem_pref_64(res->flags)) {
 			dev_warn(&pdev->dev, "Skipping expanding VF BAR%d: %pR\n",
@@ -2820,7 +2820,7 @@ static void pnv_ioda_setup_pe_seg(struct pci_controller *hose,
 	BUG_ON(!(pe->flags & (PNV_IODA_PE_BUS | PNV_IODA_PE_BUS_ALL)));
 
 	pci_bus_for_each_resource(pe->pbus, res, i) {
-		if (!res || !res->flags ||
+		if (!res || resource_disabled(res) ||
 		    res->start > res->end)
 			continue;
 
diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index 7ef12a3..72c4676 100644
--- a/arch/s390/pci/pci.c
+++ b/arch/s390/pci/pci.c
@@ -653,7 +653,7 @@ int pcibios_add_device(struct pci_dev *pdev)
 
 	for (i = 0; i < PCI_BAR_COUNT; i++) {
 		res = &pdev->resource[i];
-		if (res->parent || !res->flags)
+		if (res->parent || resource_disabled(res))
 			continue;
 		pci_claim_resource(pdev, i);
 	}
diff --git a/arch/sparc/kernel/pci.c b/arch/sparc/kernel/pci.c
index 36a0dfb..afc4720 100644
--- a/arch/sparc/kernel/pci.c
+++ b/arch/sparc/kernel/pci.c
@@ -631,7 +631,7 @@ static void pci_claim_bus_resources(struct pci_bus *bus)
 		for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 			struct resource *r = &dev->resource[i];
 
-			if (r->parent || !r->start || !r->flags)
+			if (r->parent || !r->start || resource_disabled(r))
 				continue;
 
 			if (ofpci_verbose)
diff --git a/arch/x86/pci/i386.c b/arch/x86/pci/i386.c
index 6f27780..48c367c 100644
--- a/arch/x86/pci/i386.c
+++ b/arch/x86/pci/i386.c
@@ -224,7 +224,7 @@ static void pcibios_allocate_bridge_resources(struct pci_dev *dev)
 
 	for (idx = PCI_BRIDGE_RESOURCES; idx < PCI_NUM_RESOURCES; idx++) {
 		r = &dev->resource[idx];
-		if (!r->flags)
+		if (resource_disabled(r))
 			continue;
 		if (r->parent)	/* Already allocated */
 			continue;
@@ -353,7 +353,7 @@ static void pcibios_allocate_dev_rom_resource(struct pci_dev *dev)
 	 * addresses.
 	 */
 	r = &dev->resource[PCI_ROM_RESOURCE];
-	if (!r->flags || !r->start)
+	if (resource_disabled(r) || !r->start)
 		return;
 	if (r->parent) /* Already allocated */
 		return;
diff --git a/arch/xtensa/kernel/pci.c b/arch/xtensa/kernel/pci.c
index b848cc3..f34d061 100644
--- a/arch/xtensa/kernel/pci.c
+++ b/arch/xtensa/kernel/pci.c
@@ -142,7 +142,7 @@ static void __init pci_controller_apertures(struct pci_controller *pci_ctrl,
 
 	io_offset = (unsigned long)pci_ctrl->io_space.base;
 	res = &pci_ctrl->io_resource;
-	if (!res->flags) {
+	if (resource_disabled(res)) {
 		if (io_offset)
 			printk (KERN_ERR "I/O resource not set for host"
 				" bridge %d\n", pci_ctrl->index);
@@ -156,7 +156,7 @@ static void __init pci_controller_apertures(struct pci_controller *pci_ctrl,
 
 	for (i = 0; i < 3; i++) {
 		res = &pci_ctrl->mem_resources[i];
-		if (!res->flags) {
+		if (resource_disabled(res)) {
 			if (i > 0)
 				continue;
 			printk(KERN_ERR "Memory resource not set for "
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 041bc18..d4a06d2 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -1771,7 +1771,8 @@ static int dmar_init_reserved_ranges(void)
 
 		for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 			r = &pdev->resource[i];
-			if (!r->flags || !(r->flags & IORESOURCE_MEM))
+			if (resource_disabled(r) ||
+			    !(r->flags & IORESOURCE_MEM))
 				continue;
 			iova = reserve_iova(&reserved_iova_list,
 					    IOVA_PFN(r->start),
diff --git a/drivers/pci/host/pcie-rcar.c b/drivers/pci/host/pcie-rcar.c
index 7678fe0..3f307a3 100644
--- a/drivers/pci/host/pcie-rcar.c
+++ b/drivers/pci/host/pcie-rcar.c
@@ -365,7 +365,7 @@ static int rcar_pcie_setup(int nr, struct pci_sys_data *sys)
 	for (i = 0; i < RCAR_PCI_MAX_RESOURCES; i++) {
 
 		res = &pcie->res[i];
-		if (!res->flags)
+		if (resource_disabled(res))
 			continue;
 
 		rcar_pcie_setup_window(i, pcie);
diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
index ee0ebff..808d08b 100644
--- a/drivers/pci/iov.c
+++ b/drivers/pci/iov.c
@@ -438,7 +438,7 @@ found:
 		res = &dev->resource[i + PCI_IOV_RESOURCES];
 		bar64 = __pci_read_base(dev, pci_bar_unknown, res,
 					pos + PCI_SRIOV_BAR + i * 4);
-		if (!res->flags)
+		if (resource_disabled(res))
 			continue;
 		if (resource_size(res) & (PAGE_SIZE - 1)) {
 			rc = -EIO;
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index edc8d08..f9589d9 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -2203,7 +2203,7 @@ void pci_bus_release_busn_res(struct pci_bus *b)
 	struct resource *res = &b->busn_res;
 	int ret;
 
-	if (!res->flags || !res->parent)
+	if (resource_disabled(res) || !res->parent)
 		return;
 
 	ret = release_resource(res);
diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index be0bdfb..c51c0e6 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -336,7 +336,7 @@ static void quirk_bar_fixed(struct pci_dev *dev)
 	for (i = 0; i < PCI_STD_RESOURCE_END; i++) {
 		struct resource *r = &dev->resource[i];
 
-		if (!r->start || !r->flags)
+		if (!r->start || resource_disabled(r))
 			continue;
 		r->flags |= IORESOURCE_PCI_FIXED;
 	}
@@ -350,7 +350,7 @@ static void quirk_allocate_fixed(struct pci_dev *dev)
 	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 		struct resource *r = &dev->resource[i];
 
-		if (r->parent ||
+		if (r->parent || resource_disabled(r) ||
 		    !(r->flags & IORESOURCE_PCI_FIXED) ||
 		    !(r->flags & (IORESOURCE_IO | IORESOURCE_MEM)))
 			continue;
diff --git a/drivers/pci/rom.c b/drivers/pci/rom.c
index eb0ad53..585a9d3 100644
--- a/drivers/pci/rom.c
+++ b/drivers/pci/rom.c
@@ -28,7 +28,7 @@ int pci_enable_rom(struct pci_dev *pdev)
 	struct pci_bus_region region;
 	u32 rom_addr;
 
-	if (!res->flags)
+	if (resource_disabled(res))
 		return -1;
 
 	pcibios_resource_to_bus(pdev->bus, &region, res);
diff --git a/drivers/pci/setup-bus.c b/drivers/pci/setup-bus.c
index 673778c..23318bd 100644
--- a/drivers/pci/setup-bus.c
+++ b/drivers/pci/setup-bus.c
@@ -223,7 +223,7 @@ static void pdev_assign_resources_prepare(struct pci_dev *dev,
 		if (r->flags & IORESOURCE_PCI_FIXED)
 			continue;
 
-		if (!(r->flags) || r->parent)
+		if (resource_disabled(r) || r->parent)
 			continue;
 
 		r_align = __pci_resource_alignment(dev, r, realloc_head);
@@ -319,7 +319,7 @@ static void reassign_resources_sorted(struct list_head *realloc_head,
 	list_for_each_entry_safe(add_res, tmp, realloc_head, list) {
 		res = add_res->res;
 		/* skip resource that has been reset */
-		if (!res->flags)
+		if (resource_disabled(res))
 			goto out;
 
 		/* skip this resource if not found in head list */
@@ -2124,7 +2124,7 @@ static void pci_bus_dump_res(struct pci_bus *bus)
 	int i;
 
 	pci_bus_for_each_resource(bus, res, i) {
-		if (!res || !res->end || !res->flags)
+		if (!res || !res->end || resource_disabled(res))
 			continue;
 
 		dev_printk(KERN_DEBUG, &bus->dev, "resource %d %pR\n", i, res);
@@ -2207,7 +2207,7 @@ static int iov_resources_unassigned(struct pci_dev *dev, void *data)
 		struct pci_bus_region region;
 
 		/* Not assigned or rejected by kernel? */
-		if (!r->flags)
+		if (resource_disabled(r))
 			continue;
 
 		pcibios_resource_to_bus(dev->bus, &region, r);
diff --git a/drivers/pci/setup-res.c b/drivers/pci/setup-res.c
index 26aedde..55caf7a 100644
--- a/drivers/pci/setup-res.c
+++ b/drivers/pci/setup-res.c
@@ -40,7 +40,7 @@ void pci_update_resource(struct pci_dev *dev, int resno)
 	 * Ignore resources for unimplemented BARs and unused resource slots
 	 * for 64 bit BARs.
 	 */
-	if (!res->flags)
+	if (resource_disabled(res))
 		return;
 
 	if (res->flags & IORESOURCE_UNSET)
diff --git a/include/linux/ioport.h b/include/linux/ioport.h
index 27dbb18..fb21179 100644
--- a/include/linux/ioport.h
+++ b/include/linux/ioport.h
@@ -179,6 +179,10 @@ static inline bool resource_contains(struct resource *r1, struct resource *r2)
 	return r1->start <= r2->start && r1->end >= r2->end;
 }
 
+static inline bool resource_disabled(struct resource *r)
+{
+	return !r->flags || (r->flags & IORESOURCE_DISABLED);
+}
 
 /* Convenience shorthand with allocation */
 #define request_region(start,n,name)		__request_region(&ioport_resource, (start), (n), (name), 0)
-- 
1.8.4.5

