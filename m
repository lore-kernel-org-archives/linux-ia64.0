From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 24 Apr 2003 22:25:50 +0000
Subject: [Linux-ia64] [PATCH] 3/4 multi-ioport space support for 2.5
Message-Id: <marc-linux-ia64-105590723705601@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

diff -u -ur linux-2.5.67-ia64-030416-io2/arch/ia64/pci/pci.c linux-2.5.67-ia64-030416-io3/arch/ia64/pci/pci.c
--- linux-2.5.67-ia64-030416-io2/arch/ia64/pci/pci.c	2003-04-24 12:36:53.000000000 -0600
+++ linux-2.5.67-ia64-030416-io3/arch/ia64/pci/pci.c	2003-04-24 14:47:27.000000000 -0600
@@ -191,6 +191,27 @@
 	return b;
 }
 
+static int
+alloc_resource (char *name, struct resource *root, unsigned long start, unsigned long end, unsigned long flags)
+{
+	struct resource *res;
+
+	res = kmalloc(sizeof(*res), GFP_KERNEL);
+	if (!res)
+		return -ENOMEM;
+
+	memset(res, 0, sizeof(*res));
+	res->name = name;
+	res->start = start;
+	res->end = end;
+	res->flags = flags;
+
+	if (request_resource(root, res))
+		return -EBUSY;
+
+	return 0;
+}
+
 static u64
 add_io_space (struct acpi_resource_address64 *addr)
 {
@@ -251,14 +272,17 @@
 	struct acpi_resource_address64 addr;
 	acpi_status status;
 	unsigned long flags, offset = 0;
+	struct resource *root;
 
 	status = acpi_resource_to_address64(res, &addr);
 	if (ACPI_SUCCESS(status)) {
 		if (addr.resource_type = ACPI_MEMORY_RANGE) {
 			flags = IORESOURCE_MEM;
+			root = &iomem_resource;
 			offset = addr.address_translation_offset;
 		} else if (addr.resource_type = ACPI_IO_RANGE) {
 			flags = IORESOURCE_IO;
+			root = &ioport_resource;
 			offset = add_io_space(&addr);
 			if (offset = ~0)
 				return AE_OK;
@@ -270,6 +294,12 @@
 		window->resource.start  = addr.min_address_range;
 		window->resource.end    = addr.max_address_range;
 		window->offset		= offset;
+
+		if (alloc_resource(info->name, root, addr.min_address_range + offset,
+			addr.max_address_range + offset, flags))
+			printk(KERN_ERR "alloc 0x%lx-0x%lx from %s for %s failed\n",
+				addr.min_address_range + offset, addr.max_address_range + offset,
+				root->name, info->name);
 	}
 
 	return AE_OK;


