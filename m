From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 12 Jan 2004 19:38:24 +0000
Subject: [PATCH] HP ZX1 AGPGART update
Message-Id: <200401121238.24157.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(Oops, forgot to cc: linux-ia64).

Hi Dave,

Here's a patch to update the HP ZX1 AGPGART support in 2.6.  It

        - Moves HP AGP #defines out of shared header
        - Adds better error checking/recovery
        - Adds support for AGP3 bridge (we previously recognized the
          new ACPI _HID, but didn't handle the moved AGP capability).

Bjorn

=== drivers/char/agp/agp.h 1.82 vs edited ==--- 1.82/drivers/char/agp/agp.h	Fri Sep  5 13:47:05 2003
+++ edited/drivers/char/agp/agp.h	Wed Dec 31 13:20:03 2003
@@ -345,15 +345,6 @@
 #define SVWRKS_POSTFLUSH	0x14
 #define SVWRKS_DIRFLUSH		0x0c
 
-/* HP ZX1 SBA registers */
-#define HP_ZX1_CTRL		0x200
-#define HP_ZX1_IBASE		0x300
-#define HP_ZX1_IMASK		0x308
-#define HP_ZX1_PCOM		0x310
-#define HP_ZX1_TCNFG		0x318
-#define HP_ZX1_PDIR_BASE	0x320
-#define HP_ZX1_CACHE_FLUSH	0x428
-
 /* NVIDIA registers */
 #define NVIDIA_0_APSIZE		0x80
 #define NVIDIA_1_WBC		0xf0
=== drivers/char/agp/hp-agp.c 1.27 vs edited ==--- 1.27/drivers/char/agp/hp-agp.c	Wed Sep 17 11:52:42 2003
+++ edited/drivers/char/agp/hp-agp.c	Mon Jan 12 11:58:38 2004
@@ -1,7 +1,7 @@
 /*
  * HP AGPGART routines.
- *	Copyright (C) 2002-2003 Hewlett-Packard Co
- *		Bjorn Helgaas <bjorn_helgaas@hp.com>
+ *	Copyright (C) 2002-2004 Hewlett-Packard Co
+ *		Bjorn Helgaas <bjorn.helgaas@hp.com>
  */
 
 #include <linux/acpi.h>
@@ -27,10 +27,6 @@
 #define HP_ZX1_TCNFG		0x318
 #define HP_ZX1_PDIR_BASE	0x320
 
-/* HP ZX1 LBA registers */
-#define HP_ZX1_AGP_STATUS	0x64
-#define HP_ZX1_AGP_COMMAND	0x68
-
 #define HP_ZX1_IOVA_BASE	GB(1UL)
 #define HP_ZX1_IOVA_SIZE	GB(1UL)
 #define HP_ZX1_GART_SIZE	(HP_ZX1_IOVA_SIZE / 2)
@@ -57,6 +53,7 @@
 static struct _hp_private {
 	volatile u8 *ioc_regs;
 	volatile u8 *lba_regs;
+	int lba_cap_offset;
 	u64 *io_pdir;		// PDIR for entire IOVA
 	u64 *gatt;		// PDIR just for GART (subset of above)
 	u64 gatt_entries;
@@ -75,8 +72,6 @@
 {
 	struct _hp_private *hp = &hp_private;
 
-	printk(KERN_INFO PFX "HP ZX1 IOC: IOPDIR shared with sba_iommu\n");
-
 	/*
 	 * IOC already configured by sba_iommu module; just use
 	 * its setup.  We assume:
@@ -109,10 +104,9 @@
 	hp->gatt = &hp->io_pdir[HP_ZX1_IOVA_TO_PDIR(hp->gart_base)];
 
 	if (hp->gatt[0] != HP_ZX1_SBA_IOMMU_COOKIE) {
+		/* Normal case when no AGP device in system */
 	    	hp->gatt = 0;
 		hp->gatt_entries = 0;
-		printk(KERN_ERR PFX "No reserved IO PDIR entry found; "
-		       "GART disabled\n");
 		return -ENODEV;
 	}
 
@@ -124,8 +118,6 @@
 {
 	struct _hp_private *hp = &hp_private;
 
-	printk(KERN_INFO PFX "HP ZX1 IOC: IOPDIR dedicated to GART\n");
-
 	/*
 	 * Select an IOV page size no larger than system page size.
 	 */
@@ -156,12 +148,13 @@
 }
 
 static int __init
-hp_zx1_ioc_init (u64 ioc_hpa, u64 lba_hpa)
+hp_zx1_ioc_init (u64 hpa)
 {
 	struct _hp_private *hp = &hp_private;
 
-	hp->ioc_regs = ioremap(ioc_hpa, 1024);
-	hp->lba_regs = ioremap(lba_hpa, 256);
+	hp->ioc_regs = ioremap(hpa, 1024);
+	if (!hp->ioc_regs)
+		return -ENOMEM;
 
 	/*
 	 * If the IOTLB is currently disabled, we can take it over.
@@ -176,6 +169,50 @@
 }
 
 static int
+hp_zx1_lba_find_capability(volatile u8 *hpa, int cap)
+{
+	u16 status;
+	u8 pos, id;
+	int ttl = 48;
+
+	status = INREG16(hpa, PCI_STATUS);
+	if (!(status & PCI_STATUS_CAP_LIST))
+		return 0;
+	pos = INREG8(hpa, PCI_CAPABILITY_LIST);
+	while (ttl-- && pos >= 0x40) {
+		pos &= ~3;
+		id = INREG8(hpa, pos + PCI_CAP_LIST_ID);
+		if (id = 0xff)
+			break;
+		if (id = cap)
+			return pos;
+		pos = INREG8(hpa, pos + PCI_CAP_LIST_NEXT);
+	}
+	return 0;
+}
+
+static int __init hp_zx1_lba_init(u64 hpa)
+{
+	struct _hp_private *hp = &hp_private;
+	int cap;
+
+	hp->lba_regs = ioremap(hpa, 256);
+	if (!hp->lba_regs)
+		return -ENOMEM;
+
+	hp->lba_cap_offset = hp_zx1_lba_find_capability(hp->lba_regs, PCI_CAP_ID_AGP);
+
+	cap = INREG32(hp->lba_regs, hp->lba_cap_offset) & 0xff;
+	if (cap != PCI_CAP_ID_AGP) {
+		printk(KERN_ERR PFX "Invalid capability ID 0x%02x at 0x%x\n",
+			cap, hp->lba_cap_offset);
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static int
 hp_zx1_fetch_size(void)
 {
 	int size;
@@ -192,13 +229,7 @@
 	struct _hp_private *hp = &hp_private;
 
 	agp_bridge->gart_bus_addr = hp->gart_base;
-#if 0
-	/* ouch!! can't do that with a non-PCI AGP bridge... */
-	agp_bridge->capndx = pci_find_capability(agp_bridge->dev, PCI_CAP_ID_AGP);
-#else
-	agp_bridge->capndx = 0;
-#endif
-	agp_bridge->mode = INREG32(hp->lba_regs, HP_ZX1_AGP_STATUS);
+	agp_bridge->mode = INREG32(hp->lba_regs, hp->lba_cap_offset + PCI_AGP_STATUS);
 
 	if (hp->io_pdir_owner) {
 		OUTREG64(hp->ioc_regs, HP_ZX1_PDIR_BASE, virt_to_phys(hp->io_pdir));
@@ -217,9 +248,13 @@
 {
 	struct _hp_private *hp = &hp_private;
 
-	if (hp->io_pdir_owner)
-		OUTREG64(hp->ioc_regs, HP_ZX1_IBASE, 0);
-	iounmap((void *) hp->ioc_regs);
+	if (hp->ioc_regs) {
+		if (hp->io_pdir_owner)
+			OUTREG64(hp->ioc_regs, HP_ZX1_IBASE, 0);
+		iounmap((void *) hp->ioc_regs);
+	}
+	if (hp->lba_regs)
+		iounmap((void *) hp->lba_regs);
 }
 
 static void
@@ -350,12 +385,15 @@
 	struct _hp_private *hp = &hp_private;
 	u32 command;
 
-	command = INREG32(hp->lba_regs, HP_ZX1_AGP_STATUS);
+	printk(KERN_INFO PFX "Found an AGP %d.%d compliant device.\n",
+		agp_bridge->major_version, agp_bridge->minor_version);
+
+	command = INREG32(hp->lba_regs, hp->lba_cap_offset + PCI_AGP_STATUS);
 
 	command = agp_collect_device_status(mode, command);
 	command |= 0x00000100;
 
-	OUTREG32(hp->lba_regs, HP_ZX1_AGP_COMMAND, command);
+	OUTREG32(hp->lba_regs, hp->lba_cap_offset + PCI_AGP_COMMAND, command);
 
 	agp_device_command(command, 0);
 }
@@ -385,23 +423,43 @@
 static int __init
 hp_zx1_setup (u64 ioc_hpa, u64 lba_hpa)
 {
+	struct _hp_private *hp = &hp_private;
 	struct agp_bridge_data *bridge;
+	u32 cap;
 	int error;
 
-	error = hp_zx1_ioc_init(ioc_hpa, lba_hpa);
+	memset(hp, 0, sizeof(*hp));
+
+	error = hp_zx1_ioc_init(ioc_hpa);
 	if (error)
-		return error;
+		goto fail;
+
+	error = hp_zx1_lba_init(lba_hpa);
+	if (error)
+		goto fail;
 
 	bridge = agp_alloc_bridge();
-	if (!bridge)
-		return -ENOMEM;
+	if (!bridge) {
+		error = -ENOMEM;
+		goto fail;
+	}
+
 	bridge->driver = &hp_zx1_driver;
 
+	cap = INREG32(hp->lba_regs, hp->lba_cap_offset);
+	bridge->major_version = (cap >> AGP_MAJOR_VERSION_SHIFT) & 0xf;
+	bridge->minor_version = (cap >> AGP_MINOR_VERSION_SHIFT) & 0xf;
+
 	fake_bridge_dev.vendor = PCI_VENDOR_ID_HP;
 	fake_bridge_dev.device = PCI_DEVICE_ID_HP_PCIX_LBA;
 	bridge->dev = &fake_bridge_dev;
 
-	return agp_add_bridge(bridge);
+	error = agp_add_bridge(bridge);
+
+fail:
+	if (error)
+		hp_zx1_cleanup();
+	return error;
 }
 
 static acpi_status __init
@@ -416,7 +474,7 @@
 
 	status = hp_acpi_csr_space(obj, &lba_hpa, &length);
 	if (ACPI_FAILURE(status))
-		return AE_OK;
+		return AE_OK; /* keep looking for another bridge */
 
 	/* Look for an enclosing IOC scope and find its CSR space */
 	handle = obj;
@@ -448,11 +506,11 @@
 	if (hp_zx1_setup(sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa))
 		return AE_OK;
 
-	printk(KERN_INFO PFX "Detected HP ZX1 %s AGP chipset (ioc=%lx, lba=%lx)\n",
+	printk(KERN_INFO PFX "Detected HP ZX1 %s chipset (ioc=0x%lx, lba=0x%lx)\n",
 		(char *) context, sba_hpa + HP_ZX1_IOC_OFFSET, lba_hpa);
 
 	hp_zx1_gart_found = 1;
-	return AE_CTRL_TERMINATE;
+	return AE_CTRL_TERMINATE; /* we only support one bridge; quit looking */
 }
 
 static int __init


