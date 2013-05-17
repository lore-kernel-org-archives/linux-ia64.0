From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 17 May 2013 09:55:49 +0000
Subject: [PATCH -v2 6/7] PCI/IA64: add host bridge resource release for _CRS path
Message-Id: <1368784550-18332-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1368784550-18332-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1368784550-18332-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Yinghai Lu <yinghai@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org

Set IA64 host bridge release function to make sure root bridge
related resources get freed during root bus removal.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/pci/pci.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 658030f..2857a83 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -358,6 +358,13 @@ static void __release_pci_root_info(struct pci_root_info *info)
 	kfree(info);
 }
 
+static void release_pci_root_info(struct pci_host_bridge *bridge)
+{
+	struct pci_root_info *info = bridge->release_data;
+
+	__release_pci_root_info(info);
+}
+
 struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 {
 	struct acpi_device *device = root->device;
@@ -433,7 +440,9 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 		__release_pci_root_info(info);
 		return NULL;
 	}
-
+
+	pci_set_host_bridge_release(to_pci_host_bridge(pbus->bridge),
+			release_pci_root_info, info);
 	pci_scan_child_bus(pbus);
 	return pbus;
 
-- 
1.7.1


