From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Date: Fri, 12 Sep 2003 12:47:38 +0000
Subject: Re: kernel update (relative to 2.4.22)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="--Next_Part(Fri_Sep_12_21:47:38_2003_862)--"
Message-Id: <marc-linux-ia64-106337111917901@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106312897006127@msgid-missing>
In-Reply-To: <marc-linux-ia64-106312897006127@msgid-missing>
To: linux-ia64@vger.kernel.org

----Next_Part(Fri_Sep_12_21:47:38_2003_862)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

From: Takayoshi Kochi <kochi@hpc.bs1.fc.nec.co.jp>
Subject: Re: kernel update (relative to 2.4.22)
Date: Fri, 12 Sep 2003 21:43:19 +0900 (JST)

> Hi Bjorn,
> 
> For NUMA configuration, we need the attached patch which is
> the same fix as 2.6.  I confirmed both the DIG and GENERIC
> kernels boot on 8-way (2-node) NEC TX7.

Sorry, I forgot the attachment.

Takayoshi Kochi

----Next_Part(Fri_Sep_12_21:47:38_2003_862)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="dcm-2422_2.diff"

--- linux-2.4.22/drivers/acpi/tables.c.save	Fri Sep 12 09:45:18 2003
+++ linux-2.4.22/drivers/acpi/tables.c	Fri Sep 12 21:11:05 2003
@@ -69,7 +69,7 @@
 
 static unsigned long		sdt_pa;		/* Physical Address */
 static unsigned long		sdt_count;	/* Table count */
-static struct acpi_table_sdt	*sdt_entry;
+static struct acpi_table_sdt	sdt_entry[ACPI_MAX_TABLES];
 
 void
 acpi_table_print (
@@ -425,12 +425,6 @@
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
@@ -477,12 +471,6 @@
 			sdt_count = ACPI_MAX_TABLES;
 		}
 
-		sdt_entry = alloc_bootmem(sdt_count * sizeof(struct acpi_table_sdt));
-		if (!sdt_entry) {
-			printk(KERN_ERR "ACPI: Could not allocate mem for SDT entries!\n");
-			return -ENOMEM;
-		}
-
 		for (i = 0; i < sdt_count; i++)
 			sdt_entry[i].pa = (unsigned long) mapped_rsdt->entry[i];
 	}
--- linux-2.4.22/arch/ia64/kernel/setup.c.save	Fri Sep 12 09:45:18 2003
+++ linux-2.4.22/arch/ia64/kernel/setup.c	Fri Sep 12 20:40:10 2003
@@ -378,7 +378,6 @@
 	saved_command_line[COMMAND_LINE_SIZE-1] = '\0';		/* for safety */
 
 	efi_init();
-	find_memory();
 
 #ifdef CONFIG_ACPI_BOOT
 	/* Initialize the ACPI boot-time table parser */
@@ -394,6 +393,7 @@
 #endif /* CONFIG_APCI_BOOT */
 
 	iomem_resource.end = ~0UL;	/* FIXME probably belongs elsewhere */
+	find_memory();
 
 #if 0
 	/* XXX fix me */

----Next_Part(Fri_Sep_12_21:47:38_2003_862)----
