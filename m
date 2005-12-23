From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 23 Dec 2005 18:33:25 +0000
Subject: [PATCH]: Fix sn_flush_device_kernel & spinlock initialization
Message-Id: <20051223183312.25068.87088.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch separates the sn_flush_device_list struct into kernel and
common (both kernel and PROM accessible) structures.  As it was, if the
size of a spinlock_t changed (due to additional CONFIG options, etc.) the
sal call which populated the sn_flush_device_list structs would erroneously
write data (and cause memory corruption and/or a panic).

This patch does the following:

1.  Removes sn_flush_device_list and adds sn_flush_device_common and
sn_flush_device_kernel.

2.  Adds a new SAL call to populate a sn_flush_device_common struct per
device, not per widget as previously done.

3.  Correctly initializes each device's sn_flush_device_kernel spinlock_t
struct (before it was only doing each widget's first device).

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

diff --git a/arch/ia64/sn/include/xtalk/hubdev.h b/arch/ia64/sn/include/xtalk/hubdev.h
--- a/arch/ia64/sn/include/xtalk/hubdev.h
+++ b/arch/ia64/sn/include/xtalk/hubdev.h
@@ -26,11 +26,14 @@
 #define IIO_NUM_ITTES   7
 #define HUB_NUM_BIG_WINDOW      (IIO_NUM_ITTES - 1)
 
-struct sn_flush_device_list {
+/* This struct is shared between the PROM and the kernel.
+ * Changes to this struct will require corresponding changes to the kernel.
+ */
+struct sn_flush_device_common {
 	int sfdl_bus;
 	int sfdl_slot;
 	int sfdl_pin;
-	struct bar_list {
+	struct common_bar_list {
 		unsigned long start;
 		unsigned long end;
 	} sfdl_bar_list[6];
@@ -40,14 +43,19 @@ struct sn_flush_device_list {
 	uint32_t sfdl_persistent_busnum;
 	uint32_t sfdl_persistent_segment;
 	struct pcibus_info *sfdl_pcibus_info;
+};
+
+/* This struct is kernel only and is not used by the PROM */
+struct sn_flush_device_kernel {
 	spinlock_t sfdl_flush_lock;
+	struct sn_flush_device_common *common;
 };
 
 /*
- * **widget_p - Used as an array[wid_num][device] of sn_flush_device_list.
+ * **widget_p - Used as an array[wid_num][device] of sn_flush_device_kernel.
  */
 struct sn_flush_nasid_entry  {
-	struct sn_flush_device_list **widget_p; /* Used as a array of wid_num */
+	struct sn_flush_device_kernel **widget_p; // Used as an array of wid_num
 	uint64_t iio_itte[8];
 };
 
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -76,11 +76,12 @@ static struct sn_pcibus_provider sn_pci_
 };
 
 /*
- * Retrieve the DMA Flush List given nasid.  This list is needed 
- * to implement the WAR - Flush DMA data on PIO Reads.
+ * Retrieve the DMA Flush List given nasid, widget, and device.
+ * This list is needed to implement the WAR - Flush DMA data on PIO Reads.
  */
-static inline uint64_t
-sal_get_widget_dmaflush_list(u64 nasid, u64 widget_num, u64 address)
+static inline u64
+sal_get_device_dmaflush_list(u64 nasid, u64 widget_num, u64 device_num,
+			     u64 address)
 {
 
 	struct ia64_sal_retval ret_stuff;
@@ -88,17 +89,17 @@ sal_get_widget_dmaflush_list(u64 nasid, 
 	ret_stuff.v0 = 0;
 
 	SAL_CALL_NOLOCK(ret_stuff,
-			(u64) SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST,
-			(u64) nasid, (u64) widget_num, (u64) address, 0, 0, 0,
-			0);
-	return ret_stuff.v0;
+			(u64) SN_SAL_IOIF_GET_DEVICE_DMAFLUSH_LIST,
+			(u64) nasid, (u64) widget_num,
+			(u64) device_num, (u64) address, 0, 0, 0);
+	return ret_stuff.status;
 
 }
 
 /*
  * Retrieve the hub device info structure for the given nasid.
  */
-static inline uint64_t sal_get_hubdev_info(u64 handle, u64 address)
+static inline u64 sal_get_hubdev_info(u64 handle, u64 address)
 {
 
 	struct ia64_sal_retval ret_stuff;
@@ -114,7 +115,7 @@ static inline uint64_t sal_get_hubdev_in
 /*
  * Retrieve the pci bus information given the bus number.
  */
-static inline uint64_t sal_get_pcibus_info(u64 segment, u64 busnum, u64 address)
+static inline u64 sal_get_pcibus_info(u64 segment, u64 busnum, u64 address)
 {
 
 	struct ia64_sal_retval ret_stuff;
@@ -130,7 +131,7 @@ static inline uint64_t sal_get_pcibus_in
 /*
  * Retrieve the pci device information given the bus and device|function number.
  */
-static inline uint64_t
+static inline u64
 sal_get_pcidev_info(u64 segment, u64 bus_number, u64 devfn, u64 pci_dev, 
 			u64 sn_irq_info)
 {
@@ -170,12 +171,12 @@ sn_pcidev_info_get(struct pci_dev *dev)
  */
 static void sn_fixup_ionodes(void)
 {
-
-	struct sn_flush_device_list *sn_flush_device_list;
+	struct sn_flush_device_kernel *sn_flush_device_kernel;
+	struct sn_flush_device_kernel *dev_entry;
 	struct hubdev_info *hubdev;
-	uint64_t status;
-	uint64_t nasid;
-	int i, widget;
+	u64 status;
+	u64 nasid;
+	int i, widget, device;
 
 	/*
 	 * Get SGI Specific HUB chipset information.
@@ -186,7 +187,7 @@ static void sn_fixup_ionodes(void)
 		nasid = cnodeid_to_nasid(i);
 		hubdev->max_segment_number = 0xffffffff;
 		hubdev->max_pcibus_number = 0xff;
-		status = sal_get_hubdev_info(nasid, (uint64_t) __pa(hubdev));
+		status = sal_get_hubdev_info(nasid, (u64) __pa(hubdev));
 		if (status)
 			continue;
 
@@ -213,38 +214,49 @@ static void sn_fixup_ionodes(void)
 
 		hubdev->hdi_flush_nasid_list.widget_p  		    kmalloc((HUB_WIDGET_ID_MAX + 1) *
-			    sizeof(struct sn_flush_device_list *), GFP_KERNEL);
-
+			    sizeof(struct sn_flush_device_kernel *),
+			    GFP_KERNEL);
 		memset(hubdev->hdi_flush_nasid_list.widget_p, 0x0,
 		       (HUB_WIDGET_ID_MAX + 1) *
-		       sizeof(struct sn_flush_device_list *));
+		       sizeof(struct sn_flush_device_kernel *));
 
 		for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
-			sn_flush_device_list = kmalloc(DEV_PER_WIDGET *
-						       sizeof(struct
-							      sn_flush_device_list),
-						       GFP_KERNEL);
-			memset(sn_flush_device_list, 0x0,
+			sn_flush_device_kernel = kmalloc(DEV_PER_WIDGET *
+						         sizeof(struct
+						        sn_flush_device_kernel),
+						        GFP_KERNEL);
+			if (!sn_flush_device_kernel)
+				BUG();
+			memset(sn_flush_device_kernel, 0x0,
 			       DEV_PER_WIDGET *
-			       sizeof(struct sn_flush_device_list));
+			       sizeof(struct sn_flush_device_kernel));
 
-			status -			    sal_get_widget_dmaflush_list(nasid, widget,
-							 (uint64_t)
-							 __pa
-							 (sn_flush_device_list));
-			if (status) {
-				kfree(sn_flush_device_list);
-				continue;
-			}
+			dev_entry = sn_flush_device_kernel;
+			for (device = 0; device < DEV_PER_WIDGET;
+			     device++,dev_entry++) {
+				dev_entry->common = kmalloc(sizeof(struct
+					      	        sn_flush_device_common),
+					                    GFP_KERNEL);
+				if (!dev_entry->common)
+					BUG();
+				memset(dev_entry->common, 0x0, sizeof(struct
+					     	       sn_flush_device_common));
+
+				status = sal_get_device_dmaflush_list(nasid,
+									widget,
+								       	device,
+						      (u64)(dev_entry->common));
+				if (status)
+					BUG();
 
-			spin_lock_init(&sn_flush_device_list->sfdl_flush_lock);
-			hubdev->hdi_flush_nasid_list.widget_p[widget] -			    sn_flush_device_list;
-		}
+				spin_lock_init(&dev_entry->sfdl_flush_lock);
+			}
 
+			if (sn_flush_device_kernel)
+				hubdev->hdi_flush_nasid_list.widget_p[widget] +						       sn_flush_device_kernel;
+	        }
 	}
-
 }
 
 /*
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -218,7 +218,9 @@ void sn_dma_flush(uint64_t addr)
 	uint64_t flags;
 	uint64_t itte;
 	struct hubdev_info *hubinfo;
-	volatile struct sn_flush_device_list *p;
+	volatile struct sn_flush_device_kernel *p;
+	volatile struct sn_flush_device_common *common;
+
 	struct sn_flush_nasid_entry *flush_nasid_list;
 
 	if (!sn_ioif_inited)
@@ -268,17 +270,17 @@ void sn_dma_flush(uint64_t addr)
 	p = &flush_nasid_list->widget_p[wid_num][0];
 
 	/* find a matching BAR */
-	for (i = 0; i < DEV_PER_WIDGET; i++) {
+	for (i = 0; i < DEV_PER_WIDGET; i++,p++) {
+		common = p->common;
 		for (j = 0; j < PCI_ROM_RESOURCE; j++) {
-			if (p->sfdl_bar_list[j].start = 0)
+			if (common->sfdl_bar_list[j].start = 0)
 				break;
-			if (addr >= p->sfdl_bar_list[j].start
-			    && addr <= p->sfdl_bar_list[j].end)
+			if (addr >= common->sfdl_bar_list[j].start
+			    && addr <= common->sfdl_bar_list[j].end)
 				break;
 		}
-		if (j < PCI_ROM_RESOURCE && p->sfdl_bar_list[j].start != 0)
+		if (j < PCI_ROM_RESOURCE && common->sfdl_bar_list[j].start != 0)
 			break;
-		p++;
 	}
 
 	/* if no matching BAR, return without doing anything. */
@@ -304,24 +306,24 @@ void sn_dma_flush(uint64_t addr)
 		if ((1 << XWIDGET_PART_REV_NUM_REV(revnum)) & PV907516) {
 			return;
 		} else {
-			pcireg_wrb_flush_get(p->sfdl_pcibus_info,
-					     (p->sfdl_slot - 1));
+			pcireg_wrb_flush_get(common->sfdl_pcibus_info,
+					     (common->sfdl_slot - 1));
 		}
 	} else {
-		spin_lock_irqsave(&((struct sn_flush_device_list *)p)->
-				  sfdl_flush_lock, flags);
-
-		*p->sfdl_flush_addr = 0;
+		spin_lock_irqsave((spinlock_t *)&p->sfdl_flush_lock,
+				  flags);
+		*common->sfdl_flush_addr = 0;
 
 		/* force an interrupt. */
-		*(volatile uint32_t *)(p->sfdl_force_int_addr) = 1;
+		*(volatile uint32_t *)(common->sfdl_force_int_addr) = 1;
 
 		/* wait for the interrupt to come back. */
-		while (*(p->sfdl_flush_addr) != 0x10f)
+		while (*(common->sfdl_flush_addr) != 0x10f)
 			cpu_relax();
 
 		/* okay, everything is synched up. */
-		spin_unlock_irqrestore((spinlock_t *)&p->sfdl_flush_lock, flags);
+		spin_unlock_irqrestore((spinlock_t *)&p->sfdl_flush_lock,
+				       flags);
 	}
 	return;
 }
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -92,7 +92,8 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 	cnodeid_t near_cnode;
 	struct hubdev_info *hubdev_info;
 	struct pcibus_info *soft;
-	struct sn_flush_device_list *sn_flush_device_list;
+	struct sn_flush_device_kernel *sn_flush_device_kernel;
+	struct sn_flush_device_common *common;
 
 	if (! IS_PCI_BRIDGE_ASIC(prom_bussoft->bs_asic_type)) {
 		return NULL;
@@ -137,20 +138,19 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 
 	if (hubdev_info->hdi_flush_nasid_list.widget_p) {
-		sn_flush_device_list = hubdev_info->hdi_flush_nasid_list.
+		sn_flush_device_kernel = hubdev_info->hdi_flush_nasid_list.
 		    widget_p[(int)soft->pbi_buscommon.bs_xid];
-		if (sn_flush_device_list) {
+		if (sn_flush_device_kernel) {
 			for (j = 0; j < DEV_PER_WIDGET;
-			     j++, sn_flush_device_list++) {
-				if (sn_flush_device_list->sfdl_slot = -1)
+			     j++, sn_flush_device_kernel++) {
+				common = sn_flush_device_kernel->common;
+				if (common->sfdl_slot = -1)
 					continue;
-				if ((sn_flush_device_list->
-				     sfdl_persistent_segment =
+				if ((common->sfdl_persistent_segment =
 				     soft->pbi_buscommon.bs_persist_segment) &&
-				     (sn_flush_device_list->
-				     sfdl_persistent_busnum =
+				     (common->sfdl_persistent_busnum =
 				     soft->pbi_buscommon.bs_persist_busnum))
-					sn_flush_device_list->sfdl_pcibus_info +					common->sfdl_pcibus_info  					    soft;
 			}
 		}
diff --git a/include/asm-ia64/sn/sn_sal.h b/include/asm-ia64/sn/sn_sal.h
--- a/include/asm-ia64/sn/sn_sal.h
+++ b/include/asm-ia64/sn/sn_sal.h
@@ -75,7 +75,8 @@
 #define  SN_SAL_IOIF_GET_HUBDEV_INFO		   0x02000055
 #define  SN_SAL_IOIF_GET_PCIBUS_INFO		   0x02000056
 #define  SN_SAL_IOIF_GET_PCIDEV_INFO		   0x02000057
-#define  SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST	   0x02000058
+#define  SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST	   0x02000058	// deprecated
+#define  SN_SAL_IOIF_GET_DEVICE_DMAFLUSH_LIST	   0x0200005a
 
 #define SN_SAL_HUB_ERROR_INTERRUPT		   0x02000060
 #define SN_SAL_BTE_RECOVER			   0x02000061
