From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 21 Apr 2005 13:39:39 +0000
Subject: [RFC/PATCH 2/3] ACPI based I/O APIC hot-plug
Message-Id: <4267AD1B.3040001@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, Len Brown <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Greg KH <greg@kroah.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net


This is an ia64 implementation of acpi_register_ioapic() and
acpi_unregister_ioapic() interfaces.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c    |   21 +-
 linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/iosapic.c |  131 ++++++++++++---
 linux-2.6.12-rc2-mm3-kanesige/include/asm-ia64/iosapic.h |   12 +
 3 files changed, 132 insertions(+), 32 deletions(-)

diff -puN arch/ia64/kernel/acpi.c~ioapic_hotplug_ia64 arch/ia64/kernel/acpi.c
--- linux-2.6.12-rc2-mm3/arch/ia64/kernel/acpi.c~ioapic_hotplug_ia64	2005-04-20 10:51:54.909736348 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c	2005-04-20 10:51:54.916572286 +0900
@@ -242,9 +242,7 @@ acpi_parse_iosapic (acpi_table_entry_hea
 	if (BAD_MADT_ENTRY(iosapic, end))
 		return -EINVAL;
 
-	iosapic_init(iosapic->address, iosapic->global_irq_base);
-
-	return 0;
+	return iosapic_init(iosapic->address, iosapic->global_irq_base);
 }
 
 
@@ -826,7 +824,7 @@ EXPORT_SYMBOL(acpi_unmap_lsapic);
  
 
 #ifdef CONFIG_ACPI_NUMA
-acpi_status __init
+acpi_status __devinit
 acpi_map_iosapic (acpi_handle handle, u32 depth, void *context, void **ret)
 {
 	struct acpi_buffer buffer = {ACPI_ALLOCATE_BUFFER, NULL};
@@ -896,16 +894,23 @@ acpi_map_iosapic (acpi_handle handle, u3
 int
 acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
 {
-	/* TBD */
-	return -EINVAL;
+	int err;
+
+	if ((err = iosapic_init(phys_addr, gsi_base)))
+		return err;
+
+#if CONFIG_ACPI_NUMA
+	acpi_map_iosapic(handle, 0, NULL, NULL);
+#endif /* CONFIG_ACPI_NUMA */
+
+	return 0;
 }
 EXPORT_SYMBOL(acpi_register_ioapic);
 
 int
 acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
 {
-	/* TBD */
-	return -EINVAL;
+	return iosapic_remove(gsi_base);
 }
 EXPORT_SYMBOL(acpi_unregister_ioapic);
 
diff -puN arch/ia64/kernel/iosapic.c~ioapic_hotplug_ia64 arch/ia64/kernel/iosapic.c
--- linux-2.6.12-rc2-mm3/arch/ia64/kernel/iosapic.c~ioapic_hotplug_ia64	2005-04-20 10:51:54.912666036 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/iosapic.c	2005-04-20 10:51:54.918525411 +0900
@@ -129,14 +129,13 @@ static struct iosapic {
 	char __iomem	*addr;		/* base address of IOSAPIC */
 	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
+	int		count;		/* # of RTEs in use on this IOSAPIC */
 #ifdef CONFIG_NUMA
 	unsigned short	node;		/* numa node association via pxm */
 #endif
 } iosapic_lists[NR_IOSAPICS];
 
-static int num_iosapic;
-
-static unsigned char pcat_compat __initdata;	/* 8259 compatibility flag */
+static unsigned char pcat_compat __devinitdata;	/* 8259 compatibility flag */
 
 static int iosapic_kmalloc_ok;
 static LIST_HEAD(free_rte_list);
@@ -149,7 +148,7 @@ find_iosapic (unsigned int gsi)
 {
 	int i;
 
-	for (i = 0; i < num_iosapic; i++) {
+	for (i = 0; i < NR_IOSAPICS; i++) {
 		if ((unsigned) (gsi - iosapic_lists[i].gsi_base) < iosapic_lists[i].num_rte)
 			return i;
 	}
@@ -598,6 +597,7 @@ register_intr (unsigned int gsi, int vec
 		rte->refcnt++;
 		list_add_tail(&rte->rte_list, &iosapic_intr_info[vector].rtes);
 		iosapic_intr_info[vector].count++;
+		iosapic_lists[index].count++;
 	}
 	else if (vector_is_shared(vector)) {
 		struct iosapic_intr_info *info = &iosapic_intr_info[vector];
@@ -778,7 +778,7 @@ void
 iosapic_unregister_intr (unsigned int gsi)
 {
 	unsigned long flags;
-	int irq, vector;
+	int irq, vector, index;
 	irq_desc_t *idesc;
 	u32 low32;
 	unsigned long trigger, polarity;
@@ -819,6 +819,9 @@ iosapic_unregister_intr (unsigned int gs
 		list_del(&rte->rte_list);
 		iosapic_intr_info[vector].count--;
 		iosapic_free_rte(rte);
+		index = find_iosapic(gsi);
+		iosapic_lists[index].count--;
+		WARN_ON(iosapic_lists[index].count < 0);
 
 		trigger	 = iosapic_intr_info[vector].trigger;
 		polarity = iosapic_intr_info[vector].polarity;
@@ -952,30 +955,83 @@ iosapic_system_init (int system_pcat_com
 	}
 }
 
-void __init
+static inline int iosapic_alloc (void)
+{
+	int index;
+
+	for (index = 0; index < NR_IOSAPICS; index++)
+		if (!iosapic_lists[index].addr)
+			return index;
+
+	printk(KERN_WARNING "%s: failed to allocate iosapic\n", __FUNCTION__);
+	return -1;
+}
+
+static inline void free_iosapic (int index)
+{
+	memset(&iosapic_lists[index], 0, sizeof(struct iosapic));
+}
+
+static inline int iosapic_check (unsigned int gsi_base, unsigned int ver)
+{
+	int index;
+	unsigned int gsi_end, base, end;
+
+	/* check gsi range */
+	gsi_end = gsi_base + ((ver >> 16) & 0xff);
+	for (index = 0; index < NR_IOSAPICS; index++) {
+		if (!iosapic_lists[index].addr)
+			continue;
+
+		base = iosapic_lists[index].gsi_base;
+		end  = base + iosapic_lists[index].num_rte - 1;
+
+		if (gsi_base < base && gsi_end < base)
+			continue;/* OK */
+
+		if (gsi_base > end && gsi_end > end)
+			continue; /* OK */
+
+		return -EBUSY;
+	}
+	return 0;
+}
+
+int __devinit
 iosapic_init (unsigned long phys_addr, unsigned int gsi_base)
 {
-	int num_rte;
+	int num_rte, err, index;
 	unsigned int isa_irq, ver;
 	char __iomem *addr;
+	unsigned long flags;
 
-	addr = ioremap(phys_addr, 0);
-	ver = iosapic_version(addr);
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		addr = ioremap(phys_addr, 0);
+		ver = iosapic_version(addr);
 
-	/*
-	 * The MAX_REDIR register holds the highest input pin
-	 * number (starting from 0).
-	 * We add 1 so that we can use it for number of pins (= RTEs)
-	 */
-	num_rte = ((ver >> 16) & 0xff) + 1;
+		if ((err = iosapic_check(gsi_base, ver))) {
+			iounmap(addr);
+			spin_unlock_irqrestore(&iosapic_lock, flags);
+			return err;
+		}
 
-	iosapic_lists[num_iosapic].addr = addr;
-	iosapic_lists[num_iosapic].gsi_base = gsi_base;
-	iosapic_lists[num_iosapic].num_rte = num_rte;
+		/*
+		 * The MAX_REDIR register holds the highest input pin
+		 * number (starting from 0).
+		 * We add 1 so that we can use it for number of pins (= RTEs)
+		 */
+		num_rte = ((ver >> 16) & 0xff) + 1;
+
+		index = iosapic_alloc();
+		iosapic_lists[index].addr = addr;
+		iosapic_lists[index].gsi_base = gsi_base;
+		iosapic_lists[index].num_rte = num_rte;
 #ifdef CONFIG_NUMA
-	iosapic_lists[num_iosapic].node = MAX_NUMNODES;
+		iosapic_lists[index].node = MAX_NUMNODES;
 #endif
-	num_iosapic++;
+	}
+	spin_unlock_irqrestore(&iosapic_lock, flags);
 
 	if ((gsi_base = 0) && pcat_compat) {
 		/*
@@ -986,10 +1042,43 @@ iosapic_init (unsigned long phys_addr, u
 		for (isa_irq = 0; isa_irq < 16; ++isa_irq)
 			iosapic_override_isa_irq(isa_irq, isa_irq, IOSAPIC_POL_HIGH, IOSAPIC_EDGE);
 	}
+	return 0;
 }
 
+#ifdef CONFIG_HOTPLUG
+int
+iosapic_remove (unsigned int gsi_base)
+{
+	int index, err = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		index = find_iosapic(gsi_base);
+		if (index < 0) {
+			printk(KERN_WARNING "%s: No IOSAPIC for GSI base %u\n",
+			       __FUNCTION__, gsi_base);
+			goto out;
+		}
+
+		if (iosapic_lists[index].count) {
+			err = -EBUSY;
+			printk(KERN_WARNING "%s: IOSAPIC for GSI base %u is busy\n",
+			       __FUNCTION__, gsi_base);
+			goto out;
+		}
+
+		iounmap(iosapic_lists[index].addr);
+		free_iosapic(index);
+	}
+ out:
+	spin_unlock_irqrestore(&iosapic_lock, flags);
+	return err;
+}
+#endif /* CONFIG_HOTPLUG */
+
 #ifdef CONFIG_NUMA
-void __init
+void __devinit
 map_iosapic_to_node(unsigned int gsi_base, int node)
 {
 	int index;
diff -puN include/asm-ia64/iosapic.h~ioapic_hotplug_ia64 include/asm-ia64/iosapic.h
--- linux-2.6.12-rc2-mm3/include/asm-ia64/iosapic.h~ioapic_hotplug_ia64	2005-04-20 10:51:54.914619161 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/include/asm-ia64/iosapic.h	2005-04-20 10:51:54.925361348 +0900
@@ -71,8 +71,11 @@ static inline void iosapic_eoi(char __io
 }
 
 extern void __init iosapic_system_init (int pcat_compat);
-extern void __init iosapic_init (unsigned long address,
+extern int __devinit iosapic_init (unsigned long address,
 				    unsigned int gsi_base);
+#ifdef CONFIG_HOTPLUG
+extern int iosapic_remove (unsigned int gsi_base);
+#endif /* CONFIG_HOTPLUG */
 extern int gsi_to_vector (unsigned int gsi);
 extern int gsi_to_irq (unsigned int gsi);
 extern void iosapic_enable_intr (unsigned int vector);
@@ -94,11 +97,14 @@ extern unsigned int iosapic_version (cha
 
 extern void iosapic_pci_fixup (int);
 #ifdef CONFIG_NUMA
-extern void __init map_iosapic_to_node (unsigned int, int);
+extern void __devinit map_iosapic_to_node (unsigned int, int);
 #endif
 #else
 #define iosapic_system_init(pcat_compat)			do { } while (0)
-#define iosapic_init(address,gsi_base)				do { } while (0)
+#define iosapic_init(address,gsi_base)				(-EINVAL)
+#ifdef CONFIG_HOTPLUG
+#define iosapic_remove(gsi_base)				(-ENODEV)
+#endif /* CONFIG_HOTPLUG */
 #define iosapic_register_intr(gsi,polarity,trigger)		(gsi)
 #define iosapic_unregister_intr(irq)				do { } while (0)
 #define iosapic_override_isa_irq(isa_irq,gsi,polarity,trigger)	do { } while (0)

_
