From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Tue, 30 Jul 2002 02:36:12 +0000
Subject: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905851@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

We'd like to change some of iosapic.c and IRQ (interrupt vector)
allocation behavior.

Now iosapic.c allocates an ia64 interrupt vector for each
possible _PRT entry.  So iosapic allocates vectors to
unpopulated PCI slots.
This patch fixes the behavior and only allocates vectors
for existing pci_dev only.

Now the ia64_alloc_irq() routine is somewhat(?) broken and
panics if there are more than 183 distinct entries for
interrupts.  This is easily broken with huge configuration
servers.

For example, if each PCI slot's 4 interrupt pins are
connected to differet IOSAPIC input pins and there are
more than 46 slots in a system (without PCI segment),
interrupt vectors are exhausted.  But for most cases,
a PCI card uses only INTA.  So allocating vectors for
all of _PRT entries is wasteful.

# This breaks the ACPI PCI hotplug patch I sent last week.
# I'll make an update patch for it if this is accepted.

But if such a huge server is fully populated with cards,
this patch doesn't help.  For such a case, we have to support
a PCI IRQ (interrupt vector) sharing with interrupts from
different IO SAPICs.

As usual, interrupt sharing often imply performance
degradation and such a configuration should be avoided.

So I think this patch is a reasonable solution for most
cases.

--- david-020722/arch/ia64/kernel/iosapic.c	Tue Jul 23 16:01:24 2002
+++ david-020722-pcihp/arch/ia64/kernel/iosapic.c	Mon Jul 29 18:51:10 2002
@@ -25,6 +25,7 @@
  * 02/04/02	P. Diefenbaugh	Cleaned up ACPI PCI IRQ routing.
  * 02/04/18	J.I. Lee	bug fix in iosapic_init_pci_irq
  * 02/04/30	J.I. Lee	bug fix in find_iosapic to fix ACPI PCI IRQ to IOSAPIC mapping error
+ * 02/07/29	T. Kochi	Allocate interrupt vectors dynamically
  */
 /*
  * Here is what the interrupt logic between a PCI device and the CPU looks like:
@@ -99,7 +100,7 @@
 	unsigned int 	base_irq;	/* first irq assigned to this IOSAPIC */
 	unsigned short 	max_pin;	/* max input pin supported in this IOSAPIC */
 	unsigned char	pcat_compat;	/* 8259 compatibility flag */
-} iosapic_lists[256] __initdata;
+} iosapic_lists[256] __devinitdata;
 
 static int num_iosapic = 0;
 
@@ -107,7 +108,7 @@
 /*
  * Find an IOSAPIC associated with an IRQ
  */
-static inline int __init
+static inline int __devinit
 find_iosapic (unsigned int irq)
 {
 	int i;
@@ -135,21 +136,6 @@
 	return -1;
 }
 
-/*
- * Map PCI pin to the corresponding IA-64 interrupt vector.  If no such mapping exists,
- * return -1.
- */
-int
-pci_pin_to_vector (int bus, int slot, int pci_pin)
-{
-	struct pci_vector_struct *r;
-
-	for (r = pci_irq.route; r < pci_irq.route + pci_irq.num_routes; ++r)
-		if (r->bus = bus && (r->pci_id >> 16) = slot && r->pin = pci_pin)
-			return iosapic_irq_to_vector(r->irq);
-	return -1;
-}
-
 static void
 set_rte (unsigned int vector, unsigned long dest)
 {
@@ -568,7 +554,76 @@
 	set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
 }
 
-void __init
+/*
+ * Map PCI pin to the corresponding IA-64 global interrupt vector.
+ * If no such mapping exists, return -1.
+ */
+static int
+pci_pin_to_globalvector (int bus, int slot, int pci_pin)
+{
+	struct pci_vector_struct *r;
+
+	for (r = pci_irq.route; r < pci_irq.route + pci_irq.num_routes; ++r)
+		if (r->bus = bus && (r->pci_id >> 16) = slot && r->pin = pci_pin)
+			return r->irq;
+	return -1;
+}
+
+/*
+ * Map PCI pin to the corresponding IA-64 interrupt vector.  If no such mapping exists,
+ * try to allocate a new vector.  If it fails, return -1.
+ */
+static int
+pci_pin_to_vector (int bus, int slot, int pci_pin)
+{
+	int index, vector, pin, gv;
+	int base_irq, max_pin, pcat_compat;
+	char *addr;
+
+	gv = pci_pin_to_globalvector (bus, slot, pci_pin);
+
+	if (gv < 0) {
+		printk("PCI: no interrupt route for %02x:%02x pin %c\n", bus, slot, 'A' + pci_pin);
+		return -1;
+	}
+
+	vector = iosapic_irq_to_vector(gv);
+
+	if (vector < 0) {
+		/* we should allocate a vector for this interrupt line */
+
+		index = find_iosapic(gv);
+
+		if (index < 0) {
+			printk("PCI: IRQ %d has no IOSAPIC mapping\n", gv);
+			return -1;
+		}
+
+		addr = iosapic_lists[index].addr;
+		base_irq = iosapic_lists[index].base_irq;
+		max_pin = iosapic_lists[index].max_pin;
+		pcat_compat = iosapic_lists[index].pcat_compat;
+		pin = gv - base_irq;
+
+		if (pcat_compat && (gv < 16))
+			vector = isa_irq_to_vector(gv);
+		else {
+			/* new iosapic irq: allocate a vector for it */
+			vector = ia64_alloc_irq();
+		}
+
+		register_irq(gv, vector, pin, IOSAPIC_LOWEST_PRIORITY, 0, 0, base_irq, addr);
+
+#ifdef DEBUG_IRQ_ROUTING
+		printk("PCI: (B%d,I%d,P%d) -> IOSAPIC irq 0x%02x -> vector 0x%02x\n",
+		       bus, slot, pci_pin, gv, vector);
+#endif
+	}
+
+	return vector;
+}
+
+void __devinit
 iosapic_init (unsigned long phys_addr, unsigned int base_irq, int pcat_compat)
 {
 	int irq, max_pin, vector, pin;
@@ -632,71 +687,106 @@
 	}
 }
 
-void __init
-iosapic_init_pci_irq (void)
-{
-	int i, index, vector, pin;
-	int base_irq, max_pin, pcat_compat;
-	unsigned int irq;
-	char *addr;
-
-	if (0 != acpi_get_prt(&pci_irq.route, &pci_irq.num_routes))
-		return;
-
-	for (i = 0; i < pci_irq.num_routes; i++) {
-
-		irq = pci_irq.route[i].irq;
-
-		index = find_iosapic(irq);
-		if (index < 0) {
-			printk("PCI: IRQ %u has no IOSAPIC mapping\n", irq);
-			continue;
-		}
-
-		addr = iosapic_lists[index].addr;
-		base_irq = iosapic_lists[index].base_irq;
-		max_pin = iosapic_lists[index].max_pin;
-		pcat_compat = iosapic_lists[index].pcat_compat;
-		pin = irq - base_irq;
 
-		if ((unsigned) pin > max_pin)
-			/* the interrupt route is for another controller... */
-			continue;
+/*
+ * Set dev->irq and program iosapic to deliver interrupts
+ */
+void
+iosapic_alloc_irq (struct pci_dev *dev)
+{
+	unsigned char pin;
+	int vector;
+	struct hw_interrupt_type *irq_type;
+	irq_desc_t *idesc;
 
-		if (pcat_compat && (irq < 16))
-			vector = isa_irq_to_vector(irq);
-		else {
-			vector = iosapic_irq_to_vector(irq);
-			if (vector < 0)
-				/* new iosapic irq: allocate a vector for it */
-				vector = ia64_alloc_irq();
+	pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pin);
+	if (pin) {
+		pin--;          /* interrupt pins are numbered starting from 1 */
+		vector = pci_pin_to_vector(dev->bus->number, PCI_SLOT(dev->devfn), pin);
+		if (vector < 0 && dev->bus->parent) {
+			/* go back to the bridge */
+			struct pci_dev *bridge = dev->bus->self;
+
+			if (bridge) {
+				/* allow for multiple bridges on an adapter */
+				do {
+					/* do the bridge swizzle... */
+					pin = (pin + PCI_SLOT(dev->devfn)) % 4;
+					vector = pci_pin_to_vector(bridge->bus->number,
+								   PCI_SLOT(bridge->devfn),
+								   pin);
+				} while (vector < 0 && (bridge = bridge->bus->self));
+			}
+			if (vector >= 0)
+				printk(KERN_WARNING
+				       "PCI: using PPB(B%d,I%d,P%d) to get vector %02x\n",
+				       dev->bus->number, PCI_SLOT(dev->devfn),
+				       pin, vector);
+			else
+				printk(KERN_WARNING
+				       "PCI: Couldn't map irq for (B%d,I%d,P%d)\n",
+				       dev->bus->number, PCI_SLOT(dev->devfn), pin);
 		}
-
-		register_irq(irq, vector, pin, IOSAPIC_LOWEST_PRIORITY, 0, 0, base_irq, addr);
-
-#ifdef DEBUG_IRQ_ROUTING
-		printk("PCI: (B%d,I%d,P%d) -> IOSAPIC irq 0x%02x -> vector 0x%02x\n",
-		       pci_irq.route[i].bus, pci_irq.route[i].pci_id>>16, pci_irq.route[i].pin,
-		       iosapic_irq[vector].base_irq + iosapic_irq[vector].pin, vector);
+		if (vector >= 0) {
+			printk("PCI->APIC IRQ transform: (B%d,I%d,P%d) -> 0x%02x\n",
+			       dev->bus->number, PCI_SLOT(dev->devfn), pin, vector);
+			dev->irq = vector;
+
+			irq_type = &irq_type_iosapic_level;
+			idesc = irq_desc(vector);
+			if (idesc->handler != irq_type) {
+				if (idesc->handler != &no_irq_type)
+					printk("iosapic_pci_fixup: changing vector 0x%02x "
+					       "from %s to %s\n", vector,
+					       idesc->handler->typename,
+					       irq_type->typename);
+				idesc->handler = irq_type;
+			}
+#ifdef CONFIG_SMP
+			/*
+			 * For platforms that do not support interrupt redirect
+			 * via the XTP interface, we can round-robin the PCI
+			 * device interrupts to the processors
+			 */
+			if (!(smp_int_redirect & SMP_IRQ_REDIRECTION)) {
+				static int cpu_index = 0;
+
+				set_rte(vector, cpu_physical_id(cpu_index) & 0xffff);
+
+				cpu_index++;
+				if (cpu_index >= smp_num_cpus)
+					cpu_index = 0;
+			} else {
+				/*
+				 * Direct the interrupt vector to the current cpu,
+				 * platform redirection will distribute them.
+				 */
+				set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+			}
+#else
+			/* direct the interrupt vector to the running cpu id */
+			set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
 #endif
-		/*
-		 * NOTE: The IOSAPIC RTE will be programmed in iosapic_pci_fixup().  It
-		 * needs to be done there to ensure PCI hotplug works right.
-		 */
+		}
 	}
+	/*
+	 * Nothing to fixup
+	 * Fix out-of-range IRQ numbers
+	 */
+	if (dev->irq >= IA64_NUM_VECTORS)
+		dev->irq = 15;	/* Spurious interrupts */
 }
 
+
 void
 iosapic_pci_fixup (int phase)
 {
 	struct	pci_dev	*dev;
-	unsigned char pin;
-	int vector;
-	struct hw_interrupt_type *irq_type;
-	irq_desc_t *idesc;
 
 	if (phase = 0) {
-		iosapic_init_pci_irq();
+		if (0 != acpi_get_prt(&pci_irq.route, &pci_irq.num_routes)) {
+			printk("%s: acpi_get_prt failed\n", __FILE__);
+		}
 		return;
 	}
 
@@ -704,81 +794,6 @@
 		return;
 
 	pci_for_each_dev(dev) {
-		pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pin);
-		if (pin) {
-			pin--;          /* interrupt pins are numbered starting from 1 */
-			vector = pci_pin_to_vector(dev->bus->number, PCI_SLOT(dev->devfn), pin);
-			if (vector < 0 && dev->bus->parent) {
-				/* go back to the bridge */
-				struct pci_dev *bridge = dev->bus->self;
-
-				if (bridge) {
-					/* allow for multiple bridges on an adapter */
-					do {
-						/* do the bridge swizzle... */
-						pin = (pin + PCI_SLOT(dev->devfn)) % 4;
-						vector = pci_pin_to_vector(bridge->bus->number,
-									   PCI_SLOT(bridge->devfn),
-									   pin);
-					} while (vector < 0 && (bridge = bridge->bus->self));
-				}
-				if (vector >= 0)
-					printk(KERN_WARNING
-					       "PCI: using PPB(B%d,I%d,P%d) to get vector %02x\n",
-					       dev->bus->number, PCI_SLOT(dev->devfn),
-					       pin, vector);
-				else
-					printk(KERN_WARNING
-					       "PCI: Couldn't map irq for (B%d,I%d,P%d)\n",
-					       dev->bus->number, PCI_SLOT(dev->devfn), pin);
-			}
-			if (vector >= 0) {
-				printk("PCI->APIC IRQ transform: (B%d,I%d,P%d) -> 0x%02x\n",
-				       dev->bus->number, PCI_SLOT(dev->devfn), pin, vector);
-				dev->irq = vector;
-
-				irq_type = &irq_type_iosapic_level;
-				idesc = irq_desc(vector);
-				if (idesc->handler != irq_type) {
-					if (idesc->handler != &no_irq_type)
-						printk("iosapic_pci_fixup: changing vector 0x%02x "
-						       "from %s to %s\n", vector,
-						       idesc->handler->typename,
-						       irq_type->typename);
-					idesc->handler = irq_type;
-				}
-#ifdef CONFIG_SMP
-				/*
-				 * For platforms that do not support interrupt redirect
-				 * via the XTP interface, we can round-robin the PCI
-				 * device interrupts to the processors
-				 */
-				if (!(smp_int_redirect & SMP_IRQ_REDIRECTION)) {
-					static int cpu_index = 0;
-
-					set_rte(vector, cpu_physical_id(cpu_index) & 0xffff);
-
-					cpu_index++;
-					if (cpu_index >= smp_num_cpus)
-						cpu_index = 0;
-				} else {
-					/*
-					 * Direct the interrupt vector to the current cpu,
-					 * platform redirection will distribute them.
-					 */
-					set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
-				}
-#else
-				/* direct the interrupt vector to the running cpu id */
-				set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
-#endif
-			}
-		}
-		/*
-		 * Nothing to fixup
-		 * Fix out-of-range IRQ numbers
-		 */
-		if (dev->irq >= IA64_NUM_VECTORS)
-			dev->irq = 15;	/* Spurious interrupts */
+		iosapic_alloc_irq(dev);
 	}
 }
--- david-020722/include/asm-ia64/iosapic.h	Fri Nov  9 14:26:17 2001
+++ david-020722-pcihp/include/asm-ia64/iosapic.h	Mon Jul 29 18:03:59 2002
@@ -51,8 +51,9 @@
 
 #ifndef __ASSEMBLY__
 
-extern void __init iosapic_init (unsigned long address, unsigned int base_irq,
-                                 int pcat_compat);
+extern void __devinit iosapic_init (unsigned long address,
+				    unsigned int base_irq, int pcat_compat);
+extern void iosapic_alloc_irq (struct pci_dev *dev);
 extern int iosapic_register_irq (u32 global_vector, unsigned long polarity,
                                  unsigned long edge_triggered, u32 base_irq,
                                  char *iosapic_address);



Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


