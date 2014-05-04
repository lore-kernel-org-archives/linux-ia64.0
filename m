From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:41 +0000
Subject: [PATCH v2 06/13] powerpc/PCI: Use new pci_is_bridge() to simplify code
Message-Id: <1399177428-3784-7-git-send-email-wangyijing@huawei.com>
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
 arch/powerpc/kernel/pci-hotplug.c |    3 +--
 arch/powerpc/kernel/pci_of_scan.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/kernel/pci-hotplug.c b/arch/powerpc/kernel/pci-hotplug.c
index c1e17ae..5b78917 100644
--- a/arch/powerpc/kernel/pci-hotplug.c
+++ b/arch/powerpc/kernel/pci-hotplug.c
@@ -98,8 +98,7 @@ void pcibios_add_pci_devices(struct pci_bus * bus)
 		max = bus->busn_res.start;
 		for (pass = 0; pass < 2; pass++) {
 			list_for_each_entry(dev, &bus->devices, bus_list) {
-				if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
-				    dev->hdr_type = PCI_HEADER_TYPE_CARDBUS)
+				if (pci_is_bridge(dev))
 					max = pci_scan_bridge(bus, dev,
 							      max, pass);
 			}
diff --git a/arch/powerpc/kernel/pci_of_scan.c b/arch/powerpc/kernel/pci_of_scan.c
index 83c26d8..059e244 100644
--- a/arch/powerpc/kernel/pci_of_scan.c
+++ b/arch/powerpc/kernel/pci_of_scan.c
@@ -362,8 +362,7 @@ static void __of_scan_bus(struct device_node *node, struct pci_bus *bus,
 
 	/* Now scan child busses */
 	list_for_each_entry(dev, &bus->devices, bus_list) {
-		if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
-		    dev->hdr_type = PCI_HEADER_TYPE_CARDBUS) {
+		if (pci_is_bridge(dev)) {
 			of_scan_pci_bridge(dev);
 		}
 	}
-- 
1.7.1


