From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 13 Feb 2004 22:55:52 +0000
Subject: Re: GENERIC build failure
Message-Id: <20040213225551.GA23760@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402132133.i1DLXaYS026393@napali.hpl.hp.com>
In-Reply-To: <200402132133.i1DLXaYS026393@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 13, 2004 at 02:48:42PM -0800, Andrew Morton wrote:
> 
> I dropped the patch because it's fixed in Len's tree.
> 
> If someone can send me a tested standalone patch then sure.

Here you go.

Jesse


=== drivers/acpi/numa.c 1.7 vs edited ==--- 1.7/drivers/acpi/numa.c	Tue Jan 13 01:52:03 2004
+++ edited/drivers/acpi/numa.c	Wed Feb 11 17:31:34 2004
@@ -172,7 +172,7 @@
 					       NR_CPUS);
 		result = acpi_table_parse_srat(ACPI_SRAT_MEMORY_AFFINITY,
 					       acpi_parse_memory_affinity,
-					       NR_MEMBLKS);
+					       NR_NODE_MEMBLKS);
 	} else {
 		/* FIXME */
 		printk("Warning: acpi_table_parse(ACPI_SRAT) returned %d!\n",result);
