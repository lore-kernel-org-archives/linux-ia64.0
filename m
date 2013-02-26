From: Jiang Liu <liuj97@gmail.com>
Date: Tue, 26 Feb 2013 15:25:46 +0000
Subject: [PATCH v8 06/13] PCI, ACPI: prepare stub functions to handle ACPI PCI (hotplug) slots
Message-Id: <1361892353-14786-7-git-send-email-jiang.liu@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1361892353-14786-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1361892353-14786-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>, "Rafael J . Wysocki" <rjw@sisk.pl>
Cc: Jiang Liu <jiang.liu@huawei.com>, Yinghai Lu <yinghai@kernel.org>, Yijing Wang <wangyijing@huawei.com>, Jiang Liu <liuj97@gmail.com>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Toshi Kani <toshi.kani@hp.com>, Myron Stowe <myron.stowe@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-ia64@vger.kernel.org, x86@kernel.org

Prepare two stub functions to handle ACPI PCI slots and ACPI PCI hotplug
slots, which will be invoked by the PCI core when creating/destroying
PCI buses.

It will be used to get rid of ACPI PCI subdrivers for pci_slot and
acpiphp, and eventually remove the ACPI PCI subdriver mechanism.

And it will also be used to handle ACPI PCI (hotplug) slots in a unified
way, both at boot time and for PCI hotplug operations.

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
 drivers/pci/pci-acpi.c   |   24 ++++++++++++++++++++++++
 include/linux/pci-acpi.h |    8 +++++++-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/drivers/pci/pci-acpi.c b/drivers/pci/pci-acpi.c
index c685ff5..99878ac 100644
--- a/drivers/pci/pci-acpi.c
+++ b/drivers/pci/pci-acpi.c
@@ -287,6 +287,30 @@ static struct pci_platform_pm_ops acpi_pci_platform_pm = {
 	.run_wake = acpi_pci_run_wake,
 };
 
+void acpi_pci_add_bus(struct pci_bus *bus)
+{
+	acpi_handle handle = NULL;
+
+	if (bus->bridge)
+		handle = ACPI_HANDLE(bus->bridge);
+	if (acpi_pci_disabled || handle = NULL)
+		return;
+
+	/* TODO: add PCI slots and acpiphp hotplug slots */
+}
+
+void acpi_pci_remove_bus(struct pci_bus *bus)
+{
+	/*
+	 * bus->bridge->acpi_node.handle has already been reset to NULL
+	 * when acpi_pci_remove_bus() is called, so don't check ACPI handle.
+	 */
+	if (acpi_pci_disabled)
+		return;
+
+	/* TODO: remove PCI slots and acpiphp hotplug slots */
+}
+
 /* ACPI bus type */
 static int acpi_pci_find_device(struct device *dev, acpi_handle *handle)
 {
diff --git a/include/linux/pci-acpi.h b/include/linux/pci-acpi.h
index 9a22b5e..2b1743c 100644
--- a/include/linux/pci-acpi.h
+++ b/include/linux/pci-acpi.h
@@ -41,7 +41,13 @@ static inline acpi_handle acpi_pci_get_bridge_handle(struct pci_bus *pbus)
 
 	return DEVICE_ACPI_HANDLE(dev);
 }
-#endif
+
+void acpi_pci_add_bus(struct pci_bus *bus);
+void acpi_pci_remove_bus(struct pci_bus *bus);
+#else	/* CONFIG_ACPI */
+static inline void acpi_pci_add_bus(struct pci_bus *bus) { }
+static inline void acpi_pci_remove_bus(struct pci_bus *bus) { }
+#endif	/* CONFIG_ACPI */
 
 #ifdef CONFIG_ACPI_APEI
 extern bool aer_acpi_firmware_first(void);
-- 
1.7.9.5

