From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Sep 2003 19:43:10 +0000
Subject: [AGPGART] Add HP AGP 8X bridge and fix ACPI claim
Message-Id: <marc-linux-ia64-106270494516699@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patch to the HP ZX1 GART driver
	- adds recognition of the "HWP0007" device (an AGP 8X bridge)
	- fixes the use of acpi_get_devices()

The problem with acpi_get_devices() is that it always returns AE_OK,
except when the callback (zx1_gart_probe()) returns a failure.  That
means agp_hp_init() cannot use the status from acpi_get_devices()
to distinguish between (1) an AGP bridge was found and successfully
initialized, and (2) no AGP bridge was found at all.

This applies against the current linux-2.5 BitKeeper tree.

Bjorn


=== drivers/char/agp/hp-agp.c 1.26 vs edited ==--- 1.26/drivers/char/agp/hp-agp.c	Wed Aug  6 13:33:56 2003
+++ edited/drivers/char/agp/hp-agp.c	Thu Sep  4 15:15:18 2003
@@ -42,6 +42,8 @@
 /* AGP bridge need not be PCI device, but DRM thinks it is. */
 static struct pci_dev fake_bridge_dev;
 
+static int hp_zx1_gart_found;
+
 static struct aper_size_info_fixed hp_zx1_sizes[]  {
 	{0, 0, 0},		/* filled in by hp_zx1_fetch_size() */
@@ -386,8 +388,6 @@
 	struct agp_bridge_data *bridge;
 	int error;
 
-	printk(KERN_INFO PFX "Detected HP ZX1 AGP chipset (ioc=%lx, lba=%lx)\n", ioc_hpa, lba_hpa);
-
 	error = hp_zx1_ioc_init(ioc_hpa, lba_hpa);
 	if (error)
 		return error;
@@ -416,7 +416,7 @@
 
 	status = hp_acpi_csr_space(obj, &lba_hpa, &length);
 	if (ACPI_FAILURE(status))
-		return 1;
+		return AE_OK;
 
 	/* Look for an enclosing IOC scope and find its CSR space */
 	handle = obj;
@@ -436,7 +436,7 @@
 				else {
 					printk(KERN_ERR PFX "Detected HP ZX1 "
 					       "AGP LBA but no IOC.\n");
-					return status;
+					return AE_OK;
 				}
 			}
 		}
@@ -446,22 +446,28 @@
 	} while (ACPI_SUCCESS(status));
 
 	if (hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa))
-		return 1;
-	return 0;
+		return AE_OK;
+
+	printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset (ioc=%lx, lba=%lx)\n",
+		(char *) context, sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
+
+	hp_zx1_gart_found = 1;
+	return AE_CTRL_TERMINATE;
 }
 
 static int __init
 agp_hp_init (void)
 {
-	acpi_status status;
 
-	status = acpi_get_devices("HWP0003", zx1_gart_probe, "HWP0003 AGP LBA", NULL);
-	if (!(ACPI_SUCCESS(status))) {
-		agp_bridge->type = NOT_SUPPORTED;
-		printk(KERN_INFO PFX "Failed to initialize zx1 AGP.\n");
-		return -ENODEV;
-	}
-	return 0;
+	acpi_get_devices("HWP0003", zx1_gart_probe, "HWP0003", NULL);
+	if (hp_zx1_gart_found)
+		return 0;
+
+	acpi_get_devices("HWP0007", zx1_gart_probe, "HWP0007", NULL);
+	if (hp_zx1_gart_found)
+		return 0;
+
+	return -ENODEV;
 }
 
 static void __exit

