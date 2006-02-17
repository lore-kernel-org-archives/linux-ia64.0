From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 17 Feb 2006 13:29:48 +0000
Subject: [PATCH: 011/012] Memory hotplug for new nodes v.2 (Register start func for acpi_memhotplug)
Message-Id: <20060217214043.407E.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>


This is a patch to create start function which calls add_memory().
Container driver can call add_memory() by this. If this is not,
even if the node which is defined container device in DSDT is added,
the container driver can't call memory hotplug code.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


Index: pgdat3/drivers/acpi/acpi_memhotplug.c
=================================--- pgdat3.orig/drivers/acpi/acpi_memhotplug.c	2006-02-17 15:58:04.000000000 +0900
+++ pgdat3/drivers/acpi/acpi_memhotplug.c	2006-02-17 16:18:36.000000000 +0900
@@ -57,6 +57,7 @@ MODULE_LICENSE("GPL");
 
 static int acpi_memory_device_add(struct acpi_device *device);
 static int acpi_memory_device_remove(struct acpi_device *device, int type);
+static int acpi_memory_device_start (struct acpi_device *device);
 
 static struct acpi_driver acpi_memory_device_driver = {
 	.name = ACPI_MEMORY_DEVICE_DRIVER_NAME,
@@ -65,6 +66,7 @@ static struct acpi_driver acpi_memory_de
 	.ops = {
 		.add = acpi_memory_device_add,
 		.remove = acpi_memory_device_remove,
+		.start = acpi_memory_device_start,
 		},
 };
 
@@ -382,6 +384,26 @@ static int acpi_memory_device_remove(str
 	return_VALUE(0);
 }
 
+static int
+acpi_memory_device_start (struct acpi_device *device)
+{
+	struct acpi_memory_device *mem_device = NULL;
+	int result = 0;
+
+	ACPI_FUNCTION_TRACE("acpi_memory_device_start");
+
+	mem_device = (struct acpi_memory_device *) acpi_driver_data(device);
+
+	if (!acpi_memory_check_device(mem_device)){
+		/* call add_memory func */
+		result = acpi_memory_enable_device(mem_device);
+		if (result)
+			ACPI_DEBUG_PRINT((ACPI_DB_ERROR,
+			"Error in acpi_memory_enable_device\n"));
+	}
+	return_VALUE(result);
+}
+
 /*
  * Helper function to check for memory device
  */

-- 
Yasunori Goto 


