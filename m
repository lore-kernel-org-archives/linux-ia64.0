From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 04 Jun 2013 10:59:14 +0000
Subject: [PATCH -v3 8/8] PCI: Replace printks with appropriate pr_*()
Message-Id: <1370343554-11812-9-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Replace deprecated printk(KERN_ERR...) with pr_err() in arch/ia64/pci/pci.c

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/ia64/pci/pci.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index f2139b4..716423f 100644
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
@@ -181,7 +181,7 @@ static u64 add_io_space(struct pci_root_info *info,
 	len = strlen(info->name) + 32;
 	iospace = kzalloc(sizeof(*iospace) + len, GFP_KERNEL);
 	if (!iospace) {
-		printk(KERN_ERR "PCI: No memory for %s I/O port space\n",
+		pr_err("PCI: No memory for %s I/O port space\n",
 			info->name);
 		goto out;
 	}
@@ -444,7 +444,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
-		printk(KERN_WARNING "pci_bus %04x:%02x: "
+		pr_warn("pci_bus %04x:%02x: "
 				"ignored (out of memory)\n", domain, busnum);
 		kfree(controller);
 		return NULL;
@@ -779,7 +779,7 @@ static void __init set_pci_dfl_cacheline_size(void)
 
 	status = ia64_pal_cache_summary(&levels, &unique_caches);
 	if (status != 0) {
-		printk(KERN_ERR "%s: ia64_pal_cache_summary() failed "
+		pr_err("%s: ia64_pal_cache_summary() failed "
 			"(status=%ld)\n", __func__, status);
 		return;
 	}
@@ -787,7 +787,7 @@ static void __init set_pci_dfl_cacheline_size(void)
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


