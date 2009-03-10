From: Stoyan Gaydarov <stoyboyker@gmail.com>
Date: Tue, 10 Mar 2009 05:10:30 +0000
Subject: [PATCH 05/25] [ia64] BUG to BUG_ON changes
Message-Id: <1236661850-8237-6-git-send-email-stoyboyker@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1236661850-8237-1-git-send-email-stoyboyker@gmail.com>
 <1236661850-8237-2-git-send-email-stoyboyker@gmail.com>
 <1236661850-8237-3-git-send-email-stoyboyker@gmail.com>
 <1236661850-8237-4-git-send-email-stoyboyker@gmail.com>
 <1236661850-8237-5-git-send-email-stoyboyker@gmail.com>
In-Reply-To: <1236661850-8237-5-git-send-email-stoyboyker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Stoyan Gaydarov <stoyboyker@gmail.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org

Signed-off-by: Stoyan Gaydarov <stoyboyker@gmail.com>
---
 arch/ia64/kernel/module.c           |    3 +--
 arch/ia64/kernel/setup.c            |    3 +--
 arch/ia64/mm/init.c                 |    3 +--
 arch/ia64/sn/kernel/io_common.c     |   15 +++++----------
 arch/ia64/sn/kernel/io_init.c       |   12 ++++--------
 arch/ia64/sn/kernel/setup.c         |    3 +--
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    6 ++----
 arch/ia64/sn/pci/pcibr/pcibr_dma.c  |    4 +---
 8 files changed, 16 insertions(+), 33 deletions(-)

diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
index aaa7d90..19f5ce6 100644
--- a/arch/ia64/kernel/module.c
+++ b/arch/ia64/kernel/module.c
@@ -525,8 +525,7 @@ get_ltoff (struct module *mod, uint64_t value, int *okp)
 			goto found;
 
 	/* Not enough GOT entries? */
-	if (e >= (struct got_entry *) (mod->arch.got->sh_addr + mod->arch.got->sh_size))
-		BUG();
+	BUG_ON(e >= (struct got_entry *) (mod->arch.got->sh_addr + mod->arch.got->sh_size));
 
 	e->val = value;
 	++mod->arch.next_got_entry;
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 865af27..97b0f37 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -1016,8 +1016,7 @@ cpu_init (void)
 					| IA64_DCR_DA | IA64_DCR_DD | IA64_DCR_LC));
 	atomic_inc(&init_mm.mm_count);
 	current->active_mm = &init_mm;
-	if (current->mm)
-		BUG();
+	BUG_ON(current->mm);
 
 	ia64_mmu_init(ia64_imva(cpu_data));
 	ia64_mca_cpu_init(ia64_imva(cpu_data));
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 56e1290..1e8efb1 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -633,8 +633,7 @@ mem_init (void)
 #endif
 
 #ifdef CONFIG_FLATMEM
-	if (!mem_map)
-		BUG();
+	BUG_ON(!mem_map);
 	max_mapnr = max_low_pfn;
 #endif
 
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 0d4ffa4..57f280d 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -135,8 +135,7 @@ static s64 sn_device_fixup_war(u64 nasid, u64 widget, int device,
 	}
 
 	war_list = kzalloc(DEV_PER_WIDGET * sizeof(*war_list), GFP_KERNEL);
-	if (!war_list)
-		BUG();
+	BUG_ON(!war_list);
 
 	SAL_CALL_NOLOCK(isrv, SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST,
 			nasid, widget, __pa(war_list), 0, 0, 0 ,0);
@@ -180,23 +179,20 @@ sn_common_hubdev_init(struct hubdev_info *hubdev)
 		sizeof(struct sn_flush_device_kernel *);
 	hubdev->hdi_flush_nasid_list.widget_p  		kzalloc(size, GFP_KERNEL);
-	if (!hubdev->hdi_flush_nasid_list.widget_p)
-		BUG();
+	BUG_ON(!hubdev->hdi_flush_nasid_list.widget_p);
 
 	for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
 		size = DEV_PER_WIDGET *
 			sizeof(struct sn_flush_device_kernel);
 		sn_flush_device_kernel = kzalloc(size, GFP_KERNEL);
-		if (!sn_flush_device_kernel)
-			BUG();
+		BUG_ON(!sn_flush_device_kernel);
 
 		dev_entry = sn_flush_device_kernel;
 		for (device = 0; device < DEV_PER_WIDGET;
 		     device++, dev_entry++) {
 			size = sizeof(struct sn_flush_device_common);
 			dev_entry->common = kzalloc(size, GFP_KERNEL);
-			if (!dev_entry->common)
-				BUG();
+			BUG_ON(!dev_entry->common);
 			if (sn_prom_feature_available(PRF_DEVICE_FLUSH_LIST))
 				status = sal_get_device_dmaflush_list(
 					     hubdev->hdi_nasid, widget, device,
@@ -326,8 +322,7 @@ sn_common_bus_fixup(struct pci_bus *bus,
 	 */
 	controller->platform_data = kzalloc(sizeof(struct sn_platform_data),
 					    GFP_KERNEL);
-	if (controller->platform_data = NULL)
-		BUG();
+	BUG_ON(controller->platform_data = NULL);
 	sn_platform_data  			(struct sn_platform_data *) controller->platform_data;
 	sn_platform_data->provider_soft = provider_soft;
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index e2eb2da..ee774c3 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -128,8 +128,7 @@ sn_legacy_pci_window_fixup(struct pci_controller *controller,
 {
 		controller->window = kcalloc(2, sizeof(struct pci_window),
 					     GFP_KERNEL);
-		if (controller->window = NULL)
-			BUG();
+		BUG_ON(controller->window = NULL);
 		controller->window[0].offset = legacy_io;
 		controller->window[0].resource.name = "legacy_io";
 		controller->window[0].resource.flags = IORESOURCE_IO;
@@ -168,8 +167,7 @@ sn_pci_window_fixup(struct pci_dev *dev, unsigned int count,
 	idx = controller->windows;
 	new_count = controller->windows + count;
 	new_window = kcalloc(new_count, sizeof(struct pci_window), GFP_KERNEL);
-	if (new_window = NULL)
-		BUG();
+	BUG_ON(new_window = NULL);
 	if (controller->window) {
 		memcpy(new_window, controller->window,
 		       sizeof(struct pci_window) * controller->windows);
@@ -222,8 +220,7 @@ sn_io_slot_fixup(struct pci_dev *dev)
 		(u64) __pa(pcidev_info),
 		(u64) __pa(sn_irq_info));
 
-	if (status)
-		BUG(); /* Cannot get platform pci device information */
+	BUG_ON(status); /* Cannot get platform pci device information */
 
 
 	/* Copy over PIO Mapped Addresses */
@@ -307,8 +304,7 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 	prom_bussoft_ptr = __va(prom_bussoft_ptr);
 
 	controller = kzalloc(sizeof(*controller), GFP_KERNEL);
-	if (!controller)
-		BUG();
+	BUG_ON(!controller);
 	controller->segment = segment;
 
 	/*
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 02c5b8a..edbf168 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -732,8 +732,7 @@ void __init build_cnode_tables(void)
 		kl_config_hdr_t *klgraph_header;
 		nasid = cnodeid_to_nasid(node);
 		klgraph_header = ia64_sn_get_klconfig_addr(nasid);
-		if (klgraph_header = NULL)
-			BUG();
+		BUG_ON(klgraph_header = NULL);
 		brd = NODE_OFFSET_TO_LBOARD(nasid, klgraph_header->ch_board_info);
 		while (brd) {
 			if (board_needs_cnode(brd->brd_type) && physical_node_map[brd->brd_nasid] < 0) {
diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index be33947..2ae6d3f 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -275,8 +275,7 @@ static int sn_hwperf_get_nearest_node_objdata(struct sn_hwperf_object_info *objb
 
 	/* get it's interconnect topology */
 	sz = op->ports * sizeof(struct sn_hwperf_port_info);
-	if (sz > sizeof(ptdata))
-		BUG();
+	BUG_ON(sz > sizeof(ptdata));
 	e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
 			      SN_HWPERF_ENUM_PORTS, nodeobj->id, sz,
 			      (u64)&ptdata, 0, 0, NULL);
@@ -310,8 +309,7 @@ static int sn_hwperf_get_nearest_node_objdata(struct sn_hwperf_object_info *objb
 	if (router && (!found_cpu || !found_mem)) {
 		/* search for a node connected to the same router */
 		sz = router->ports * sizeof(struct sn_hwperf_port_info);
-		if (sz > sizeof(ptdata))
-			BUG();
+		BUG_ON(sz > sizeof(ptdata));
 		e = ia64_sn_hwperf_op(sn_hwperf_master_nasid,
 				      SN_HWPERF_ENUM_PORTS, router->id, sz,
 				      (u64)&ptdata, 0, 0, NULL);
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
index 060df4a..c659ad5 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -256,9 +256,7 @@ void sn_dma_flush(u64 addr)
 
 	hubinfo = (NODEPDA(nasid_to_cnodeid(nasid)))->pdinfo;
 
-	if (!hubinfo) {
-		BUG();
-	}
+	BUG_ON(!hubinfo);
 
 	flush_nasid_list = &hubinfo->hdi_flush_nasid_list;
 	if (flush_nasid_list->widget_p = NULL)
-- 
1.6.1.3

