From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 05 Jan 2004 17:46:34 +0000
Subject: [PATCH] Ignore zero-length _CRS descriptors
Message-Id: <200401051046.34916.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Skip zero-length resources in PCI root bridge _CRS

(add_window): Skip zero-length resources.  It seems to be common
	practice to leave extra descriptors in the _CRS and set
	the _LEN field of unused ones to zero.

=== arch/ia64/pci/pci.c 1.39 vs edited ==--- 1.39/arch/ia64/pci/pci.c	Tue Nov 25 06:23:17 2003
+++ edited/arch/ia64/pci/pci.c	Mon Jan  5 10:33:32 2004
@@ -223,6 +223,9 @@
 
 	status = acpi_resource_to_address64(res, &addr);
 	if (ACPI_SUCCESS(status)) {
+		if (!addr.address_length)
+			return AE_OK;
+
 		if (addr.resource_type = ACPI_MEMORY_RANGE) {
 			flags = IORESOURCE_MEM;
 			root = &iomem_resource;

