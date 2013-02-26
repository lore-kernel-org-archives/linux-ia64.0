From: Jiang Liu <liuj97@gmail.com>
Date: Tue, 26 Feb 2013 15:25:45 +0000
Subject: [PATCH v8 05/13] PCI: introduce platform dependent hooks for creating/destroying PCI busses
Message-Id: <1361892353-14786-6-git-send-email-jiang.liu@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1361892353-14786-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1361892353-14786-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, "Rafael J . Wysocki" <rjw@sisk.pl>
Cc: Jiang Liu <jiang.liu@huawei.com>, Yinghai Lu <yinghai@kernel.org>, Yijing Wang <wangyijing@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Myron Stowe <myron.stowe@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, x86@kernel.org

On ACPI based platforms, the pci_slot driver creates PCI slot devices
according to information from ACPI tables by registering an ACPI PCI
subdriver. The ACPI PCI subdriver will only be called when creating/
destroying PCI root buses, and it won't be called when hot-plugging
P2P bridges. It may cause stale PCI slot devices after hot-removing
a P2P bridge if that bridge has associated PCI slots. And the acpiphp
driver has the same issue too.

This patch introduces two hook points into the PCI core, which will
be invoked when creating/destroying PCI busses for PCI host and P2P
bridges. They could be used to setup/destroy platform dependent staffs
in a unified way, both at boot time and for PCI hotplug operations.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Myron Stowe <myron.stowe@redhat.com>
Cc: linux-pci@vger.kernel.org
Cc: linux-ia64@vger.kernel.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/pci/probe.c  |   12 ++++++++++++
 drivers/pci/remove.c |    1 +
 include/linux/pci.h  |    2 ++
 3 files changed, 15 insertions(+)

diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 45c93b3..43ece5d 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -673,6 +673,8 @@ add_dev:
 	ret = device_register(&child->dev);
 	WARN_ON(ret < 0);
 
+	pcibios_add_bus(child);
+
 	/* Create legacy_io and legacy_mem files for this bus */
 	pci_create_legacy_files(child);
 
@@ -1660,6 +1662,14 @@ int __weak pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
 	return 0;
 }
 
+void __weak pcibios_add_bus(struct pci_bus *bus)
+{
+}
+
+void __weak pcibios_remove_bus(struct pci_bus *bus)
+{
+}
+
 struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
 		struct pci_ops *ops, void *sysdata, struct list_head *resources)
 {
@@ -1714,6 +1724,8 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int bus,
 	if (error)
 		goto class_dev_reg_err;
 
+	pcibios_add_bus(b);
+
 	/* Create legacy_io and legacy_mem files for this bus */
 	pci_create_legacy_files(b);
 
diff --git a/drivers/pci/remove.c b/drivers/pci/remove.c
index 66967e5..6ae6480 100644
--- a/drivers/pci/remove.c
+++ b/drivers/pci/remove.c
@@ -49,6 +49,7 @@ void pci_remove_bus(struct pci_bus *bus)
 	pci_bus_release_busn_res(bus);
 	up_write(&pci_bus_sem);
 	pci_remove_legacy_files(bus);
+	pcibios_remove_bus(bus);
 	device_unregister(&bus->dev);
 }
 EXPORT_SYMBOL(pci_remove_bus);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 7e87b1e..00d6ba7 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -678,6 +678,8 @@ extern struct list_head pci_root_buses;	/* list of all known PCI buses */
 extern int no_pci_devices(void);
 
 void pcibios_resource_survey_bus(struct pci_bus *bus);
+void pcibios_add_bus(struct pci_bus *bus);
+void pcibios_remove_bus(struct pci_bus *bus);
 void pcibios_fixup_bus(struct pci_bus *);
 int __must_check pcibios_enable_device(struct pci_dev *, int mask);
 /* Architecture specific versions may override this (weak) */
-- 
1.7.9.5

