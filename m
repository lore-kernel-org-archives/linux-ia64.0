From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 10 Sep 2003 19:07:06 +0000
Subject: [PATCH] 2.4 IA64 ZX1 gart support
Message-Id: <marc-linux-ia64-106322242900336@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This updates the GART support for the IA64 HP ZX1 chipset.
As with the 460GX, there's more infrastructure that this
depends on that will remain in the ia64 patch.

--- 1.23/drivers/char/agp/agp.h	Wed Sep 10 14:49:49 2003
+++ edited/drivers/char/agp/agp.h	Wed Sep 10 14:59:32 2003
@@ -511,14 +511,16 @@
 #define NVIDIA_3_APBASE     0x50
 #define NVIDIA_3_APLIMIT    0x54
 
-/* HP ZX1 SBA registers */
-#define HP_ZX1_CTRL		0x200
+/* HP ZX1 IOC registers */
 #define HP_ZX1_IBASE		0x300
 #define HP_ZX1_IMASK		0x308
 #define HP_ZX1_PCOM		0x310
 #define HP_ZX1_TCNFG		0x318
 #define HP_ZX1_PDIR_BASE	0x320
-#define HP_ZX1_CACHE_FLUSH	0x428
+
+/* HP ZX1 LBA registers */
+#define HP_ZX1_AGP_STATUS	0x64
+#define HP_ZX1_AGP_COMMAND	0x68
 
 /* ATI register */
 #define ATI_APBASE                  0x10
=== drivers/char/agp/agpgart_be.c 1.47 vs edited ==--- 1.47/drivers/char/agp/agpgart_be.c	Wed Sep 10 14:49:49 2003
+++ edited/drivers/char/agp/agpgart_be.c	Wed Sep 10 15:01:55 2003
@@ -5038,6 +5038,8 @@
 #define log2(x)		ffz(~(x))
 #endif
 
+#define HP_ZX1_IOC_OFFSET	0x1000  /* ACPI reports SBA, we want IOC */
+
 #define HP_ZX1_IOVA_BASE	GB(1UL)
 #define HP_ZX1_IOVA_SIZE	GB(1UL)
 #define HP_ZX1_GART_SIZE	(HP_ZX1_IOVA_SIZE / 2)
@@ -5047,19 +5049,16 @@
 #define HP_ZX1_IOVA_TO_PDIR(va)	((va - hp_private.iova_base) >> \
 					hp_private.io_tlb_shift)
 
+static int hp_zx1_gart_found;
+
 static aper_size_info_fixed hp_zx1_sizes[]  {
 	{0, 0, 0},		/* filled in by hp_zx1_fetch_size() */
 };
 
-static gatt_mask hp_zx1_masks[] -{
-	{HP_ZX1_PDIR_VALID_BIT, 0}
-};
-
 static struct _hp_private {
-	struct pci_dev *ioc;
-	volatile u8 *registers;
+	volatile u8 *ioc_regs;
+	volatile u8 *lba_regs;
 	u64 *io_pdir;		// PDIR for entire IOVA
 	u64 *gatt;		// PDIR just for GART (subset of above)
 	u64 gatt_entries;
@@ -5086,7 +5085,7 @@
 	 * 	- IOVA space is 1Gb in size
 	 * 	- first 512Mb is IOMMU, second 512Mb is GART
 	 */
-	hp->io_tlb_ps = INREG64(hp->registers, HP_ZX1_TCNFG);
+	hp->io_tlb_ps = INREG64(hp->ioc_regs, HP_ZX1_TCNFG);
 	switch (hp->io_tlb_ps) {
 		case 0: hp->io_tlb_shift = 12; break;
 		case 1: hp->io_tlb_shift = 13; break;
@@ -5102,13 +5101,13 @@
 	hp->io_page_size = 1 << hp->io_tlb_shift;
 	hp->io_pages_per_kpage = PAGE_SIZE / hp->io_page_size;
 
-	hp->iova_base = INREG64(hp->registers, HP_ZX1_IBASE) & ~0x1;
+	hp->iova_base = INREG64(hp->ioc_regs, HP_ZX1_IBASE) & ~0x1;
 	hp->gart_base = hp->iova_base + HP_ZX1_IOVA_SIZE - HP_ZX1_GART_SIZE;
 
 	hp->gart_size = HP_ZX1_GART_SIZE;
 	hp->gatt_entries = hp->gart_size / hp->io_page_size;
 
-	hp->io_pdir = phys_to_virt(INREG64(hp->registers, HP_ZX1_PDIR_BASE));
+	hp->io_pdir = phys_to_virt(INREG64(hp->ioc_regs, HP_ZX1_PDIR_BASE));
 	hp->gatt = &hp->io_pdir[HP_ZX1_IOVA_TO_PDIR(hp->gart_base)];
 
 	if (hp->gatt[0] != HP_ZX1_SBA_IOMMU_COOKIE) {
@@ -5122,7 +5121,7 @@
 	return 0;
 }
 
-static int __init hp_zx1_ioc_owner(u8 ioc_rev)
+static int __init hp_zx1_ioc_owner(void)
 {
 	struct _hp_private *hp = &hp_private;
 
@@ -5157,44 +5156,21 @@
 	return 0;
 }
 
-static int __init hp_zx1_ioc_init(void)
+static int __init hp_zx1_ioc_init(u64 ioc_hpa, u64 lba_hpa)
 {
 	struct _hp_private *hp = &hp_private;
-	struct pci_dev *ioc;
-	int i;
-	u8 ioc_rev;
-
-	ioc = pci_find_device(PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_ZX1_IOC, NULL);
-	if (!ioc) {
-		printk(KERN_ERR PFX "Detected HP ZX1 AGP bridge but no IOC\n");
-		return -ENODEV;
-	}
-	hp->ioc = ioc;
-
-	pci_read_config_byte(ioc, PCI_REVISION_ID, &ioc_rev);
-
-	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
-		if (pci_resource_flags(ioc, i) = IORESOURCE_MEM) {
-			hp->registers = (u8 *) ioremap(pci_resource_start(ioc,
-									    i),
-						    pci_resource_len(ioc, i));
-			break;
-		}
-	}
-	if (!hp->registers) {
-		printk(KERN_ERR PFX "Detected HP ZX1 AGP bridge but no CSRs\n");
 
-		return -ENODEV;
-	}
+	hp->ioc_regs = ioremap(ioc_hpa, 1024);
+	hp->lba_regs = ioremap(lba_hpa, 256);
 
 	/*
 	 * If the IOTLB is currently disabled, we can take it over.
 	 * Otherwise, we have to share with sba_iommu.
 	 */
-	hp->io_pdir_owner = (INREG64(hp->registers, HP_ZX1_IBASE) & 0x1) = 0;
+	hp->io_pdir_owner = (INREG64(hp->ioc_regs, HP_ZX1_IBASE) & 0x1) = 0;
 
 	if (hp->io_pdir_owner)
-		return hp_zx1_ioc_owner(ioc_rev);
+		return hp_zx1_ioc_owner();
 
 	return hp_zx1_ioc_shared();
 }
@@ -5214,19 +5190,17 @@
 	struct _hp_private *hp = &hp_private;
 
 	agp_bridge.gart_bus_addr = hp->gart_base;
-	agp_bridge.capndx = pci_find_capability(agp_bridge.dev, PCI_CAP_ID_AGP);
-	pci_read_config_dword(agp_bridge.dev,
-		agp_bridge.capndx + PCI_AGP_STATUS, &agp_bridge.mode);
+	agp_bridge.mode = INREG32(hp->lba_regs, HP_ZX1_AGP_STATUS);
 
 	if (hp->io_pdir_owner) {
-		OUTREG64(hp->registers, HP_ZX1_PDIR_BASE,
+		OUTREG64(hp->ioc_regs, HP_ZX1_PDIR_BASE,
 			virt_to_phys(hp->io_pdir));
-		OUTREG64(hp->registers, HP_ZX1_TCNFG, hp->io_tlb_ps);
-		OUTREG64(hp->registers, HP_ZX1_IMASK, ~(HP_ZX1_IOVA_SIZE - 1));
-		OUTREG64(hp->registers, HP_ZX1_IBASE, hp->iova_base | 0x1);
-		OUTREG64(hp->registers, HP_ZX1_PCOM,
+		OUTREG64(hp->ioc_regs, HP_ZX1_TCNFG, hp->io_tlb_ps);
+		OUTREG64(hp->ioc_regs, HP_ZX1_IMASK, ~(HP_ZX1_IOVA_SIZE - 1));
+		OUTREG64(hp->ioc_regs, HP_ZX1_IBASE, hp->iova_base | 0x1);
+		OUTREG64(hp->ioc_regs, HP_ZX1_PCOM,
 			hp->iova_base | log2(HP_ZX1_IOVA_SIZE));
-		INREG64(hp->registers, HP_ZX1_PCOM);
+		INREG64(hp->ioc_regs, HP_ZX1_PCOM);
 	}
 
 	return 0;
@@ -5237,17 +5211,18 @@
 	struct _hp_private *hp = &hp_private;
 
 	if (hp->io_pdir_owner)
-		OUTREG64(hp->registers, HP_ZX1_IBASE, 0);
-	iounmap((void *) hp->registers);
+		OUTREG64(hp->ioc_regs, HP_ZX1_IBASE, 0);
+	iounmap((void *) hp->ioc_regs);
+	iounmap((void *) hp->lba_regs);
 }
 
 static void hp_zx1_tlbflush(agp_memory * mem)
 {
 	struct _hp_private *hp = &hp_private;
 
-	OUTREG64(hp->registers, HP_ZX1_PCOM, 
+	OUTREG64(hp->ioc_regs, HP_ZX1_PCOM, 
 		hp->gart_base | log2(hp->gart_size));
-	INREG64(hp->registers, HP_ZX1_PCOM);
+	INREG64(hp->ioc_regs, HP_ZX1_PCOM);
 }
 
 static int hp_zx1_create_gatt_table(void)
@@ -5314,11 +5289,6 @@
 		j++;
 	}
 
-	if (mem->is_flushed = FALSE) {
-		CACHE_FLUSH();
-		mem->is_flushed = TRUE;
-	}
-
 	for (i = 0, j = io_pg_start; i < mem->page_count; i++) {
 		unsigned long paddr;
 
@@ -5358,14 +5328,23 @@
 	return HP_ZX1_PDIR_VALID_BIT | addr;
 }
 
-static unsigned long hp_zx1_unmask_memory(unsigned long addr)
+static void hp_zx1_agp_enable(u32 mode)
 {
-	return addr & ~(HP_ZX1_PDIR_VALID_BIT);
+	struct _hp_private *hp = &hp_private;
+	u32 command;
+
+	command = INREG32(hp->lba_regs, HP_ZX1_AGP_STATUS);
+
+	command = agp_collect_device_status(mode, command);
+	command |= 0x00000100;
+
+	OUTREG32(hp->lba_regs, HP_ZX1_AGP_COMMAND, command);
+
+	agp_device_command(command, 0);
 }
 
-static int __init hp_zx1_setup (struct pci_dev *pdev)
+static int __init hp_zx1_setup(u64 ioc_hpa, u64 lba_hpa)
 {
-	agp_bridge.masks = hp_zx1_masks;
 	agp_bridge.dev_private_data = NULL;
 	agp_bridge.size_type = FIXED_APER_SIZE;
 	agp_bridge.needs_scratch_page = FALSE;
@@ -5374,8 +5353,7 @@
 	agp_bridge.cleanup = hp_zx1_cleanup;
 	agp_bridge.tlb_flush = hp_zx1_tlbflush;
 	agp_bridge.mask_memory = hp_zx1_mask_memory;
-	agp_bridge.unmask_memory = hp_zx1_unmask_memory;
-	agp_bridge.agp_enable = agp_generic_agp_enable;
+	agp_bridge.agp_enable = hp_zx1_agp_enable;
 	agp_bridge.cache_flush = global_cache_flush;
 	agp_bridge.create_gatt_table = hp_zx1_create_gatt_table;
 	agp_bridge.free_gatt_table = hp_zx1_free_gatt_table;
@@ -5386,10 +5364,76 @@
 	agp_bridge.agp_alloc_page = agp_generic_alloc_page;
 	agp_bridge.agp_destroy_page = agp_generic_destroy_page;
 	agp_bridge.cant_use_aperture = 1;
+	agp_bridge.type = HP_ZX1;
 
-	return hp_zx1_ioc_init();
+	fake_bridge_dev.vendor = PCI_VENDOR_ID_HP;
+	fake_bridge_dev.device = PCI_DEVICE_ID_HP_PCIX_LBA;
 
-	(void) pdev; /* unused */
+	return hp_zx1_ioc_init(ioc_hpa, lba_hpa);
+}
+
+static acpi_status __init hp_zx1_gart_probe(acpi_handle obj, u32 depth, void *context, void **ret)
+{
+	acpi_handle handle, parent;
+	acpi_status status;
+	struct acpi_buffer buffer;
+	struct acpi_device_info *info;
+	u64 lba_hpa, sba_hpa, length;
+	int match;
+
+	status = acpi_hp_csr_space(obj, &lba_hpa, &length);
+	if (ACPI_FAILURE(status))
+		return AE_OK;
+
+	/* Look for an enclosing IOC scope and find its CSR space */
+	handle = obj;
+	do {
+		buffer.length = ACPI_ALLOCATE_LOCAL_BUFFER;
+		status = acpi_get_object_info(handle, &buffer);
+		if (ACPI_SUCCESS(status)) {
+			/* TBD check _CID also */
+			info = buffer.pointer;
+			info->hardware_id.value[sizeof(info->hardware_id)-1] = '\0';
+			match = (strcmp(info->hardware_id.value, "HWP0001") = 0);
+			ACPI_MEM_FREE(info);
+			if (match) {
+				status = acpi_hp_csr_space(handle, &sba_hpa, &length);
+				if (ACPI_SUCCESS(status))
+					break;
+				else {
+					printk(KERN_ERR PFX "Detected HP ZX1 "
+					       "AGP LBA but no IOC.\n");
+					return AE_OK;
+				}
+			}
+		}
+
+		status = acpi_get_parent(handle, &parent);
+		handle = parent;
+	} while (ACPI_SUCCESS(status));
+
+	if (hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa))
+		return AE_OK;
+
+	printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset (ioc=%lx, lba=%lx)\n",
+		(char *) context, sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
+
+	hp_zx1_gart_found = 1;
+	return AE_CTRL_TERMINATE;
+}
+
+static int __init
+hp_zx1_gart_init(void)
+{
+	acpi_get_devices("HWP0003", hp_zx1_gart_probe, "HWP0003", NULL);
+	if (hp_zx1_gart_found)
+		return 0;
+
+	acpi_get_devices("HWP0007", hp_zx1_gart_probe, "HWP0007", NULL);
+	if (hp_zx1_gart_found)
+		return 0;
+
+	return -ENODEV;
 }
 
 #endif /* CONFIG_AGP_HP_ZX1 */
@@ -6250,15 +6294,6 @@
 		nvidia_generic_setup },
 #endif /* CONFIG_AGP_NVIDIA */
 
-#ifdef CONFIG_AGP_HP_ZX1
-	{ PCI_DEVICE_ID_HP_ZX1_LBA,
-		PCI_VENDOR_ID_HP,
-		HP_ZX1,
-		"HP",
-		"ZX1",
-		hp_zx1_setup },
-#endif
-
 #ifdef CONFIG_AGP_ATI
 	{ PCI_DEVICE_ID_ATI_RS100,
 	  PCI_VENDOR_ID_ATI,
@@ -6390,6 +6425,11 @@
 	struct pci_dev *dev = NULL;
 	u8 cap_ptr = 0x00;
 
+#ifdef CONFIG_AGP_HP_ZX1
+	if (hp_zx1_gart_init() = 0)
+		return 0;
+#endif
+
 	if ((dev = pci_find_class(PCI_CLASS_BRIDGE_HOST << 8, NULL)) = NULL)
 		return -ENODEV;
 
@@ -6662,23 +6702,6 @@
 	}
 
 #endif	/* CONFIG_AGP_SWORKS */
-
-#ifdef CONFIG_AGP_HP_ZX1
-	if (dev->vendor = PCI_VENDOR_ID_HP) {
-		do {
-			/* ZX1 LBAs can be either PCI or AGP bridges */
-			if (pci_find_capability(dev, PCI_CAP_ID_AGP)) {
-				printk(KERN_INFO PFX "Detected HP ZX1 AGP "
-				       "chipset at %s\n", dev->slot_name);
-				agp_bridge.type = HP_ZX1;
-				agp_bridge.dev = dev;
-				return hp_zx1_setup(dev);
-			}
-			dev = pci_find_class(PCI_CLASS_BRIDGE_HOST << 8, dev);
-		} while (dev);
-		return -ENODEV;
-	}
-#endif	/* CONFIG_AGP_HP_ZX1 */
 
 	/* find capndx */
 	cap_ptr = pci_find_capability(dev, PCI_CAP_ID_AGP);
=== drivers/char/drm-4.0/agpsupport.c 1.6 vs edited ==--- 1.6/drivers/char/drm-4.0/agpsupport.c	Wed Sep 10 14:49:49 2003
+++ edited/drivers/char/drm-4.0/agpsupport.c	Wed Sep 10 15:01:15 2003
@@ -301,6 +301,7 @@
 			break;
 		case SVWRKS_HE: 	head->chipset = "Serverworks HE"; break;
 		case SVWRKS_LE: 	head->chipset = "Serverworks LE"; break;
+		case HP_ZX1:		head->chipset = "HP ZX1";	break;
 
 		default:		head->chipset = "Unknown";       break;
 		}

