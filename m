From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 11 Mar 2010 19:20:11 +0000
Subject: [PATCH v4 2/2] ACPI: pci_root: pass acpi_pci_root to arch-specific
Message-Id: <20100311192011.17859.33830.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100311191936.17859.3619.stgit@bob.kio>
In-Reply-To: <20100311191936.17859.3619.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


The acpi_pci_root structure contains all the individual items (acpi_device,
domain, bus number) we pass to pci_acpi_scan_root(), so just pass the
single acpi_pci_root pointer directly.

This will make it easier to add _CBA support later.  For _CBA, we need the
entire downstream bus range, not just the base bus number.  We have that in
the acpi_pci_root structure, so passing the pointer makes it available to
the arch-specific code.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Reviewed-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
---

 arch/ia64/pci/pci.c         |    5 ++++-
 arch/x86/pci/acpi.c         |    5 ++++-
 drivers/acpi/pci_root.c     |    2 +-
 include/acpi/acpi_drivers.h |    3 +--
 4 files changed, 10 insertions(+), 5 deletions(-)


diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 64aff52..aa2533a 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -335,8 +335,11 @@ pcibios_setup_root_windows(struct pci_bus *bus, struct pci_controller *ctrl)
 }
 
 struct pci_bus * __devinit
-pci_acpi_scan_root(struct acpi_device *device, int domain, int bus)
+pci_acpi_scan_root(struct acpi_pci_root *root)
 {
+	struct acpi_device *device = root->device;
+	int domain = root->segment;
+	int bus = root->secondary.start;
 	struct pci_controller *controller;
 	unsigned int windows = 0;
 	struct pci_bus *pbus;
diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 5f11ff6..0c36ad5 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -215,8 +215,11 @@ res_alloc_fail:
 	return;
 }
 
-struct pci_bus * __devinit pci_acpi_scan_root(struct acpi_device *device, int domain, int busnum)
+struct pci_bus * __devinit pci_acpi_scan_root(struct acpi_pci_root *root)
 {
+	struct acpi_device *device = root->device;
+	int domain = root->segment;
+	int busnum = root->secondary.start;
 	struct pci_bus *bus;
 	struct pci_sysdata *sd;
 	int node;
diff --git a/drivers/acpi/pci_root.c b/drivers/acpi/pci_root.c
index bf476fe..680450c 100644
--- a/drivers/acpi/pci_root.c
+++ b/drivers/acpi/pci_root.c
@@ -498,7 +498,7 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	 * PCI namespace does not get created until this call is made (and 
 	 * thus the root bridge's pci_dev does not exist).
 	 */
-	root->bus = pci_acpi_scan_root(device, segment, root->secondary.start);
+	root->bus = pci_acpi_scan_root(root);
 	if (!root->bus) {
 		printk(KERN_ERR PREFIX
 			    "Bus %04x:%02x not present in PCI namespace\n",
diff --git a/include/acpi/acpi_drivers.h b/include/acpi/acpi_drivers.h
index 3a4767c..16903b3 100644
--- a/include/acpi/acpi_drivers.h
+++ b/include/acpi/acpi_drivers.h
@@ -102,8 +102,7 @@ int acpi_pci_bind_root(struct acpi_device *device);
 
 /* Arch-defined function to add a bus to the system */
 
-struct pci_bus *pci_acpi_scan_root(struct acpi_device *device, int domain,
-				   int bus);
+struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root);
 void pci_acpi_crs_quirks(void);
 
 /* --------------------------------------------------------------------------

