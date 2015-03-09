From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 09 Mar 2015 02:34:00 +0000
Subject: [PATCH v6 03/30] PCI: Export busn_resource to drivers/pci
Message-Id: <1425868467-9667-4-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425868467-9667-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-pci@vger.kernel.org, Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Export out busn_resource. Xen pcifront module need it.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/pci/pci.h   |    2 ++
 drivers/pci/probe.c |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 4091f82..eeacab9 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -10,6 +10,8 @@ bool pcie_cap_has_lnkctl(const struct pci_dev *dev);
 
 /* Functions internal to the PCI core code */
 
+extern struct resource busn_resource;
+
 int pci_create_sysfs_dev_files(struct pci_dev *pdev);
 void pci_remove_sysfs_dev_files(struct pci_dev *pdev);
 #if !defined(CONFIG_DMI) && !defined(CONFIG_ACPI)
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 8ef0375..b97ea81 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -17,12 +17,13 @@
 #define CARDBUS_LATENCY_TIMER	176	/* secondary latency timer */
 #define CARDBUS_RESERVE_BUSNR	3
 
-static struct resource busn_resource = {
+struct resource busn_resource = {
 	.name	= "PCI busn",
 	.start	= 0,
 	.end	= 255,
 	.flags	= IORESOURCE_BUS,
 };
+EXPORT_SYMBOL(busn_resource);
 
 /* Ugh.  Need to stop exporting this to modules. */
 LIST_HEAD(pci_root_buses);
-- 
1.7.1

