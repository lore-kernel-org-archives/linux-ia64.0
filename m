From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Tue, 06 Aug 2002 00:34:41 +0000
Subject: [Linux-ia64] IOSAPIC cleanup and bugfixes patch
Message-Id: <marc-linux-ia64-105590701905911@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

Here's a patch for iosapic.c name cleanup and bugfixes.

During the cleanup, I found another bug in iosapic.c.

If you echo "r xx" > /proc/irq/yy/smp_affinity, the redirection
is encoded in bit31 of `irq' in iosapic_set_affinity().
But the old code didn't care the bit31 and would call
set_irq_affinity_info() with bit31 on.  This may
lead to memory corruption.

This patch is generated against ia64 020722 patch and includes:

  1) cleanup irq/vector/pin terminology in iosapic.c

  2) 20_iosapic_gsi.diff from Bjorn (Jul.22)
    the old gsi_to_vector is obviously wrong and we have to
    remove it.

  3) 30_sci.diff from Bjorn (Jul.22) with slight changes
    ACPI assumed irq = vector, but this patch resolves this.

  4) dynamic vector allocation patch from me (Jul.29)
    allocates ia64 interrupt vector only for existing pci_dev's.

  5) legacy irq override patch from me (Aug.2)
    fix incorrect programming of IOSAPIC when ACPI MADT interrupt
    source override record points to other IOSAPIC than default one.

  6) fix for smp_affinity redirection bit

  7) Bjorn's cleanups for printk's

I'm sorry that a patch grew this big.
The fixes 2-7 are relatively independent, but (1) cleanup depends on
especially 2 and 3 and touches places for 4,5,6,7.
So I couldn't divide:)

diff -Nura david-020722/arch/ia64/kernel/acpi.c david-020722-iosapic/arch/ia64/kernel/acpi.c
--- david-020722/arch/ia64/kernel/acpi.c	Tue Jul 23 16:01:24 2002
+++ david-020722-iosapic/arch/ia64/kernel/acpi.c	Mon Aug  5 14:57:29 2002
@@ -47,9 +47,9 @@
 
 #define PREFIX			"ACPI: "
 
-asm (".weak iosapic_register_irq");
-asm (".weak iosapic_register_legacy_irq");
-asm (".weak iosapic_register_platform_irq");
+asm (".weak iosapic_register_intr");
+asm (".weak iosapic_override_isa_irq");
+asm (".weak iosapic_register_platform_intr");
 asm (".weak iosapic_init");
 asm (".weak iosapic_version");
 
@@ -173,10 +173,10 @@
 
 #ifdef CONFIG_ACPI_BOOT
 
-#define ACPI_MAX_PLATFORM_IRQS	256
+#define ACPI_MAX_PLATFORM_INTERRUPTS	256
 
 /* Array to record platform interrupt vectors for generic interrupt routing. */
-int platform_irq_list[ACPI_MAX_PLATFORM_IRQS];
+int platform_intr_list[ACPI_MAX_PLATFORM_INTERRUPTS];
 
 enum acpi_irq_model_id acpi_irq_model = ACPI_IRQ_MODEL_IOSAPIC;
 
@@ -189,9 +189,9 @@
 {
 	int vector = -1;
 
-	if (int_type < ACPI_MAX_PLATFORM_IRQS) {
+	if (int_type < ACPI_MAX_PLATFORM_INTERRUPTS) {
 		/* correctable platform error interrupt */
-		vector = platform_irq_list[int_type];
+		vector = platform_intr_list[int_type];
 	} else
 		printk("acpi_request_vector(): invalid interrupt type\n");
 
@@ -213,6 +213,7 @@
 static int			total_cpus __initdata;
 static int			available_cpus __initdata;
 struct acpi_table_madt *	acpi_madt __initdata;
+static u8			has_8259;
 
 
 static int __init
@@ -289,7 +290,7 @@
 
 
 static int __init
-acpi_find_iosapic (int global_vector, u32 *irq_base, char **iosapic_address)
+acpi_find_iosapic (unsigned int gsi, u32 *gsi_base, char **iosapic_address)
 {
 	struct acpi_table_iosapic *iosapic = NULL;
 	int ver = 0;
@@ -297,7 +298,7 @@
 	char *p = 0;
 	char *end = 0;
 
-	if (!irq_base || !iosapic_address)
+	if (!gsi_base || !iosapic_address)
 		return -ENODEV;
 
 	p = (char *) (acpi_madt + 1);
@@ -307,13 +308,13 @@
 		if (*p = ACPI_MADT_IOSAPIC) {
 			iosapic = (struct acpi_table_iosapic *) p;
 
-			*irq_base = iosapic->global_irq_base;
+			*gsi_base = iosapic->global_irq_base;
 			*iosapic_address = ioremap(iosapic->address, 0);
 
 			ver = iosapic_version(*iosapic_address);
 			max_pin = (ver >> 16) & 0xff;
 
-			if ((global_vector - *irq_base) <= max_pin)
+			if ((gsi - *gsi_base) <= max_pin)
 				return 0;	/* Found it! */
 		}
 		p += p[1];
@@ -352,7 +353,7 @@
 {
 	struct acpi_table_plat_int_src *plintsrc = NULL;
 	int vector = 0;
-	u32 irq_base = 0;
+	u32 gsi_base = 0;
 	char *iosapic_address = NULL;
 
 	plintsrc = (struct acpi_table_plat_int_src *) header;
@@ -361,31 +362,31 @@
 
 	acpi_table_print_madt_entry(header);
 
-	if (!iosapic_register_platform_irq) {
-		printk(KERN_WARNING PREFIX "No ACPI platform IRQ support\n");
+	if (!iosapic_register_platform_intr) {
+		printk(KERN_WARNING PREFIX "No ACPI platform interrupt support\n");
 		return -ENODEV;
 	}
 
-	if (0 != acpi_find_iosapic(plintsrc->global_irq, &irq_base, &iosapic_address)) {
+	if (0 != acpi_find_iosapic(plintsrc->global_irq, &gsi_base, &iosapic_address)) {
 		printk(KERN_WARNING PREFIX "IOSAPIC not found\n");
 		return -ENODEV;
 	}
 
 	/*
-	 * Get vector assignment for this IRQ, set attributes, and program the
-	 * IOSAPIC routing table.
+	 * Get vector assignment for this interrupt, set attributes,
+	 * and program the IOSAPIC routing table.
 	 */
-	vector = iosapic_register_platform_irq (plintsrc->type,
-						plintsrc->global_irq,
-						plintsrc->iosapic_vector,
-						plintsrc->eid,
-						plintsrc->id,
-						(plintsrc->flags.polarity = 1) ? 1 : 0,
-						(plintsrc->flags.trigger = 1) ? 1 : 0,
-						irq_base,
-						iosapic_address);
+	vector = iosapic_register_platform_intr (plintsrc->type,
+						 plintsrc->global_irq,
+						 plintsrc->iosapic_vector,
+						 plintsrc->eid,
+						 plintsrc->id,
+						 (plintsrc->flags.polarity = 1) ? 1 : 0,
+						 (plintsrc->flags.trigger = 1) ? 1 : 0,
+						 gsi_base,
+						 iosapic_address);
 
-	platform_irq_list[plintsrc->type] = vector;
+	platform_intr_list[plintsrc->type] = vector;
 	return 0;
 }
 
@@ -402,10 +403,10 @@
 	acpi_table_print_madt_entry(header);
 
 	/* Ignore if the platform doesn't support overrides */
-	if (!iosapic_register_legacy_irq)
+	if (!iosapic_override_isa_irq)
 		return 0;
 
-	iosapic_register_legacy_irq(p->bus_irq, p->global_irq,
+	iosapic_override_isa_irq(p->bus_irq, p->global_irq,
 		(p->flags.polarity = 1) ? 1 : 0,
 		(p->flags.trigger = 1) ? 1 : 0);
 
@@ -444,10 +445,13 @@
 		return -ENODEV;
 	}
 
+	/* remember the value for reference after free_initmem() */
+	has_8259 = acpi_madt->flags.pcat_compat;
+
 	/* Initialize platform interrupt vector array */
 
-	for (i = 0; i < ACPI_MAX_PLATFORM_IRQS; i++)
-		platform_irq_list[i] = -1;
+	for (i = 0; i < ACPI_MAX_PLATFORM_INTERRUPTS; i++)
+		platform_intr_list[i] = -1;
 
 	/* Get base address of IPI Message Block */
 
@@ -461,6 +465,39 @@
 }
 
 
+static int __init
+acpi_parse_facp (unsigned long phys_addr, unsigned long size)
+{
+	struct acpi_table_header *facp_header;
+	fadt_descriptor_rev2 *facp;
+	u32 sci_irq, gsi_base = 0;
+	char *iosapic_address = NULL;
+
+	if (!phys_addr || !size)
+		return -EINVAL;
+
+	if (!iosapic_register_intr)
+		return -ENODEV;
+
+	facp_header = (struct acpi_table_header *) __va(phys_addr);
+
+	/* Only deal with ACPI 2.0 FACP */
+	if (facp_header->revision != 3)
+		return -ENODEV;
+
+	facp = (fadt_descriptor_rev2 *)facp_header;
+	sci_irq = facp->sci_int;
+
+	if (has_8259 && sci_irq < 16)
+		return 0;	/* legacy, no setup required */
+
+	if (!acpi_find_iosapic(sci_irq, &gsi_base, &iosapic_address))
+		iosapic_register_intr(sci_irq, 0, 0, gsi_base, iosapic_address);
+
+	return 0;
+}
+
+
 unsigned long __init
 acpi_find_rsdp (void)
 {
@@ -485,12 +522,12 @@
 acpi_parse_spcr (unsigned long phys_addr, unsigned long size)
 {
 	acpi_ser_t *spcr = NULL;
-	unsigned long global_int = 0;
+	unsigned int gsi = 0;
 
 	if (!phys_addr || !size)
 		return -EINVAL;
 
-	if (!iosapic_register_irq)
+	if (!iosapic_register_intr)
 		return -ENODEV;
 
 	/*
@@ -517,22 +554,22 @@
 	if ((spcr->base_addr.space_id != ACPI_SERIAL_PCICONF_SPACE) &&
 	    (spcr->int_type = ACPI_SERIAL_INT_SAPIC))
 	{
-		u32 irq_base = 0;
+		u32 gsi_base = 0;
 		char *iosapic_address = NULL;
 		int vector = 0;
 
 		/* We have a UART in memory space with an SAPIC interrupt */
 
-		global_int = (  (spcr->global_int[3] << 24) |
-				(spcr->global_int[2] << 16) |
-				(spcr->global_int[1] << 8)  |
-				(spcr->global_int[0])  );
-
-		/* Which iosapic does this IRQ belong to? */
-
-		if (0 = acpi_find_iosapic(global_int, &irq_base, &iosapic_address)) {
-			vector = iosapic_register_irq (global_int, 1, 1,
-						       irq_base, iosapic_address);
+		gsi = (  (spcr->global_int[3] << 24) |
+			 (spcr->global_int[2] << 16) |
+			 (spcr->global_int[1] << 8)  |
+			 (spcr->global_int[0])  );
+
+		/* Which iosapic does this interrupt belong to? */
+
+		if (0 = acpi_find_iosapic(gsi, &gsi_base, &iosapic_address)) {
+			vector = iosapic_register_intr (gsi, 1, 1,
+						       gsi_base, iosapic_address);
 		}
 	}
 	return 0;
@@ -611,6 +648,13 @@
 		return result;
 	}
 
+	/*
+	 * The FADT table contains an SCI_INT line, by which the system
+	 * gets interrupts such as power and sleep buttons.  If it's not
+	 * on a Legacy interrupt, it needs to be setup.
+	 */
+	acpi_table_parse(ACPI_FACP, acpi_parse_facp);
+
 #ifdef CONFIG_SERIAL_ACPI
 	/*
 	 * TBD: Need phased approach to table parsing (only do those absolutely
@@ -654,7 +698,7 @@
 	*count = 0;
 
 	if (acpi_prt.count < 0) {
-		printk(KERN_ERR PREFIX "No PCI IRQ routing entries\n");
+		printk(KERN_ERR PREFIX "No PCI interrupt routing entries\n");
 		return -ENODEV;
 	}
 
@@ -693,4 +737,13 @@
         return 0;
 }
 
+int
+acpi_irq_to_vector(u32 irq)
+{
+	if (has_8259 && irq < 16)
+		return isa_irq_to_vector(irq);
+
+	return gsi_to_vector(irq);
+}
+
 #endif /* CONFIG_ACPI_BOOT */
diff -Nura david-020722/arch/ia64/kernel/ia64_ksyms.c david-020722-iosapic/arch/ia64/kernel/ia64_ksyms.c
--- david-020722/arch/ia64/kernel/ia64_ksyms.c	Tue Jul 23 16:01:24 2002
+++ david-020722-iosapic/arch/ia64/kernel/ia64_ksyms.c	Mon Aug  5 13:26:22 2002
@@ -28,7 +28,6 @@
 
 #include <linux/irq.h>
 EXPORT_SYMBOL(isa_irq_to_vector_map);
-EXPORT_SYMBOL(gsi_to_vector_map);
 EXPORT_SYMBOL(enable_irq);
 EXPORT_SYMBOL(disable_irq);
 EXPORT_SYMBOL(disable_irq_nosync);
diff -Nura david-020722/arch/ia64/kernel/iosapic.c david-020722-iosapic/arch/ia64/kernel/iosapic.c
--- david-020722/arch/ia64/kernel/iosapic.c	Tue Jul 23 16:01:24 2002
+++ david-020722-iosapic/arch/ia64/kernel/iosapic.c	Mon Aug  5 16:16:23 2002
@@ -25,6 +25,8 @@
  * 02/04/02	P. Diefenbaugh	Cleaned up ACPI PCI IRQ routing.
  * 02/04/18	J.I. Lee	bug fix in iosapic_init_pci_irq
  * 02/04/30	J.I. Lee	bug fix in find_iosapic to fix ACPI PCI IRQ to IOSAPIC mapping error
+ * 02/07/29	T. Kochi	Allocate interrupt vectors dynamically
+ * 02/08/04	T. Kochi	Cleaned up terminology (irq, global system interrupt, vector, etc.)
  */
 /*
  * Here is what the interrupt logic between a PCI device and the CPU looks like:
@@ -36,19 +38,20 @@
  *
  * (2) The motherboard routes the interrupt line to a pin on a IOSAPIC controller.
  *     Multiple interrupt lines may have to share the same IOSAPIC pin (if they're level
- *     triggered and use the same polarity).  Each interrupt line has a unique IOSAPIC
- *     irq number which can be calculated as the sum of the controller's base irq number
- *     and the IOSAPIC pin number to which the line connects.
+ *     triggered and use the same polarity).  Each interrupt line has a unique Global
+ *     System Interrupt (GSI) number which can be calculated as the sum of the controller's
+ *     base GSI number and the IOSAPIC pin number to which the line connects.
  *
- * (3) The IOSAPIC uses an internal table to map the IOSAPIC pin into the IA-64 interrupt
- *     vector.  This interrupt vector is then sent to the CPU.
+ * (3) The IOSAPIC uses an internal routing table entries (RTEs) to map the IOSAPIC pin
+ *     into the IA-64 interrupt vector.  This interrupt vector is then sent to the CPU.
  *
  * In other words, there are two levels of indirections involved:
  *
- *	pci pin -> iosapic irq -> IA-64 vector
+ *	pci pin -> global system interrupt (GSI) -> IA-64 vector
  *
- * Note: outside this module, IA-64 vectors are called "irqs".  This is because that's
- * the traditional name Linux uses for interrupt vectors.
+ * Note: outside this module, IA-64 vectors are called "irqs".  This is because
+ *       we chose one-to-one mapping between "irqs" and "IA-64 vectors" and
+ *       "IRQ" is the traditional name Linux uses for interrupt requests.
  */
 #include <linux/config.h>
 
@@ -71,49 +74,55 @@
 #include <asm/system.h>
 
 
-#undef DEBUG_IRQ_ROUTING
+#undef DEBUG_INTERRUPT_ROUTING
 #undef OVERRIDE_DEBUG
 
+#ifdef DEBUG_INTERRUPT_ROUTING
+#define DBG(fmt...)	printk(fmt)
+#else
+#define DBG(fmt...)
+#endif
+
 static spinlock_t iosapic_lock = SPIN_LOCK_UNLOCKED;
 
-/* PCI pin to IOSAPIC irq routing information.  This info typically comes from ACPI. */
+/* PCI pin to GSI routing information.  This info typically comes from ACPI. */
 
 static struct {
 	int num_routes;
 	struct pci_vector_struct *route;
 } pci_irq;
 
-/* This tables maps IA-64 vectors to the IOSAPIC pin that generates this vector. */
+/* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
 
-static struct iosapic_irq {
-	char *addr;			/* base address of IOSAPIC */
-	unsigned int base_irq;		/* first irq assigned to this IOSAPIC */
-	char pin;			/* IOSAPIC pin (-1 => not an IOSAPIC irq) */
-	unsigned char dmode	: 3;	/* delivery mode (see iosapic.h) */
-	unsigned char polarity	: 1;	/* interrupt polarity (see iosapic.h) */
-	unsigned char trigger	: 1;	/* trigger mode (see iosapic.h) */
-} iosapic_irq[IA64_NUM_VECTORS];
+static struct iosapic_intr_info {
+	char		*addr;		/* base address of IOSAPIC */
+	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
+	char		rte_index;	/* IOSAPIC RTE index (-1 => not an IOSAPIC interrupt) */
+	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
+	unsigned char 	polarity: 1;	/* interrupt polarity (see iosapic.h) */
+	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
+} iosapic_intr_info[IA64_NUM_VECTORS];
 
 static struct iosapic {
-	char *addr;			/* base address of IOSAPIC */
-	unsigned int 	base_irq;	/* first irq assigned to this IOSAPIC */
-	unsigned short 	max_pin;	/* max input pin supported in this IOSAPIC */
+	char		*addr;		/* base address of IOSAPIC */
+	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
+	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
 	unsigned char	pcat_compat;	/* 8259 compatibility flag */
-} iosapic_lists[256] __initdata;
+} iosapic_lists[256] __devinitdata;
 
 static int num_iosapic = 0;
 
 
 /*
- * Find an IOSAPIC associated with an IRQ
+ * Find an IOSAPIC associated with a GSI
  */
-static inline int __init
-find_iosapic (unsigned int irq)
+static inline int __devinit
+find_iosapic (unsigned int gsi)
 {
 	int i;
 
 	for (i = 0; i < num_iosapic; i++) {
-		if ((unsigned) (irq - iosapic_lists[i].base_irq) <= iosapic_lists[i].max_pin)
+		if ((unsigned) (gsi - iosapic_lists[i].gsi_base) < iosapic_lists[i].num_rte)
 			return i;
 	}
 
@@ -121,56 +130,49 @@
 }
 
 /*
- * Translate IOSAPIC irq number to the corresponding IA-64 interrupt vector.  If no
+ * Translate GSI number to the corresponding IA-64 interrupt vector.  If no
  * entry exists, return -1.
  */
-static int
-iosapic_irq_to_vector (int irq)
+int
+gsi_to_vector (unsigned int gsi)
 {
 	int vector;
 
 	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
-		if (iosapic_irq[vector].base_irq + iosapic_irq[vector].pin = irq)
+		if (iosapic_intr_info[vector].gsi_base + iosapic_intr_info[vector].rte_index = gsi)
 			return vector;
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
-set_rte (unsigned int vector, unsigned long dest)
+set_rte (unsigned int vector, unsigned int dest)
 {
 	unsigned long pol, trigger, dmode;
 	u32 low32, high32;
 	char *addr;
-	int pin;
+	int rte_index;
 	char redir;
 
-	pin = iosapic_irq[vector].pin;
-	if (pin < 0)
+	rte_index = iosapic_intr_info[vector].rte_index;
+	if (rte_index < 0)
 		return;		/* not an IOSAPIC interrupt */
 
-	addr    = iosapic_irq[vector].addr;
-	pol     = iosapic_irq[vector].polarity;
-	trigger = iosapic_irq[vector].trigger;
-	dmode   = iosapic_irq[vector].dmode;
+	addr    = iosapic_intr_info[vector].addr;
+	pol     = iosapic_intr_info[vector].polarity;
+	trigger = iosapic_intr_info[vector].trigger;
+	dmode   = iosapic_intr_info[vector].dmode;
 
 	redir = (dmode = IOSAPIC_LOWEST_PRIORITY) ? 1 : 0;
 #ifdef CONFIG_SMP
-	set_irq_affinity_info(vector, (int)(dest & 0xffff), redir);
+	{
+		int irq;
+
+		for (irq = 0; irq < NR_IRQS; ++irq)
+			if (irq_to_vector(irq) = vector) {
+				set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);
+				break;
+			}
+	}
 #endif
 
 	low32 = ((pol << IOSAPIC_POLARITY_SHIFT) |
@@ -181,9 +183,9 @@
 	/* dest contains both id and eid */
 	high32 = (dest << IOSAPIC_DEST_SHIFT);
 
-	writel(IOSAPIC_RTE_HIGH(pin), addr + IOSAPIC_REG_SELECT);
+	writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
 	writel(high32, addr + IOSAPIC_WINDOW);
-	writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+	writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 	writel(low32, addr + IOSAPIC_WINDOW);
 }
 
@@ -199,18 +201,18 @@
 	unsigned long flags;
 	char *addr;
 	u32 low32;
-	int pin;
+	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
 
-	addr = iosapic_irq[vec].addr;
-	pin = iosapic_irq[vec].pin;
+	addr = iosapic_intr_info[vec].addr;
+	rte_index = iosapic_intr_info[vec].rte_index;
 
-	if (pin < 0)
+	if (rte_index < 0)
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 		low32 = readl(addr + IOSAPIC_WINDOW);
 
 		low32 |= (1 << IOSAPIC_MASK_SHIFT);    /* set only the mask bit */
@@ -225,17 +227,17 @@
 	unsigned long flags;
 	char *addr;
 	u32 low32;
-	int pin;
+	int rte_index;
 	ia64_vector vec = irq_to_vector(irq);
 
-	addr = iosapic_irq[vec].addr;
-	pin = iosapic_irq[vec].pin;
-	if (pin < 0)
+	addr = iosapic_intr_info[vec].addr;
+	rte_index = iosapic_intr_info[vec].rte_index;
+	if (rte_index < 0)
 		return;			/* not an IOSAPIC interrupt! */
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 		low32 = readl(addr + IOSAPIC_WINDOW);
 
 		low32 &= ~(1 << IOSAPIC_MASK_SHIFT);    /* clear only the mask bit */
@@ -251,24 +253,28 @@
 #ifdef CONFIG_SMP
 	unsigned long flags;
 	u32 high32, low32;
-	int dest, pin;
+	int dest, rte_index;
 	char *addr;
-	int redir = (irq & (1<<31)) ? 1 : 0;
+	int redir = (irq & IA64_IRQ_REDIRECTED) ? 1 : 0;
+	ia64_vector vec;
+
+	irq &= (~IA64_IRQ_REDIRECTED);
+	vec = irq_to_vector(irq);
 
 	mask &= (1UL << smp_num_cpus) - 1;
 
-	if (!mask || irq >= IA64_NUM_VECTORS)
+	if (!mask || vec >= IA64_NUM_VECTORS)
 		return;
 
 	dest = cpu_physical_id(ffz(~mask));
 
-	pin = iosapic_irq[irq].pin;
-	addr = iosapic_irq[irq].addr;
+	rte_index = iosapic_intr_info[vec].rte_index;
+	addr = iosapic_intr_info[vec].addr;
 
-	if (pin < 0)
+	if (rte_index < 0)
 		return;			/* not an IOSAPIC interrupt */
 
-	set_irq_affinity_info(irq,dest,redir);
+	set_irq_affinity_info(irq, dest, redir);
 
 	/* dest contains both id and eid */
 	high32 = dest << IOSAPIC_DEST_SHIFT;
@@ -276,7 +282,7 @@
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		/* get current delivery mode by reading the low32 */
-		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 		low32 = readl(addr + IOSAPIC_WINDOW);
 
 		low32 &= ~(7 << IOSAPIC_DELIVERY_SHIFT);
@@ -287,9 +293,9 @@
 		        /* change delivery mode to fixed */
 			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
-		writel(IOSAPIC_RTE_HIGH(pin), addr + IOSAPIC_REG_SELECT);
+		writel(IOSAPIC_RTE_HIGH(rte_index), addr + IOSAPIC_REG_SELECT);
 		writel(high32, addr + IOSAPIC_WINDOW);
-		writel(IOSAPIC_RTE_LOW(pin), addr + IOSAPIC_REG_SELECT);
+		writel(IOSAPIC_RTE_LOW(rte_index), addr + IOSAPIC_REG_SELECT);
 		writel(low32, addr + IOSAPIC_WINDOW);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
@@ -312,7 +318,7 @@
 {
 	ia64_vector vec = irq_to_vector(irq);
 
-	writel(vec, iosapic_irq[vec].addr + IOSAPIC_EOI);
+	writel(vec, iosapic_intr_info[vec].addr + IOSAPIC_EOI);
 }
 
 #define iosapic_shutdown_level_irq	mask_irq
@@ -383,7 +389,7 @@
 	 * {
 	 *	unsigned int version   : 8;
 	 *	unsigned int reserved1 : 8;
-	 *	unsigned int pins      : 8;
+	 *	unsigned int max_redir : 8;
 	 *	unsigned int reserved2 : 8;
 	 * }
 	 */
@@ -400,70 +406,72 @@
 {
 	int new_vector;
 
-	if (iosapic_irq[vector].pin >= 0 || iosapic_irq[vector].addr
-	    || iosapic_irq[vector].base_irq || iosapic_irq[vector].dmode
-	    || iosapic_irq[vector].polarity || iosapic_irq[vector].trigger)
+	if (iosapic_intr_info[vector].rte_index >= 0 || iosapic_intr_info[vector].addr
+	    || iosapic_intr_info[vector].gsi_base || iosapic_intr_info[vector].dmode
+	    || iosapic_intr_info[vector].polarity || iosapic_intr_info[vector].trigger)
 	{
-		new_vector = ia64_alloc_irq();
-		printk("Reassigning Vector 0x%x to 0x%x\n", vector, new_vector);
-		memcpy (&iosapic_irq[new_vector], &iosapic_irq[vector],
-			sizeof(struct iosapic_irq));
-		memset (&iosapic_irq[vector], 0, sizeof(struct iosapic_irq));
-		iosapic_irq[vector].pin = -1;
+		new_vector = ia64_alloc_vector();
+		printk("Reassigning Vector %d to %d\n", vector, new_vector);
+		memcpy (&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
+			sizeof(struct iosapic_intr_info));
+		memset (&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
+		iosapic_intr_info[vector].rte_index = -1;
 	}
 }
 
 static void
-register_irq (u32 global_vector, int vector, int pin, unsigned char delivery,
-	      unsigned long polarity, unsigned long edge_triggered,
-	      u32 base_irq, char *iosapic_address)
+register_intr (unsigned int gsi, int vector, unsigned char delivery,
+	       unsigned long polarity, unsigned long edge_triggered,
+	       unsigned int gsi_base, char *iosapic_address)
 {
 	irq_desc_t *idesc;
 	struct hw_interrupt_type *irq_type;
+	int rte_index;
 
-	gsi_to_vector(global_vector) = vector;
-	iosapic_irq[vector].pin	= pin;
-	iosapic_irq[vector].polarity = polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW;
-	iosapic_irq[vector].dmode    = delivery;
+	rte_index = gsi - gsi_base;
+	iosapic_intr_info[vector].rte_index = rte_index;
+	iosapic_intr_info[vector].polarity = polarity ? IOSAPIC_POL_HIGH : IOSAPIC_POL_LOW;
+	iosapic_intr_info[vector].dmode    = delivery;
 
 	/*
-	 * In override, it does not provide addr/base_irq.  global_vector is enough to
-	 * locate iosapic addr, base_irq and pin by examining base_irq and max_pin of
-	 * registered iosapics (tbd)
+	 * In override, it may not provide addr/gsi_base.  GSI is enough to
+	 * locate iosapic addr, gsi_base and rte_index by examining
+	 * gsi_base and num_rte of registered iosapics (tbd)
 	 */
 #ifndef	OVERRIDE_DEBUG
 	if (iosapic_address) {
-		iosapic_irq[vector].addr = iosapic_address;
-		iosapic_irq[vector].base_irq = base_irq;
+		iosapic_intr_info[vector].addr = iosapic_address;
+		iosapic_intr_info[vector].gsi_base = gsi_base;
 	}
 #else
 	if (iosapic_address) {
-		if (iosapic_irq[vector].addr && (iosapic_irq[vector].addr != iosapic_address))
-			printk("WARN: register_irq: diff IOSAPIC ADDRESS for gv %x, v %x\n",
-			       global_vector, vector);
-		iosapic_irq[vector].addr = iosapic_address;
-		if (iosapic_irq[vector].base_irq && (iosapic_irq[vector].base_irq != base_irq)) {
-			printk("WARN: register_irq: diff BASE IRQ %x for gv %x, v %x\n",
-			       base_irq, global_vector, vector);
+		if (iosapic_intr_info[vector].addr && (iosapic_intr_info[vector].addr != iosapic_address))
+			printk("WARN: register_intr: diff IOSAPIC ADDRESS for GSI 0x%x, vector %d\n",
+			       gsi, vector);
+		iosapic_intr_info[vector].addr = iosapic_address;
+		if (iosapic_intr_info[vector].gsi_base && (iosapic_intr_info[vector].gsi_base != gsi_base)) {
+			printk("WARN: register_intr: diff GSI base 0x%x for GSI 0x%x, vector %d\n",
+			       gsi_base, gsi, vector);
 		}
-		iosapic_irq[vector].base_irq = base_irq;
-	} else if (!iosapic_irq[vector].addr)
-		printk("WARN: register_irq: invalid override for gv %x, v %x\n",
-		       global_vector, vector);
+		iosapic_intr_info[vector].gsi_base = gsi_base;
+	} else if (!iosapic_intr_info[vector].addr)
+		printk("WARN: register_intr: invalid override for GSI 0x%x, vector %d\n",
+		       gsi, vector);
 #endif
 	if (edge_triggered) {
-		iosapic_irq[vector].trigger = IOSAPIC_EDGE;
+		iosapic_intr_info[vector].trigger = IOSAPIC_EDGE;
 		irq_type = &irq_type_iosapic_edge;
 	} else {
-		iosapic_irq[vector].trigger = IOSAPIC_LEVEL;
+		iosapic_intr_info[vector].trigger = IOSAPIC_LEVEL;
 		irq_type = &irq_type_iosapic_level;
 	}
 
 	idesc = irq_desc(vector);
 	if (idesc->handler != irq_type) {
 		if (idesc->handler != &no_irq_type)
-			printk("register_irq(): changing vector 0x%02x from "
-			       "%s to %s\n", vector, idesc->handler->typename, irq_type->typename);
+			printk("%s: changing vector %d from %s to %s\n",
+			       __FUNCTION__, vector, idesc->handler->typename,
+			       irq_type->typename);
 		idesc->handler = irq_type;
 	}
 }
@@ -474,24 +482,26 @@
  * program the IOSAPIC RTE.
  */
 int
-iosapic_register_irq (u32 global_vector, unsigned long polarity, unsigned long
-                      edge_triggered, u32 base_irq, char *iosapic_address)
+iosapic_register_intr (unsigned int gsi,
+		       unsigned long polarity, unsigned long edge_triggered,
+		       unsigned int gsi_base, char *iosapic_address)
 {
 	int vector;
+	unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
 
-	vector = iosapic_irq_to_vector(global_vector);
+	vector = gsi_to_vector(gsi);
 	if (vector < 0)
-		vector = ia64_alloc_irq();
+		vector = ia64_alloc_vector();
 
-	register_irq (global_vector, vector, global_vector - base_irq,
-			IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered,
-			base_irq, iosapic_address);
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+		      polarity, edge_triggered, gsi_base, iosapic_address);
 
-	printk("IOSAPIC 0x%x(%s,%s) -> Vector 0x%x\n", global_vector,
-	       (polarity ? "high" : "low"), (edge_triggered ? "edge" : "level"), vector);
+	printk("GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
+	       gsi, (polarity ? "high" : "low"),
+	       (edge_triggered ? "edge" : "level"), dest, vector);
 
 	/* program the IOSAPIC routing table */
-	set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+	set_rte(vector, dest);
 	return vector;
 }
 
@@ -500,12 +510,14 @@
  * Note that the irq_base and IOSAPIC address must be set in iosapic_init().
  */
 int
-iosapic_register_platform_irq (u32 int_type, u32 global_vector,
-			       u32 iosapic_vector, u16 eid, u16 id, unsigned long polarity,
-			       unsigned long edge_triggered, u32 base_irq, char *iosapic_address)
+iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
+				int iosapic_vector, u16 eid, u16 id,
+				unsigned long polarity, unsigned long edge_triggered,
+				unsigned int gsi_base, char *iosapic_address)
 {
 	unsigned char delivery;
 	int vector;
+	unsigned int dest = ((id << 8) | eid) & 0xffff;
 
 	switch (int_type) {
 	      case ACPI_INTERRUPT_PMI:
@@ -518,7 +530,7 @@
 		delivery = IOSAPIC_PMI;
 		break;
 	      case ACPI_INTERRUPT_INIT:
-		vector = ia64_alloc_irq();
+		vector = ia64_alloc_vector();
 		delivery = IOSAPIC_INIT;
 		break;
 	      case ACPI_INTERRUPT_CPEI:
@@ -530,56 +542,137 @@
 		return -1;
 	}
 
-	register_irq(global_vector, vector, global_vector - base_irq, delivery, polarity,
-		     edge_triggered, base_irq, iosapic_address);
+	register_intr(gsi, vector, delivery, polarity,
+		      edge_triggered, gsi_base, iosapic_address);
 
-	printk("PLATFORM int 0x%x: IOSAPIC 0x%x(%s,%s) -> Vector 0x%x CPU %.02u:%.02u\n",
-	       int_type, global_vector, (polarity ? "high" : "low"),
-	       (edge_triggered ? "edge" : "level"), vector, eid, id);
+	printk("PLATFORM int 0x%x: GSI 0x%x(%s,%s) -> CPU 0x%04x vector %d\n",
+	       int_type, gsi, (polarity ? "high" : "low"),
+	       (edge_triggered ? "edge" : "level"), dest, vector);
 
 	/* program the IOSAPIC routing table */
-	set_rte(vector, ((id << 8) | eid) & 0xffff);
+	set_rte(vector, dest);
 	return vector;
 }
 
 
 /*
- * ACPI calls this when it finds an entry for a legacy ISA interrupt.
- * Note that the irq_base and IOSAPIC address must be set in iosapic_init().
+ * ACPI calls this when it finds an entry for a legacy ISA IRQ override.
+ * Note that the gsi_base and IOSAPIC address must be set in iosapic_init().
  */
 void
-iosapic_register_legacy_irq (unsigned long irq,
-			     unsigned long pin, unsigned long polarity,
-			     unsigned long edge_triggered)
-{
-	int vector = isa_irq_to_vector(irq);
-
-	register_irq(irq, vector, (int)pin, IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered,
-		     0, NULL);		/* ignored for override */
-
-#ifdef DEBUG_IRQ_ROUTING
-	printk("ISA: IRQ %u -> IOSAPIC irq 0x%02x (%s, %s) -> vector %02x\n",
-	       (unsigned) irq, (unsigned) pin,
-	       polarity ? "high" : "low", edge_triggered ? "edge" : "level",
-	       vector);
-#endif
+iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
+			  unsigned long polarity,
+			  unsigned long edge_triggered)
+{
+	int index, vector;
+	unsigned int gsi_base;
+	char *addr;
+	unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
+
+	index = find_iosapic(gsi);
+
+	if (index < 0) {
+		printk("ISA: No corresponding IOSAPIC found : ISA IRQ %u -> GSI 0x%x\n", isa_irq, gsi);
+		return;
+	}
+
+	vector = isa_irq_to_vector(isa_irq);
+	addr = iosapic_lists[index].addr;
+	gsi_base = iosapic_lists[index].gsi_base;
+
+	register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY, polarity, edge_triggered,
+		      gsi_base, addr);
+
+	DBG("ISA: IRQ %u -> GSI 0x%x (%s,%s) -> CPU 0x%04x vector %d\n",
+	    isa_irq, global_vector,
+	    polarity ? "high" : "low", edge_triggered ? "edge" : "level",
+	    dest, vector);
 
 	/* program the IOSAPIC routing table */
-	set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+	set_rte(vector, dest);
+}
+
+/*
+ * Map PCI pin to the corresponding GSI.
+ * If no such mapping exists, return -1.
+ */
+static int
+pci_pin_to_gsi (int bus, int slot, int pci_pin, unsigned int *gsi)
+{
+	struct pci_vector_struct *r;
+
+	for (r = pci_irq.route; r < pci_irq.route + pci_irq.num_routes; ++r)
+		if (r->bus = bus &&
+		    (r->pci_id >> 16) = slot && r->pin = pci_pin) {
+			*gsi = r->irq;
+			return 0;
+		}
+
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
+	int index, vector;
+	int gsi_base, pcat_compat;
+	char *addr;
+	unsigned int gsi;
+
+	if (pci_pin_to_gsi(bus, slot, pci_pin, &gsi) < 0) {
+		printk("PCI: no interrupt route for %02x:%02x pin %c\n", bus, slot, 'A' + pci_pin);
+		return -1;
+	}
+
+	vector = gsi_to_vector(gsi);
+
+	if (vector < 0) {
+		/* we should allocate a vector for this interrupt line */
+
+		index = find_iosapic(gsi);
+
+		if (index < 0) {
+			printk("PCI: GSI 0x%x has no IOSAPIC mapping\n", gsi);
+			return -1;
+		}
+
+		addr = iosapic_lists[index].addr;
+		gsi_base = iosapic_lists[index].gsi_base;
+		pcat_compat = iosapic_lists[index].pcat_compat;
+
+		if (pcat_compat && (gsi < 16))
+			vector = isa_irq_to_vector(gsi);
+		else {
+			/* new GSI; allocate a vector for it */
+			vector = ia64_alloc_vector();
+		}
+
+		register_intr(gsi, vector, IOSAPIC_LOWEST_PRIORITY,
+			      0, 0, gsi_base, addr);
+
+		DBG("PCI: (%02x:%02x:%02x INT%c) -> GSI 0x%x -> vector %d\n",
+		    bus, slot, 'A' + pci_pin, gsi, vector);
+	}
+
+	return vector;
 }
 
-void __init
-iosapic_init (unsigned long phys_addr, unsigned int base_irq, int pcat_compat)
+void __devinit
+iosapic_init (unsigned long phys_addr, unsigned int gsi_base, int pcat_compat)
 {
-	int irq, max_pin, vector, pin;
-	unsigned int ver;
+	int num_rte, vector;
+	unsigned int isa_irq, ver;
 	char *addr;
 	static int first_time = 1;
 
 	if (first_time) {
 		first_time = 0;
 		for (vector = 0; vector < IA64_NUM_VECTORS; ++vector)
-			iosapic_irq[vector].pin = -1;	/* mark as unused */
+			iosapic_intr_info[vector].rte_index = -1;	/* mark as unused */
 	}
 
 	if (pcat_compat) {
@@ -594,109 +687,148 @@
 
 	addr = ioremap(phys_addr, 0);
 	ver = iosapic_version(addr);
-	max_pin = (ver >> 16) & 0xff;
+
+	/*
+	 * The MAX_REDIR register holds the highest input pin
+	 * number (starting from 0).
+	 * We add 1 so that we can use it for number of pins (= RTEs)
+	 */
+	num_rte = ((ver >> 16) & 0xff) + 1;
 
 	iosapic_lists[num_iosapic].addr = addr;
 	iosapic_lists[num_iosapic].pcat_compat = pcat_compat;
-	iosapic_lists[num_iosapic].base_irq = base_irq;
-	iosapic_lists[num_iosapic].max_pin = max_pin;
+	iosapic_lists[num_iosapic].gsi_base = gsi_base;
+	iosapic_lists[num_iosapic].num_rte = num_rte;
 	num_iosapic++;
 
-	printk("IOSAPIC: version %x.%x, address 0x%lx, IRQs 0x%02x-0x%02x\n",
-	       (ver & 0xf0) >> 4, (ver & 0x0f), phys_addr, base_irq, base_irq + max_pin);
+	printk("IOSAPIC: version %x.%x, address 0x%lx, GSIs 0x%x-0x%x\n",
+	       (ver & 0xf0) >> 4, (ver & 0x0f), phys_addr, gsi_base, gsi_base + num_rte - 1);
+
+	if ((gsi_base = 0) && pcat_compat) {
+		unsigned int dest = (ia64_get_lid() >> 16) & 0xffff;
 
-	if ((base_irq = 0) && pcat_compat) {
 		/*
 		 * Map the legacy ISA devices into the IOSAPIC data.  Some of these may
 		 * get reprogrammed later on with data from the ACPI Interrupt Source
 		 * Override table.
 		 */
-		for (irq = 0; irq < 16; ++irq) {
-			vector = isa_irq_to_vector(irq);
-			if ((pin = iosapic_irq[vector].pin) = -1)
-				pin = irq;
+		for (isa_irq = 0; isa_irq < 16; ++isa_irq) {
+			vector = isa_irq_to_vector(isa_irq);
 
-			register_irq(irq, vector, pin,
+			register_intr(isa_irq, vector, IOSAPIC_LOWEST_PRIORITY,
 				     /* IOSAPIC_POL_HIGH, IOSAPIC_EDGE */
-				     IOSAPIC_LOWEST_PRIORITY, 1, 1, base_irq, addr);
+				     1, 1, gsi_base, addr);
 
-#ifdef DEBUG_IRQ_ROUTING
-			printk("ISA: IRQ %u -> IOSAPIC irq 0x%02x (high, edge) -> vector 0x%02x\n",
-			       irq, iosapic_irq[vector].base_irq + iosapic_irq[vector].pin,
-			       vector);
-#endif
+			DBG("ISA: IRQ %u -> GSI 0x%x (high,edge) -> CPU 0x%04x vector %d\n",
+			    isa_irq, isa_irq, dest, vector);
 
 			/* program the IOSAPIC routing table: */
-			set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
+			set_rte(vector, dest);
 		}
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
 
-		irq = pci_irq.route[i].irq;
+/*
+ * Set allocated interrupt vector to dev->irq and
+ * program IOSAPIC to deliver interrupts
+ */
+void
+iosapic_fixup_pci_interrupt (struct pci_dev *dev)
+{
+	unsigned char pci_pin;
+	int vector;
+	unsigned int dest;
+	struct hw_interrupt_type *irq_type;
+	irq_desc_t *idesc;
 
-		index = find_iosapic(irq);
-		if (index < 0) {
-			printk("PCI: IRQ %u has no IOSAPIC mapping\n", irq);
-			continue;
+	pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &pci_pin);
+	if (pci_pin) {
+		pci_pin--; /* interrupt pins are numberd starting from 1 */
+
+		vector = pci_pin_to_vector(dev->bus->number, PCI_SLOT(dev->devfn), pci_pin);
+
+		if (vector < 0 && dev->bus->parent) {
+			/* go back to the bridge */
+			struct pci_dev *bridge = dev->bus->self;
+
+			if (bridge) {
+				/* allow for multiple bridges on an adapter */
+				do {
+					/* do the bridge swizzle... */
+					pci_pin = (pci_pin + PCI_SLOT(dev->devfn)) % 4;
+					vector = pci_pin_to_vector(bridge->bus->number,
+								   PCI_SLOT(bridge->devfn),
+								   pci_pin);
+				} while (vector < 0 && (bridge = bridge->bus->self));
+			}
+			if (vector >= 0)
+				printk(KERN_WARNING
+				       "PCI: using PPB (%s INT%c) to get vector %d\n",
+				       dev->slot_name, 'A' + pci_pin,
+				       vector);
+			else
+				printk(KERN_WARNING
+				       "PCI: Couldn't map irq for (%s INT%c)\n",
+				       dev->slot_name, 'A' + pci_pin);
 		}
 
-		addr = iosapic_lists[index].addr;
-		base_irq = iosapic_lists[index].base_irq;
-		max_pin = iosapic_lists[index].max_pin;
-		pcat_compat = iosapic_lists[index].pcat_compat;
-		pin = irq - base_irq;
+		if (vector >= 0) {
+			dev->irq = vector;
 
-		if ((unsigned) pin > max_pin)
-			/* the interrupt route is for another controller... */
-			continue;
+			irq_type = &irq_type_iosapic_level;
+			idesc = irq_desc(vector);
+			if (idesc->handler != irq_type) {
+				if (idesc->handler != &no_irq_type)
+					printk("%s: changing vector %d from %s to %s\n",
+					       __FUNCTION__, vector,
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
+				dest = cpu_physical_id(cpu_index) & 0xffff;
+
+				cpu_index++;
+				if (cpu_index >= smp_num_cpus)
+					cpu_index = 0;
+			} else {
+				/*
+				 * Direct the interrupt vector to the current cpu,
+				 * platform redirection will distribute them.
+				 */
+				dest = (ia64_get_lid() >> 16) & 0xffff;
+			}
+#else
+			/* direct the interrupt vector to the running cpu id */
+			dest = (ia64_get_lid() >> 16) & 0xffff;
+#endif
 
-		if (pcat_compat && (irq < 16))
-			vector = isa_irq_to_vector(irq);
-		else {
-			vector = iosapic_irq_to_vector(irq);
-			if (vector < 0)
-				/* new iosapic irq: allocate a vector for it */
-				vector = ia64_alloc_irq();
+			printk("PCI->APIC IRQ transform: (%s INT%c) -> CPU 0x%04x vector %d\n",
+			       dev->slot_name, 'A' + pci_pin, dest, vector);
+			set_rte(vector, dest);
 		}
-
-		register_irq(irq, vector, pin, IOSAPIC_LOWEST_PRIORITY, 0, 0, base_irq, addr);
-
-#ifdef DEBUG_IRQ_ROUTING
-		printk("PCI: (B%d,I%d,P%d) -> IOSAPIC irq 0x%02x -> vector 0x%02x\n",
-		       pci_irq.route[i].bus, pci_irq.route[i].pci_id>>16, pci_irq.route[i].pin,
-		       iosapic_irq[vector].base_irq + iosapic_irq[vector].pin, vector);
-#endif
-		/*
-		 * NOTE: The IOSAPIC RTE will be programmed in iosapic_pci_fixup().  It
-		 * needs to be done there to ensure PCI hotplug works right.
-		 */
 	}
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
 
@@ -704,76 +836,9 @@
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
+		/* fixup dev->irq and program IOSAPIC */
+		iosapic_fixup_pci_interrupt(dev);
 
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
 		/*
 		 * Nothing to fixup
 		 * Fix out-of-range IRQ numbers
diff -Nura david-020722/arch/ia64/kernel/irq.c david-020722-iosapic/arch/ia64/kernel/irq.c
--- david-020722/arch/ia64/kernel/irq.c	Tue Jul 23 16:01:24 2002
+++ david-020722-iosapic/arch/ia64/kernel/irq.c	Mon Aug  5 16:17:13 2002
@@ -1165,7 +1165,7 @@
 	if (!(new_value & cpu_online_map))
 		return -EINVAL;
 
-	irq_desc(irq)->handler->set_affinity(irq | (redir?(1<<31):0), new_value);
+	irq_desc(irq)->handler->set_affinity(irq | (redir? IA64_IRQ_REDIRECTED :0), new_value);
 
 	return full_count;
 }
diff -Nura david-020722/arch/ia64/kernel/irq_ia64.c david-020722-iosapic/arch/ia64/kernel/irq_ia64.c
--- david-020722/arch/ia64/kernel/irq_ia64.c	Tue Jul 23 16:01:24 2002
+++ david-020722-iosapic/arch/ia64/kernel/irq_ia64.c	Mon Aug  5 14:58:40 2002
@@ -54,20 +54,15 @@
 	0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21
 };
 
-/*
- * GSI to IA-64 vector translation table.
- */
-__u8 gsi_to_vector_map[255];
-
 int
-ia64_alloc_irq (void)
+ia64_alloc_vector (void)
 {
-	static int next_irq = IA64_FIRST_DEVICE_VECTOR;
+	static int next_vector = IA64_FIRST_DEVICE_VECTOR;
 
-	if (next_irq > IA64_LAST_DEVICE_VECTOR)
+	if (next_vector > IA64_LAST_DEVICE_VECTOR)
 		/* XXX could look for sharable vectors instead of panic'ing... */
-		panic("ia64_alloc_irq: out of interrupt vectors!");
-	return next_irq++;
+		panic("ia64_alloc_vector: out of interrupt vectors!");
+	return next_vector++;
 }
 
 extern unsigned int do_IRQ(unsigned long irq, struct pt_regs *regs);
diff -Nura david-020722/drivers/acpi/osl.c david-020722-iosapic/drivers/acpi/osl.c
--- david-020722/drivers/acpi/osl.c	Tue Jul 23 16:01:29 2002
+++ david-020722-iosapic/drivers/acpi/osl.c	Mon Aug  5 13:41:46 2002
@@ -41,11 +41,6 @@
 u64 efi_mem_attributes (u64 phys_addr);
 #endif
 
-#ifdef CONFIG_IA64
-#include <asm/hw_irq.h>
-#include <asm/delay.h>
-#endif
-
 
 #define _COMPONENT		ACPI_OS_SERVICES
 ACPI_MODULE_NAME	("osl")
@@ -235,7 +230,14 @@
 acpi_os_install_interrupt_handler(u32 irq, OSD_HANDLER handler, void *context)
 {
 #ifdef CONFIG_IA64
-	irq = gsi_to_vector(irq);
+	int vector;
+
+	vector = acpi_irq_to_vector(irq);
+	if (vector < 0) {
+		printk(KERN_ERR PREFIX "SCI (IRQ%d) not registerd\n", irq);
+		return AE_OK;
+	}
+	irq = vector;
 #endif /* CONFIG_IA64 */
 	acpi_irq_irq = irq;
 	acpi_irq_handler = handler;
@@ -253,7 +255,7 @@
 {
 	if (acpi_irq_handler) {
 #ifdef CONFIG_IA64
-		irq = gsi_to_vector(irq);
+		irq = acpi_irq_to_vector(irq);
 #endif /* CONFIG_IA64 */
 		free_irq(irq, acpi_irq);
 		acpi_irq_handler = NULL;
diff -Nura david-020722/include/asm-ia64/acpi.h david-020722-iosapic/include/asm-ia64/acpi.h
--- david-020722/include/asm-ia64/acpi.h	Tue Jul 23 16:01:34 2002
+++ david-020722-iosapic/include/asm-ia64/acpi.h	Mon Aug  5 15:01:50 2002
@@ -101,6 +101,7 @@
 int acpi_request_vector (u32 int_type);
 int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
 int acpi_get_interrupt_model(int *type);
+int acpi_irq_to_vector(u32 irq);
 
 #ifdef CONFIG_DISCONTIGMEM
 #define NODE_ARRAY_INDEX(x)	((x) / 8)	/* 8 bits/char */
diff -Nura david-020722/include/asm-ia64/hw_irq.h david-020722-iosapic/include/asm-ia64/hw_irq.h
--- david-020722/include/asm-ia64/hw_irq.h	Tue Jul 23 16:01:34 2002
+++ david-020722-iosapic/include/asm-ia64/hw_irq.h	Mon Aug  5 16:13:34 2002
@@ -52,6 +52,10 @@
 #define IA64_IPI_RESCHEDULE		0xfd	/* SMP reschedule */
 #define IA64_IPI_VECTOR			0xfe	/* inter-processor interrupt vector */
 
+/* Used for encoding redirected irqs */
+
+#define IA64_IRQ_REDIRECTED		(1 << 31)
+
 /* IA64 inter-cpu interrupt related definitions */
 
 #define IA64_IPI_DEFAULT_BASE_ADDR	0xfee00000
@@ -67,14 +71,12 @@
 
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
-extern __u8 gsi_to_vector_map[255];
-#define gsi_to_vector(x)	gsi_to_vector_map[(x)]
 
 extern unsigned long ipi_base_addr;
 
 extern struct hw_interrupt_type irq_type_ia64_lsapic;	/* CPU-internal interrupt controller */
 
-extern int ia64_alloc_irq (void);	/* allocate a free irq */
+extern int ia64_alloc_vector (void);	/* allocate a free vector */
 extern void ia64_send_ipi (int cpu, int vector, int delivery_mode, int redirect);
 extern void register_percpu_irq (ia64_vector vec, struct irqaction *action);
 
diff -Nura david-020722/include/asm-ia64/iosapic.h david-020722-iosapic/include/asm-ia64/iosapic.h
--- david-020722/include/asm-ia64/iosapic.h	Fri Nov  9 14:26:17 2001
+++ david-020722-iosapic/include/asm-ia64/iosapic.h	Mon Aug  5 15:01:57 2002
@@ -51,17 +51,24 @@
 
 #ifndef __ASSEMBLY__
 
-extern void __init iosapic_init (unsigned long address, unsigned int base_irq,
-                                 int pcat_compat);
-extern int iosapic_register_irq (u32 global_vector, unsigned long polarity,
-                                 unsigned long edge_triggered, u32 base_irq,
-                                 char *iosapic_address);
-extern void iosapic_register_legacy_irq (unsigned long irq, unsigned long pin,
-					 unsigned long polarity, unsigned long trigger);
-extern int iosapic_register_platform_irq (u32 int_type, u32 global_vector, u32 iosapic_vector,
-					  u16 eid, u16 id, unsigned long polarity,
-					  unsigned long edge_triggered, u32 base_irq,
-					  char *iosapic_address);
+extern void __devinit iosapic_init (unsigned long address,
+				    unsigned int gsi_base,
+				    int pcat_compat);
+extern int gsi_to_vector (unsigned int gsi);
+extern int iosapic_register_intr (unsigned int gsi, unsigned long polarity,
+				  unsigned long edge_triggered,
+				  u32 gsi_base, char *iosapic_address);
+extern void iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
+				      unsigned long polarity,
+				      unsigned long edge_triggered);
+extern int iosapic_register_platform_intr (u32 int_type,
+					   unsigned int gsi,
+					   int pmi_vector,
+					   u16 eid, u16 id,
+					   unsigned long polarity,
+					   unsigned long edge_triggered,
+					   unsigned int gsi_base,
+					   char *iosapic_address);
 extern unsigned int iosapic_version (char *addr);
 
 extern void iosapic_pci_fixup (int);

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


