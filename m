From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 06 Nov 2003 17:20:17 +0000
Subject: Re: [DMESG] cpumask_t in action
Message-Id: <marc-linux-ia64-106813933604851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106807117402763@msgid-missing>
In-Reply-To: <marc-linux-ia64-106807117402763@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Nov 06, 2003 at 04:51:59PM +0000, Matthew Wilcox wrote:
> The arch/ia64 code is not the only offender; ACPI is terribly verbose too.
> I'm going to cc the acpi list too.  See comments below.
> 
> > ACPI: SRAT Processor (id[0x00] eid[0x00]) in proximity domain 0 enabled
[snip[
> > ACPI: SRAT Processor (id[0x20] eid[0x5e]) in proximity domain 47 enabled
> 
> ... for example ;-)  96 lines which honestly tell me nothing.
> 
> > ACPI: SRAT Memory (0x0000003000000000 length 0x0000001000000000 type 0x1) in proximity domain 0 enabled
> > ACPI: SRAT Memory (0x000000b000000000 length 0x0000001000000000 type 0x1) in proximity domain 1 enabled
> [ snip 44 lines ]
> > ACPI: SRAT Memory (0x0000173000000000 length 0x0000001000000000 type 0x1) in proximity domain 46 enabled
> > ACPI: SRAT Memory (0x000017b000000000 length 0x0000001000000000 type 0x1) in proximity domain 47 enabled

Here's one for those two.

Jesse

=== drivers/acpi/numa.c 1.5 vs edited ==--- 1.5/drivers/acpi/numa.c	Tue Feb 18 12:56:05 2003
+++ edited/drivers/acpi/numa.c	Thu Nov  6 09:18:50 2003
@@ -31,6 +31,13 @@
 #include <linux/acpi.h>
 #include <acpi/acpi_bus.h>
 
+#undef ACPI_NUMA_DEBUG
+#ifdef ACPI_NUMA_DEBUG
+#define Dprintk(x...) printk(x)
+#else
+#define Dprintk(x...)
+#endif
+
 extern int __init acpi_table_parse_madt_family (enum acpi_table_id id, unsigned long madt_size, int entry_id, acpi_madt_entry_handler handler);
 
 void __init
@@ -46,7 +53,7 @@
 	{
 		struct acpi_table_processor_affinity *p  			(struct acpi_table_processor_affinity*) header;
-		printk(KERN_INFO PREFIX "SRAT Processor (id[0x%02x] eid[0x%02x]) in proximity domain %d %s\n",
+		Dprintk(KERN_INFO PREFIX "SRAT Processor (id[0x%02x] eid[0x%02x]) in proximity domain %d %s\n",
 		       p->apic_id, p->lsapic_eid, p->proximity_domain,
 		       p->flags.enabled?"enabled":"disabled");
 	}
@@ -56,7 +63,7 @@
 	{
 		struct acpi_table_memory_affinity *p  			(struct acpi_table_memory_affinity*) header;
-		printk(KERN_INFO PREFIX "SRAT Memory (0x%08x%08x length 0x%08x%08x type 0x%x) in proximity domain %d %s%s\n",
+		Dprintk(KERN_INFO PREFIX "SRAT Memory (0x%08x%08x length 0x%08x%08x type 0x%x) in proximity domain %d %s%s\n",
 		       p->base_addr_hi, p->base_addr_lo, p->length_hi, p->length_lo,
 		       p->memory_type, p->proximity_domain,
 		       p->flags.enabled ? "enabled" : "disabled",
