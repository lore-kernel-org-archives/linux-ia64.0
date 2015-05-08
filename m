From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 08 May 2015 07:22:56 +0000
Subject: [PATCH Part3 v11 6/9] PCI: Make pci_host_bridge hold sysdata in drvdata
Message-Id: <1431069779-29346-7-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1431069779-29346-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-arm-kernel@lists.infradead.org, Liviu Dudau <liviu@dudau.co.uk>, x86@kernel.org, linux-ia64@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-pci@vger.kernel.org, dja@axtens.net, Arnd Bergmann <arnd@arndb.de>, Yijing Wang <wangyijing@huawei.com>

Now platform specific sysdata is saved in pci_bus,
and pcibios_root_bridge_prepare() need to know
the sysdata. Later, we would move pcibios_root_bridge_prepare()
prior to root bus creation, so we need to make
pci_host_bridge hold sysdata.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 arch/ia64/pci/pci.c |    2 +-
 arch/x86/pci/acpi.c |    2 +-
 drivers/pci/probe.c |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 33803f7..c82d666 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -478,7 +478,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
 {
-	struct pci_controller *controller = bridge->bus->sysdata;
+	struct pci_controller *controller = dev_get_drvdata(&bridge->dev);
 
 	ACPI_COMPANION_SET(&bridge->dev, controller->companion);
 	return 0;
diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 7563855..948b675 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -462,7 +462,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 
 int pcibios_root_bridge_prepare(struct pci_host_bridge *bridge)
 {
-	struct pci_sysdata *sd = bridge->bus->sysdata;
+	struct pci_sysdata *sd = dev_get_drvdata(&bridge->dev);
 
 	ACPI_COMPANION_SET(&bridge->dev, sd->companion);
 	return 0;
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index f5f5de6..9ed8ab7 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -1931,6 +1931,7 @@ struct pci_bus *pci_create_root_bus(struct device *parent, int domain,
 	bridge->domain = domain;
 	bridge->dev.parent = parent;
 	bridge->dev.release = pci_release_host_bridge_dev;
+	dev_set_drvdata(&bridge->dev, sysdata);
 	dev_set_name(&bridge->dev, "pci%04x:%02x", pci_domain_nr(b), bus);
 	error = pcibios_root_bridge_prepare(bridge);
 	if (error) {
-- 
1.7.1

