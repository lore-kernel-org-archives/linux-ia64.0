From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 15 Jul 2004 22:20:09 +0000
Subject: [PATCH] make madt parsing quieter
Message-Id: <200407151820.09638.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_ZMw9A59v7cSf1dZ"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_ZMw9A59v7cSf1dZ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We already get this info in other forms from other boot messages, so kill the 
printing of the MADT entries as they're parsed.  This patch significantly 
reduces the amount of output from a boot of a 512p system.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_ZMw9A59v7cSf1dZ
Content-Type: text/x-diff;
  charset="us-ascii";
  name="acpi-madt-parse-quiet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="acpi-madt-parse-quiet.patch"

===== arch/ia64/kernel/acpi.c 1.71 vs edited =====
--- 1.71/arch/ia64/kernel/acpi.c	2004-05-24 22:32:34 -07:00
+++ edited/arch/ia64/kernel/acpi.c	2004-07-15 14:41:29 -07:00
@@ -171,8 +171,6 @@
 	if (BAD_MADT_ENTRY(lapic, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
-
 	if (lapic->address) {
 		iounmap((void *) ipi_base_addr);
 		ipi_base_addr = (unsigned long) ioremap(lapic->address, 0);
@@ -191,25 +189,13 @@
 	if (BAD_MADT_ENTRY(lsapic, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
-
-	printk(KERN_INFO "CPU %d (0x%04x)", total_cpus, (lsapic->id << 8) | lsapic->eid);
-
-	if (!lsapic->flags.enabled)
-		printk(" disabled");
-	else {
-		printk(" enabled");
+	if (lsapic->flags.enabled) {
 #ifdef CONFIG_SMP
 		smp_boot_data.cpu_phys_id[available_cpus] = (lsapic->id << 8) | lsapic->eid;
-		if (hard_smp_processor_id()
-		    == (unsigned int) smp_boot_data.cpu_phys_id[available_cpus])
-			printk(" (BSP)");
 #endif
 		++available_cpus;
 	}
 
-	printk("\n");
-
 	total_cpus++;
 	return 0;
 }
@@ -225,8 +211,6 @@
 	if (BAD_MADT_ENTRY(lacpi_nmi, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
-
 	/* TBD: Support lapic_nmi entries */
 	return 0;
 }
@@ -242,8 +226,6 @@
 	if (BAD_MADT_ENTRY(iosapic, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
-
 	iosapic_init(iosapic->address, iosapic->global_irq_base);
 
 	return 0;
@@ -262,8 +244,6 @@
 	if (BAD_MADT_ENTRY(plintsrc, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
-
 	/*
 	 * Get vector assignment for this interrupt, set attributes,
 	 * and program the IOSAPIC routing table.
@@ -292,8 +272,6 @@
 	if (BAD_MADT_ENTRY(p, end))
 		return -EINVAL;
 
-	acpi_table_print_madt_entry(header);
-
 	iosapic_override_isa_irq(p->bus_irq, p->global_irq,
 				 (p->flags.polarity == 1) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
 				 (p->flags.trigger == 1) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
@@ -310,8 +288,6 @@
 
 	if (BAD_MADT_ENTRY(nmi_src, end))
 		return -EINVAL;
-
-	acpi_table_print_madt_entry(header);
 
 	/* TBD: Support nimsrc entries */
 	return 0;

--Boundary-00=_ZMw9A59v7cSf1dZ--
