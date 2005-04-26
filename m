From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 26 Apr 2005 15:07:30 +0000
Subject: Re: [RFC/PATCH 0/3] ACPI based I/O APIC hot-plug
Message-Id: <426E5932.3070003@jp.fujitsu.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050601030001010505080600"
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD0E.3080006@jp.fujitsu.com>	<20050426025716.142c5726.akpm@osdl.org>	<426E15DA.9030800@jp.fujitsu.com> <20050426033503.3fd6b84c.akpm@osdl.org>
In-Reply-To: <20050426033503.3fd6b84c.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Cc: len.brown@intel.com, tony.luck@intel.com, greg@kroah.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------050601030001010505080600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> wrote:
> 
>>Andrew Morton wrote:
>> > "Kenji Kaneshige" <kaneshige.kenji@jp.fujitsu.com> wrote:
>> > 
>> >>Here is a set of patches to support ACPI based I/O APIC hotplug.
>> > 
>> > 
>> > OK, with the help of Tony's git tree I managed to get those merged up.
>> > 
>>
>> Wow, great!
>> But I'm now updating these patches based on the feedbacks.
>> How should I do about this? Should I send these updates as
>> another cleanup patch?
> 
> 
> Replacement patches would be OK at this time.  Incremental patches are
> preferred once the code settles down a bit, so we can see what changed.
> 
> 

I'm attaching the updated set of patches based on feedbacks.
Could you please replace the old ones with these?

Thanks,
Kenji Kaneshige

--------------050601030001010505080600
Content-Type: text/plain;
 name="acpi-based-i-o-apic-hot-plug-add-interfaces.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="acpi-based-i-o-apic-hot-plug-add-interfaces.patch"


This patch adds the following new interfaces for I/O xAPIC
hotplug. The implemantation of these interfaces depends on each
architecture.

    o int acpi_register_ioapic(acpi_handle handle, u64 phys_addr,
			       u32 gsi_base);

        This new interface is to add a new I/O xAPIC specified by
        phys_addr and gsi_base pair. phys_addr is the physical address
        to which the I/O xAPIC is mapped and gsi_base is global system
        interrupt base of the I/O xAPIC. acpi_register_ioapic returns
        0 on success, or negative value on error.

    o int acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base);

        This new interface is to remove a I/O xAPIC specified by
        gsi_base. acpi_unregister_ioapic returns 0 on success, or
        negative value on error.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.12-rc2-mm3-kanesige/arch/i386/kernel/acpi/boot.c |   16 ++++++++++++
 linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c      |   17 +++++++++++++
 linux-2.6.12-rc2-mm3-kanesige/include/linux/acpi.h         |    3 ++
 3 files changed, 36 insertions(+)

diff -puN arch/i386/kernel/acpi/boot.c~ioapic_hotplug_acpi arch/i386/kernel/acpi/boot.c
--- linux-2.6.12-rc2-mm3/arch/i386/kernel/acpi/boot.c~ioapic_hotplug_acpi	2005-04-20 10:51:30.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/i386/kernel/acpi/boot.c	2005-04-25 13:12:46.291657116 +0900
@@ -506,6 +506,22 @@ acpi_unmap_lsapic(int cpu)
 EXPORT_SYMBOL(acpi_unmap_lsapic);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
+int
+acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_register_ioapic);
+
+int
+acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_unregister_ioapic);
+
 static unsigned long __init
 acpi_scan_rsdp (
 	unsigned long		start,
diff -puN arch/ia64/kernel/acpi.c~ioapic_hotplug_acpi arch/ia64/kernel/acpi.c
--- linux-2.6.12-rc2-mm3/arch/ia64/kernel/acpi.c~ioapic_hotplug_acpi	2005-04-20 10:51:30.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c	2005-04-25 13:13:47.819000112 +0900
@@ -892,4 +892,21 @@ acpi_map_iosapic (acpi_handle handle, u3
 	return AE_OK;
 }
 #endif /* CONFIG_NUMA */
+
+int
+acpi_register_ioapic (acpi_handle handle, u64 phys_addr, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_register_ioapic);
+
+int
+acpi_unregister_ioapic (acpi_handle handle, u32 gsi_base)
+{
+	/* TBD */
+	return -EINVAL;
+}
+EXPORT_SYMBOL(acpi_unregister_ioapic);
+
 #endif /* CONFIG_ACPI_BOOT */
diff -puN include/linux/acpi.h~ioapic_hotplug_acpi include/linux/acpi.h
--- linux-2.6.12-rc2-mm3/include/linux/acpi.h~ioapic_hotplug_acpi	2005-04-20 10:51:30.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/include/linux/acpi.h	2005-04-25 13:12:46.307282115 +0900
@@ -408,6 +408,9 @@ int acpi_map_lsapic(acpi_handle handle, 
 int acpi_unmap_lsapic(int cpu);
 #endif /* CONFIG_ACPI_HOTPLUG_CPU */
 
+int acpi_register_ioapic(acpi_handle handle, u64 phys_addr, u32 gsi_base);
+int acpi_unregister_ioapic(acpi_handle handle, u32 gsi_base);
+
 extern int acpi_mp_config;
 
 extern u32 pci_mmcfg_base_addr;

_

--------------050601030001010505080600
Content-Type: text/plain;
 name="acpi-based-i-o-apic-hot-plug-ia64-support.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="acpi-based-i-o-apic-hot-plug-ia64-support.patch"


This ia64 implementation of acpi_register_ioapic() and
acpi_unregister_ioapic() interfaces.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c    |   21 +-
 linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/iosapic.c |  134 ++++++++++++---
 linux-2.6.12-rc2-mm3-kanesige/include/asm-ia64/iosapic.h |   12 +
 3 files changed, 135 insertions(+), 32 deletions(-)

diff -puN arch/ia64/kernel/acpi.c~ioapic_hotplug_ia64 arch/ia64/kernel/acpi.c
--- linux-2.6.12-rc2-mm3/arch/ia64/kernel/acpi.c~ioapic_hotplug_ia64	2005-04-25 13:16:22.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/acpi.c	2005-04-26 21:28:14.494875134 +0900
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
 acpi_register_ioapic (acpi_handle handle, u64 phys_addr, u32 gsi_base)
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
 acpi_unregister_ioapic (acpi_handle handle, u32 gsi_base)
 {
-	/* TBD */
-	return -EINVAL;
+	return iosapic_remove(gsi_base);
 }
 EXPORT_SYMBOL(acpi_unregister_ioapic);
 
diff -puN arch/ia64/kernel/iosapic.c~ioapic_hotplug_ia64 arch/ia64/kernel/iosapic.c
--- linux-2.6.12-rc2-mm3/arch/ia64/kernel/iosapic.c~ioapic_hotplug_ia64	2005-04-25 13:16:22.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/arch/ia64/kernel/iosapic.c	2005-04-26 21:30:09.333740915 +0900
@@ -129,14 +129,13 @@ static struct iosapic {
 	char __iomem	*addr;		/* base address of IOSAPIC */
 	unsigned int 	gsi_base;	/* first GSI assigned to this IOSAPIC */
 	unsigned short 	num_rte;	/* number of RTE in this IOSAPIC */
+	int		rtes_inuse;	/* # of RTEs in use on this IOSAPIC */
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
+		iosapic_lists[index].rtes_inuse++;
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
+		iosapic_lists[index].rtes_inuse--;
+		WARN_ON(iosapic_lists[index].rtes_inuse < 0);
 
 		trigger	 = iosapic_intr_info[vector].trigger;
 		polarity = iosapic_intr_info[vector].polarity;
@@ -952,30 +955,86 @@ iosapic_system_init (int system_pcat_com
 	}
 }
 
-void __init
+static inline int
+iosapic_alloc (void)
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
+static inline void
+iosapic_free (int index)
+{
+	memset(&iosapic_lists[index], 0, sizeof(iosapic_lists[0]));
+}
+
+static inline int
+iosapic_check_gsi_range (unsigned int gsi_base, unsigned int ver)
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
+
+	spin_lock_irqsave(&iosapic_lock, flags);
+	{
+		addr = ioremap(phys_addr, 0);
+		ver = iosapic_version(addr);
 
-	addr = ioremap(phys_addr, 0);
-	ver = iosapic_version(addr);
+		if ((err = iosapic_check_gsi_range(gsi_base, ver))) {
+			iounmap(addr);
+			spin_unlock_irqrestore(&iosapic_lock, flags);
+			return err;
+		}
 
-	/*
-	 * The MAX_REDIR register holds the highest input pin
-	 * number (starting from 0).
-	 * We add 1 so that we can use it for number of pins (= RTEs)
-	 */
-	num_rte = ((ver >> 16) & 0xff) + 1;
+		/*
+		 * The MAX_REDIR register holds the highest input pin
+		 * number (starting from 0).
+		 * We add 1 so that we can use it for number of pins (= RTEs)
+		 */
+		num_rte = ((ver >> 16) & 0xff) + 1;
 
-	iosapic_lists[num_iosapic].addr = addr;
-	iosapic_lists[num_iosapic].gsi_base = gsi_base;
-	iosapic_lists[num_iosapic].num_rte = num_rte;
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
 
 	if ((gsi_base == 0) && pcat_compat) {
 		/*
@@ -986,10 +1045,43 @@ iosapic_init (unsigned long phys_addr, u
 		for (isa_irq = 0; isa_irq < 16; ++isa_irq)
 			iosapic_override_isa_irq(isa_irq, isa_irq, IOSAPIC_POL_HIGH, IOSAPIC_EDGE);
 	}
+	return 0;
+}
+
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
+		if (iosapic_lists[index].rtes_inuse) {
+			err = -EBUSY;
+			printk(KERN_WARNING "%s: IOSAPIC for GSI base %u is busy\n",
+			       __FUNCTION__, gsi_base);
+			goto out;
+		}
+
+		iounmap(iosapic_lists[index].addr);
+		iosapic_free(index);
+	}
+ out:
+	spin_unlock_irqrestore(&iosapic_lock, flags);
+	return err;
 }
+#endif /* CONFIG_HOTPLUG */
 
 #ifdef CONFIG_NUMA
-void __init
+void __devinit
 map_iosapic_to_node(unsigned int gsi_base, int node)
 {
 	int index;
diff -puN include/asm-ia64/iosapic.h~ioapic_hotplug_ia64 include/asm-ia64/iosapic.h
--- linux-2.6.12-rc2-mm3/include/asm-ia64/iosapic.h~ioapic_hotplug_ia64	2005-04-25 13:16:22.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/include/asm-ia64/iosapic.h	2005-04-25 13:16:22.000000000 +0900
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

--------------050601030001010505080600
Content-Type: text/plain;
 name="acpi-based-i-o-apic-hot-plug-acpiphp-support.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="acpi-based-i-o-apic-hot-plug-acpiphp-support.patch"


This patch adds PCI based I/O xAPIC hot-add support to ACPIPHP
driver. When PCI root bridge is hot-added, all PCI based I/O xAPICs
under the root bridge are hot-added by this patch. Hot-remove support
is TBD.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.12-rc2-mm3-kanesige/drivers/pci/hotplug/acpiphp_glue.c |  127 ++++++++++
 linux-2.6.12-rc2-mm3-kanesige/include/linux/pci_ids.h            |    2 
 2 files changed, 129 insertions(+)

diff -puN drivers/pci/hotplug/acpiphp_glue.c~acpiphp_ioapic_add drivers/pci/hotplug/acpiphp_glue.c
--- linux-2.6.12-rc2-mm3/drivers/pci/hotplug/acpiphp_glue.c~acpiphp_ioapic_add	2005-04-26 21:30:18.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/drivers/pci/hotplug/acpiphp_glue.c	2005-04-26 21:54:26.000000000 +0900
@@ -552,6 +552,132 @@ static void remove_bridge(acpi_handle ha
 	}
 }
 
+static struct pci_dev * get_apic_pci_info(acpi_handle handle)
+{
+	struct acpi_pci_id id;
+	struct pci_bus *bus;
+	struct pci_dev *dev;
+
+	if (ACPI_FAILURE(acpi_get_pci_id(handle, &id)))
+		return NULL;
+
+	bus = pci_find_bus(id.segment, id.bus);
+	if (!bus)
+		return NULL;
+
+	dev = pci_get_slot(bus, PCI_DEVFN(id.device, id.function));
+	if (!dev)
+		return NULL;
+
+	if ((dev->class != PCI_CLASS_SYSTEM_PIC_IOAPIC) &&
+	    (dev->class != PCI_CLASS_SYSTEM_PIC_IOXAPIC))
+	{
+		pci_dev_put(dev);
+		return NULL;
+	}
+
+	return dev;
+}
+
+static int get_gsi_base(acpi_handle handle, u32 *gsi_base)
+{
+	acpi_status status;
+	int result = -1;
+	unsigned long gsb;
+	struct acpi_buffer buffer = {ACPI_ALLOCATE_BUFFER, NULL};
+	union acpi_object *obj;
+	void *table;
+
+	status = acpi_evaluate_integer(handle, "_GSB", NULL, &gsb);
+	if (ACPI_SUCCESS(status)) {
+		*gsi_base = (u32)gsb;
+		return 0;
+	}
+
+	status = acpi_evaluate_object(handle, "_MAT", NULL, &buffer);
+	if (ACPI_FAILURE(status) || !buffer.length || !buffer.pointer)
+		return -1;
+
+	obj = buffer.pointer;
+	if (obj->type != ACPI_TYPE_BUFFER)
+		goto out;
+
+	table = obj->buffer.pointer;
+	switch (((acpi_table_entry_header *)table)->type) {
+	case ACPI_MADT_IOSAPIC:
+		*gsi_base = ((struct acpi_table_iosapic *)table)->global_irq_base;
+		result = 0;
+		break;
+	case ACPI_MADT_IOAPIC:
+		*gsi_base = ((struct acpi_table_ioapic *)table)->global_irq_base;
+		result = 0;
+		break;
+	default:
+		break;
+	}
+ out:
+	acpi_os_free(buffer.pointer);
+	return result;
+}
+
+static acpi_status
+ioapic_add(acpi_handle handle, u32 lvl, void *context, void **rv)
+{
+	acpi_status status;
+	unsigned long sta;
+	acpi_handle tmp;
+	struct pci_dev *pdev;
+	u32 gsi_base;
+	u64 phys_addr;
+
+	/* Evaluate _STA if present */
+	status = acpi_evaluate_integer(handle, "_STA", NULL, &sta);
+	if (ACPI_SUCCESS(status) && sta != ACPI_STA_ALL)
+		return AE_CTRL_DEPTH;
+
+	/* Scan only PCI bus scope */
+	status = acpi_get_handle(handle, "_HID", &tmp);
+	if (ACPI_SUCCESS(status))
+		return AE_CTRL_DEPTH;
+
+	if (get_gsi_base(handle, &gsi_base))
+		return AE_OK;
+
+	pdev = get_apic_pci_info(handle);
+	if (!pdev)
+		return AE_OK;
+
+	if (pci_enable_device(pdev)) {
+		pci_dev_put(pdev);
+		return AE_OK;
+	}
+
+	pci_set_master(pdev);
+
+	if (pci_request_region(pdev, 0, "I/O APIC(acpiphp)")) {
+		pci_disable_device(pdev);
+		pci_dev_put(pdev);
+		return AE_OK;
+	}
+
+	phys_addr = pci_resource_start(pdev, 0);
+	if (acpi_register_ioapic(handle, phys_addr, gsi_base)) {
+		pci_release_region(pdev, 0);
+		pci_disable_device(pdev);
+		pci_dev_put(pdev);
+		return AE_OK;
+	}
+
+	return AE_OK;
+}
+
+static int acpiphp_configure_ioapics(acpi_handle handle)
+{
+	acpi_walk_namespace(ACPI_TYPE_DEVICE, handle,
+			    ACPI_UINT32_MAX, ioapic_add, NULL, NULL);
+	return 0;
+}
+
 static int power_on_slot(struct acpiphp_slot *slot)
 {
 	acpi_status status;
@@ -942,6 +1068,7 @@ static int acpiphp_configure_bridge (acp
 	acpiphp_sanitize_bus(bus);
 	acpiphp_set_hpp_values(handle, bus);
 	pci_enable_bridges(bus);
+	acpiphp_configure_ioapics(handle);
 	return 0;
 }
 
diff -puN include/linux/pci_ids.h~acpiphp_ioapic_add include/linux/pci_ids.h
--- linux-2.6.12-rc2-mm3/include/linux/pci_ids.h~acpiphp_ioapic_add	2005-04-26 21:30:18.000000000 +0900
+++ linux-2.6.12-rc2-mm3-kanesige/include/linux/pci_ids.h	2005-04-26 21:30:18.000000000 +0900
@@ -62,6 +62,8 @@
 
 #define PCI_BASE_CLASS_SYSTEM		0x08
 #define PCI_CLASS_SYSTEM_PIC		0x0800
+#define PCI_CLASS_SYSTEM_PIC_IOAPIC	0x080010
+#define PCI_CLASS_SYSTEM_PIC_IOXAPIC	0x080020
 #define PCI_CLASS_SYSTEM_DMA		0x0801
 #define PCI_CLASS_SYSTEM_TIMER		0x0802
 #define PCI_CLASS_SYSTEM_RTC		0x0803

_

--------------050601030001010505080600--
