From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 06 Aug 2003 22:44:53 +0000
Subject: PATCH: remove unused PCI root bridge resource stuff
Message-Id: <marc-linux-ia64-106021000131789@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch against the current 2.4 tree removes a bunch of
ill-advised code I added to get _TRA information from PCI
root bridges.

This was the wrong approach because for one thing, it only
handled one MEM window and one IO window, and root bridges
may have several of each.

This patch can be applied for both 2.4 and 2.5.  ia64 was the
only user of this code, and we no longer need it.  The current
approach we use is to walk the _CRS in pcibios_scan_root(),
as shown here:

http://lia64.bkbits.net:8080/linux-ia64-2.4/anno/arch/ia64/kernel/pci.c@1.21?nav=index.html|src/.|src/arch|src/arch/ia64|src/arch/ia64/kernel

#### AUTHOR bjorn.helgaas@hp.com
#### COMMENT START
### Comments for ChangeSet
ACPI: Remove acpi_pci_get_translations() and support.  pcibios_scan_root()
	should walk the _CRS if necessary.
### Comments for include/acpi/acpi_drivers.h
(acpi_pci_get_translations): Removed.
### Comments for drivers/acpi/pci_root.c
(acpi_pci_get_translations)
(acpi_pci_root_bus_tra)
(acpi_pci_evaluate_crs): Removed.
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1066  -> 1.1067 
#	drivers/acpi/pci_root.c	1.5     -> 1.6    
#	include/acpi/acpi_drivers.h	1.5     -> 1.6    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/06	bjorn.helgaas@hp.com	1.1067
# ACPI: Remove acpi_pci_get_translations() and support.  pcibios_scan_root()
# 	should walk the _CRS if necessary.
# --------------------------------------------
#
diff -Nru a/drivers/acpi/pci_root.c b/drivers/acpi/pci_root.c
--- a/drivers/acpi/pci_root.c	Wed Aug  6 17:29:00 2003
+++ b/drivers/acpi/pci_root.c	Wed Aug  6 17:29:00 2003
@@ -61,8 +61,6 @@
 	acpi_handle		handle;
 	struct acpi_pci_id	id;
 	struct pci_bus		*bus;
-	u64			mem_tra;
-	u64			io_tra;
 };
 
 struct list_head		acpi_pci_roots;
@@ -114,97 +112,6 @@
 	}
 }
 
-void
-acpi_pci_get_translations (
-	struct acpi_pci_id	*id,
-	u64			*mem_tra,
-	u64			*io_tra)
-{
-	struct list_head	*node = NULL;
-	struct acpi_pci_root	*entry;
-
-	/* TBD: Locking */
-	list_for_each(node, &acpi_pci_roots) {
-		entry = list_entry(node, struct acpi_pci_root, node);
-		if ((id->segment = entry->id.segment)
-			&& (id->bus = entry->id.bus)) {
-			*mem_tra = entry->mem_tra;
-			*io_tra = entry->io_tra;
-			return;
-		}
-	}
-
-	*mem_tra = 0;
-	*io_tra = 0;
-}
-
-
-static u64
-acpi_pci_root_bus_tra (
-       struct acpi_resource	*resource,
-       int			type)
-{
-	struct acpi_resource_address16 *address16;
-	struct acpi_resource_address32 *address32;
-	struct acpi_resource_address64 *address64;
-
-	while (1) {
-		switch (resource->id) {
-		case ACPI_RSTYPE_END_TAG:
-			return 0;
-
-		case ACPI_RSTYPE_ADDRESS16:
-			address16 = (struct acpi_resource_address16 *) &resource->data;
-			if (type = address16->resource_type) {
-				return address16->address_translation_offset;
-			}
-			break;
-
-		case ACPI_RSTYPE_ADDRESS32:
-			address32 = (struct acpi_resource_address32 *) &resource->data;
-			if (type = address32->resource_type) {
-				return address32->address_translation_offset;
-			}
-			break;
-
-		case ACPI_RSTYPE_ADDRESS64:
-			address64 = (struct acpi_resource_address64 *) &resource->data;
-			if (type = address64->resource_type) {
-				return address64->address_translation_offset;
-			}
-			break;
-		}
-		resource = ACPI_PTR_ADD (struct acpi_resource,
-				resource, resource->length);
-	}
-
-	return 0;
-}
-
-
-static int
-acpi_pci_evaluate_crs (
-	struct acpi_pci_root	*root)
-{
-	acpi_status		status;
-	struct acpi_buffer	buffer = {ACPI_ALLOCATE_BUFFER, NULL};
-
-	ACPI_FUNCTION_TRACE("acpi_pci_evaluate_crs");
-
-	status = acpi_get_current_resources (root->handle, &buffer);
-	if (ACPI_FAILURE(status))
-		return_VALUE(-ENODEV);
-
-	root->io_tra = acpi_pci_root_bus_tra ((struct acpi_resource *)
-			buffer.pointer, ACPI_IO_RANGE);
-	root->mem_tra = acpi_pci_root_bus_tra ((struct acpi_resource *)
-			buffer.pointer, ACPI_MEMORY_RANGE);
-
-	acpi_os_free(buffer.pointer);
-	return_VALUE(0);
-}
-
-
 static int
 acpi_pci_root_add (
 	struct acpi_device	*device)
@@ -287,10 +194,8 @@
 	root->id.function = device->pnp.bus_address & 0xFFFF;
 
 	/*
-	 * Evaluate _CRS to get root bridge resources
 	 * TBD: Need PCI interface for enumeration/configuration of roots.
 	 */
- 	acpi_pci_evaluate_crs(root);
 
  	/* TBD: Locking */
  	list_add_tail(&root->node, &acpi_pci_roots);
diff -Nru a/include/acpi/acpi_drivers.h b/include/acpi/acpi_drivers.h
--- a/include/acpi/acpi_drivers.h	Wed Aug  6 17:29:00 2003
+++ b/include/acpi/acpi_drivers.h	Wed Aug  6 17:29:00 2003
@@ -162,7 +162,6 @@
 
 int acpi_pci_root_init (void);
 void acpi_pci_root_exit (void);
-void acpi_pci_get_translations (struct acpi_pci_id* id, u64* mem_tra, u64* io_tra);
 
 /* ACPI PCI Interrupt Link (pci_link.c) */
 

