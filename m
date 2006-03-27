From: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>
Date: Mon, 27 Mar 2006 08:12:19 +0000
Subject: [PATCH 1/2] correct some messages and fixes some minor things
Message-Id: <87ek0ofgrg.wl%takeuchi_satoru@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87odzwfihv.wl%takeuchi_satoru@jp.fujitsu.com>
In-Reply-To: <87odzwfihv.wl%takeuchi_satoru@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch corrects some wrong comments and a printk message.
It also fixes some minor things.

Signed-off-by: Satoru Takeuchi <takeuchi_satoru@jp.fujitsu.com>

---
 arch/ia64/kernel/iosapic.c |  260 +++++++++++++++++++++++++++------------------
 1 files changed, 161 insertions(+), 99 deletions(-)

Index: linux-2.6.16/arch/ia64/kernel/iosapic.c
=================================--- linux-2.6.16.orig/arch/ia64/kernel/iosapic.c	2006-03-24 14:42:43.000000000 +0900
+++ linux-2.6.16/arch/ia64/kernel/iosapic.c	2006-03-27 09:42:34.000000000 +0900
@@ -9,54 +9,65 @@
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999,2000 Walt Drummond <drummond@valinux.com>
  *
- * 00/04/19	D. Mosberger	Rewritten to mirror more closely the x86 I/O APIC code.
- *				In particular, we now have separate handlers for edge
- *				and level triggered interrupts.
- * 00/10/27	Asit Mallick, Goutham Rao <goutham.rao@intel.com> IRQ vector allocation
- *				PCI to vector mapping, shared PCI interrupts.
- * 00/10/27	D. Mosberger	Document things a bit more to make them more understandable.
- *				Clean up much of the old IOSAPIC cruft.
- * 01/07/27	J.I. Lee	PCI irq routing, Platform/Legacy interrupts and fixes for
- *				ACPI S5(SoftOff) support.
+ * 00/04/19	D. Mosberger	Rewritten to mirror more closely the x86 I/O
+ *				APIC code.  In particular, we now have separate
+ *				handlers for edge and level triggered
+ *				interrupts.
+ * 00/10/27	Asit Mallick, Goutham Rao <goutham.rao@intel.com> IRQ vector
+ *				allocation PCI to vector mapping, shared PCI
+ *				interrupts.
+ * 00/10/27	D. Mosberger	Document things a bit more to make them more
+ *				understandable.  Clean up much of the old
+ *				IOSAPIC cruft.
+ * 01/07/27	J.I. Lee	PCI irq routing, Platform/Legacy interrupts
+ *				and fixes for ACPI S5(SoftOff) support.
  * 02/01/23	J.I. Lee	iosapic pgm fixes for PCI irq routing from _PRT
- * 02/01/07     E. Focht        <efocht@ess.nec.de> Redirectable interrupt vectors in
- *                              iosapic_set_affinity(), initializations for
- *                              /proc/irq/#/smp_affinity
+ * 02/01/07     E. Focht        <efocht@ess.nec.de> Redirectable interrupt
+ *				vectors in iosapic_set_affinity(),
+ *				initializations for /proc/irq/#/smp_affinity
  * 02/04/02	P. Diefenbaugh	Cleaned up ACPI PCI IRQ routing.
  * 02/04/18	J.I. Lee	bug fix in iosapic_init_pci_irq
- * 02/04/30	J.I. Lee	bug fix in find_iosapic to fix ACPI PCI IRQ to IOSAPIC mapping
- *				error
+ * 02/04/30	J.I. Lee	bug fix in find_iosapic to fix ACPI PCI IRQ to
+ *				IOSAPIC mapping error
  * 02/07/29	T. Kochi	Allocate interrupt vectors dynamically
- * 02/08/04	T. Kochi	Cleaned up terminology (irq, global system interrupt, vector, etc.)
- * 02/09/20	D. Mosberger	Simplified by taking advantage of ACPI's pci_irq code.
+ * 02/08/04	T. Kochi	Cleaned up terminology (irq, global system
+ *				interrupt, vector, etc.)
+ * 02/09/20	D. Mosberger	Simplified by taking advantage of ACPI's
+ *				pci_irq code.
  * 03/02/19	B. Helgaas	Make pcat_compat system-wide, not per-IOSAPIC.
- *				Remove iosapic_address & gsi_base from external interfaces.
- *				Rationalize __init/__devinit attributes.
+ *				Remove iosapic_address & gsi_base from
+ *				external interfaces.  Rationalize
+ *				__init/__devinit attributes.
  * 04/12/04 Ashok Raj	<ashok.raj@intel.com> Intel Corporation 2004
- *				Updated to work with irq migration necessary for CPU Hotplug
+ *				Updated to work with irq migration necessary
+ *				for CPU Hotplug
  */
 /*
- * Here is what the interrupt logic between a PCI device and the kernel looks like:
+ * Here is what the interrupt logic between a PCI device and the kernel looks
+ * like:
  *
- * (1) A PCI device raises one of the four interrupt pins (INTA, INTB, INTC, INTD).  The
- *     device is uniquely identified by its bus--, and slot-number (the function
- *     number does not matter here because all functions share the same interrupt
- *     lines).
+ * (1) A PCI device raises one of the four interrupt pins (INTA, INTB, INTC,
+ *     INTD).  The device is uniquely identified by its bus-, and slot-number
+ *     (the function number does not matter here because all functions share
+ *     the same interrupt lines).
  *
- * (2) The motherboard routes the interrupt line to a pin on a IOSAPIC controller.
- *     Multiple interrupt lines may have to share the same IOSAPIC pin (if they're level
- *     triggered and use the same polarity).  Each interrupt line has a unique Global
- *     System Interrupt (GSI) number which can be calculated as the sum of the controller's
- *     base GSI number and the IOSAPIC pin number to which the line connects.
+ * (2) The motherboard routes the interrupt line to a pin on a IOSAPIC
+ *     controller.  Multiple interrupt lines may have to share the same
+ *     IOSAPIC pin (if they're level triggered and use the same polarity).
+ *     Each interrupt line has a unique Global System Interrupt (GSI) number
+ *     which can be calculated as the sum of the controller's base GSI number
+ *     and the IOSAPIC pin number to which the line connects.
  *
- * (3) The IOSAPIC uses an internal routing table entries (RTEs) to map the IOSAPIC pin
- *     into the IA-64 interrupt vector.  This interrupt vector is then sent to the CPU.
+ * (3) The IOSAPIC uses an internal routing table entries (RTEs) to map the
+ * IOSAPIC pin into the IA-64 interrupt vector.  This interrupt vector is then
+ * sent to the CPU.
  *
- * (4) The kernel recognizes an interrupt as an IRQ.  The IRQ interface is used as
- *     architecture-independent interrupt handling mechanism in Linux.  As an
- *     IRQ is a number, we have to have IA-64 interrupt vector number <-> IRQ number
- *     mapping.  On smaller systems, we use one-to-one mapping between IA-64 vector and
- *     IRQ.  A platform can implement platform_irq_to_vector(irq) and
+ * (4) The kernel recognizes an interrupt as an IRQ.  The IRQ interface is
+ *     used as architecture-independent interrupt handling mechanism in Linux.
+ *     As an IRQ is a number, we have to have
+ *     IA-64 interrupt vector number <-> IRQ number mapping.  On smaller
+ *     systems, we use one-to-one mapping between IA-64 vector and IRQ.  A
+ *     platform can implement platform_irq_to_vector(irq) and
  *     platform_local_vector_to_irq(vector) APIs to differentiate the mapping.
  *     Please see also include/asm-ia64/hw_irq.h for those APIs.
  *
@@ -64,9 +75,9 @@
  *
  *	PCI pin -> global system interrupt (GSI) -> IA-64 vector <-> IRQ
  *
- * Note: The term "IRQ" is loosely used everywhere in Linux kernel to describe interrupts.
- * Now we use "IRQ" only for Linux IRQ's.  ISA IRQ (isa_irq) is the only exception in this
- * source code.
+ * Note: The term "IRQ" is loosely used everywhere in Linux kernel to
+ * describeinterrupts.  Now we use "IRQ" only for Linux IRQ's.  ISA IRQ
+ * (isa_irq) is the only exception in this source code.
  */
 #include <linux/config.h>
 
@@ -90,7 +101,6 @@
 #include <asm/ptrace.h>
 #include <asm/system.h>
 
-
 #undef DEBUG_INTERRUPT_ROUTING
 
 #ifdef DEBUG_INTERRUPT_ROUTING
@@ -99,36 +109,46 @@
 #define DBG(fmt...)
 #endif
 
-#define NR_PREALLOCATE_RTE_ENTRIES	(PAGE_SIZE / sizeof(struct iosapic_rte_info))
+#define NR_PREALLOCATE_RTE_ENTRIES \
+	(PAGE_SIZE / sizeof(struct iosapic_rte_info))
 #define RTE_PREALLOCATED	(1)
 
 static DEFINE_SPINLOCK(iosapic_lock);
 
-/* These tables map IA-64 vectors to the IOSAPIC pin that generates this vector. */
+/*
+ * These tables map IA-64 vectors to the IOSAPIC pin that generates this
+ * vector.
+ */
 
 struct iosapic_rte_info {
-	struct list_head rte_list;	/* node in list of RTEs sharing the same vector */
+	struct list_head rte_list;	/* node in list of RTEs sharing the
+					 * same vector */
 	char __iomem	*addr;		/* base address of IOSAPIC */
-	unsigned int	gsi_base;	/* first GSI assigned to this IOSAPIC */
+	unsigned int	gsi_base;	/* first GSI assigned to this
+					 * IOSAPIC */
 	char		rte_index;	/* IOSAPIC RTE index */
 	int		refcnt;		/* reference counter */
 	unsigned int	flags;		/* flags */
 } ____cacheline_aligned;
 
 static struct iosapic_intr_info {
-	struct list_head rtes;		/* RTEs using this vector (empty => not an IOSAPIC interrupt) */
+	struct list_head rtes;		/* RTEs using this vector (empty =>
+					 * not an IOSAPIC interrupt) */
 	int		count;		/* # of RTEs that shares this vector */
-	u32		low32;		/* current value of low word of Redirection table entry */
+	u32		low32;		/* current value of low word of
+					 * Redirection table entry */
 	unsigned int	dest;		/* destination CPU physical ID */
 	unsigned char	dmode	: 3;	/* delivery mode (see iosapic.h) */
-	unsigned char 	polarity: 1;	/* interrupt polarity (see iosapic.h) */
+	unsigned char 	polarity: 1;	/* interrupt polarity
+					 * (see iosapic.h) */
 	unsigned char	trigger	: 1;	/* trigger mode (see iosapic.h) */
 } iosapic_intr_info[IA64_NUM_VECTORS];
 
 static struct iosapic {
 	char __iomem	*addr;		/* base address of IOSAPIC */
-	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
-	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
+	unsigned int 	gsi_base;	/* first GSI assigned to this
+					 * IOSAPIC */
+	unsigned short 	num_rte;	/* # of RTEs on this IOSAPIC */
 	int		rtes_inuse;	/* # of RTEs in use on this IOSAPIC */
 #ifdef CONFIG_NUMA
 	unsigned short	node;		/* numa node association via pxm */
@@ -149,7 +169,8 @@
 	int i;
 
 	for (i = 0; i < NR_IOSAPICS; i++) {
-		if ((unsigned) (gsi - iosapic_lists[i].gsi_base) < iosapic_lists[i].num_rte)
+		if ((unsigned) (gsi - iosapic_lists[i].gsi_base) <
+		    iosapic_lists[i].num_rte)
 			return i;
 	}
 
@@ -162,7 +183,8 @@
 	struct iosapic_intr_info *info;
 	struct iosapic_rte_info *rte;
 
-	for (info = iosapic_intr_info; info < iosapic_intr_info + IA64_NUM_VECTORS; ++info)
+	for (info = iosapic_intr_info; info <
+		     iosapic_intr_info + IA64_NUM_VECTORS; ++info)
 		list_for_each_entry(rte, &info->rtes, rte_list)
 			if (rte->gsi_base + rte->rte_index = gsi)
 				return info - iosapic_intr_info;
@@ -185,8 +207,8 @@
 	unsigned long flags;
 	int irq;
 	/*
-	 * XXX fix me: this assumes an identity mapping vetween IA-64 vector and Linux irq
-	 * numbers...
+	 * XXX fix me: this assumes an identity mapping between IA-64 vector
+	 * and Linux irq numbers...
 	 */
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
@@ -197,7 +219,8 @@
 	return irq;
 }
 
-static struct iosapic_rte_info *gsi_vector_to_rte(unsigned int gsi, unsigned int vec)
+static struct iosapic_rte_info *gsi_vector_to_rte(unsigned int gsi,
+						  unsigned int vec)
 {
 	struct iosapic_rte_info *rte;
 
@@ -237,7 +260,9 @@
 
 		for (irq = 0; irq < NR_IRQS; ++irq)
 			if (irq_to_vector(irq) = vector) {
-				set_irq_affinity_info(irq, (int)(dest & 0xffff), redir);
+				set_irq_affinity_info(irq,
+						      (int)(dest & 0xffff),
+						      redir);
 				break;
 			}
 	}
@@ -259,7 +284,7 @@
 }
 
 static void
-nop (unsigned int vector)
+nop (unsigned int irq)
 {
 	/* do nothing... */
 }
@@ -281,7 +306,8 @@
 	{
 		/* set only the mask bit */
 		low32 = iosapic_intr_info[vec].low32 |= IOSAPIC_MASK;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
+				    rte_list) {
 			addr = rte->addr;
 			rte_index = rte->rte_index;
 			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
@@ -306,7 +332,8 @@
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
 		low32 = iosapic_intr_info[vec].low32 &= ~IOSAPIC_MASK;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
+				    rte_list) {
 			addr = rte->addr;
 			rte_index = rte->rte_index;
 			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
@@ -346,21 +373,25 @@
 
 	spin_lock_irqsave(&iosapic_lock, flags);
 	{
-		low32 = iosapic_intr_info[vec].low32 & ~(7 << IOSAPIC_DELIVERY_SHIFT);
+		low32 = iosapic_intr_info[vec].low32 &
+			~(7 << IOSAPIC_DELIVERY_SHIFT);
 
 		if (redir)
 		        /* change delivery mode to lowest priority */
-			low32 |= (IOSAPIC_LOWEST_PRIORITY << IOSAPIC_DELIVERY_SHIFT);
+			low32 |= (IOSAPIC_LOWEST_PRIORITY <<
+				  IOSAPIC_DELIVERY_SHIFT);
 		else
 		        /* change delivery mode to fixed */
 			low32 |= (IOSAPIC_FIXED << IOSAPIC_DELIVERY_SHIFT);
 
 		iosapic_intr_info[vec].low32 = low32;
 		iosapic_intr_info[vec].dest = dest;
-		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list) {
+		list_for_each_entry(rte, &iosapic_intr_info[vec].rtes,
+				    rte_list) {
 			addr = rte->addr;
 			rte_index = rte->rte_index;
-			iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index), high32);
+			iosapic_write(addr, IOSAPIC_RTE_HIGH(rte_index),
+				      high32);
 			iosapic_write(addr, IOSAPIC_RTE_LOW(rte_index), low32);
 		}
 	}
@@ -433,7 +464,8 @@
 	 * interrupt for real. This prevents IRQ storms from unhandled
 	 * devices.
 	 */
-	if ((idesc->status & (IRQ_PENDING|IRQ_DISABLED)) = (IRQ_PENDING|IRQ_DISABLED))
+	if ((idesc->status & (IRQ_PENDING|IRQ_DISABLED)) =
+	    (IRQ_PENDING|IRQ_DISABLED))
 		mask_irq(irq);
 }
 
@@ -467,7 +499,8 @@
 	return iosapic_read(addr, IOSAPIC_VERSION);
 }
 
-static int iosapic_find_sharable_vector (unsigned long trigger, unsigned long pol)
+static int iosapic_find_sharable_vector (unsigned long trigger,
+					 unsigned long pol)
 {
 	int i, vector = -1, min_count = -1;
 	struct iosapic_intr_info *info;
@@ -482,7 +515,8 @@
 	for (i = IA64_FIRST_DEVICE_VECTOR; i <= IA64_LAST_DEVICE_VECTOR; i++) {
 		info = &iosapic_intr_info[i];
 		if (info->trigger = trigger && info->polarity = pol &&
-		    (info->dmode = IOSAPIC_FIXED || info->dmode = IOSAPIC_LOWEST_PRIORITY)) {
+		    (info->dmode = IOSAPIC_FIXED || info->dmode =
+		     IOSAPIC_LOWEST_PRIORITY)) {
 			if (min_count = -1 || info->count < min_count) {
 				vector = i;
 				min_count = info->count;
@@ -506,12 +540,15 @@
 		new_vector = assign_irq_vector(AUTO_ASSIGN);
 		if (new_vector < 0)
 			panic("%s: out of interrupt vectors!\n", __FUNCTION__);
-		printk(KERN_INFO "Reassigning vector %d to %d\n", vector, new_vector);
+		printk(KERN_INFO "Reassigning vector %d to %d\n",
+		       vector, new_vector);
 		memcpy(&iosapic_intr_info[new_vector], &iosapic_intr_info[vector],
 		       sizeof(struct iosapic_intr_info));
 		INIT_LIST_HEAD(&iosapic_intr_info[new_vector].rtes);
-		list_move(iosapic_intr_info[vector].rtes.next, &iosapic_intr_info[new_vector].rtes);
-		memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
+		list_move(iosapic_intr_info[vector].rtes.next,
+			  &iosapic_intr_info[new_vector].rtes);
+		memset(&iosapic_intr_info[vector], 0,
+		       sizeof(struct iosapic_intr_info));
 		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
 		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
 	}
@@ -524,7 +561,8 @@
 	int preallocated = 0;
 
 	if (!iosapic_kmalloc_ok && list_empty(&free_rte_list)) {
-		rte = alloc_bootmem(sizeof(struct iosapic_rte_info) * NR_PREALLOCATE_RTE_ENTRIES);
+		rte = alloc_bootmem(sizeof(struct iosapic_rte_info) *
+				    NR_PREALLOCATE_RTE_ENTRIES);
 		if (!rte)
 			return NULL;
 		for (i = 0; i < NR_PREALLOCATE_RTE_ENTRIES; i++, rte++)
@@ -532,7 +570,8 @@
 	}
 
 	if (!list_empty(&free_rte_list)) {
-		rte = list_entry(free_rte_list.next, struct iosapic_rte_info, rte_list);
+		rte = list_entry(free_rte_list.next, struct iosapic_rte_info,
+				 rte_list);
 		list_del(&rte->rte_list);
 		preallocated++;
 	} else {
@@ -575,7 +614,8 @@
 
 	index = find_iosapic(gsi);
 	if (index < 0) {
-		printk(KERN_WARNING "%s: No IOSAPIC for GSI %u\n", __FUNCTION__, gsi);
+		printk(KERN_WARNING "%s: No IOSAPIC for GSI %u\n",
+		       __FUNCTION__, gsi);
 		return -ENODEV;
 	}
 
@@ -586,7 +626,8 @@
 	if (!rte) {
 		rte = iosapic_alloc_rte();
 		if (!rte) {
-			printk(KERN_WARNING "%s: cannot allocate memory\n", __FUNCTION__);
+			printk(KERN_WARNING "%s: cannot allocate memory\n",
+			       __FUNCTION__);
 			return -ENOMEM;
 		}
 
@@ -602,7 +643,9 @@
 	else if (vector_is_shared(vector)) {
 		struct iosapic_intr_info *info = &iosapic_intr_info[vector];
 		if (info->trigger != trigger || info->polarity != polarity) {
-			printk (KERN_WARNING "%s: cannot override the interrupt\n", __FUNCTION__);
+			printk (KERN_WARNING
+				"%s: cannot override the interrupt\n",
+				__FUNCTION__);
 			return -EINVAL;
 		}
 	}
@@ -619,8 +662,10 @@
 	idesc = irq_descp(vector);
 	if (idesc->handler != irq_type) {
 		if (idesc->handler != &no_irq_type)
-			printk(KERN_WARNING "%s: changing vector %d from %s to %s\n",
-			       __FUNCTION__, vector, idesc->handler->typename, irq_type->typename);
+			printk(KERN_WARNING
+			       "%s: changing vector %d from %s to %s\n",
+			       __FUNCTION__, vector,
+			       idesc->handler->typename, irq_type->typename);
 		idesc->handler = irq_type;
 	}
 	return 0;
@@ -675,7 +720,7 @@
 		if (!num_cpus)
 			goto skip_numa_setup;
 
-		/* Use vector assigment to distribute across cpus in node */
+		/* Use vector assignment to distribute across cpus in node */
 		cpu_index = vector % num_cpus;
 
 		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
@@ -697,7 +742,7 @@
 	} while (!cpu_online(cpu));
 
 	return cpu_physical_id(cpu);
-#else
+#else  /* CONFIG_SMP */
 	return cpu_physical_id(smp_processor_id());
 #endif
 }
@@ -749,7 +794,8 @@
 			if (list_empty(&iosapic_intr_info[vector].rtes))
 				free_irq_vector(vector);
 			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
+			spin_unlock_irqrestore(&irq_descp(vector)->lock,
+					       flags);
 			goto again;
 		}
 
@@ -758,7 +804,8 @@
 			      polarity, trigger);
 		if (err < 0) {
 			spin_unlock(&iosapic_lock);
-			spin_unlock_irqrestore(&irq_descp(vector)->lock, flags);
+			spin_unlock_irqrestore(&irq_descp(vector)->lock,
+					       flags);
 			return err;
 		}
 
@@ -800,7 +847,8 @@
 	 */
 	irq = gsi_to_irq(gsi);
 	if (irq < 0) {
-		printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n", gsi);
+		printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n",
+		       gsi);
 		WARN_ON(1);
 		return;
 	}
@@ -811,7 +859,9 @@
 	spin_lock(&iosapic_lock);
 	{
 		if ((rte = gsi_vector_to_rte(gsi, vector)) = NULL) {
-			printk(KERN_ERR "iosapic_unregister_intr(%u) unbalanced\n", gsi);
+			printk(KERN_ERR
+			       "iosapic_unregister_intr(%u) unbalanced\n",
+			       gsi);
 			WARN_ON(1);
 			goto out;
 		}
@@ -821,7 +871,8 @@
 
 		/* Mask the interrupt */
 		low32 = iosapic_intr_info[vector].low32 | IOSAPIC_MASK;
-		iosapic_write(rte->addr, IOSAPIC_RTE_LOW(rte->rte_index), low32);
+		iosapic_write(rte->addr, IOSAPIC_RTE_LOW(rte->rte_index),
+			      low32);
 
 		/* Remove the rte entry from the list */
 		list_del(&rte->rte_list);
@@ -834,7 +885,9 @@
 		trigger	 = iosapic_intr_info[vector].trigger;
 		polarity = iosapic_intr_info[vector].polarity;
 		dest     = iosapic_intr_info[vector].dest;
-		printk(KERN_INFO "GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d unregistered\n",
+		printk(KERN_INFO
+		       "GSI %u (%s, %s) -> CPU %d (0x%04x)"
+		       " vector %d unregistered\n",
 		       gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 		       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
 		       cpu_logical_id(dest), dest, vector);
@@ -847,12 +900,15 @@
 			idesc->handler = &no_irq_type;
 
 			/* Clear the interrupt information */
-			memset(&iosapic_intr_info[vector], 0, sizeof(struct iosapic_intr_info));
+			memset(&iosapic_intr_info[vector], 0,
+			       sizeof(struct iosapic_intr_info));
 			iosapic_intr_info[vector].low32 |= IOSAPIC_MASK;
 			INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
 
 			if (idesc->action) {
-				printk(KERN_ERR "interrupt handlers still exist on IRQ %u\n", irq);
+				printk(KERN_ERR
+				       "interrupt handlers still exist on"
+				       "IRQ %u\n", irq);
 				WARN_ON(1);
 			}
 
@@ -867,7 +923,6 @@
 
 /*
  * ACPI calls this when it finds an entry for a platform interrupt.
- * Note that the irq_base and IOSAPIC address must be set in iosapic_init().
  */
 int __init
 iosapic_register_platform_intr (u32 int_type, unsigned int gsi,
@@ -901,13 +956,16 @@
 		mask = 1;
 		break;
 	      default:
-		printk(KERN_ERR "iosapic_register_platform_irq(): invalid int type 0x%x\n", int_type);
+		printk(KERN_ERR "%s: invalid int type 0x%x\n", __FUNCTION__,
+		       int_type);
 		return -1;
 	}
 
 	register_intr(gsi, vector, delivery, polarity, trigger);
 
-	printk(KERN_INFO "PLATFORM int %s (0x%x): GSI %u (%s, %s) -> CPU %d (0x%04x) vector %d\n",
+	printk(KERN_INFO
+	       "PLATFORM int %s (0x%x): GSI %u (%s, %s) -> CPU %d (0x%04x)"
+	       " vector %d\n",
 	       int_type < ARRAY_SIZE(name) ? name[int_type] : "unknown",
 	       int_type, gsi, (trigger = IOSAPIC_EDGE ? "edge" : "level"),
 	       (polarity = IOSAPIC_POL_HIGH ? "high" : "low"),
@@ -917,10 +975,8 @@
 	return vector;
 }
 
-
 /*
  * ACPI calls this when it finds an entry for a legacy ISA IRQ override.
- * Note that the gsi_base and IOSAPIC address must be set in iosapic_init().
  */
 void __init
 iosapic_override_isa_irq (unsigned int isa_irq, unsigned int gsi,
@@ -949,16 +1005,19 @@
 
 	for (vector = 0; vector < IA64_NUM_VECTORS; ++vector) {
 		iosapic_intr_info[vector].low32 = IOSAPIC_MASK;
-		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);	/* mark as unused */
+		/* mark as unused */
+		INIT_LIST_HEAD(&iosapic_intr_info[vector].rtes);
 	}
 
 	pcat_compat = system_pcat_compat;
 	if (pcat_compat) {
 		/*
-		 * Disable the compatibility mode interrupts (8259 style), needs IN/OUT support
-		 * enabled.
+		 * Disable the compatibility mode interrupts (8259 style),
+		 * needs IN/OUT support enabled.
 		 */
-		printk(KERN_INFO "%s: Disabling PC-AT compatible 8259 interrupts\n", __FUNCTION__);
+		printk(KERN_INFO
+		       "%s: Disabling PC-AT compatible 8259 interrupts\n",
+		       __FUNCTION__);
 		outb(0xff, 0xA1);
 		outb(0xff, 0x21);
 	}
@@ -1047,12 +1106,14 @@
 
 	if ((gsi_base = 0) && pcat_compat) {
 		/*
-		 * Map the legacy ISA devices into the IOSAPIC data.  Some of these may
-		 * get reprogrammed later on with data from the ACPI Interrupt Source
-		 * Override table.
+		 * Map the legacy ISA devices into the IOSAPIC data.  Some of
+		 * these may get reprogrammed later on with data from the ACPI
+		 * Interrupt Source Override table.
 		 */
 		for (isa_irq = 0; isa_irq < 16; ++isa_irq)
-			iosapic_override_isa_irq(isa_irq, isa_irq, IOSAPIC_POL_HIGH, IOSAPIC_EDGE);
+			iosapic_override_isa_irq(isa_irq, isa_irq,
+						 IOSAPIC_POL_HIGH,
+						 IOSAPIC_EDGE);
 	}
 	return 0;
 }
@@ -1075,7 +1136,8 @@
 
 		if (iosapic_lists[index].rtes_inuse) {
 			err = -EBUSY;
-			printk(KERN_WARNING "%s: IOSAPIC for GSI base %u is busy\n",
+			printk(KERN_WARNING
+			       "%s: IOSAPIC for GSI base %u is busy\n",
 			       __FUNCTION__, gsi_base);
 			goto out;
 		}
