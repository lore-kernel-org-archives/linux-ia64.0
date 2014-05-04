From: Yijing Wang <wangyijing@huawei.com>
Date: Sun, 04 May 2014 04:23:37 +0000
Subject: [PATCH v2 02/13] PCI: Introduce new pci_is_bridge() helper function
Message-Id: <1399177428-3784-3-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1399177428-3784-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1399177428-3784-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Yijing Wang <wangyijing@huawei.com>

PCIe Spec define the PCI bridge is the PCI device
which header type(bit 0 through 6) is 0x1(PCI bridge)
or 0x2(CardBus bridge).

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 include/linux/pci.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index aab57b4..9f5f89e 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -477,6 +477,19 @@ static inline bool pci_is_root_bus(struct pci_bus *pbus)
 	return !(pbus->parent);
 }
 
+/**
+ * pci_is_bridge - check if the PCI device is a bridge
+ * @dev: PCI device
+ *
+ * Return true if the PCI device is bridge whether it has subordinate
+ * or not.
+ */
+static inline bool pci_is_bridge(struct pci_dev *dev)
+{
+	return dev->hdr_type = PCI_HEADER_TYPE_BRIDGE ||
+		dev->hdr_type = PCI_HEADER_TYPE_CARDBUS;
+}
+
 static inline struct pci_dev *pci_upstream_bridge(struct pci_dev *dev)
 {
 	dev = pci_physfn(dev);
-- 
1.7.1


