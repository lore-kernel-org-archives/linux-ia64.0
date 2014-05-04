From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:38 +0000
Subject: [PATCH v2 03/13] PCI: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-4-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1399177428-3784-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1399177428-3784-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Yijing Wang <wangyijing@huawei.com>

Now we can use new pci_is_bridge() helper function
to simplify code.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci-acpi.c  |    8 +-------
 drivers/pci/probe.c     |    3 +--
 drivers/pci/setup-bus.c |    4 +---
 3 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/pci/pci-acpi.c b/drivers/pci/pci-acpi.c
index f49abef..ca4927b 100644
--- a/drivers/pci/pci-acpi.c
+++ b/drivers/pci/pci-acpi.c
@@ -309,13 +309,7 @@ static struct acpi_device *acpi_pci_find_companion(struct device *dev)
 	bool check_children;
 	u64 addr;
 
-	/*
-	 * pci_is_bridge() is not suitable here, because pci_dev->subordinate
-	 * is set only after acpi_pci_find_device() has been called for the
-	 * given device.
-	 */
-	check_children = pci_dev->hdr_type = PCI_HEADER_TYPE_BRIDGE
-			|| pci_dev->hdr_type = PCI_HEADER_TYPE_CARDBUS;
+	check_children = pci_is_bridge(pci_dev);
 	/* Please ref to ACPI spec for the syntax of _ADR */
 	addr = (PCI_SLOT(pci_dev->devfn) << 16) | PCI_FUNC(pci_dev->devfn);
 	return acpi_find_child_device(ACPI_COMPANION(dev->parent), addr,
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index ef09f5f..f831dd8 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1670,8 +1670,7 @@ unsigned int pci_scan_child_bus(struct pci_bus *bus)
 
 	for (pass=0; pass < 2; pass++)
 		list_for_each_entry(dev, &bus->devices, bus_list) {
-			if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
-			    dev->hdr_type = PCI_HEADER_TYPE_CARDBUS)
+			if (pci_is_bridge(dev))
 				max = pci_scan_bridge(bus, dev, max, pass);
 		}
 
diff --git a/drivers/pci/setup-bus.c b/drivers/pci/setup-bus.c
index 138bdd6..e399d00 100644
--- a/drivers/pci/setup-bus.c
+++ b/drivers/pci/setup-bus.c
@@ -1629,9 +1629,7 @@ void pci_assign_unassigned_bus_resources(struct pci_bus *bus)
 
 	down_read(&pci_bus_sem);
 	list_for_each_entry(dev, &bus->devices, bus_list)
-		if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
-		    dev->hdr_type = PCI_HEADER_TYPE_CARDBUS)
-			if (dev->subordinate)
+		if (pci_is_bridge(dev) && pci_has_subordinate(dev))
 				__pci_bus_size_bridges(dev->subordinate,
 							 &add_list);
 	up_read(&pci_bus_sem);
-- 
1.7.1


