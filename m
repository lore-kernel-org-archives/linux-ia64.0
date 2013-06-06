From: Yijing Wang <wangyijing@huawei.com>
Date: Thu, 06 Jun 2013 07:34:53 +0000
Subject: [PATCH -v5 8/8] PCI: Replace printks with appropriate pr_*()
Message-Id: <1370504093-14908-9-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1370504093-14908-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1370504093-14908-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-pci@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Replace deprecated printk(KERN_ERR...) with pr_err() in arch/ia64/pci/pci.c

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/pci/pci.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 586cac1..2326790 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -157,7 +157,7 @@ new_space (u64 phys_base, int sparse)
 			return i;
 
 	if (num_io_spaces = MAX_IO_SPACES) {
-		printk(KERN_ERR "PCI: Too many IO port spaces "
+		pr_err("PCI: Too many IO port spaces "
 			"(MAX_IO_SPACES=%lu)\n", MAX_IO_SPACES);
 		return ~0;
 	}
@@ -181,8 +181,9 @@ static u64 add_io_space(struct pci_root_info *info,
 	len = strlen(info->name) + 32;
 	iospace = kzalloc(sizeof(*iospace) + len, GFP_KERNEL);
 	if (!iospace) {
-		printk(KERN_ERR "PCI: No memory for %s I/O port space\n",
-			info->name);
+		dev_err(&info->bridge->dev,
+				"PCI: No memory for %s I/O port space\n",
+				info->name);
 		goto out;
 	}
 
@@ -445,7 +446,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
-		printk(KERN_WARNING
+		dev_err(&device->dev,
 				"pci_bus %04x:%02x: ignored (out of memory)\n",
 				domain, busnum);
 		kfree(controller);
@@ -781,7 +782,7 @@ static void __init set_pci_dfl_cacheline_size(void)
 
 	status = ia64_pal_cache_summary(&levels, &unique_caches);
 	if (status != 0) {
-		printk(KERN_ERR "%s: ia64_pal_cache_summary() failed "
+		pr_err("%s: ia64_pal_cache_summary() failed "
 			"(status=%ld)\n", __func__, status);
 		return;
 	}
@@ -789,7 +790,7 @@ static void __init set_pci_dfl_cacheline_size(void)
 	status = ia64_pal_cache_config_info(levels - 1,
 				/* cache_type (data_or_unified)= */ 2, &cci);
 	if (status != 0) {
-		printk(KERN_ERR "%s: ia64_pal_cache_config_info() failed "
+		pr_err("%s: ia64_pal_cache_config_info() failed "
 			"(status=%ld)\n", __func__, status);
 		return;
 	}
-- 
1.7.1


