From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 20 Feb 2003 18:01:13 +0000
Subject: [Linux-ia64] [PATCH] 2/5 iosapic: remove find_iosapic duplication
Message-Id: <marc-linux-ia64-105590709805888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove IOSAPIC address and GSI base from external interrupt
registration interfaces.  This lets us remove acpi_find_iosapic(),
which is functionally similar to find_iosapic().

diff -u -ur iosapic-2/arch/ia64/kernel/acpi.c iosapic-3/arch/ia64/kernel/acpi.c
--- iosapic-2/arch/ia64/kernel/acpi.c	2003-02-18 15:08:09.000000000 -0700
+++ iosapic-3/arch/ia64/kernel/acpi.c	2003-02-18 15:11:00.000000000 -0700
@@ -292,40 +292,6 @@
 
 
 static int __init
-acpi_find_iosapic (unsigned int gsi, u32 *gsi_base, char **iosapic_address)
-{
-	struct acpi_table_iosapic *iosapic;
-	int ver;
-	int max_pin;
-	char *p;
-	char *end;
-
-	if (!gsi_base || !iosapic_address)
-		return -ENODEV;
-
-	p = (char *) (acpi_madt + 1);
-	end = p + (acpi_madt->header.length - sizeof(struct acpi_table_madt));
-
-	while (p < end) {
-		if (*p = ACPI_MADT_IOSAPIC) {
-			iosapic = (struct acpi_table_iosapic *) p;
-
-			*gsi_base = iosapic->global_irq_base;
-			*iosapic_address = ioremap(iosapic->address, 0);
-
-			ver = iosapic_version(*iosapic_address);
-			max_pin = (ver >> 16) & 0xff;
-
-			if ((gsi - *gsi_base) <= max_pin)
-				return 0;	/* Found it! */
-		}
-		p += p[1];
-	}
-	return -ENODEV;
-}
-
-
-static int __init
 acpi_parse_iosapic (acpi_table_entry_header *header)
 {
 	struct acpi_table_iosapic *iosapic;
@@ -348,8 +314,6 @@
 {
 	struct acpi_table_plat_int_src *plintsrc;
 	int vector;
-	u32 gsi_base;
-	char *iosapic_address;
 
 	plintsrc = (struct acpi_table_plat_int_src *) header;
 	if (!plintsrc)
@@ -362,11 +326,6 @@
 		return -ENODEV;
 	}
 
-	if (acpi_find_iosapic(plintsrc->global_irq, &gsi_base, &iosapic_address)) {
-		printk(KERN_WARNING PREFIX "IOSAPIC not found\n");
-		return -ENODEV;
-	}
-
 	/*
 	 * Get vector assignment for this interrupt, set attributes,
 	 * and program the IOSAPIC routing table.
@@ -377,9 +336,7 @@
 						plintsrc->eid,
 						plintsrc->id,
 						(plintsrc->flags.polarity = 1) ? 1 : 0,
-						(plintsrc->flags.trigger = 1) ? 1 : 0,
-						gsi_base,
-						iosapic_address);
+						(plintsrc->flags.trigger = 1) ? 1 : 0);
 
 	platform_intr_list[plintsrc->type] = vector;
 	return 0;
@@ -639,8 +596,7 @@
 {
 	struct acpi_table_header *fadt_header;
 	struct fadt_descriptor_rev2 *fadt;
-	u32 sci_irq, gsi_base;
-	char *iosapic_address;
+	u32 sci_irq;
 
 	if (!phys_addr || !size)
 		return -EINVAL;
@@ -662,8 +618,7 @@
 	if (has_8259 && sci_irq < 16)
 		return 0;	/* legacy, no setup required */
 
-	if (!acpi_find_iosapic(sci_irq, &gsi_base, &iosapic_address))
-		iosapic_register_intr(sci_irq, 0, 0, gsi_base, iosapic_address);
+	iosapic_register_intr(sci_irq, 0, 0);
 	return 0;
 }
 
@@ -717,8 +672,6 @@
 	if ((spcr->base_addr.space_id != ACPI_SERIAL_PCICONF_SPACE) &&
 	    (spcr->int_type = ACPI_SERIAL_INT_SAPIC))
 	{
-		u32 gsi_base;
-		char *iosapic_address;
 		int vector;
 
 		/* We have a UART in memory space with an SAPIC interrupt */
@@ -728,11 +681,7 @@
 			 (spcr->global_int[1] << 8)  |
 			 (spcr->global_int[0])  );
 
-		/* Which iosapic does this interrupt belong to? */
-
-		if (!acpi_find_iosapic(gsi, &gsi_base, &iosapic_address))
-			vector = iosapic_register_intr(gsi, 1, 1,
-						       gsi_base, iosapic_address);
+		vector = iosapic_register_intr(gsi, 1, 1);
 	}
 	return 0;
 }
@@ -892,8 +841,6 @@
 acpi_register_irq (u32 gsi, u32 polarity, u32 trigger)
 {
 	int vector = 0;
-	u32 irq_base;
-	char *iosapic_address;
 
 	if (acpi_madt->flags.pcat_compat && (gsi < 16))
 		return isa_irq_to_vector(gsi);
@@ -901,12 +848,8 @@
 	if (!iosapic_register_intr)
 		return 0;
 
-	/* Find the IOSAPIC */
-	if (!acpi_find_iosapic(gsi, &irq_base, &iosapic_address)) {
-		/* Turn it on */
-		vector = iosapic_register_intr (gsi, polarity, trigger,
-						irq_base, iosapic_address);
-	}
+	/* Turn it on */
+	vector = iosapic_register_intr (gsi, polarity, trigger);
 	return vector;
 }
 
diff -u -ur iosapic-2/arch/ia64/kernel/iosapic.c iosapic-3/arch/ia64/kernel/iosapic.c
--- iosapic-2/arch/ia64/kernel/iosapic.c	2003-02-18 15:09:15.000000000 -0700
+++ iosapic-3/arch/ia64/kernel/iosapic.c	2003-02-18 15:24:23.000000000 -0700
@@ -444,43 +444,31 @@
 
 static void
 register_intr (unsigned int gsi, int vector, unsigned char delivery,
-	       unsigned long polarity, unsigned long edge_triggered,
-	       unsigned int gsi_base, char *iosapic_address)
+	       unsigned long polarity, unsigned long edge_triggered)
 {
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
 	int rte_index;
+	int index;
+	unsigned long gsi_base;
+	char *iosapic_address;
+
+	index = find_iosapic(gsi);
+	if (index < 0) {
+		printk(KERN_WARNING "%s: No IOSAPIC for GSI 0x%x\n", __FUNCTION__, gsi);
+		return;
+	}
+
+	iosapic_address = iosapic_lists[index].addr;
+	gsi_base = iosapic_lists[index].gsi_base;
 
 	rte_index = gsi - gsi_base;
 	iosapic_intr_info[vector].rte_index = rte_index;
 	iosapic_intr_info[vector].polarity = polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW;
 	iosapic_intr_info[vector].dmode    = delivery;
+	iosapic_intr_info[vector].addr     = iosapic_address;
+	iosapic_intr_info[vector].gsi_base = gsi_base;
 
-	/*
-	 * In override, it may not provide addr/gsi_base.  GSI is enough to
-	 * locate iosapic addr, gsi_base and rte_index by examining
-	 * gsi_base and num_rte of registered iosapics (tbd)
-	 */
-#ifndef	OVERRIDE_DEBUG
-	if (iosapic_address) {
-		iosapic_intr_info[vector].addr = iosapic_address;
-		iosapic_intr_info[vector].gsi_base = gsi_base;
-	}
-#else
-	if (iosapic_address) {
-		if (iosapic_intr_info[vector].addr && (iosapic_intr_info[vector].addr != iosapic_address))
-			printk(KERN_WARNING "warning: register_intr: diff IOSAPIC ADDRESS for "
-			       "GSI 0x%x, vector %d\n", gsi, vector);
-		iosapic_intr_info[vector].addr = iosapic_address;
-		if (iosapic_intr_info[vector].gsi_base && (iosapic_intr_info[vector].gsi_base != gsi_base)) {
-			printk(KERN_WARNING "warning: register_intr: diff GSI base 0x%x for "
-			       "GSI 0x%x, vector %d\n", gsi_base, gsi, vector);
-		}
-		iosapic_intr_info[vector].gsi_base = gsi_base;
-	} else if (!iosapic_intr_info[vector].addr)
-		printk(KERN_WARNING "warning: register_intr: invalid override for GSI 0x%x, "
-		       "vector %d\n", gsi, vector);
-#endif
 	if (edge_triggered) {
 		iosapic_intr_info[vector].trigger = IOSAPIC_EDGE;
 		irq_type = &irq_type_iosapic_edge;
@@ -505,8 +493,7 @@
  */
 int
 iosapic_register_intr (unsigned int gsi,
-		       unsigned long polarity, unsigned long edge_triggered,
-		       unsigned int gsi_base, char *iosapic_address)
+		       unsigned long polarity, unsigned long edge_triggered)
 {
 	int vector;
 	unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
@@ -516,7 +503,7 @@
 		vector = ia64_alloc_vector();
 
 	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
-		      polarity, edge_triggered, gsi_base, iosapic_address);
+		      polarity, edge_triggered);
 
 	printk(KERN_INFO "GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
 	       gsi, (polarity ? "high" : "low"),
@@ -534,8 +521,7 @@
 int
 iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
 				int iosapic_vector, u16 eid, u16 id,
-				unsigned long polarity, unsigned long edge_triggered,
-				unsigned int gsi_base, char *iosapic_address)
+				unsigned long polarity, unsigned long edge_triggered)
 {
 	unsigned char delivery;
 	int vector;
@@ -565,7 +551,7 @@
 	}
 
 	register_intr(gsi, vector, delivery, polarity,
-		      edge_triggered, gsi_base, iosapic_address);
+		      edge_triggered);
 
 	printk(KERN_INFO "PLATFORM int 0x%x: GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
 	       int_type, gsi, (polarity ? "high" : "low"),
@@ -586,25 +572,12 @@
 			  unsigned long polarity,
 			  unsigned long edge_triggered)
 {
-	int index, vector;
-	unsigned int gsi_base;
-	char *addr;
+	int vector;
 	unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
 
-	index = find_iosapic(gsi);
-
-	if (index < 0) {
-		printk(KERN_ERR "ISA: No corresponding IOSAPIC found : ISA IRQ %u -> GSI 0x%x\n",
-		       isa_irq, gsi);
-		return;
-	}
-
 	vector = isa_irq_to_vector(isa_irq);
-	addr = iosapic_lists[index].addr;
-	gsi_base = iosapic_lists[index].gsi_base;
 
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered,
-		      gsi_base, addr);
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered);
 
 	DBG("ISA: IRQ %u -> GSI 0x%x (%s,%s) -> CPU 0x%04x vector %d\n",
 	    isa_irq, gsi,
@@ -673,7 +646,7 @@
 
 			register_intr(isa_irq, vector, IOSAPIC_LOWEST_PRIORITY,
 				     /* IOSAPIC_POL_HIGH, IOSAPIC_EDGE */
-				     1, 1, gsi_base, addr);
+				     1, 1);
 
 			DBG("ISA: IRQ %u -> GSI 0x%x (high,edge) -> CPU 0x%04x vector %d\n",
 			    isa_irq, isa_irq, dest, vector);
@@ -734,10 +707,9 @@
 {
 	struct acpi_prt_entry *entry;
 	struct list_head *node;
-	unsigned int gsi, gsi_base;
-	int index, vector;
+	unsigned int gsi;
+	int vector;
 	char pci_id[16];
-	char *addr;
 
 	list_for_each(node, &acpi_prt.entries) {
 		entry = list_entry(node, struct acpi_prt_entry, node);
@@ -751,22 +723,13 @@
 		vector = gsi_to_vector(gsi);
 		if (vector < 0) {
 			/* allocate a vector for this interrupt line */
-			index = find_iosapic(gsi);
-
-			if (index < 0) {
-				printk(KERN_WARNING "IOSAPIC: GSI 0x%x has no IOSAPIC!\n", gsi);
-				continue;
-			}
-			addr = iosapic_lists[index].addr;
-			gsi_base = iosapic_lists[index].gsi_base;
-
 			if (pcat_compat && (gsi < 16))
 				vector = isa_irq_to_vector(gsi);
 			else
 				/* new GSI; allocate a vector for it */
 				vector = ia64_alloc_vector();
 
-			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, 0, 0, gsi_base, addr);
+			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, 0, 0);
 		}
 		snprintf(pci_id, sizeof(pci_id), "%02x:%02x:%02x[%c]",
 			 entry->id.segment, entry->id.bus, entry->id.device, 'A' + entry->pin);
diff -u -ur iosapic-2/include/asm-ia64/iosapic.h iosapic-3/include/asm-ia64/iosapic.h
--- iosapic-2/include/asm-ia64/iosapic.h	2003-02-18 15:08:09.000000000 -0700
+++ iosapic-3/include/asm-ia64/iosapic.h	2003-02-18 15:11:00.000000000 -0700
@@ -58,8 +58,7 @@
 extern int gsi_to_irq (unsigned int gsi);
 extern void iosapic_parse_prt (void);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
-				  unsigned long edge_triggered,
-				  u32 gsi_base, char *iosapic_address);
+				  unsigned long edge_triggered);
 extern void iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 				      unsigned long polarity,
 				      unsigned long edge_triggered);
@@ -68,9 +67,7 @@
 					   int pmi_vector,
 					   u16 eid, u16 id,
 					   unsigned long polarity,
-					   unsigned long edge_triggered,
-					   unsigned int gsi_base,
-					   char *iosapic_address);
+					   unsigned long edge_triggered);
 extern unsigned int iosapic_version (char *addr);
 
 extern void iosapic_pci_fixup (int);


