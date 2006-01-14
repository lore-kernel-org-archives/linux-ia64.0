From: Prarit Bhargava <prarit@sgi.com>
Date: Sat, 14 Jan 2006 23:17:30 +0000
Subject: [PATCH 1/6 ]: arch/ia64/sn [u]intX_t cleanup
Message-Id: <20060114231641.12238.58545.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cleanup of arch/ia64/sn

Replace uintX_t declarations with uX declarations.
Replace intX_t declarations with sX declarations.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
---
commit 2ed3f5435b5b99558d4a4235d2f0237af8ec3568
tree 0e1711233980bb3d22415b569b135995c297c540
parent 87530db5ec7d519c7ba334e414307c5130ae2da8
author Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:57:13 -0500
committer Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:57:13 -0500

 arch/ia64/sn/include/xtalk/hubdev.h     |   10 ++-
 arch/ia64/sn/include/xtalk/xbow.h       |   94 ++++++++++++++++---------------
 arch/ia64/sn/include/xtalk/xwidgetdev.h |   46 ++++++++-------
 arch/ia64/sn/kernel/io_init.c           |   20 +++----
 arch/ia64/sn/kernel/irq.c               |   10 ++-
 arch/ia64/sn/kernel/tiocx.c             |   18 +++---
 arch/ia64/sn/pci/pcibr/pcibr_ate.c      |   16 +++--
 arch/ia64/sn/pci/pcibr/pcibr_dma.c      |   44 +++++++--------
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |   12 ++--
 arch/ia64/sn/pci/pcibr/pcibr_reg.c      |   28 +++++----
 arch/ia64/sn/pci/tioca_provider.c       |   36 ++++++------
 arch/ia64/sn/pci/tioce_provider.c       |   68 +++++++++++-----------
 12 files changed, 201 insertions(+), 201 deletions(-)

diff --git a/arch/ia64/sn/include/xtalk/hubdev.h b/arch/ia64/sn/include/xtalk/hubdev.h
--- a/arch/ia64/sn/include/xtalk/hubdev.h
+++ b/arch/ia64/sn/include/xtalk/hubdev.h
@@ -37,8 +37,8 @@ struct sn_flush_device_list {
 	unsigned long sfdl_force_int_addr;
 	unsigned long sfdl_flush_value;
 	volatile unsigned long *sfdl_flush_addr;
-	uint32_t sfdl_persistent_busnum;
-	uint32_t sfdl_persistent_segment;
+	u32 sfdl_persistent_busnum;
+	u32 sfdl_persistent_segment;
 	struct pcibus_info *sfdl_pcibus_info;
 	spinlock_t sfdl_flush_lock;
 };
@@ -48,7 +48,7 @@ struct sn_flush_device_list {
  */
 struct sn_flush_nasid_entry  {
 	struct sn_flush_device_list **widget_p; /* Used as a array of wid_num */
-	uint64_t iio_itte[8];
+	u64 iio_itte[8];
 };
 
 struct hubdev_info {
@@ -62,8 +62,8 @@ struct hubdev_info {
 
 	void				*hdi_nodepda;
 	void				*hdi_node_vertex;
-	uint32_t			max_segment_number;
-	uint32_t			max_pcibus_number;
+	u32				max_segment_number;
+	u32				max_pcibus_number;
 };
 
 extern void hubdev_init_node(nodepda_t *, cnodeid_t);
diff --git a/arch/ia64/sn/include/xtalk/xbow.h b/arch/ia64/sn/include/xtalk/xbow.h
--- a/arch/ia64/sn/include/xtalk/xbow.h
+++ b/arch/ia64/sn/include/xtalk/xbow.h
@@ -26,22 +26,22 @@ typedef volatile struct xb_linkregs_s {
  * gets twiddled (i.e. references to 0x4 actually go to 0x0 and vv.)
  * That's why we put the register first and filler second.
  */
-    uint32_t               link_ibf;
-    uint32_t               filler0;	/* filler for proper alignment */
-    uint32_t               link_control;
-    uint32_t               filler1;
-    uint32_t               link_status;
-    uint32_t               filler2;
-    uint32_t               link_arb_upper;
-    uint32_t               filler3;
-    uint32_t               link_arb_lower;
-    uint32_t               filler4;
-    uint32_t               link_status_clr;
-    uint32_t               filler5;
-    uint32_t               link_reset;
-    uint32_t               filler6;
-    uint32_t               link_aux_status;
-    uint32_t               filler7;
+    u32               link_ibf;
+    u32               filler0;	/* filler for proper alignment */
+    u32               link_control;
+    u32               filler1;
+    u32               link_status;
+    u32               filler2;
+    u32               link_arb_upper;
+    u32               filler3;
+    u32               link_arb_lower;
+    u32               filler4;
+    u32               link_status_clr;
+    u32               filler5;
+    u32               link_reset;
+    u32               filler6;
+    u32               link_aux_status;
+    u32               filler7;
 } xb_linkregs_t;
 
 typedef volatile struct xbow_s {
@@ -68,40 +68,40 @@ typedef volatile struct xbow_s {
  * That's why we put the register first and filler second.
  */
     /* xbow-specific widget configuration                  0x000058-0x0000FF */
-    uint32_t               xb_wid_arb_reload;  /* 0x00005C */
-    uint32_t               _pad_000058;
-    uint32_t               xb_perf_ctr_a;      /* 0x000064 */
-    uint32_t               _pad_000060;
-    uint32_t               xb_perf_ctr_b;      /* 0x00006c */
-    uint32_t               _pad_000068;
-    uint32_t               xb_nic;     /* 0x000074 */
-    uint32_t               _pad_000070;
+    u32               xb_wid_arb_reload;  /* 0x00005C */
+    u32               _pad_000058;
+    u32               xb_perf_ctr_a;      /* 0x000064 */
+    u32               _pad_000060;
+    u32               xb_perf_ctr_b;      /* 0x00006c */
+    u32               _pad_000068;
+    u32               xb_nic;     /* 0x000074 */
+    u32               _pad_000070;
 
     /* Xbridge only */
-    uint32_t               xb_w0_rst_fnc;      /* 0x00007C */
-    uint32_t               _pad_000078;
-    uint32_t               xb_l8_rst_fnc;      /* 0x000084 */
-    uint32_t               _pad_000080;
-    uint32_t               xb_l9_rst_fnc;      /* 0x00008c */
-    uint32_t               _pad_000088;
-    uint32_t               xb_la_rst_fnc;      /* 0x000094 */
-    uint32_t               _pad_000090;
-    uint32_t               xb_lb_rst_fnc;      /* 0x00009c */
-    uint32_t               _pad_000098;
-    uint32_t               xb_lc_rst_fnc;      /* 0x0000a4 */
-    uint32_t               _pad_0000a0;
-    uint32_t               xb_ld_rst_fnc;      /* 0x0000ac */
-    uint32_t               _pad_0000a8;
-    uint32_t               xb_le_rst_fnc;      /* 0x0000b4 */
-    uint32_t               _pad_0000b0;
-    uint32_t               xb_lf_rst_fnc;      /* 0x0000bc */
-    uint32_t               _pad_0000b8;
-    uint32_t               xb_lock;            /* 0x0000c4 */
-    uint32_t               _pad_0000c0;
-    uint32_t               xb_lock_clr;        /* 0x0000cc */
-    uint32_t               _pad_0000c8;
+    u32               xb_w0_rst_fnc;      /* 0x00007C */
+    u32               _pad_000078;
+    u32               xb_l8_rst_fnc;      /* 0x000084 */
+    u32               _pad_000080;
+    u32               xb_l9_rst_fnc;      /* 0x00008c */
+    u32               _pad_000088;
+    u32               xb_la_rst_fnc;      /* 0x000094 */
+    u32               _pad_000090;
+    u32               xb_lb_rst_fnc;      /* 0x00009c */
+    u32               _pad_000098;
+    u32               xb_lc_rst_fnc;      /* 0x0000a4 */
+    u32               _pad_0000a0;
+    u32               xb_ld_rst_fnc;      /* 0x0000ac */
+    u32               _pad_0000a8;
+    u32               xb_le_rst_fnc;      /* 0x0000b4 */
+    u32               _pad_0000b0;
+    u32               xb_lf_rst_fnc;      /* 0x0000bc */
+    u32               _pad_0000b8;
+    u32               xb_lock;            /* 0x0000c4 */
+    u32               _pad_0000c0;
+    u32               xb_lock_clr;        /* 0x0000cc */
+    u32               _pad_0000c8;
     /* end of Xbridge only */
-    uint32_t               _pad_0000d0[12];
+    u32               _pad_0000d0[12];
 
     /* Link Specific Registers, port 8..15                 0x000100-0x000300 */
     xb_linkregs_t           xb_link_raw[MAX_XBOW_PORTS];
diff --git a/arch/ia64/sn/include/xtalk/xwidgetdev.h b/arch/ia64/sn/include/xtalk/xwidgetdev.h
--- a/arch/ia64/sn/include/xtalk/xwidgetdev.h
+++ b/arch/ia64/sn/include/xtalk/xwidgetdev.h
@@ -25,28 +25,28 @@
 
 /* widget configuration registers */
 struct widget_cfg{
-	uint32_t	w_id;	/* 0x04 */
-	uint32_t	w_pad_0;	/* 0x00 */
-	uint32_t	w_status;	/* 0x0c */
-	uint32_t	w_pad_1;	/* 0x08 */
-	uint32_t	w_err_upper_addr;	/* 0x14 */
-	uint32_t	w_pad_2;	/* 0x10 */
-	uint32_t	w_err_lower_addr;	/* 0x1c */
-	uint32_t	w_pad_3;	/* 0x18 */
-	uint32_t	w_control;	/* 0x24 */
-	uint32_t	w_pad_4;	/* 0x20 */
-	uint32_t	w_req_timeout;	/* 0x2c */
-	uint32_t	w_pad_5;	/* 0x28 */
-	uint32_t	w_intdest_upper_addr;	/* 0x34 */
-	uint32_t	w_pad_6;	/* 0x30 */
-	uint32_t	w_intdest_lower_addr;	/* 0x3c */
-	uint32_t	w_pad_7;	/* 0x38 */
-	uint32_t	w_err_cmd_word;	/* 0x44 */
-	uint32_t	w_pad_8;	/* 0x40 */
-	uint32_t	w_llp_cfg;	/* 0x4c */
-	uint32_t	w_pad_9;	/* 0x48 */
-	uint32_t	w_tflush;	/* 0x54 */
-	uint32_t	w_pad_10;	/* 0x50 */
+	u32	w_id;	/* 0x04 */
+	u32	w_pad_0;	/* 0x00 */
+	u32	w_status;	/* 0x0c */
+	u32	w_pad_1;	/* 0x08 */
+	u32	w_err_upper_addr;	/* 0x14 */
+	u32	w_pad_2;	/* 0x10 */
+	u32	w_err_lower_addr;	/* 0x1c */
+	u32	w_pad_3;	/* 0x18 */
+	u32	w_control;	/* 0x24 */
+	u32	w_pad_4;	/* 0x20 */
+	u32	w_req_timeout;	/* 0x2c */
+	u32	w_pad_5;	/* 0x28 */
+	u32	w_intdest_upper_addr;	/* 0x34 */
+	u32	w_pad_6;	/* 0x30 */
+	u32	w_intdest_lower_addr;	/* 0x3c */
+	u32	w_pad_7;	/* 0x38 */
+	u32	w_err_cmd_word;	/* 0x44 */
+	u32	w_pad_8;	/* 0x40 */
+	u32	w_llp_cfg;	/* 0x4c */
+	u32	w_pad_9;	/* 0x48 */
+	u32	w_tflush;	/* 0x54 */
+	u32	w_pad_10;	/* 0x50 */
 };
 
 /*
@@ -63,7 +63,7 @@ struct xwidget_info{
 	struct xwidget_hwid	xwi_hwid;	/* Widget Identification */
 	char			xwi_masterxid;	/* Hub's Widget Port Number */
 	void			*xwi_hubinfo;     /* Hub's provider private info */
-	uint64_t		*xwi_hub_provider; /* prom provider functions */
+	u64			*xwi_hub_provider; /* prom provider functions */
 	void			*xwi_vertex;
 };
 
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -79,7 +79,7 @@ static struct sn_pcibus_provider sn_pci_
  * Retrieve the DMA Flush List given nasid.  This list is needed 
  * to implement the WAR - Flush DMA data on PIO Reads.
  */
-static inline uint64_t
+static inline u64
 sal_get_widget_dmaflush_list(u64 nasid, u64 widget_num, u64 address)
 {
 
@@ -98,7 +98,7 @@ sal_get_widget_dmaflush_list(u64 nasid, 
 /*
  * Retrieve the hub device info structure for the given nasid.
  */
-static inline uint64_t sal_get_hubdev_info(u64 handle, u64 address)
+static inline u64 sal_get_hubdev_info(u64 handle, u64 address)
 {
 
 	struct ia64_sal_retval ret_stuff;
@@ -114,7 +114,7 @@ static inline uint64_t sal_get_hubdev_in
 /*
  * Retrieve the pci bus information given the bus number.
  */
-static inline uint64_t sal_get_pcibus_info(u64 segment, u64 busnum, u64 address)
+static inline u64 sal_get_pcibus_info(u64 segment, u64 busnum, u64 address)
 {
 
 	struct ia64_sal_retval ret_stuff;
@@ -130,7 +130,7 @@ static inline uint64_t sal_get_pcibus_in
 /*
  * Retrieve the pci device information given the bus and device|function number.
  */
-static inline uint64_t
+static inline u64
 sal_get_pcidev_info(u64 segment, u64 bus_number, u64 devfn, u64 pci_dev, 
 			u64 sn_irq_info)
 {
@@ -173,8 +173,8 @@ static void sn_fixup_ionodes(void)
 
 	struct sn_flush_device_list *sn_flush_device_list;
 	struct hubdev_info *hubdev;
-	uint64_t status;
-	uint64_t nasid;
+	u64 status;
+	u64 nasid;
 	int i, widget;
 
 	/*
@@ -186,7 +186,7 @@ static void sn_fixup_ionodes(void)
 		nasid = cnodeid_to_nasid(i);
 		hubdev->max_segment_number = 0xffffffff;
 		hubdev->max_pcibus_number = 0xff;
-		status = sal_get_hubdev_info(nasid, (uint64_t) __pa(hubdev));
+		status = sal_get_hubdev_info(nasid, (u64) __pa(hubdev));
 		if (status)
 			continue;
 
@@ -230,7 +230,7 @@ static void sn_fixup_ionodes(void)
 
 			status  			    sal_get_widget_dmaflush_list(nasid, widget,
-							 (uint64_t)
+							 (u64)
 							 __pa
 							 (sn_flush_device_list));
 			if (status) {
@@ -256,7 +256,7 @@ static void sn_fixup_ionodes(void)
  */
 static void
 sn_pci_window_fixup(struct pci_dev *dev, unsigned int count,
-		    int64_t * pci_addrs)
+		    s64 * pci_addrs)
 {
 	struct pci_controller *controller = PCI_CONTROLLER(dev->bus);
 	unsigned int i;
@@ -316,7 +316,7 @@ void sn_pci_fixup_slot(struct pci_dev *d
  	struct pci_bus *host_pci_bus;
  	struct pci_dev *host_pci_dev;
 	struct pcidev_info *pcidev_info;
-	int64_t pci_addrs[PCI_ROM_RESOURCE + 1];
+	s64 pci_addrs[PCI_ROM_RESOURCE + 1];
  	struct sn_irq_info *sn_irq_info;
  	unsigned long size;
  	unsigned int bus_no, devfn;
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -28,7 +28,7 @@ extern int sn_ioif_inited;
 static struct list_head **sn_irq_lh;
 static spinlock_t sn_irq_info_lock = SPIN_LOCK_UNLOCKED; /* non-IRQ lock */
 
-static inline uint64_t sn_intr_alloc(nasid_t local_nasid, int local_widget,
+static inline u64 sn_intr_alloc(nasid_t local_nasid, int local_widget,
 				     u64 sn_irq_info,
 				     int req_irq, nasid_t req_nasid,
 				     int req_slice)
@@ -123,7 +123,7 @@ static void sn_set_affinity_irq(unsigned
 
 	list_for_each_entry_safe(sn_irq_info, sn_irq_info_safe,
 				 sn_irq_lh[irq], list) {
-		uint64_t bridge;
+		u64 bridge;
 		int local_widget, status;
 		nasid_t local_nasid;
 		struct sn_irq_info *new_irq_info;
@@ -134,7 +134,7 @@ static void sn_set_affinity_irq(unsigned
 			break;
 		memcpy(new_irq_info, sn_irq_info, sizeof(struct sn_irq_info));
 
-		bridge = (uint64_t) new_irq_info->irq_bridge;
+		bridge = (u64) new_irq_info->irq_bridge;
 		if (!bridge) {
 			kfree(new_irq_info);
 			break; /* irq is not a device interrupt */
@@ -349,10 +349,10 @@ static void force_interrupt(int irq)
  */
 static void sn_check_intr(int irq, struct sn_irq_info *sn_irq_info)
 {
-	uint64_t regval;
+	u64 regval;
 	int irr_reg_num;
 	int irr_bit;
-	uint64_t irr_reg;
+	u64 irr_reg;
 	struct pcidev_info *pcidev_info;
 	struct pcibus_info *pcibus_info;
 
diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
--- a/arch/ia64/sn/kernel/tiocx.c
+++ b/arch/ia64/sn/kernel/tiocx.c
@@ -245,7 +245,7 @@ static int cx_device_reload(struct cx_de
 				  cx_dev->bt);
 }
 
-static inline uint64_t tiocx_intr_alloc(nasid_t nasid, int widget,
+static inline u64 tiocx_intr_alloc(nasid_t nasid, int widget,
 					u64 sn_irq_info,
 					int req_irq, nasid_t req_nasid,
 					int req_slice)
@@ -302,7 +302,7 @@ struct sn_irq_info *tiocx_irq_alloc(nasi
 
 void tiocx_irq_free(struct sn_irq_info *sn_irq_info)
 {
-	uint64_t bridge = (uint64_t) sn_irq_info->irq_bridge;
+	u64 bridge = (u64) sn_irq_info->irq_bridge;
 	nasid_t nasid = NASID_GET(bridge);
 	int widget;
 
@@ -313,12 +313,12 @@ void tiocx_irq_free(struct sn_irq_info *
 	}
 }
 
-uint64_t tiocx_dma_addr(uint64_t addr)
+u64 tiocx_dma_addr(u64 addr)
 {
 	return PHYS_TO_TIODMA(addr);
 }
 
-uint64_t tiocx_swin_base(int nasid)
+u64 tiocx_swin_base(int nasid)
 {
 	return TIO_SWIN_BASE(nasid, TIOCX_CORELET);
 }
@@ -335,8 +335,8 @@ EXPORT_SYMBOL(tiocx_swin_base);
 
 static void tio_conveyor_set(nasid_t nasid, int enable_flag)
 {
-	uint64_t ice_frz;
-	uint64_t disable_cb = (1ull << 61);
+	u64 ice_frz;
+	u64 disable_cb = (1ull << 61);
 
 	if (!(nasid & 1))
 		return;
@@ -388,7 +388,7 @@ static int is_fpga_tio(int nasid, int *b
 
 static int bitstream_loaded(nasid_t nasid)
 {
-	uint64_t cx_credits;
+	u64 cx_credits;
 
 	cx_credits = REMOTE_HUB_L(nasid, TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3);
 	cx_credits &= TIO_ICE_PMI_TX_DYN_CREDIT_STAT_CB3_CREDIT_CNT_MASK;
@@ -404,14 +404,14 @@ static int tiocx_reload(struct cx_dev *c
 	nasid_t nasid = cx_dev->cx_id.nasid;
 
 	if (bitstream_loaded(nasid)) {
-		uint64_t cx_id;
+		u64 cx_id;
 		int rv;
 
 		rv = ia64_sn_sysctl_tio_clock_reset(nasid);
 		if (rv) {
 			printk(KERN_ALERT "CX port JTAG reset failed.\n");
 		} else {
-			cx_id = *(volatile uint64_t *)
+			cx_id = *(volatile u64 *)
 				(TIO_SWIN_BASE(nasid, TIOCX_CORELET) +
 					  WIDGET_ID);
 			part_num = XWIDGET_PART_NUM(cx_id);
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_ate.c b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_ate.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
@@ -18,10 +18,10 @@ int pcibr_invalidate_ate = 0;	/* by defa
  * mark_ate: Mark the ate as either free or inuse.
  */
 static void mark_ate(struct ate_resource *ate_resource, int start, int number,
-		     uint64_t value)
+		     u64 value)
 {
 
-	uint64_t *ate = ate_resource->ate;
+	u64 *ate = ate_resource->ate;
 	int index;
 	int length = 0;
 
@@ -38,7 +38,7 @@ static int find_free_ate(struct ate_reso
 			 int count)
 {
 
-	uint64_t *ate = ate_resource->ate;
+	u64 *ate = ate_resource->ate;
 	int index;
 	int start_free;
 
@@ -119,7 +119,7 @@ static inline int alloc_ate_resource(str
 int pcibr_ate_alloc(struct pcibus_info *pcibus_info, int count)
 {
 	int status = 0;
-	uint64_t flag;
+	u64 flag;
 
 	flag = pcibr_lock(pcibus_info);
 	status = alloc_ate_resource(&pcibus_info->pbi_int_ate_resource, count);
@@ -139,7 +139,7 @@ int pcibr_ate_alloc(struct pcibus_info *
  * Setup an Address Translation Entry as specified.  Use either the Bridge
  * internal maps or the external map RAM, as appropriate.
  */
-static inline uint64_t *pcibr_ate_addr(struct pcibus_info *pcibus_info,
+static inline u64 *pcibr_ate_addr(struct pcibus_info *pcibus_info,
 				       int ate_index)
 {
 	if (ate_index < pcibus_info->pbi_int_ate_size) {
@@ -153,7 +153,7 @@ static inline uint64_t *pcibr_ate_addr(s
  */
 void inline
 ate_write(struct pcibus_info *pcibus_info, int ate_index, int count,
-	  volatile uint64_t ate)
+	  volatile u64 ate)
 {
 	while (count-- > 0) {
 		if (ate_index < pcibus_info->pbi_int_ate_size) {
@@ -171,9 +171,9 @@ ate_write(struct pcibus_info *pcibus_inf
 void pcibr_ate_free(struct pcibus_info *pcibus_info, int index)
 {
 
-	volatile uint64_t ate;
+	volatile u64 ate;
 	int count;
-	uint64_t flags;
+	u64 flags;
 
 	if (pcibr_invalidate_ate) {
 		/* For debugging purposes, clear the valid bit in the ATE */
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -41,21 +41,21 @@ extern int sn_ioif_inited;
 
 static dma_addr_t
 pcibr_dmamap_ate32(struct pcidev_info *info,
-		   uint64_t paddr, size_t req_size, uint64_t flags)
+		   u64 paddr, size_t req_size, u64 flags)
 {
 
 	struct pcidev_info *pcidev_info = info->pdi_host_pcidev_info;
 	struct pcibus_info *pcibus_info = (struct pcibus_info *)pcidev_info->
 	    pdi_pcibus_info;
-	uint8_t internal_device = (PCI_SLOT(pcidev_info->pdi_host_pcidev_info->
+	u8 internal_device = (PCI_SLOT(pcidev_info->pdi_host_pcidev_info->
 					    pdi_linux_pcidev->devfn)) - 1;
 	int ate_count;
 	int ate_index;
-	uint64_t ate_flags = flags | PCI32_ATE_V;
-	uint64_t ate;
-	uint64_t pci_addr;
-	uint64_t xio_addr;
-	uint64_t offset;
+	u64 ate_flags = flags | PCI32_ATE_V;
+	u64 ate;
+	u64 pci_addr;
+	u64 xio_addr;
+	u64 offset;
 
 	/* PIC in PCI-X mode does not supports 32bit PageMap mode */
 	if (IS_PIC_SOFT(pcibus_info) && IS_PCIX(pcibus_info)) {
@@ -109,12 +109,12 @@ pcibr_dmamap_ate32(struct pcidev_info *i
 }
 
 static dma_addr_t
-pcibr_dmatrans_direct64(struct pcidev_info * info, uint64_t paddr,
-			uint64_t dma_attributes)
+pcibr_dmatrans_direct64(struct pcidev_info * info, u64 paddr,
+			u64 dma_attributes)
 {
 	struct pcibus_info *pcibus_info = (struct pcibus_info *)
 	    ((info->pdi_host_pcidev_info)->pdi_pcibus_info);
-	uint64_t pci_addr;
+	u64 pci_addr;
 
 	/* Translate to Crosstalk View of Physical Address */
 	pci_addr = (IS_PIC_SOFT(pcibus_info) ? PHYS_TO_DMA(paddr) :
@@ -127,7 +127,7 @@ pcibr_dmatrans_direct64(struct pcidev_in
 	/* Handle Bridge Chipset differences */
 	if (IS_PIC_SOFT(pcibus_info)) {
 		pci_addr |-		    ((uint64_t) pcibus_info->
+		    ((u64) pcibus_info->
 		     pbi_hub_xid << PIC_PCI64_ATTR_TARG_SHFT);
 	} else
 		pci_addr |= TIOCP_PCI64_CMDTYPE_MEM;
@@ -142,17 +142,17 @@ pcibr_dmatrans_direct64(struct pcidev_in
 
 static dma_addr_t
 pcibr_dmatrans_direct32(struct pcidev_info * info,
-			uint64_t paddr, size_t req_size, uint64_t flags)
+			u64 paddr, size_t req_size, u64 flags)
 {
 
 	struct pcidev_info *pcidev_info = info->pdi_host_pcidev_info;
 	struct pcibus_info *pcibus_info = (struct pcibus_info *)pcidev_info->
 	    pdi_pcibus_info;
-	uint64_t xio_addr;
+	u64 xio_addr;
 
-	uint64_t xio_base;
-	uint64_t offset;
-	uint64_t endoff;
+	u64 xio_base;
+	u64 offset;
+	u64 endoff;
 
 	if (IS_PCIX(pcibus_info)) {
 		return 0;
@@ -209,14 +209,14 @@ pcibr_dma_unmap(struct pci_dev *hwdev, d
  * unlike the PIC Device(x) Write Request Buffer Flush register.
  */
 
-void sn_dma_flush(uint64_t addr)
+void sn_dma_flush(u64 addr)
 {
 	nasid_t nasid;
 	int is_tio;
 	int wid_num;
 	int i, j;
-	uint64_t flags;
-	uint64_t itte;
+	u64 flags;
+	u64 itte;
 	struct hubdev_info *hubinfo;
 	volatile struct sn_flush_device_list *p;
 	struct sn_flush_nasid_entry *flush_nasid_list;
@@ -297,8 +297,8 @@ void sn_dma_flush(uint64_t addr)
 		 * If CE ever needs the sn_dma_flush mechanism, we will have
 		 * to account for that here and in tioce_bus_fixup().
 	 	 */
-		uint32_t tio_id = HUB_L(TIO_IOSPACE_ADDR(nasid, TIO_NODE_ID));
-		uint32_t revnum = XWIDGET_PART_REV_NUM(tio_id);
+		u32 tio_id = HUB_L(TIO_IOSPACE_ADDR(nasid, TIO_NODE_ID));
+		u32 revnum = XWIDGET_PART_REV_NUM(tio_id);
 
 		/* TIOCP BRINGUP WAR (PV907516): Don't write buffer flush reg */
 		if ((1 << XWIDGET_PART_REV_NUM_REV(revnum)) & PV907516) {
@@ -314,7 +314,7 @@ void sn_dma_flush(uint64_t addr)
 		*p->sfdl_flush_addr = 0;
 
 		/* force an interrupt. */
-		*(volatile uint32_t *)(p->sfdl_force_int_addr) = 1;
+		*(volatile u32 *)(p->sfdl_force_int_addr) = 1;
 
 		/* wait for the interrupt to come back. */
 		while (*(p->sfdl_flush_addr) != 0x10f)
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -23,7 +23,7 @@ int
 sal_pcibr_slot_enable(struct pcibus_info *soft, int device, void *resp)
 {
 	struct ia64_sal_retval ret_stuff;
-	uint64_t busnum;
+	u64 busnum;
 
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -40,7 +40,7 @@ sal_pcibr_slot_disable(struct pcibus_inf
 		       void *resp)
 {
 	struct ia64_sal_retval ret_stuff;
-	uint64_t busnum;
+	u64 busnum;
 
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -56,7 +56,7 @@ sal_pcibr_slot_disable(struct pcibus_inf
 static int sal_pcibr_error_interrupt(struct pcibus_info *soft)
 {
 	struct ia64_sal_retval ret_stuff;
-	uint64_t busnum;
+	u64 busnum;
 	int segment;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -159,9 +159,9 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 	/* Setup the PMU ATE map */
 	soft->pbi_int_ate_resource.lowest_free_index = 0;
 	soft->pbi_int_ate_resource.ate -	    kmalloc(soft->pbi_int_ate_size * sizeof(uint64_t), GFP_KERNEL);
+	    kmalloc(soft->pbi_int_ate_size * sizeof(u64), GFP_KERNEL);
 	memset(soft->pbi_int_ate_resource.ate, 0,
- 	       (soft->pbi_int_ate_size * sizeof(uint64_t)));
+ 	       (soft->pbi_int_ate_size * sizeof(u64)));
 
 	if (prom_bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP) {
 		/* TIO PCI Bridge: find nearest node with CPUs */
@@ -203,7 +203,7 @@ void pcibr_target_interrupt(struct sn_ir
 	struct pcidev_info *pcidev_info;
 	struct pcibus_info *pcibus_info;
 	int bit = sn_irq_info->irq_int_bit;
-	uint64_t xtalk_addr = sn_irq_info->irq_xtalkaddr;
+	u64 xtalk_addr = sn_irq_info->irq_xtalkaddr;
 
 	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	if (pcidev_info) {
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_reg.c b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_reg.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
@@ -23,7 +23,7 @@ union br_ptr {
 /*
  * Control Register Access -- Read/Write                            0000_0020
  */
-void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, uint64_t bits)
+void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
@@ -43,7 +43,7 @@ void pcireg_control_bit_clr(struct pcibu
 	}
 }
 
-void pcireg_control_bit_set(struct pcibus_info *pcibus_info, uint64_t bits)
+void pcireg_control_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
@@ -66,10 +66,10 @@ void pcireg_control_bit_set(struct pcibu
 /*
  * PCI/PCIX Target Flush Register Access -- Read Only		    0000_0050
  */
-uint64_t pcireg_tflush_get(struct pcibus_info *pcibus_info)
+u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-	uint64_t ret = 0;
+	u64 ret = 0;
 
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
@@ -96,10 +96,10 @@ uint64_t pcireg_tflush_get(struct pcibus
 /*
  * Interrupt Status Register Access -- Read Only		    0000_0100
  */
-uint64_t pcireg_intr_status_get(struct pcibus_info * pcibus_info)
+u64 pcireg_intr_status_get(struct pcibus_info * pcibus_info)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-	uint64_t ret = 0;
+	u64 ret = 0;
 
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
@@ -121,7 +121,7 @@ uint64_t pcireg_intr_status_get(struct p
 /*
  * Interrupt Enable Register Access -- Read/Write                   0000_0108
  */
-void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, uint64_t bits)
+void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
@@ -141,7 +141,7 @@ void pcireg_intr_enable_bit_clr(struct p
 	}
 }
 
-void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, uint64_t bits)
+void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
@@ -165,7 +165,7 @@ void pcireg_intr_enable_bit_set(struct p
  * Intr Host Address Register (int_addr) -- Read/Write  0000_0130 - 0000_0168
  */
 void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
-			       uint64_t addr)
+			       u64 addr)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
@@ -217,10 +217,10 @@ void pcireg_force_intr_set(struct pcibus
 /*
  * Device(x) Write Buffer Flush Reg Access -- Read Only 0000_0240 - 0000_0258
  */
-uint64_t pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
+u64 pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-	uint64_t ret = 0;
+	u64 ret = 0;
 
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
@@ -242,7 +242,7 @@ uint64_t pcireg_wrb_flush_get(struct pci
 }
 
 void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
-			uint64_t val)
+			u64 val)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
@@ -262,10 +262,10 @@ void pcireg_int_ate_set(struct pcibus_in
 	}
 }
 
-uint64_t __iomem *pcireg_int_ate_addr(struct pcibus_info *pcibus_info, int ate_index)
+u64 __iomem *pcireg_int_ate_addr(struct pcibus_info *pcibus_info, int ate_index)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-	uint64_t __iomem *ret = NULL;
+	u64 __iomem *ret = NULL;
 
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -16,7 +16,7 @@
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/tioca_provider.h>
 
-uint32_t tioca_gart_found;
+u32 tioca_gart_found;
 EXPORT_SYMBOL(tioca_gart_found);	/* used by agp-sgi */
 
 LIST_HEAD(tioca_list);
@@ -34,8 +34,8 @@ static int tioca_gart_init(struct tioca_
 static int
 tioca_gart_init(struct tioca_kernel *tioca_kern)
 {
-	uint64_t ap_reg;
-	uint64_t offset;
+	u64 ap_reg;
+	u64 offset;
 	struct page *tmp;
 	struct tioca_common *tioca_common;
 	struct tioca __iomem *ca_base;
@@ -214,7 +214,7 @@ void
 tioca_fastwrite_enable(struct tioca_kernel *tioca_kern)
 {
 	int cap_ptr;
-	uint32_t reg;
+	u32 reg;
 	struct tioca __iomem *tioca_base;
 	struct pci_dev *pdev;
 	struct tioca_common *common;
@@ -276,7 +276,7 @@ EXPORT_SYMBOL(tioca_fastwrite_enable);	/
  *                                 We will always use 0x1
  * 55:55 - Swap bytes		   Currently unused
  */
-static uint64_t
+static u64
 tioca_dma_d64(unsigned long paddr)
 {
 	dma_addr_t bus_addr;
@@ -318,15 +318,15 @@ tioca_dma_d64(unsigned long paddr)
  * and so a given CA can only directly target nodes in the range
  * xxx - xxx+255.
  */
-static uint64_t
-tioca_dma_d48(struct pci_dev *pdev, uint64_t paddr)
+static u64
+tioca_dma_d48(struct pci_dev *pdev, u64 paddr)
 {
 	struct tioca_common *tioca_common;
 	struct tioca __iomem *ca_base;
-	uint64_t ct_addr;
+	u64 ct_addr;
 	dma_addr_t bus_addr;
-	uint32_t node_upper;
-	uint64_t agp_dma_extn;
+	u32 node_upper;
+	u64 agp_dma_extn;
 	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(pdev);
 
 	tioca_common = (struct tioca_common *)pcidev_info->pdi_pcibus_info;
@@ -367,10 +367,10 @@ tioca_dma_d48(struct pci_dev *pdev, uint
  * dma_addr_t is guarenteed to be contiguous in CA bus space.
  */
 static dma_addr_t
-tioca_dma_mapped(struct pci_dev *pdev, uint64_t paddr, size_t req_size)
+tioca_dma_mapped(struct pci_dev *pdev, u64 paddr, size_t req_size)
 {
 	int i, ps, ps_shift, entry, entries, mapsize, last_entry;
-	uint64_t xio_addr, end_xio_addr;
+	u64 xio_addr, end_xio_addr;
 	struct tioca_common *tioca_common;
 	struct tioca_kernel *tioca_kern;
 	dma_addr_t bus_addr = 0;
@@ -514,10 +514,10 @@ tioca_dma_unmap(struct pci_dev *pdev, dm
  * The mapping mode used is based on the devices dma_mask.  As a last resort
  * use the GART mapped mode.
  */
-static uint64_t
-tioca_dma_map(struct pci_dev *pdev, uint64_t paddr, size_t byte_count)
+static u64
+tioca_dma_map(struct pci_dev *pdev, u64 paddr, size_t byte_count)
 {
-	uint64_t mapaddr;
+	u64 mapaddr;
 
 	/*
 	 * If card is 64 or 48 bit addresable, use a direct mapping.  32
@@ -554,8 +554,8 @@ tioca_error_intr_handler(int irq, void *
 {
 	struct tioca_common *soft = arg;
 	struct ia64_sal_retval ret_stuff;
-	uint64_t segment;
-	uint64_t busnum;
+	u64 segment;
+	u64 busnum;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
 
@@ -620,7 +620,7 @@ tioca_bus_fixup(struct pcibus_bussoft *p
 	INIT_LIST_HEAD(&tioca_kern->ca_dmamaps);
 	tioca_kern->ca_closest_node  	    nasid_to_cnodeid(tioca_common->ca_closest_nasid);
-	tioca_common->ca_kernel_private = (uint64_t) tioca_kern;
+	tioca_common->ca_kernel_private = (u64) tioca_kern;
 
 	bus = pci_find_bus(tioca_common->ca_common.bs_persist_segment,
 		tioca_common->ca_common.bs_persist_busnum);
diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -81,10 +81,10 @@
  * 61    - 0 since this is not an MSI transaction
  * 60:54 - reserved, MBZ
  */
-static uint64_t
+static u64
 tioce_dma_d64(unsigned long ct_addr)
 {
-	uint64_t bus_addr;
+	u64 bus_addr;
 
 	bus_addr = ct_addr | (1UL << 63);
 
@@ -141,9 +141,9 @@ pcidev_to_tioce(struct pci_dev *pdev, st
  * length, and if enough resources exist, fill in the ATE's and construct a
  * tioce_dmamap struct to track the mapping.
  */
-static uint64_t
+static u64
 tioce_alloc_map(struct tioce_kernel *ce_kern, int type, int port,
-		uint64_t ct_addr, int len)
+		u64 ct_addr, int len)
 {
 	int i;
 	int j;
@@ -152,11 +152,11 @@ tioce_alloc_map(struct tioce_kernel *ce_
 	int entries;
 	int nates;
 	int pagesize;
-	uint64_t *ate_shadow;
-	uint64_t *ate_reg;
-	uint64_t addr;
+	u64 *ate_shadow;
+	u64 *ate_reg;
+	u64 addr;
 	struct tioce *ce_mmr;
-	uint64_t bus_base;
+	u64 bus_base;
 	struct tioce_dmamap *map;
 
 	ce_mmr = (struct tioce *)ce_kern->ce_common->ce_pcibus.bs_base;
@@ -224,7 +224,7 @@ tioce_alloc_map(struct tioce_kernel *ce_
 
 	addr = ct_addr;
 	for (j = 0; j < nates; j++) {
-		uint64_t ate;
+		u64 ate;
 
 		ate = ATE_MAKE(addr, pagesize);
 		ate_shadow[i + j] = ate;
@@ -252,15 +252,15 @@ tioce_alloc_map(struct tioce_kernel *ce_
  *
  * Map @paddr into 32-bit bus space of the CE associated with @pcidev_info.
  */
-static uint64_t
-tioce_dma_d32(struct pci_dev *pdev, uint64_t ct_addr)
+static u64
+tioce_dma_d32(struct pci_dev *pdev, u64 ct_addr)
 {
 	int dma_ok;
 	int port;
 	struct tioce *ce_mmr;
 	struct tioce_kernel *ce_kern;
-	uint64_t ct_upper;
-	uint64_t ct_lower;
+	u64 ct_upper;
+	u64 ct_lower;
 	dma_addr_t bus_addr;
 
 	ct_upper = ct_addr & ~0x3fffffffUL;
@@ -269,7 +269,7 @@ tioce_dma_d32(struct pci_dev *pdev, uint
 	pcidev_to_tioce(pdev, &ce_mmr, &ce_kern, &port);
 
 	if (ce_kern->ce_port[port].dirmap_refcnt = 0) {
-		uint64_t tmp;
+		u64 tmp;
 
 		ce_kern->ce_port[port].dirmap_shadow = ct_upper;
 		writeq(ct_upper, &ce_mmr->ce_ure_dir_map[port]);
@@ -295,10 +295,10 @@ tioce_dma_d32(struct pci_dev *pdev, uint
  * Given a TIOCE bus address, set the appropriate bit to indicate barrier
  * attributes.
  */
-static uint64_t
-tioce_dma_barrier(uint64_t bus_addr, int on)
+static u64
+tioce_dma_barrier(u64 bus_addr, int on)
 {
-	uint64_t barrier_bit;
+	u64 barrier_bit;
 
 	/* barrier not supported in M40/M40S mode */
 	if (TIOCE_M40_ADDR(bus_addr) || TIOCE_M40S_ADDR(bus_addr))
@@ -351,7 +351,7 @@ tioce_dma_unmap(struct pci_dev *pdev, dm
 
 		list_for_each_entry(map, &ce_kern->ce_dmamap_list,
 				    ce_dmamap_list) {
-			uint64_t last;
+			u64 last;
 
 			last = map->pci_start + map->nbytes - 1;
 			if (bus_addr >= map->pci_start && bus_addr <= last)
@@ -385,17 +385,17 @@ tioce_dma_unmap(struct pci_dev *pdev, dm
  * This is the main wrapper for mapping host physical pages to CE PCI space.
  * The mapping mode used is based on the device's dma_mask.
  */
-static uint64_t
-tioce_do_dma_map(struct pci_dev *pdev, uint64_t paddr, size_t byte_count,
+static u64
+tioce_do_dma_map(struct pci_dev *pdev, u64 paddr, size_t byte_count,
 		 int barrier)
 {
 	unsigned long flags;
-	uint64_t ct_addr;
-	uint64_t mapaddr = 0;
+	u64 ct_addr;
+	u64 mapaddr = 0;
 	struct tioce_kernel *ce_kern;
 	struct tioce_dmamap *map;
 	int port;
-	uint64_t dma_mask;
+	u64 dma_mask;
 
 	dma_mask = (barrier) ? pdev->dev.coherent_dma_mask : pdev->dma_mask;
 
@@ -425,7 +425,7 @@ tioce_do_dma_map(struct pci_dev *pdev, u
 	 * address bits than this device can support.
 	 */
 	list_for_each_entry(map, &ce_kern->ce_dmamap_list, ce_dmamap_list) {
-		uint64_t last;
+		u64 last;
 
 		last = map->ct_start + map->nbytes - 1;
 		if (ct_addr >= map->ct_start &&
@@ -501,8 +501,8 @@ dma_map_done:
  * Simply call tioce_do_dma_map() to create a map with the barrier bit clear
  * in the address.
  */
-static uint64_t
-tioce_dma(struct pci_dev *pdev, uint64_t paddr, size_t byte_count)
+static u64
+tioce_dma(struct pci_dev *pdev, u64 paddr, size_t byte_count)
 {
 	return tioce_do_dma_map(pdev, paddr, byte_count, 0);
 }
@@ -515,8 +515,8 @@ tioce_dma(struct pci_dev *pdev, uint64_t
  *
  * Simply call tioce_do_dma_map() to create a map with the barrier bit set
  * in the address.
- */ static uint64_t
-tioce_dma_consistent(struct pci_dev *pdev, uint64_t paddr, size_t byte_count)
+ */ static u64
+tioce_dma_consistent(struct pci_dev *pdev, u64 paddr, size_t byte_count)
 {
 	return tioce_do_dma_map(pdev, paddr, byte_count, 1);
 }
@@ -551,7 +551,7 @@ tioce_error_intr_handler(int irq, void *
 tioce_kern_init(struct tioce_common *tioce_common)
 {
 	int i;
-	uint32_t tmp;
+	u32 tmp;
 	struct tioce *tioce_mmr;
 	struct tioce_kernel *tioce_kern;
 
@@ -563,7 +563,7 @@ tioce_kern_init(struct tioce_common *tio
 	tioce_kern->ce_common = tioce_common;
 	spin_lock_init(&tioce_kern->ce_lock);
 	INIT_LIST_HEAD(&tioce_kern->ce_dmamap_list);
-	tioce_common->ce_kernel_private = (uint64_t) tioce_kern;
+	tioce_common->ce_kernel_private = (u64) tioce_kern;
 
 	/*
 	 * Determine the secondary bus number of the port2 logical PPB.
@@ -575,7 +575,7 @@ tioce_kern_init(struct tioce_common *tio
 	raw_pci_ops->read(tioce_common->ce_pcibus.bs_persist_segment,
 			  tioce_common->ce_pcibus.bs_persist_busnum,
 			  PCI_DEVFN(2, 0), PCI_SECONDARY_BUS, 1, &tmp);
-	tioce_kern->ce_port1_secondary = (uint8_t) tmp;
+	tioce_kern->ce_port1_secondary = (u8) tmp;
 
 	/*
 	 * Set PMU pagesize to the largest size available, and zero out
@@ -615,7 +615,7 @@ tioce_force_interrupt(struct sn_irq_info
 	struct pcidev_info *pcidev_info;
 	struct tioce_common *ce_common;
 	struct tioce *ce_mmr;
-	uint64_t force_int_val;
+	u64 force_int_val;
 
 	if (!sn_irq_info->irq_bridge)
 		return;
@@ -687,7 +687,7 @@ tioce_target_interrupt(struct sn_irq_inf
 	struct tioce_common *ce_common;
 	struct tioce *ce_mmr;
 	int bit;
-	uint64_t vector;
+	u64 vector;
 
 	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	if (!pcidev_info)
@@ -699,7 +699,7 @@ tioce_target_interrupt(struct sn_irq_inf
 	bit = sn_irq_info->irq_int_bit;
 
 	__sn_setq_relaxed(&ce_mmr->ce_adm_int_mask, (1UL << bit));
-	vector = (uint64_t)sn_irq_info->irq_irq << INTR_VECTOR_SHFT;
+	vector = (u64)sn_irq_info->irq_irq << INTR_VECTOR_SHFT;
 	vector |= sn_irq_info->irq_xtalkaddr;
 	writeq(vector, &ce_mmr->ce_adm_int_dest[bit]);
 	__sn_clrq_relaxed(&ce_mmr->ce_adm_int_mask, (1UL << bit));
