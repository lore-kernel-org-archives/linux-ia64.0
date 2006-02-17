From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 17 Feb 2006 13:29:56 +0000
Subject: [PATCH: 012/012] Memory hotplug for new nodes v.2 (allow -EEXIST of add_memory)
Message-Id: <20060217214125.4080.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

When acpi_memory_device_init() is called at boottime to
register struct memory acpi_memory_device. So, 
acpi_bus_add() are called via acpi_driver_attach().
But it also calls ops->start() function.
It is called even if the memory blocks are initialized at
early boottime. In this case add_memory() return -EEXIST, and
the memory blocks becomes INVALID state even if it is normal.

This is patch for it.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat3/drivers/acpi/acpi_memhotplug.c
=================================--- pgdat3.orig/drivers/acpi/acpi_memhotplug.c	2006-02-17 16:18:36.000000000 +0900
+++ pgdat3/drivers/acpi/acpi_memhotplug.c	2006-02-17 16:20:53.000000000 +0900
@@ -199,7 +199,16 @@ static int acpi_memory_enable_device(str
 	 * Note: Assume that this function returns zero on success
 	 */
 	result = add_memory(mem_device->start_addr, mem_device->length);
-	if (result) {
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
 		ACPI_ERROR((AE_INFO, "add_memory failed"));
 		mem_device->state = MEMORY_INVALID_STATE;
 		return result;

-- 
Yasunori Goto 


