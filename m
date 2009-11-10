From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 10 Nov 2009 17:11:38 +0000
Subject: [PATCH v2 2/3] ACPI: pci_root: save downstream bus range
Message-Id: <20091110171138.10645.99610.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091110170802.10645.91272.stgit@bob.kio>
In-Reply-To: <20091110170802.10645.91272.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org

We need the entire downstream bus range, not just the base bus number, to
support _CBA.  See the PCI Firmware spec, rev 3.0, sec 4.1.3.  It's clear
that the bus range is supposed to be in _CRS, but if we don't find it there,
we'll assume [_BBN - 0xFF].

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
---
 drivers/acpi/pci_root.c |   19 +++++++++++++------
 include/acpi/acpi_bus.h |    1 +
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/acpi/pci_root.c b/drivers/acpi/pci_root.c
index aa9eeee..a3e6f0e 100644
--- a/drivers/acpi/pci_root.c
+++ b/drivers/acpi/pci_root.c
@@ -485,16 +485,22 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 
 	/* Check _CRS first, then _BBN.  If no _BBN, default to zero. */
 	secondary.start = 0;
+	secondary.end = 0xFF;
 	status = try_get_root_bridge_busnr(device->handle, &secondary);
-	if (ACPI_SUCCESS(status)) {
-		bus = secondary.start;
-	} else {
+	if (ACPI_FAILURE(status)) {
+		/*
+		 * We need both the start and end of the downstream bus range
+		 * to interpret _CBA (MMCONFIG base address), so it really is
+		 * supposed to be in _CRS.
+		 */
+		printk(KERN_WARNING FW_BUG PREFIX
+		       "no secondary bus range in _CRS\n");
 		status = acpi_evaluate_integer(device->handle, METHOD_NAME__BBN,					       NULL, &bus);
 		if (ACPI_FAILURE(status) && status != AE_NOT_FOUND) {
-			printk(KERN_ERR PREFIX
-			     "no bus number in _CRS and can't evaluate _BBN\n");
+			printk(KERN_ERR PREFIX "can't evaluate _BBN\n");
 			return -ENODEV;
 		}
+		secondary.start = bus;
 	}
 
 	root = kzalloc(sizeof(struct acpi_pci_root), GFP_KERNEL);
@@ -504,7 +510,8 @@ static int __devinit acpi_pci_root_add(struct acpi_device *device)
 	INIT_LIST_HEAD(&root->node);
 	root->device = device;
 	root->segment = segment & 0xFFFF;
-	root->bus_nr = bus & 0xFF;
+	root->bus_nr = secondary.start & 0xFF;
+	root->subordinate_bus_nr = secondary.end & 0xFF;
 	strcpy(acpi_device_name(device), ACPI_PCI_ROOT_DEVICE_NAME);
 	strcpy(acpi_device_class(device), ACPI_PCI_ROOT_CLASS);
 	device->driver_data = root;
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 3cd9ccd..3d6e6e8 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -371,6 +371,7 @@ struct acpi_pci_root {
 	struct pci_bus *bus;
 	u16 segment;
 	u8 bus_nr;
+	u8 subordinate_bus_nr;
 
 	u32 osc_support_set;	/* _OSC state of support bits */
 	u32 osc_control_set;	/* _OSC state of control bits */

