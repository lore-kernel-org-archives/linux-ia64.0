From: Martin Hicks <mort@wildopensource.com>
Date: Tue, 26 Aug 2003 16:13:07 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
Message-Id: <marc-linux-ia64-106191478719084@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Tue, Aug 26, 2003 at 05:39:32PM +0200, Xavier Bru wrote:
> 
> I tried to put find_memory()  after acpi_numa_init() as in 2.5.72, but 
> now we get:
>      bootmem alloc of 100 bytes failed! in acpi_table_init()
> that now uses the bootmem allocator.
> 
> I wonder what should be the right order for initialisation, and if
> there are ia64 platforms running 2.6.0 with CONFIG_NUMA. Any help is
> apreciated.

Jesse Barnes has an unreleased patch to make SGI SN2 work, which does
move the find_memory() after acpi_numa_init().  There is another patch,
which I've attached, which removes the bootmem alloc of memory in ACPI.

I haven't played with this recently, so your mileage may vary.  Jesse
should be back from vacation next week, and should release updated SN2
patches then.

mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1395  -> 1.1396 
#	drivers/acpi/tables.c	1.14    -> 1.15   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/30	jbarnes@tomahawk.engr.sgi.com	1.1396
# don't use alloc_bootmem in acpi table init
# --------------------------------------------
#
diff -Nru a/drivers/acpi/tables.c b/drivers/acpi/tables.c
--- a/drivers/acpi/tables.c	Wed Jul 30 11:45:27 2003
+++ b/drivers/acpi/tables.c	Wed Jul 30 11:45:27 2003
@@ -69,7 +69,8 @@
 
 static unsigned long		sdt_pa;		/* Physical Address */
 static unsigned long		sdt_count;	/* Table count */
-static struct acpi_table_sdt	*sdt_entry;
+
+static struct acpi_table_sdt	sdt_entry[ACPI_MAX_TABLES];
 
 void
 acpi_table_print (
@@ -413,12 +414,6 @@
 			sdt_count = ACPI_MAX_TABLES;
 		}
 
-		sdt_entry = alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt));
-		if (!sdt_entry) {
-			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
-			return -ENOMEM;
-		}
-
 		for (i = 0; i < sdt_count; i++)
 			sdt_entry[i].pa = (unsigned long) mapped_xsdt->entry[i];
 	}
@@ -463,12 +458,6 @@
 			printk(KERN_WARNING PREFIX "Truncated %lu RSDT entries\n",
 				(sdt_count - ACPI_MAX_TABLES));
 			sdt_count = ACPI_MAX_TABLES;
-		}
-
-		sdt_entry = alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt));
-		if (!sdt_entry) {
-			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
-			return -ENOMEM;
 		}
 
 		for (i = 0; i < sdt_count; i++)
