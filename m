From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 13 Sep 2004 18:27:48 +0000
Subject: [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <1095100068.20631.30.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, acpi-devel <acpi-devel@lists.sourceforge.net>


   A recent change to ACPI made the _OS object falsely report the OS as
"Microsoft Windows NT".  This seems like a slippery slope, and I'd
rather not go down it for ia64.  I think all of the ia64 OEMs are
involved enough with Linux that this isn't necessary and the change
limits the options should ACPI firmware need to make an OS specific work
around.  The patch below will make all ia64 boxes report a default _OS
of "Linux".  Thanks,

	Alex

-- 
Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/kernel/acpi.c 1.74 vs edited ==--- 1.74/arch/ia64/kernel/acpi.c	Thu Aug  5 22:40:29 2004
+++ edited/arch/ia64/kernel/acpi.c	Mon Sep 13 09:32:46 2004
@@ -629,6 +629,13 @@
 #endif
 	/* Make boot-up look pretty */
 	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
+
+	/*
+	 * Make the _OS object report the right name, ia64 Linux has
+	 * enough OEM support that we shouldn't need to fake another OS.
+	 */
+	acpi_os_name_setup("Linux");
+
 	return 0;
 }
 
=== include/acpi/acpiosxf.h 1.34 vs edited ==--- 1.34/include/acpi/acpiosxf.h	Fri Jul 16 23:37:53 2004
+++ edited/include/acpi/acpiosxf.h	Mon Sep 13 09:38:55 2004
@@ -313,6 +313,10 @@
 	u32                             function,
 	void                            *info);
 
+int __init
+acpi_os_name_setup (
+	char				*str);
+
 /*
  * Debug print routines
  */


