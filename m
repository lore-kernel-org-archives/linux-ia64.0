From: Colin Ngam <cngam@sgi.com>
Date: Wed, 03 Aug 2005 20:34:44 +0000
Subject: [PATCH 2.6-test 0/0] Altix only: Add PCI Domain number support.
Message-Id: <20050803203444.10877.61020.29766@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch enables PCI Domain numbering on Altix.

Signed-off-by: Colin Ngam <cngam@sgi.com>

Index: test-2.6/arch/ia64/sn/kernel/io_init.c
=================================--- test-2.6.orig/arch/ia64/sn/kernel/io_init.c	2005-07-28 16:02:04.466055779 -0500
+++ test-2.6/arch/ia64/sn/kernel/io_init.c	2005-08-02 13:40:32.572471100 -0500
@@ -44,6 +44,9 @@
 
 struct sn_pcibus_provider *sn_pci_provider[PCIIO_ASIC_MAX_TYPES];	/* indexed by asic type */
 
+static int max_segment_number = 0; /* Default highest segment number */
+static int max_pcibus_number = 255; /* Default highest pci bus number */
+
 /*
  * Hooks and struct for unsupported pci providers
  */
@@ -157,13 +160,28 @@
 	uint64_t nasid;
 	int i, widget;
 
+	/*
+	 * Get SGI Specific HUB chipset information.
+	 * Inform Prom that this kernel can support domain bus numbering.
+	 */
 	for (i = 0; i < numionodes; i++) {
 		hubdev = (struct hubdev_info *)(NODEPDA(i)->pdinfo);
 		nasid = cnodeid_to_nasid(i);
+		hubdev->max_segment_number = 0xffffffff;
+		hubdev->max_pcibus_number = 0xff;
 		status = sal_get_hubdev_info(nasid, (uint64_t) __pa(hubdev));
 		if (status)
 			continue;
 
+		/* Save the largest Domain and pcibus numbers found. */
+		if (hubdev->max_segment_number) {
+			/*
+			 * Dealing with a Prom that supports segments.
+			 */
+			max_segment_number = hubdev->max_segment_number;
+			max_pcibus_number = hubdev->max_pcibus_number;
+		}
+
 		/* Attach the error interrupt handlers */
 		if (nasid & 1)
 			ice_error_init(hubdev);
@@ -229,7 +247,7 @@
 void sn_pci_fixup_slot(struct pci_dev *dev)
 {
 	int idx;
-	int segment = 0;
+	int segment = pci_domain_nr(dev->bus);
 	int status = 0;
 	struct pcibus_bussoft *bs;
  	struct pci_bus *host_pci_bus;
@@ -282,9 +300,9 @@
  	 * PCI host_pci_dev struct and set up host bus linkages
  	 */
 
- 	bus_no = SN_PCIDEV_INFO(dev)->pdi_slot_host_handle >> 32;
+ 	bus_no = (SN_PCIDEV_INFO(dev)->pdi_slot_host_handle >> 32) & 0xff;
  	devfn = SN_PCIDEV_INFO(dev)->pdi_slot_host_handle & 0xffffffff;
- 	host_pci_bus = pci_find_bus(pci_domain_nr(dev->bus), bus_no);
+ 	host_pci_bus = pci_find_bus(segment, bus_no);
  	host_pci_dev = pci_get_slot(host_pci_bus, devfn);
 
 	SN_PCIDEV_INFO(dev)->host_pci_dev = host_pci_dev;
@@ -332,6 +350,7 @@
 	prom_bussoft_ptr = __va(prom_bussoft_ptr);
 
  	controller = kcalloc(1,sizeof(struct pci_controller), GFP_KERNEL);
+	controller->segment = segment;
  	if (!controller)
  		BUG();
 
@@ -426,6 +445,7 @@
 static int __init sn_pci_init(void)
 {
 	int i = 0;
+	int j = 0;
 	struct pci_dev *pci_dev = NULL;
 	extern void sn_init_cpei_timer(void);
 #ifdef CONFIG_PROC_FS
@@ -460,8 +480,9 @@
 #endif
 
 	/* busses are not known yet ... */
-	for (i = 0; i < PCI_BUSES_TO_SCAN; i++)
-		sn_pci_controller_fixup(0, i, NULL);
+	for (i = 0; i <= max_segment_number; i++)
+		for (j = 0; j <= max_pcibus_number; j++)
+			sn_pci_controller_fixup(i, j, NULL);
 
 	/*
 	 * Generic Linux PCI Layer has created the pci_bus and pci_dev 
Index: test-2.6/arch/ia64/sn/include/xtalk/hubdev.h
=================================--- test-2.6.orig/arch/ia64/sn/include/xtalk/hubdev.h	2005-07-28 16:02:04.462149924 -0500
+++ test-2.6/arch/ia64/sn/include/xtalk/hubdev.h	2005-08-01 10:55:51.959801006 -0500
@@ -34,7 +34,8 @@
 	unsigned long sfdl_force_int_addr;
 	unsigned long sfdl_flush_value;
 	volatile unsigned long *sfdl_flush_addr;
-	uint64_t sfdl_persistent_busnum;
+	uint32_t sfdl_persistent_busnum;
+	uint32_t sfdl_persistent_segment;
 	struct pcibus_info *sfdl_pcibus_info;
 	spinlock_t sfdl_flush_lock;
 };
@@ -58,7 +59,8 @@
 
 	void				*hdi_nodepda;
 	void				*hdi_node_vertex;
-	void				*hdi_xtalk_vertex;
+	uint32_t			max_segment_number;
+	uint32_t			max_pcibus_number;
 };
 
 extern void hubdev_init_node(nodepda_t *, cnodeid_t);
Index: test-2.6/include/asm-ia64/sn/pcibus_provider_defs.h
=================================--- test-2.6.orig/include/asm-ia64/sn/pcibus_provider_defs.h	2005-07-28 16:02:13.888931637 -0500
+++ test-2.6/include/asm-ia64/sn/pcibus_provider_defs.h	2005-08-01 10:55:52.071117705 -0500
@@ -30,7 +30,8 @@
 struct pcibus_bussoft {
 	uint32_t		bs_asic_type;	/* chipset type */
 	uint32_t		bs_xid;		/* xwidget id */
-	uint64_t		bs_persist_busnum; /* Persistent Bus Number */
+	uint32_t		bs_persist_busnum; /* Persistent Bus Number */
+	uint32_t		bs_persist_segment; /* Segment Number */
 	uint64_t		bs_legacy_io;	/* legacy io pio addr */
 	uint64_t		bs_legacy_mem;	/* legacy mem pio addr */
 	uint64_t		bs_base;	/* widget base */
Index: test-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- test-2.6.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-07-28 16:02:04.523667144 -0500
+++ test-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-08-01 10:55:52.198057801 -0500
@@ -60,7 +60,7 @@
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 
-	segment = 0;
+	segment = soft->pbi_buscommon.bs_persist_segment;
 	busnum = soft->pbi_buscommon.bs_persist_busnum;
 	SAL_CALL_NOLOCK(ret_stuff,
 			(u64) SN_SAL_IOIF_ERROR_INTERRUPT,
@@ -142,9 +142,12 @@
 			     j++, sn_flush_device_list++) {
 				if (sn_flush_device_list->sfdl_slot = -1)
 					continue;
-				if (sn_flush_device_list->
-				    sfdl_persistent_busnum =
-				    soft->pbi_buscommon.bs_persist_busnum)
+				if ((sn_flush_device_list->
+				     sfdl_persistent_segment =
+				     soft->pbi_buscommon.bs_persist_segment) &&
+				     (sn_flush_device_list->
+				     sfdl_persistent_busnum =
+				     soft->pbi_buscommon.bs_persist_busnum))
 					sn_flush_device_list->sfdl_pcibus_info  					    soft;
 			}
Index: test-2.6/arch/ia64/sn/pci/tioca_provider.c
=================================--- test-2.6.orig/arch/ia64/sn/pci/tioca_provider.c	2005-07-28 16:02:04.524643608 -0500
+++ test-2.6/arch/ia64/sn/pci/tioca_provider.c	2005-08-01 15:54:37.849344268 -0500
@@ -559,7 +559,7 @@
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 
-	segment = 0;
+	segment = soft->ca_common.bs_persist_segment;
 	busnum = soft->ca_common.bs_persist_busnum;
 
 	SAL_CALL_NOLOCK(ret_stuff,
@@ -622,7 +622,8 @@
 	    nasid_to_cnodeid(tioca_common->ca_closest_nasid);
 	tioca_common->ca_kernel_private = (uint64_t) tioca_kern;
 
-	bus = pci_find_bus(0, tioca_common->ca_common.bs_persist_busnum);
+	bus = pci_find_bus(tioca_common->ca_common.bs_persist_segment,
+		tioca_common->ca_common.bs_persist_busnum);
 	BUG_ON(!bus);
 	tioca_kern->ca_devices = &bus->devices;
 
