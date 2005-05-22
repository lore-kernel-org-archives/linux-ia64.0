From: Prarit Bhargava <prarit@sgi.com>
Date: Sun, 22 May 2005 01:13:09 +0000
Subject: Re: [Pcihpd-discuss] [PATCH 5/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428FDCA5.3040801@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090806010407040802000606"
List-Id: <linux-ia64.vger.kernel.org>
References: <200505131003.18143@bilbo.math.uni-mannheim.de>
In-Reply-To: <200505131003.18143@bilbo.math.uni-mannheim.de>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090806010407040802000606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Greg KH wrote:
> On Fri, May 20, 2005 at 08:24:09PM -0400, Prarit Bhargava wrote:
> 
>>+	list_for_each(list, &sn_sysdata_list) {
>>+		element = list_entry(list, struct sysdata_el, entry);
> 
> 
> All instances of list_for_each() and then a list_entry() call can be
> replaced with list_for_each_entry().

New patch with list_for_each_entry.

P.


--------------090806010407040802000606
Content-Type: text/plain;
 name="hp.patch-5"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hp.patch-5"

This patch is the SGI hotplug driver and additional changes required for
the driver.  These modifications include changes to the SN io_init.c code
for memory management, the inclusion of new SAL calls to enable and disable
PCI slots, and a hotplug-style driver.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 7ec91b987e364af6998f9f26a744d0a343e05ca1
tree 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848
parent c95c10da25e11764596c4517c02fea3b9df6753c
author Prarit Bhargava <prarit@sgi.com> 1810947453 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810947453 -0400

Index: arch/ia64/sn/kernel/io_init.c
===================================================================
--- f8014bc6a8330d22e2dbb0cac34d87e8a5352278/arch/ia64/sn/kernel/io_init.c  (mode:100644 sha1:ae6628cd41f8cc2f94643fce2c4fe21bdd85d2d9)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/arch/ia64/sn/kernel/io_init.c  (mode:100644 sha1:f8a789c15007b627ec5c3b38fb662a74ad252c7e)
@@ -23,6 +23,14 @@
 
 nasid_t master_nasid = INVALID_NASID;	/* Partition Master */
 
+static struct list_head sn_sysdata_list;
+
+/* sysdata list struct */
+struct sysdata_el {
+	struct list_head entry;
+	void *sysdata;
+};
+
 struct slab_info {
 	struct hubdev_info hubdev;
 };
@@ -137,23 +145,6 @@
 }
 
 /*
- * sn_alloc_pci_sysdata() - This routine allocates a pci controller
- *	which is expected as the pci_dev and pci_bus sysdata by the Linux
- *	PCI infrastructure.
- */
-static inline struct pci_controller *sn_alloc_pci_sysdata(void)
-{
-	struct pci_controller *pci_sysdata;
-
-	pci_sysdata = kmalloc(sizeof(*pci_sysdata), GFP_KERNEL);
-	if (!pci_sysdata)
-		BUG();
-
-	memset(pci_sysdata, 0, sizeof(*pci_sysdata));
-	return pci_sysdata;
-}
-
-/*
  * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for 
  *	each node in the system.
  */
@@ -220,6 +211,15 @@
 
 }
 
+void sn_pci_unfixup_slot(struct pci_dev *dev)
+{
+	struct pci_dev *host_pci_dev = SN_PCIDEV_INFO(dev)->host_pci_dev;
+
+	sn_irq_unfixup(dev);
+	pci_dev_put(host_pci_dev);
+	pci_dev_put(dev);
+}
+
 /*
  * sn_pci_fixup_slot() - This routine sets up a slot's resources
  * consistent with the Linux PCI abstraction layer.  Resources acquired
@@ -238,10 +238,10 @@
  	unsigned long size;
  	unsigned int bus_no, devfn;
 
-	dev->sysdata = kmalloc(sizeof(struct pcidev_info), GFP_KERNEL);
+	pci_dev_get(dev); /* for the sysdata pointer */
+	dev->sysdata = kcalloc(1, sizeof(struct pcidev_info), GFP_KERNEL);
 	if (SN_PCIDEV_INFO(dev) <= 0)
 		BUG();		/* Cannot afford to run out of memory */
-	memset(SN_PCIDEV_INFO(dev), 0, sizeof(struct pcidev_info));
 
 	sn_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
 	if (sn_irq_info <= 0)
@@ -276,7 +276,8 @@
 			dev->resource[idx].parent = &iomem_resource;
 	}
 
- 	/* Using the PROMs values for the PCI host bus, get the Linux
+	/*
+	 * Using the PROMs values for the PCI host bus, get the Linux
  	 * PCI host_pci_dev struct and set up host bus linkages
  	 */
 
@@ -292,11 +293,10 @@
 	bs = SN_PCIBUS_BUSSOFT(dev->bus);
 	SN_PCIDEV_INFO(dev)->pdi_pcibus_info = bs;
 
-	if (bs && bs->bs_asic_type < PCIIO_ASIC_MAX_TYPES) {
+	if (bs && bs->bs_asic_type < PCIIO_ASIC_MAX_TYPES)
 		SN_PCIDEV_BUSPROVIDER(dev) = sn_pci_provider[bs->bs_asic_type];
-	} else {
+	else
 		SN_PCIDEV_BUSPROVIDER(dev) = &sn_pci_default_provider;
-	}
 
 	/* Only set up IRQ stuff if this device has a host bus context */
 	if (bs && sn_irq_info->irq_irq) {
@@ -313,55 +313,57 @@
  * sn_pci_controller_fixup() - This routine sets up a bus's resources
  * consistent with the Linux PCI abstraction layer.
  */
-static void sn_pci_controller_fixup(int segment, int busnum)
+void sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 {
 	int status = 0;
 	int nasid, cnode;
-	struct pci_bus *bus;
 	struct pci_controller *controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
 	struct hubdev_info *hubdev_info;
 	void *provider_soft;
 	struct sn_pcibus_provider *provider;
 
-	status =
-	    sal_get_pcibus_info((u64) segment, (u64) busnum,
-				(u64) ia64_tpa(&prom_bussoft_ptr));
-	if (status > 0) {
-		return;		/* bus # does not exist */
-	}
-
+ 	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
+ 				     (u64) ia64_tpa(&prom_bussoft_ptr));
+ 	if (status > 0)
+		return;		/*bus # does not exist */
 	prom_bussoft_ptr = __va(prom_bussoft_ptr);
-	controller = sn_alloc_pci_sysdata();
-	/* controller non-zero is BUG'd in sn_alloc_pci_sysdata */
 
-	bus = pci_scan_bus(busnum, &pci_root_ops, controller);
+ 	controller = kcalloc(1,sizeof(*controller), GFP_KERNEL);
+ 	if (!controller)
+ 		BUG();
+
 	if (bus == NULL) {
-		return;		/* error, or bus already scanned */
+ 		bus = pci_scan_bus(busnum, &pci_root_ops, controller);
+ 		if (bus == NULL)
+ 			return;	/* error, or bus already scanned */
+ 		bus->sysdata = NULL;
 	}
 
+	if (bus->sysdata)
+		goto error_return; /* sysdata already alloc'd */
+
 	/*
 	 * Per-provider fixup.  Copies the contents from prom to local
 	 * area and links SN_PCIBUS_BUSSOFT().
 	 */
 
-	if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES) {
+	if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES)
 		return;		/* unsupported asic type */
-	}
+
+	if (prom_bussoft_ptr->bs_asic_type == PCIIO_ASIC_TYPE_PPB)
+		goto error_return; /* no further fixup necessary */
 
 	provider = sn_pci_provider[prom_bussoft_ptr->bs_asic_type];
-	if (provider == NULL) {
+	if (provider == NULL)
 		return;		/* no provider registerd for this asic */
-	}
 
 	provider_soft = NULL;
-	if (provider->bus_fixup) {
+	if (provider->bus_fixup)
 		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr);
-	}
 
-	if (provider_soft == NULL) {
+	if (provider_soft == NULL)
 		return;		/* fixup failed or not applicable */
-	}
 
 	/*
 	 * Generic bus fixup goes here.  Don't reference prom_bussoft_ptr
@@ -370,12 +372,45 @@
 
 	bus->sysdata = controller;
 	PCI_CONTROLLER(bus)->platform_data = provider_soft;
-
 	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
 	cnode = nasid_to_cnodeid(nasid);
 	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 	SN_PCIBUS_BUSSOFT(bus)->bs_xwidget_info =
 	    &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);
+
+	return;
+
+error_return:
+
+	kfree(controller);
+	return;
+}
+
+void sn_bus_store_sysdata(struct pci_dev *dev)
+{
+	struct sysdata_el *element;
+
+	element = kcalloc(1, sizeof(*element), GFP_KERNEL);
+	if (!element) {
+		dev_dbg(dev, "%s: out of memory!\n", __FUNCTION__);
+		return;
+	}
+	element->sysdata = dev->sysdata;
+	list_add(&element->entry, &sn_sysdata_list);
+}
+
+void sn_bus_free_sysdata(void)
+{
+	struct sysdata_el *element;
+
+sn_sysdata_free_start:
+	list_for_each_entry(element, &sn_sysdata_list, entry) {
+		list_del(&element->entry);
+		kfree(element->sysdata);
+		kfree(element);
+		goto sn_sysdata_free_start;
+	}
+	return;
 }
 
 /*
@@ -413,15 +448,16 @@
 	ia64_max_iommu_merge_mask = ~PAGE_MASK;
 	sn_fixup_ionodes();
 	sn_irq_lh_init();
+	INIT_LIST_HEAD(&sn_sysdata_list);
 	sn_init_cpei_timer();
 
 #ifdef CONFIG_PROC_FS
 	register_sn_procfs();
 #endif
 
-	for (i = 0; i < PCI_BUSES_TO_SCAN; i++) {
-		sn_pci_controller_fixup(0, i);
-	}
+	/* busses are not known yet ... */
+	for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
+		sn_pci_controller_fixup(0, i, NULL);
 
 	/*
 	 * Generic Linux PCI Layer has created the pci_bus and pci_dev 
@@ -430,9 +466,8 @@
 	 */
 
 	while ((pci_dev =
-		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
+		pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL)
 		sn_pci_fixup_slot(pci_dev);
-	}
 
 	sn_ioif_inited = 1;	/* sn I/O infrastructure now initialized */
 
@@ -474,3 +509,8 @@
 }
 
 subsys_initcall(sn_pci_init);
+EXPORT_SYMBOL_GPL(sn_pci_fixup_slot);
+EXPORT_SYMBOL_GPL(sn_pci_unfixup_slot);
+EXPORT_SYMBOL_GPL(sn_pci_controller_fixup);
+EXPORT_SYMBOL_GPL(sn_bus_store_sysdata);
+EXPORT_SYMBOL_GPL(sn_bus_free_sysdata);
Index: arch/ia64/sn/kernel/irq.c
===================================================================
--- f8014bc6a8330d22e2dbb0cac34d87e8a5352278/arch/ia64/sn/kernel/irq.c  (mode:100644 sha1:ee4ac68d745f2c91e39d10e2f82cf624cf655edd)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/arch/ia64/sn/kernel/irq.c  (mode:100644 sha1:ec5e7a01c5b55f328e0dff8a45b012bc1024e84e)
@@ -284,7 +284,6 @@
 	int cpu = nasid_slice_to_cpuid(nasid, slice);
 
 	pci_dev_get(pci_dev);
-
 	sn_irq_info->irq_cpuid = cpu;
 	sn_irq_info->irq_pciioinfo = SN_PCIDEV_INFO(pci_dev);
 
@@ -305,15 +304,16 @@
 		return;
 
 	sn_irq_info = SN_PCIDEV_INFO(pci_dev)->pdi_sn_irq_info;
-	if (!sn_irq_info || !sn_irq_info->irq_irq)
+	if (!sn_irq_info || !sn_irq_info->irq_irq) {
+		kfree(sn_irq_info);
 		return;
+	}
 
 	unregister_intr_pda(sn_irq_info);
 	spin_lock(&sn_irq_info_lock);
 	list_del_rcu(&sn_irq_info->list);
 	spin_unlock(&sn_irq_info_lock);
 	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
-
 	pci_dev_put(pci_dev);
 }
 
Index: arch/ia64/sn/pci/pcibr/pcibr_provider.c
===================================================================
--- f8014bc6a8330d22e2dbb0cac34d87e8a5352278/arch/ia64/sn/pci/pcibr/pcibr_provider.c  (mode:100644 sha1:9bc4de4a3ec0778aa4724e75457bd253a6b1e45e)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/arch/ia64/sn/pci/pcibr/pcibr_provider.c  (mode:100644 sha1:9813da56d3113c41fb1b413cfa4c7963cda316cb)
@@ -18,6 +18,40 @@
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
 
+int
+sal_pcibr_slot_enable(struct pcibus_info *soft, int device, void *resp)
+{
+	struct ia64_sal_retval ret_stuff;
+	uint64_t busnum;
+
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+
+	busnum = soft->pbi_buscommon.bs_persist_busnum;
+	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_ENABLE, (u64) busnum,
+			(u64) device, (u64) resp, 0, 0, 0, 0);
+
+	return (int)ret_stuff.v0;
+}
+
+int
+sal_pcibr_slot_disable(struct pcibus_info *soft, int device, int action,
+		       void *resp)
+{
+	struct ia64_sal_retval ret_stuff;
+	uint64_t busnum;
+
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+
+	busnum = soft->pbi_buscommon.bs_persist_busnum;
+	SAL_CALL_NOLOCK(ret_stuff, (u64) SN_SAL_IOIF_SLOT_DISABLE,
+			(u64) busnum, (u64) device, (u64) action,
+			(u64) resp, 0, 0, 0);
+
+	return (int)ret_stuff.v0;
+}
+
 static int sal_pcibr_error_interrupt(struct pcibus_info *soft)
 {
 	struct ia64_sal_retval ret_stuff;
@@ -187,3 +221,6 @@
 
 	return 0;
 }
+
+EXPORT_SYMBOL_GPL(sal_pcibr_slot_enable);
+EXPORT_SYMBOL_GPL(sal_pcibr_slot_disable);
Index: drivers/pci/hotplug/Kconfig
===================================================================
--- f8014bc6a8330d22e2dbb0cac34d87e8a5352278/drivers/pci/hotplug/Kconfig  (mode:100644 sha1:1a4d4ca2a4dc386d3f63189ecc9cf30f806b947e)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/drivers/pci/hotplug/Kconfig  (mode:100644 sha1:9c4a39ee89b57b5065f575b86b2798ed31dc2fc6)
@@ -187,9 +187,10 @@
 
 config HOTPLUG_PCI_SGI
 	tristate "SGI PCI Hotplug Support"
-	depends on HOTPLUG_PCI && IA64_SGI_SN2
+	depends on HOTPLUG_PCI && (IA64_SGI_SN2 || IA64_GENERIC)
 	help
-	  Say Y here if you have an SGI IA64 Altix system.
+	  Say Y here if you want to use the SGI Altix Hotplug
+	  Driver for PCI devices.
 
 	  When in doubt, say N.
 
Index: drivers/pci/hotplug/Makefile
===================================================================
--- f8014bc6a8330d22e2dbb0cac34d87e8a5352278/drivers/pci/hotplug/Makefile  (mode:100644 sha1:93c120ddbd395f5ddeddcc3cc5d52bd31a47dcc4)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/drivers/pci/hotplug/Makefile  (mode:100644 sha1:24ed904514c5043095dfe484877dd38cdfa0f3b6)
@@ -14,6 +14,7 @@
 obj-$(CONFIG_HOTPLUG_PCI_SHPC)		+= shpchp.o
 obj-$(CONFIG_HOTPLUG_PCI_RPA)		+= rpaphp.o
 obj-$(CONFIG_HOTPLUG_PCI_RPA_DLPAR)	+= rpadlpar_io.o
+obj-$(CONFIG_HOTPLUG_PCI_SGI)		+= sgi_hotplug.o
 
 pci_hotplug-objs	:=	pci_hotplug_core.o
 
Index: drivers/pci/hotplug/sgi_hotplug.c
===================================================================
--- /dev/null  (tree:f8014bc6a8330d22e2dbb0cac34d87e8a5352278)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/drivers/pci/hotplug/sgi_hotplug.c  (mode:100644 sha1:5ab8f0fa11bd462c6c97e7a1c1c4a47263698dd7)
@@ -0,0 +1,598 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2005 Silicon Graphics, Inc. All rights reserved.
+ *
+ * This work was based on the 2.4/2.6 kernel development by Dick Reigner.
+ * Work to add BIOS PROM support was completed by Mike Habeck.
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include <linux/types.h>
+
+#include <asm/sn/addrs.h>
+#include <asm/sn/l1.h>
+#include <asm/sn/module.h>
+#include <asm/sn/pcibr_provider.h>
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
+#include <asm/sn/sn_sal.h>
+#include <asm/sn/types.h>
+
+#include "../pci.h"
+#include "pci_hotplug.h"
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("SGI (prarit@sgi.com, dickie@sgi.com, habeck@sgi.com)");
+MODULE_DESCRIPTION("SGI Altix Hot Plug PCI Controller Driver");
+
+#define PCIIO_ASIC_TYPE_TIOCA		4
+#define PCI_SLOT_ALREADY_UP		2	/* slot already up */
+#define PCI_SLOT_ALREADY_DOWN		3	/* slot already down */
+#define PCI_L1_ERR			7	/* L1 console command error */
+#define PCI_EMPTY_33MHZ			15	/* empty 33 MHz bus */
+#define PCI_L1_QSIZE			128	/* our L1 message buffer size */
+#define SN_MAX_HP_SLOTS			32	/* max hotplug slots */
+#define SGI_HOTPLUG_PROM_REV		0x0420	/* Min. required PROM version */
+#define SN_SLOT_NAME_SIZE		33	/* size of name string */
+
+/* internal list head */
+static struct list_head sn_hp_list;
+
+/* hotplug_slot struct's private pointer */
+struct slot {
+	int device_num;
+	struct pci_bus *pci_bus;
+	/* this struct for glue internal only */
+	struct hotplug_slot *hotplug_slot;
+	struct list_head hp_list;
+	char physical_path[SN_SLOT_NAME_SIZE];
+};
+
+struct pcibr_slot_enable_resp {
+	int resp_sub_errno;
+	char resp_l1_msg[PCI_L1_QSIZE + 1];
+};
+
+struct pcibr_slot_disable_resp {
+	int resp_sub_errno;
+	char resp_l1_msg[PCI_L1_QSIZE + 1];
+};
+
+enum sn_pci_req_e {
+	PCI_REQ_SLOT_ELIGIBLE,
+	PCI_REQ_SLOT_DISABLE
+};
+
+static int enable_slot(struct hotplug_slot *slot);
+static int disable_slot(struct hotplug_slot *slot);
+static inline int get_power_status(struct hotplug_slot *slot, u8 *value);
+
+static struct hotplug_slot_ops sn_hotplug_slot_ops = {
+	.owner                  = THIS_MODULE,
+	.enable_slot            = enable_slot,
+	.disable_slot           = disable_slot,
+	.get_power_status       = get_power_status,
+};
+
+static DECLARE_MUTEX(sn_hotplug_sem);
+
+static ssize_t path_show (struct hotplug_slot *bss_hotplug_slot,
+	       		  char *buf)
+{
+	int retval = -ENOENT;
+	struct slot *slot = bss_hotplug_slot->private;
+
+	if (!slot)
+		return retval;
+
+	retval = sprintf (buf, "%s\n", slot->physical_path);
+	return retval;
+}
+
+static struct hotplug_slot_attribute sn_slot_path_attr = __ATTR_RO(path);
+
+static int sn_pci_slot_valid(struct pci_bus *pci_bus, int device)
+{
+	struct pcibus_info *pcibus_info;
+	int bricktype;
+	int bus_num;
+
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(pci_bus);
+
+	/* Check to see if this is a valid slot on 'pci_bus' */
+	if (!(pcibus_info->pbi_valid_devices & (1 << device)))
+		return -EPERM;
+
+	bricktype = MODULE_GET_BTYPE(pcibus_info->pbi_moduleid);
+	bus_num = pcibus_info->pbi_buscommon.bs_persist_busnum & 0xf;
+
+	/* Do not allow hotplug operations on base I/O cards */
+	if ((bricktype == L1_BRICKTYPE_IX ||  bricktype == L1_BRICKTYPE_IA) &&
+	    (bus_num == 1 && device != 1))
+		return -EPERM;
+
+	return 1;
+}
+
+static int sn_pci_bus_valid(struct pci_bus *pci_bus)
+{
+	struct pcibus_info *pcibus_info;
+	int asic_type;
+	int bricktype;
+
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(pci_bus);
+
+	/* Don't register slots hanging off the TIOCA bus */
+	asic_type = pcibus_info->pbi_buscommon.bs_asic_type;
+	if (asic_type == PCIIO_ASIC_TYPE_TIOCA)
+		return -EPERM;
+
+	/* Only register slots in I/O Bricks that support hotplug */
+	bricktype = MODULE_GET_BTYPE(pcibus_info->pbi_moduleid);
+	switch (bricktype) {
+		case L1_BRICKTYPE_IX:
+		case L1_BRICKTYPE_PX:
+		case L1_BRICKTYPE_IA:
+		case L1_BRICKTYPE_PA:
+			return 1;
+			break;
+		default:
+			return -EPERM;
+			break;
+	}
+
+	return -EIO;
+}
+
+static int sn_hp_slot_private_alloc(struct hotplug_slot *bss_hotplug_slot,
+				    struct pci_bus *pci_bus, int device)
+{
+	struct pcibus_info *pcibus_info;
+	struct slot *slot;
+
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(pci_bus);
+
+	slot = kcalloc(1, sizeof(*slot), GFP_KERNEL);
+	if (!slot)
+		return -ENOMEM;
+	bss_hotplug_slot->private = slot;
+
+	bss_hotplug_slot->name = kmalloc(SN_SLOT_NAME_SIZE, GFP_KERNEL);
+	if (!bss_hotplug_slot->name) {
+		kfree(bss_hotplug_slot->private);
+		return -ENOMEM;
+	}
+
+	slot->device_num = device;
+	slot->pci_bus = pci_bus;
+	sprintf(bss_hotplug_slot->name, "%04x:%02x:%02x",
+		pci_domain_nr(pci_bus),
+		((int)pcibus_info->pbi_buscommon.bs_persist_busnum) & 0xf,
+		device + 1);
+	sprintf(slot->physical_path, "module_%c%c%c%c%.2d",
+		'0'+RACK_GET_CLASS(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
+		'0'+RACK_GET_GROUP(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
+		'0'+RACK_GET_NUM(MODULE_GET_RACK(pcibus_info->pbi_moduleid)),
+		MODULE_GET_BTCHAR(pcibus_info->pbi_moduleid),
+		MODULE_GET_BPOS(pcibus_info->pbi_moduleid));
+	slot->hotplug_slot = bss_hotplug_slot;
+	list_add(&slot->hp_list, &sn_hp_list);
+
+	return 0;
+}
+
+static struct hotplug_slot * sn_hp_destroy(void)
+{
+	struct slot *slot;
+	struct hotplug_slot *bss_hotplug_slot = NULL;
+
+	list_for_each_entry(slot, &sn_hp_list, hp_list) {
+		bss_hotplug_slot = slot->hotplug_slot;
+		list_del(&((struct slot *)bss_hotplug_slot->private)->
+			 hp_list);
+		sysfs_remove_file(&bss_hotplug_slot->kobj,
+				  &sn_slot_path_attr.attr);
+		break;
+	}
+	return bss_hotplug_slot;
+}
+
+static void sn_bus_alloc_data(struct pci_dev *dev)
+{
+	struct pci_bus *subordinate_bus;
+	struct pci_dev *child;
+
+	sn_pci_fixup_slot(dev);
+
+	/* Recursively sets up the sn_irq_info structs */
+	if (dev->subordinate) {
+		subordinate_bus = dev->subordinate;
+		list_for_each_entry(child, &subordinate_bus->devices, bus_list)
+			sn_bus_alloc_data(child);
+	}
+}
+
+static void sn_bus_free_data(struct pci_dev *dev)
+{
+	struct pci_bus *subordinate_bus;
+	struct pci_dev *child;
+
+	/* Recursively clean up sn_irq_info structs */
+	if (dev->subordinate) {
+		subordinate_bus = dev->subordinate;
+		list_for_each_entry(child, &subordinate_bus->devices, bus_list)
+			sn_bus_free_data(child);
+	}
+	sn_pci_unfixup_slot(dev);
+}
+
+static int sn_slot_enable(struct hotplug_slot *bss_hotplug_slot,
+			  int device_num)
+{
+	struct slot *slot = bss_hotplug_slot->private;
+	struct pcibus_info *pcibus_info;
+	struct pcibr_slot_enable_resp resp;
+	int rc;
+
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(slot->pci_bus);
+
+	/*
+	 * Power-on and initialize the slot in the SN
+	 * PCI infrastructure.
+	 */
+	rc = sal_pcibr_slot_enable(pcibus_info, device_num, &resp);
+
+	if (rc == PCI_SLOT_ALREADY_UP) {
+		dev_dbg(slot->pci_bus->self, "is already active\n");
+		return 1; /* return 1 to user */
+	}
+
+	if (rc == PCI_L1_ERR) {
+		dev_dbg(slot->pci_bus->self,
+			"L1 failure %d with message: %s",
+			resp.resp_sub_errno, resp.resp_l1_msg);
+		return -EPERM;
+	}
+
+	if (rc) {
+		dev_dbg(slot->pci_bus->self,
+			"insert failed with error %d sub-error %d\n",
+			rc, resp.resp_sub_errno);
+		return -EIO;
+	}
+
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(slot->pci_bus);
+	pcibus_info->pbi_enabled_devices |= (1 << device_num);
+
+	return 0;
+}
+
+static int sn_slot_disable(struct hotplug_slot *bss_hotplug_slot,
+			   int device_num, int action)
+{
+	struct slot *slot = bss_hotplug_slot->private;
+	struct pcibus_info *pcibus_info;
+	struct pcibr_slot_disable_resp resp;
+	int rc;
+
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(slot->pci_bus);
+
+	rc = sal_pcibr_slot_disable(pcibus_info, device_num, action, &resp);
+
+	if ((action == PCI_REQ_SLOT_ELIGIBLE) &&
+	    (rc == PCI_SLOT_ALREADY_DOWN)) {
+		dev_dbg(slot->pci_bus->self, "Slot %s already inactive\n");
+		return 1; /* return 1 to user */
+	}
+
+	if ((action == PCI_REQ_SLOT_ELIGIBLE) && (rc == PCI_EMPTY_33MHZ)) {
+		dev_dbg(slot->pci_bus->self,
+			"Cannot remove last 33MHz card\n");
+		return -EPERM;
+	}
+
+	if ((action == PCI_REQ_SLOT_ELIGIBLE) && (rc == PCI_L1_ERR)) {
+		dev_dbg(slot->pci_bus->self,
+			"L1 failure %d with message \n%s\n",
+			resp.resp_sub_errno, resp.resp_l1_msg);
+		return -EPERM;
+	}
+
+	if ((action == PCI_REQ_SLOT_ELIGIBLE) && rc) {
+		dev_dbg(slot->pci_bus->self,
+			"remove failed with error %d sub-error %d\n",
+			rc, resp.resp_sub_errno);
+		return -EIO;
+	}
+
+	if ((action == PCI_REQ_SLOT_ELIGIBLE) && !rc)
+		return 0;
+
+	if ((action == PCI_REQ_SLOT_DISABLE) && !rc) {
+		pcibus_info = SN_PCIBUS_BUSSOFT_INFO(slot->pci_bus);
+		pcibus_info->pbi_enabled_devices &= ~(1 << device_num);
+		dev_dbg(slot->pci_bus->self, "remove successful\n");
+		return 0;
+	}
+
+	if ((action == PCI_REQ_SLOT_DISABLE) && rc) {
+		dev_dbg(slot->pci_bus->self,"remove failed rc = %d\n", rc);
+	}
+
+	return rc;
+}
+
+static int enable_slot(struct hotplug_slot *bss_hotplug_slot)
+{
+	struct slot *slot = bss_hotplug_slot->private;
+	struct pci_bus *new_bus = NULL;
+	struct pci_dev *dev;
+	int func, num_funcs;
+	int new_ppb = 0;
+	int rc;
+
+	/* Serialize the Linux PCI infrastructure */
+	down(&sn_hotplug_sem);
+
+	/*
+	 * Power-on and initialize the slot in the SN
+	 * PCI infrastructure.
+	 */
+	rc = sn_slot_enable(bss_hotplug_slot, slot->device_num);
+	if (rc) {
+		up(&sn_hotplug_sem);
+		return rc;
+	}
+
+	num_funcs = pci_scan_slot(slot->pci_bus,
+				  PCI_DEVFN(slot->device_num + 1, 0));
+	if (!num_funcs) {
+		dev_dbg(slot->pci_bus->self, "no device in slot\n");
+		up(&sn_hotplug_sem);
+		return -ENODEV;
+	}
+
+	sn_pci_controller_fixup(pci_domain_nr(slot->pci_bus),
+				slot->pci_bus->number,
+				slot->pci_bus);
+	/*
+	 * Map SN resources for all functions on the card
+	 * to the Linux PCI interface and tell the drivers
+	 * about them.
+	 */
+	for (func = 0; func < num_funcs;  func++) {
+		dev = pci_get_slot(slot->pci_bus,
+				   PCI_DEVFN(slot->device_num + 1,
+					     PCI_FUNC(func)));
+		if (dev) {
+			if (dev->hdr_type == PCI_HEADER_TYPE_BRIDGE) {
+				unsigned char sec_bus;
+				pci_read_config_byte(dev, PCI_SECONDARY_BUS,
+						     &sec_bus);
+				new_bus = pci_add_new_bus(dev->bus, dev,
+							  sec_bus);
+				pci_scan_child_bus(new_bus);
+				sn_pci_controller_fixup(pci_domain_nr(new_bus),
+							new_bus->number,
+							new_bus);
+				new_ppb = 1;
+			}
+			sn_bus_alloc_data(dev);
+			pci_dev_put(dev);
+		}
+	}
+
+	/* Call the driver for the new device */
+	pci_bus_add_devices(slot->pci_bus);
+	/* Call the drivers for the new devices subordinate to PPB */
+	if (new_ppb)
+		pci_bus_add_devices(new_bus);
+
+	up(&sn_hotplug_sem);
+
+	if (rc == 0)
+		dev_dbg(slot->pci_bus->self,
+			"insert operation successful\n");
+	else
+		dev_dbg(slot->pci_bus->self,
+			"insert operation failed rc = %d\n", rc);
+
+	return rc;
+}
+
+static int disable_slot(struct hotplug_slot *bss_hotplug_slot)
+{
+	struct slot *slot = bss_hotplug_slot->private;
+	struct pci_dev *dev;
+	int func;
+	int rc;
+
+	/* Acquire update access to the bus */
+	down(&sn_hotplug_sem);
+
+	/* is it okay to bring this slot down? */
+	rc = sn_slot_disable(bss_hotplug_slot, slot->device_num,
+			     PCI_REQ_SLOT_ELIGIBLE);
+	if (rc)
+		goto leaving;
+
+	/* Free the SN resources assigned to the Linux device.*/
+	for (func = 0; func < 8;  func++) {
+		dev = pci_get_slot(slot->pci_bus,
+				   PCI_DEVFN(slot->device_num + 1,
+				   	     PCI_FUNC(func)));
+		if (dev) {
+			/*
+			 * Some drivers may use dma accesses during the
+			 * driver remove function. We release the sysdata
+			 * areas after the driver remove functions have
+			 * been called.
+			 */
+			sn_bus_store_sysdata(dev);
+			sn_bus_free_data(dev);
+			pci_remove_bus_device(dev);
+			pci_dev_put(dev);
+		}
+	}
+
+	/* free the collected sysdata pointers */
+	sn_bus_free_sysdata();
+
+	/* Deactivate slot */
+	rc = sn_slot_disable(bss_hotplug_slot, slot->device_num,
+			     PCI_REQ_SLOT_DISABLE);
+ leaving:
+	/* Release the bus lock */
+	up(&sn_hotplug_sem);
+
+	return rc;
+}
+
+static inline int get_power_status(struct hotplug_slot *bss_hotplug_slot,
+				   u8 *value)
+{
+	struct slot *slot = bss_hotplug_slot->private;
+	struct pcibus_info *pcibus_info;
+
+	pcibus_info = SN_PCIBUS_BUSSOFT_INFO(slot->pci_bus);
+	down(&sn_hotplug_sem);
+	*value = pcibus_info->pbi_enabled_devices & (1 << slot->device_num);
+	up(&sn_hotplug_sem);
+	return 0;
+}
+
+static void sn_release_slot(struct hotplug_slot *bss_hotplug_slot)
+{
+	kfree(bss_hotplug_slot->info);
+	kfree(bss_hotplug_slot->name);
+	kfree(bss_hotplug_slot->private);
+	kfree(bss_hotplug_slot);
+}
+
+static int sn_hotplug_slot_register(struct pci_bus *pci_bus)
+{
+	int device;
+	struct hotplug_slot *bss_hotplug_slot;
+	int rc = 0;
+
+	/*
+	 * Currently only four devices are supported,
+	 * in the future there maybe more -- up to 32.
+	 */
+
+	for (device = 0; device < SN_MAX_HP_SLOTS ; device++) {
+		if (sn_pci_slot_valid(pci_bus, device) != 1)
+			continue;
+
+		bss_hotplug_slot = kcalloc(1, sizeof(*bss_hotplug_slot),
+					   GFP_KERNEL);
+		if (!bss_hotplug_slot) {
+			rc = -ENOMEM;
+			goto alloc_err;
+		}
+
+		bss_hotplug_slot->info =
+			kcalloc(1, sizeof(struct hotplug_slot_info),
+				GFP_KERNEL);
+		if (!bss_hotplug_slot->info) {
+			rc = -ENOMEM;
+			goto alloc_err;
+		}
+
+		if (sn_hp_slot_private_alloc(bss_hotplug_slot,
+					     pci_bus, device)) {
+			rc = -ENOMEM;
+			goto alloc_err;
+		}
+
+		bss_hotplug_slot->ops = &sn_hotplug_slot_ops;
+		bss_hotplug_slot->release = &sn_release_slot;
+
+		rc = pci_hp_register(bss_hotplug_slot);
+		if (rc)
+			goto register_err;
+
+		rc = sysfs_create_file(&bss_hotplug_slot->kobj,
+				       &sn_slot_path_attr.attr);
+		if (rc)
+			goto register_err;
+	}
+	dev_dbg(pci_bus->self, "Registered bus with hotplug\n");
+	return rc;
+
+register_err:
+	dev_dbg(pci_bus->self, "bus failed to register with err = %d\n",
+	        rc);
+
+alloc_err:
+	if (rc == -ENOMEM)
+		dev_dbg(pci_bus->self, "Memory allocation error\n");
+
+	/* destroy THIS element */
+	if (bss_hotplug_slot)
+		sn_release_slot(bss_hotplug_slot);
+
+	/* destroy anything else on the list */
+	while ((bss_hotplug_slot = sn_hp_destroy()))
+		pci_hp_deregister(bss_hotplug_slot);
+
+	return rc;
+}
+
+static int sn_pci_hotplug_init(void)
+{
+	struct pci_bus *pci_bus = NULL;
+	int rc;
+	int registered = 0;
+
+	if (sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {
+		printk(KERN_ERR "%s: PROM version must be greater than 4.20\n",
+		       __FUNCTION__);
+		return -EPERM;
+	}
+
+	INIT_LIST_HEAD(&sn_hp_list);
+
+	while ((pci_bus = pci_find_next_bus(pci_bus))) {
+		if (!pci_bus->sysdata)
+			continue;
+
+		rc = sn_pci_bus_valid(pci_bus);
+		if (rc != 1) {
+			dev_dbg(pci_bus->self, "not a valid hotplug bus\n");
+			continue;
+		}
+		dev_dbg(pci_bus->self, "valid hotplug bus\n");
+
+		rc = sn_hotplug_slot_register(pci_bus);
+		if (!rc) {
+			registered = 1;
+		} else {
+			registered = 0;
+			break;
+		}
+	}
+
+	return registered == 1 ? 0 : -ENODEV;
+}
+
+static void sn_pci_hotplug_exit(void)
+{
+	struct hotplug_slot *bss_hotplug_slot;
+
+	while ((bss_hotplug_slot = sn_hp_destroy()))
+		pci_hp_deregister(bss_hotplug_slot);
+
+	if (!list_empty(&sn_hp_list))
+		printk(KERN_ERR "%s: internal list is not empty\n", __FILE__);
+}
+
+module_init(sn_pci_hotplug_init);
+module_exit(sn_pci_hotplug_exit);
Index: include/asm-ia64/sn/pcibr_provider.h
===================================================================
--- f8014bc6a8330d22e2dbb0cac34d87e8a5352278/include/asm-ia64/sn/pcibr_provider.h  (mode:100644 sha1:0abf539cb0414d752fcf14d9318bf1fa00278d32)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/include/asm-ia64/sn/pcibr_provider.h  (mode:100644 sha1:c1bf22505ff339ea7a5255ec9a8a60031397e9a8)
@@ -151,4 +151,8 @@
 extern int 		pcibr_ate_alloc(struct pcibus_info *, int);
 extern void 		pcibr_ate_free(struct pcibus_info *, int);
 extern void 		ate_write(struct pcibus_info *, int, int, uint64_t);
+extern int sal_pcibr_slot_enable(struct pcibus_info *soft, int device,
+				 void *resp);
+extern int sal_pcibr_slot_disable(struct pcibus_info *soft, int device,
+				  int action, void *resp);
 #endif
Index: include/asm-ia64/sn/pcidev.h
===================================================================
--- f8014bc6a8330d22e2dbb0cac34d87e8a5352278/include/asm-ia64/sn/pcidev.h  (mode:100644 sha1:9610fcc635450e57bf9be693fb8fa5e22eb60be1)
+++ 7f8b42b9f9d9e31ebd6d26e86f93a8bc22b19848/include/asm-ia64/sn/pcidev.h  (mode:100644 sha1:49711d00ad04f77d90467daf33bfd13d549e2109)
@@ -23,6 +23,8 @@
 #define SN_PCIBUS_BUSSOFT(pci_bus) \
         ((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
 
+#define SN_PCIBUS_BUSSOFT_INFO(pci_bus) \
+	(struct pcibus_info *)((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
 /*
  * Given a struct pci_dev, return the sn pcibus_bussoft struct.  Note
  * that this is not equivalent to SN_PCIBUS_BUSSOFT(pci_dev->bus) due
@@ -56,6 +58,10 @@
 extern void sn_irq_fixup(struct pci_dev *pci_dev,
 			 struct sn_irq_info *sn_irq_info);
 extern void sn_irq_unfixup(struct pci_dev *pci_dev);
+extern void sn_pci_controller_fixup(int segment, int busnum,
+ 				    struct pci_bus *bus);
+extern void sn_bus_store_sysdata(struct pci_dev *dev);
+extern void sn_bus_free_sysdata(void);
 extern void sn_pci_fixup_slot(struct pci_dev *dev);
 extern void sn_pci_unfixup_slot(struct pci_dev *dev);
 extern void sn_irq_lh_init(void);

--------------090806010407040802000606--
