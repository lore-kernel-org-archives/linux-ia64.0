From: tianyu.lan@intel.com
Date: Fri, 11 Oct 2013 06:52:09 +0000
Subject: [PATCH 5/5] IA64/PCI/ACPI: Rework PCI root bridge ACPI resource conversion
Message-Id: <1381474332-11328-6-git-send-email-tianyu.lan@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1381474332-11328-1-git-send-email-tianyu.lan@intel.com>
In-Reply-To: <1381474332-11328-1-git-send-email-tianyu.lan@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, bhelgaas@google.com, lenb@kernel.org, rjw@sisk.pl, yinghai@kernel.org
Cc: Lan Tianyu <tianyu.lan@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Lan Tianyu <tianyu.lan@intel.com>

Using ACPI resource functions to convert ACPI resource to generic resource

Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
---
This patch just passes through compilation test due to no ia64 machine on hand.

 arch/ia64/pci/pci.c | 38 +++++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 17 deletions(-)

diff --git a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
index 2326790..14fa175 100644
--- a/arch/ia64/pci/pci.c
+++ b/arch/ia64/pci/pci.c
@@ -232,8 +232,9 @@ out:
 	return ~0;
 }
 
-static acpi_status resource_to_window(struct acpi_resource *resource,
-				      struct acpi_resource_address64 *addr)
+static acpi_status resource_to_window(struct acpi_resource *ares,
+				      struct acpi_resource_address64 *addr,
+				      struct resource *res)
 {
 	acpi_status status;
 
@@ -244,7 +245,7 @@ static acpi_status resource_to_window(struct acpi_resource *resource,
 	 *	- producers, i.e., the address space is routed downstream,
 	 *	  not consumed by the bridge itself
 	 */
-	status = acpi_resource_to_address64(resource, addr);
+	status = acpi_dev_resource_address_space_full(ares, addr, res);
 	if (ACPI_SUCCESS(status) &&
 	    (addr->resource_type = ACPI_MEMORY_RANGE ||
 	     addr->resource_type = ACPI_IO_RANGE) &&
@@ -255,51 +256,54 @@ static acpi_status resource_to_window(struct acpi_resource *resource,
 	return AE_ERROR;
 }
 
-static acpi_status count_window(struct acpi_resource *resource, void *data)
+static acpi_status count_window(struct acpi_resource *ares, void *data)
 {
 	unsigned int *windows = (unsigned int *) data;
 	struct acpi_resource_address64 addr;
+	struct resource res;
 	acpi_status status;
 
-	status = resource_to_window(resource, &addr);
+	status = resource_to_window(ares, &addr, &res);
 	if (ACPI_SUCCESS(status))
 		(*windows)++;
 
 	return AE_OK;
 }
 
-static acpi_status add_window(struct acpi_resource *res, void *data)
+static acpi_status add_window(struct acpi_resource *ares, void *data)
 {
 	struct pci_root_info *info = data;
-	struct resource *resource;
+	struct resource *resource = &info->res[info->res_num];
 	struct acpi_resource_address64 addr;
 	acpi_status status;
-	unsigned long flags, offset = 0;
+	unsigned long offset = 0;
 	struct resource *root;
 
 	/* Return AE_OK for non-window resources to keep scanning for more */
-	status = resource_to_window(res, &addr);
+	status = resource_to_window(ares, &addr, resource);
 	if (!ACPI_SUCCESS(status))
 		return AE_OK;
 
-	if (addr.resource_type = ACPI_MEMORY_RANGE) {
-		flags = IORESOURCE_MEM;
+	if (resource->flags & IORESOURCE_MEM) {
 		root = &iomem_resource;
 		offset = addr.translation_offset;
-	} else if (addr.resource_type = ACPI_IO_RANGE) {
-		flags = IORESOURCE_IO;
+	} else if (resource->flags & IORESOURCE_IO) {
 		root = &ioport_resource;
 		offset = add_io_space(info, &addr);
 		if (offset = ~0)
 			return AE_OK;
+
+		/*
+		 * io space address translation offset depends
+		 * on the return value of add_io_space(). So
+		 * Repopulate resource->start and end here.
+		 */
+		resource->start = addr.minimum + offset;
+		resource->end = resource->start + addr.address_length - 1;
 	} else
 		return AE_OK;
 
-	resource = &info->res[info->res_num];
 	resource->name = info->name;
-	resource->flags = flags;
-	resource->start = addr.minimum + offset;
-	resource->end = resource->start + addr.address_length - 1;
 	info->res_offset[info->res_num] = offset;
 
 	if (insert_resource(root, resource)) {
-- 
1.8.2.1

