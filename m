From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 10 Feb 2006 14:21:46 +0000
Subject: [RFC/PATCH: 010/010] Memory hotplug for new nodes with pgdat allocation.(allow -EEXIST of add_memory
Message-Id: <20060210224740.C548.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>

When acpi_memory_device_init() is called at boottime to
register struct memory acpi_memory_device. So, 
acpi_bus_add() are called via acpi_driver_attach().
But it also calls ops->start() function.
It is called even if the memory blocks are initialized at
early boottime. In this case add_memory() return -EEXIST, and
the memory blocks becomes INVALID state even if it is normal.

This is patch for it.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


Index: pgdat2/drivers/acpi/acpi_memhotplug.c
=================================--- pgdat2.orig/drivers/acpi/acpi_memhotplug.c	2006-02-10 15:35:34.000000000 +0900
+++ pgdat2/drivers/acpi/acpi_memhotplug.c	2006-02-10 15:35:36.000000000 +0900
@@ -201,8 +201,18 @@ static int acpi_memory_enable_device(str
 	 * Note: Assume that this function returns zero on success
 	 */
 	result = add_memory(mem_device->start_addr, mem_device->length);
-	if (result) {
-		ACPI_DEBUG_PRINT((ACPI_DB_ERROR, "\nadd_memory failed\n"));
+	switch(result) {
+	case 0:
+		break;
+	case -EEXIST:
+		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
+				  "\nmemory start=%lu size=%lu has already existed\n",
+				  mem_device->start_addr,
+				  mem_device->length));
+		return 0;
+	default:
+		ACPI_DEBUG_PRINT((ACPI_DB_ERROR,
+				  "\nadd_memory failed result=%d\n", result));
 		mem_device->state = MEMORY_INVALID_STATE;
 		return result;
 	}

-- 
Yasunori Goto 


