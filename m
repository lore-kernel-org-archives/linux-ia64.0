From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 20 Feb 2003 18:03:03 +0000
Subject: [Linux-ia64] [PATCH] 4/5 iosapic: self-documenting polarity/trigger arguments
Message-Id: <marc-linux-ia64-105590709805890@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make interrupt registration functions take named constants for
polarity and trigger mode.  Old -> new magic decoder ring:
	polarity 0 -> IOSAPIC_POL_LOW	(#defined to 1)
	polarity 1 -> IOSAPIC_POL_HIGH	(#defined to 0)
	trigger 0  -> IOSAPIC_LEVEL	(#defined to 1)
	trigger 1  -> IOSAPIC_EDGE	(#defined to 0)

diff -u -ur iosapic-4/arch/ia64/kernel/acpi.c iosapic-5/arch/ia64/kernel/acpi.c
--- iosapic-4/arch/ia64/kernel/acpi.c	2003-02-18 15:33:08.000000000 -0700
+++ iosapic-5/arch/ia64/kernel/acpi.c	2003-02-19 16:50:25.000000000 -0700
@@ -335,8 +335,8 @@
 						plintsrc->iosapic_vector,
 						plintsrc->eid,
 						plintsrc->id,
-						(plintsrc->flags.polarity = 1) ? 1 : 0,
-						(plintsrc->flags.trigger = 1) ? 1 : 0);
+						(plintsrc->flags.polarity = 1) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
+						(plintsrc->flags.trigger = 1) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 
 	platform_intr_list[plintsrc->type] = vector;
 	return 0;
@@ -359,8 +359,8 @@
 		return 0;
 
 	iosapic_override_isa_irq(p->bus_irq, p->global_irq,
-				 (p->flags.polarity = 1) ? 1 : 0,
-				 (p->flags.trigger = 1) ? 1 : 0);
+				 (p->flags.polarity = 1) ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
+				 (p->flags.trigger = 1) ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 	return 0;
 }
 
@@ -618,7 +618,7 @@
 	if (has_8259 && sci_irq < 16)
 		return 0;	/* legacy, no setup required */
 
-	iosapic_register_intr(sci_irq, 0, 0);
+	iosapic_register_intr(sci_irq, IOSAPIC_POL_LOW, IOSAPIC_LEVEL);
 	return 0;
 }
 
@@ -681,7 +681,7 @@
 			 (spcr->global_int[1] << 8)  |
 			 (spcr->global_int[0])  );
 
-		vector = iosapic_register_intr(gsi, 1, 1);
+		vector = iosapic_register_intr(gsi, IOSAPIC_POL_HIGH, IOSAPIC_EDGE);
 	}
 	return 0;
 }
@@ -849,7 +849,8 @@
 		return 0;
 
 	/* Turn it on */
-	vector = iosapic_register_intr (gsi, polarity, trigger);
+	vector = iosapic_register_intr (gsi, polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW,
+			trigger ? IOSAPIC_EDGE : IOSAPIC_LEVEL);
 	return vector;
 }
 
diff -u -ur iosapic-4/arch/ia64/kernel/iosapic.c iosapic-5/arch/ia64/kernel/iosapic.c
--- iosapic-4/arch/ia64/kernel/iosapic.c	2003-02-18 15:26:54.000000000 -0700
+++ iosapic-5/arch/ia64/kernel/iosapic.c	2003-02-18 15:30:34.000000000 -0700
@@ -444,7 +444,7 @@
 
 static void
 register_intr (unsigned int gsi, int vector, unsigned char delivery,
-	       unsigned long polarity, unsigned long edge_triggered)
+	       unsigned long polarity, unsigned long trigger)
 {
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
@@ -464,18 +464,16 @@
 
 	rte_index = gsi - gsi_base;
 	iosapic_intr_info[vector].rte_index = rte_index;
-	iosapic_intr_info[vector].polarity = polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW;
+	iosapic_intr_info[vector].polarity = polarity;
 	iosapic_intr_info[vector].dmode    = delivery;
 	iosapic_intr_info[vector].addr     = iosapic_address;
 	iosapic_intr_info[vector].gsi_base = gsi_base;
+	iosapic_intr_info[vector].trigger  = trigger;
 
-	if (edge_triggered) {
-		iosapic_intr_info[vector].trigger = IOSAPIC_EDGE;
+	if (trigger = IOSAPIC_EDGE)
 		irq_type = &irq_type_iosapic_edge;
-	} else {
-		iosapic_intr_info[vector].trigger = IOSAPIC_LEVEL;
+	else
 		irq_type = &irq_type_iosapic_level;
-	}
 
 	idesc = irq_desc(vector);
 	if (idesc->handler != irq_type) {
@@ -493,7 +491,7 @@
  */
 int
 iosapic_register_intr (unsigned int gsi,
-		       unsigned long polarity, unsigned long edge_triggered)
+		       unsigned long polarity, unsigned long trigger)
 {
 	int vector;
 	unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
@@ -503,11 +501,11 @@
 		vector = ia64_alloc_vector();
 
 	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
-		      polarity, edge_triggered);
+		      polarity, trigger);
 
 	printk(KERN_INFO "GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
-	       gsi, (polarity ? "high" : "low"),
-	       (edge_triggered ? "edge" : "level"), dest, vector);
+	       gsi, (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
+	       (trigger = IOSAPIC_EDGE ? "edge" : "level"), dest, vector);
 
 	/* program the IOSAPIC routing table */
 	set_rte(vector, dest);
@@ -521,7 +519,7 @@
 int
 iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
 				int iosapic_vector, u16 eid, u16 id,
-				unsigned long polarity, unsigned long edge_triggered)
+				unsigned long polarity, unsigned long trigger)
 {
 	unsigned char delivery;
 	int vector;
@@ -551,11 +549,11 @@
 	}
 
 	register_intr(gsi, vector, delivery, polarity,
-		      edge_triggered);
+		      trigger);
 
 	printk(KERN_INFO "PLATFORM int 0x%x: GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
-	       int_type, gsi, (polarity ? "high" : "low"),
-	       (edge_triggered ? "edge" : "level"), dest, vector);
+	       int_type, gsi, (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
+	       (trigger = IOSAPIC_EDGE ? "edge" : "level"), dest, vector);
 
 	/* program the IOSAPIC routing table */
 	set_rte(vector, dest);
@@ -570,18 +568,18 @@
 void
 iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 			  unsigned long polarity,
-			  unsigned long edge_triggered)
+			  unsigned long trigger)
 {
 	int vector;
 	unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
 
 	vector = isa_irq_to_vector(isa_irq);
 
-	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered);
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, trigger);
 
 	DBG("ISA: IRQ %u -> GSI 0x%x (%s,%s) -> CPU 0x%04x vector %d\n",
 	    isa_irq, gsi,
-	    polarity ? "high" : "low", edge_triggered ? "edge" : "level",
+	    polarity = IOSAPIC_POL_HIGH ? "high" : "low", trigger = IOSAPIC_EDGE ? "edge" : "level",
 	    dest, vector);
 
 	/* program the IOSAPIC routing table */
@@ -641,8 +639,7 @@
 		 * Override table.
 		 */
 		for (isa_irq = 0; isa_irq < 16; ++isa_irq)
-			/* IOSAPIC_POL_HIGH, IOSAPIC_EDGE */
-			iosapic_override_isa_irq(isa_irq, isa_irq, 1, 1);
+			iosapic_override_isa_irq(isa_irq, isa_irq, IOSAPIC_POL_HIGH, IOSAPIC_EDGE);
 	}
 }
 
@@ -718,7 +715,7 @@
 				/* new GSI; allocate a vector for it */
 				vector = ia64_alloc_vector();
 
-			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, 0, 0);
+			register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, IOSAPIC_POL_LOW, IOSAPIC_LEVEL);
 		}
 		snprintf(pci_id, sizeof(pci_id), "%02x:%02x:%02x[%c]",
 			 entry->id.segment, entry->id.bus, entry->id.device, 'A' + entry->pin);
diff -u -ur iosapic-4/include/asm-ia64/iosapic.h iosapic-5/include/asm-ia64/iosapic.h
--- iosapic-4/include/asm-ia64/iosapic.h	2003-02-18 15:11:00.000000000 -0700
+++ iosapic-5/include/asm-ia64/iosapic.h	2003-02-18 15:27:45.000000000 -0700
@@ -58,16 +58,16 @@
 extern int gsi_to_irq (unsigned int gsi);
 extern void iosapic_parse_prt (void);
 extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
-				  unsigned long edge_triggered);
+				  unsigned long trigger);
 extern void iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
 				      unsigned long polarity,
-				      unsigned long edge_triggered);
+				      unsigned long trigger);
 extern int iosapic_register_platform_intr (u32 int_type,
 					   unsigned int gsi,
 					   int pmi_vector,
 					   u16 eid, u16 id,
 					   unsigned long polarity,
-					   unsigned long edge_triggered);
+					   unsigned long trigger);
 extern unsigned int iosapic_version (char *addr);
 
 extern void iosapic_pci_fixup (int);


