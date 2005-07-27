From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 27 Jul 2005 22:05:38 +0000
Subject: [PATCH] ia64: remove IOSAPIC locality domain mapping from pci.c
Message-Id: <200507271605.38999.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Move acpi_map_iosapics() from pci.c to acpi.c, since it doesn't
have anything to do with PCI.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work/arch/ia64/kernel/acpi.c
=================================--- work.orig/arch/ia64/kernel/acpi.c	2005-07-25 15:54:59.000000000 -0600
+++ work/arch/ia64/kernel/acpi.c	2005-07-25 15:57:09.000000000 -0600
@@ -826,7 +826,7 @@
  
 
 #ifdef CONFIG_ACPI_NUMA
-acpi_status __devinit
+static acpi_status __devinit
 acpi_map_iosapic (acpi_handle handle, u32 depth, void *context, void **ret)
 {
 	struct acpi_buffer buffer = {ACPI_ALLOCATE_BUFFER, NULL};
@@ -878,7 +878,16 @@
 	map_iosapic_to_node(gsi_base, node);
 	return AE_OK;
 }
-#endif /* CONFIG_NUMA */
+
+static int __init
+acpi_map_iosapics (void)
+{
+	acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
+	return 0;
+}
+
+fs_initcall(acpi_map_iosapics);
+#endif /* CONFIG_ACPI_NUMA */
 
 int
 acpi_register_ioapic (acpi_handle handle, u64 phys_addr, u32 gsi_base)
Index: work/arch/ia64/pci/pci.c
=================================--- work.orig/arch/ia64/pci/pci.c	2005-07-25 15:56:43.000000000 -0600
+++ work/arch/ia64/pci/pci.c	2005-07-25 15:58:07.000000000 -0600
@@ -120,29 +120,6 @@
 	.write = pci_write,
 };
 
-#ifdef CONFIG_NUMA
-extern acpi_status acpi_map_iosapic(acpi_handle, u32, void *, void **);
-static void acpi_map_iosapics(void)
-{
-	acpi_get_devices(NULL, acpi_map_iosapic, NULL, NULL);
-}
-#else
-static void acpi_map_iosapics(void)
-{
-	return;
-}
-#endif /* CONFIG_NUMA */
-
-static int __init
-pci_acpi_init (void)
-{
-	acpi_map_iosapics();
-
-	return 0;
-}
-
-subsys_initcall(pci_acpi_init);
-
 /* Called by ACPI when it finds a new root bus.  */
 
 static struct pci_controller * __devinit
