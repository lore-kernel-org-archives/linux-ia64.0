From: Prarit Bhargava <prarit@sgi.com>
Date: Sat, 14 Jan 2006 23:17:35 +0000
Subject: [PATCH 2/2 ]: include/asm-ia64/sn [u]intX_t cleanup
Message-Id: <20060114231647.12238.44688.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In include/asm-ia64/sn, excluding pic.h, shubio.h, and tioce.h

Replace uintX_t declarations with uX declarations.
Replace intX_t declarations with sX declarations.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
---
commit 388e2e7769a5e7d4e2cfe3f90dbf33568ff78170
tree 66f28f26f9ca4ec39349b7cdf511426b725c912a
parent 2ed3f5435b5b99558d4a4235d2f0237af8ec3568
author Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:57:52 -0500
committer Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:57:52 -0500

 include/asm-ia64/sn/intr.h                 |    2 
 include/asm-ia64/sn/pcibr_provider.h       |   48 +++--
 include/asm-ia64/sn/pcibus_provider_defs.h |   14 +-
 include/asm-ia64/sn/pcidev.h               |    4 
 include/asm-ia64/sn/sn_sal.h               |   12 +
 include/asm-ia64/sn/tioca.h                |   78 ++++-----
 include/asm-ia64/sn/tioca_provider.h       |   56 +++---
 include/asm-ia64/sn/tioce_provider.h       |   30 ++-
 include/asm-ia64/sn/tiocp.h                |  254 ++++++++++++++--------------
 include/asm-ia64/sn/tiocx.h                |   14 +-
 10 files changed, 256 insertions(+), 256 deletions(-)

diff --git a/include/asm-ia64/sn/intr.h b/include/asm-ia64/sn/intr.h
--- a/include/asm-ia64/sn/intr.h
+++ b/include/asm-ia64/sn/intr.h
@@ -40,7 +40,7 @@ struct sn_irq_info {
 	int		irq_cpuid;	/* kernel logical cpuid	     */
 	int		irq_irq;	/* the IRQ number */
 	int		irq_int_bit;	/* Bridge interrupt pin */
-	uint64_t	irq_xtalkaddr;	/* xtalkaddr IRQ is sent to  */
+	u64	irq_xtalkaddr;	/* xtalkaddr IRQ is sent to  */
 	int		irq_bridge_type;/* pciio asic type (pciio.h) */
 	void	       *irq_bridge;	/* bridge generating irq     */
 	void	       *irq_pciioinfo;	/* associated pciio_info_t   */
diff --git a/include/asm-ia64/sn/pcibr_provider.h b/include/asm-ia64/sn/pcibr_provider.h
--- a/include/asm-ia64/sn/pcibr_provider.h
+++ b/include/asm-ia64/sn/pcibr_provider.h
@@ -44,9 +44,9 @@
 #define PCI32_MAPPED_BASE               0x40000000
 #define PCI32_DIRECT_BASE               0x80000000
 
-#define IS_PCI32_MAPPED(x)              ((uint64_t)(x) < PCI32_DIRECT_BASE && \
-                                         (uint64_t)(x) >= PCI32_MAPPED_BASE)
-#define IS_PCI32_DIRECT(x)              ((uint64_t)(x) >= PCI32_MAPPED_BASE)
+#define IS_PCI32_MAPPED(x)              ((u64)(x) < PCI32_DIRECT_BASE && \
+                                         (u64)(x) >= PCI32_MAPPED_BASE)
+#define IS_PCI32_DIRECT(x)              ((u64)(x) >= PCI32_MAPPED_BASE)
 
 
 /*
@@ -63,7 +63,7 @@
 	(IOPG(IOPGOFF(addr) + (size) - 1) = IOPG((size) - 1))
 
 #define MINIMAL_ATE_FLAG(addr, size) \
-	(MINIMAL_ATES_REQUIRED((uint64_t)addr, size) ? 1 : 0)
+	(MINIMAL_ATES_REQUIRED((u64)addr, size) ? 1 : 0)
 
 /* bit 29 of the pci address is the SWAP bit */
 #define ATE_SWAPSHIFT                   29
@@ -90,27 +90,27 @@
  * PMU resources.
  */
 struct ate_resource{
-	uint64_t *ate;
-	uint64_t num_ate;
-	uint64_t lowest_free_index;
+	u64 *ate;
+	u64 num_ate;
+	u64 lowest_free_index;
 };
 
 struct pcibus_info {
 	struct pcibus_bussoft	pbi_buscommon;   /* common header */
-	uint32_t                pbi_moduleid;
+	u32                pbi_moduleid;
 	short                   pbi_bridge_type;
 	short                   pbi_bridge_mode;
 
 	struct ate_resource     pbi_int_ate_resource;
-	uint64_t                pbi_int_ate_size;
+	u64                pbi_int_ate_size;
 
-	uint64_t                pbi_dir_xbase;
+	u64                pbi_dir_xbase;
 	char                    pbi_hub_xid;
 
-	uint64_t                pbi_devreg[8];
+	u64                pbi_devreg[8];
 
-	uint32_t		pbi_valid_devices;
-	uint32_t		pbi_enabled_devices;
+	u32		pbi_valid_devices;
+	u32		pbi_enabled_devices;
 
 	spinlock_t              pbi_lock;
 };
@@ -136,22 +136,22 @@ extern void pcibr_dma_unmap(struct pci_d
 /*
  * prototypes for the bridge asic register access routines in pcibr_reg.c
  */
-extern void             pcireg_control_bit_clr(struct pcibus_info *, uint64_t);
-extern void             pcireg_control_bit_set(struct pcibus_info *, uint64_t);
-extern uint64_t         pcireg_tflush_get(struct pcibus_info *);
-extern uint64_t         pcireg_intr_status_get(struct pcibus_info *);
-extern void             pcireg_intr_enable_bit_clr(struct pcibus_info *, uint64_t);
-extern void             pcireg_intr_enable_bit_set(struct pcibus_info *, uint64_t);
-extern void             pcireg_intr_addr_addr_set(struct pcibus_info *, int, uint64_t);
+extern void             pcireg_control_bit_clr(struct pcibus_info *, u64);
+extern void             pcireg_control_bit_set(struct pcibus_info *, u64);
+extern u64         pcireg_tflush_get(struct pcibus_info *);
+extern u64         pcireg_intr_status_get(struct pcibus_info *);
+extern void             pcireg_intr_enable_bit_clr(struct pcibus_info *, u64);
+extern void             pcireg_intr_enable_bit_set(struct pcibus_info *, u64);
+extern void             pcireg_intr_addr_addr_set(struct pcibus_info *, int, u64);
 extern void             pcireg_force_intr_set(struct pcibus_info *, int);
-extern uint64_t         pcireg_wrb_flush_get(struct pcibus_info *, int);
-extern void             pcireg_int_ate_set(struct pcibus_info *, int, uint64_t);
-extern uint64_t *	pcireg_int_ate_addr(struct pcibus_info *, int);
+extern u64         pcireg_wrb_flush_get(struct pcibus_info *, int);
+extern void             pcireg_int_ate_set(struct pcibus_info *, int, u64);
+extern u64 *	pcireg_int_ate_addr(struct pcibus_info *, int);
 extern void 		pcibr_force_interrupt(struct sn_irq_info *sn_irq_info);
 extern void 		pcibr_change_devices_irq(struct sn_irq_info *sn_irq_info);
 extern int 		pcibr_ate_alloc(struct pcibus_info *, int);
 extern void 		pcibr_ate_free(struct pcibus_info *, int);
-extern void 		ate_write(struct pcibus_info *, int, int, uint64_t);
+extern void 		ate_write(struct pcibus_info *, int, int, u64);
 extern int sal_pcibr_slot_enable(struct pcibus_info *soft, int device,
 				 void *resp);
 extern int sal_pcibr_slot_disable(struct pcibus_info *soft, int device,
diff --git a/include/asm-ia64/sn/pcibus_provider_defs.h b/include/asm-ia64/sn/pcibus_provider_defs.h
--- a/include/asm-ia64/sn/pcibus_provider_defs.h
+++ b/include/asm-ia64/sn/pcibus_provider_defs.h
@@ -29,13 +29,13 @@
  */
 
 struct pcibus_bussoft {
-	uint32_t		bs_asic_type;	/* chipset type */
-	uint32_t		bs_xid;		/* xwidget id */
-	uint32_t		bs_persist_busnum; /* Persistent Bus Number */
-	uint32_t		bs_persist_segment; /* Segment Number */
-	uint64_t		bs_legacy_io;	/* legacy io pio addr */
-	uint64_t		bs_legacy_mem;	/* legacy mem pio addr */
-	uint64_t		bs_base;	/* widget base */
+	u32		bs_asic_type;	/* chipset type */
+	u32		bs_xid;		/* xwidget id */
+	u32		bs_persist_busnum; /* Persistent Bus Number */
+	u32		bs_persist_segment; /* Segment Number */
+	u64		bs_legacy_io;	/* legacy io pio addr */
+	u64		bs_legacy_mem;	/* legacy mem pio addr */
+	u64		bs_base;	/* widget base */
 	struct xwidget_info	*bs_xwidget_info;
 };
 
diff --git a/include/asm-ia64/sn/pcidev.h b/include/asm-ia64/sn/pcidev.h
--- a/include/asm-ia64/sn/pcidev.h
+++ b/include/asm-ia64/sn/pcidev.h
@@ -55,8 +55,8 @@ struct sn_pci_controller {
 #define PCIIO_VENDOR_ID_NONE	(-1)
 
 struct pcidev_info {
-	uint64_t		pdi_pio_mapped_addr[7]; /* 6 BARs PLUS 1 ROM */
-	uint64_t		pdi_slot_host_handle;	/* Bus and devfn Host pci_dev */
+	u64		pdi_pio_mapped_addr[7]; /* 6 BARs PLUS 1 ROM */
+	u64		pdi_slot_host_handle;	/* Bus and devfn Host pci_dev */
 
 	struct pcibus_bussoft	*pdi_pcibus_info;	/* Kernel common bus soft */
 	struct pcidev_info	*pdi_host_pcidev_info;	/* Kernel Host pci_dev */
diff --git a/include/asm-ia64/sn/sn_sal.h b/include/asm-ia64/sn/sn_sal.h
--- a/include/asm-ia64/sn/sn_sal.h
+++ b/include/asm-ia64/sn/sn_sal.h
@@ -272,7 +272,7 @@ ia64_sn_console_putc(char ch)
 	ret_stuff.v0 = 0;
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_CONSOLE_PUTC, (uint64_t)ch, 0, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_CONSOLE_PUTC, (u64)ch, 0, 0, 0, 0, 0, 0);
 
 	return ret_stuff.status;
 }
@@ -289,7 +289,7 @@ ia64_sn_console_putb(const char *buf, in
 	ret_stuff.v0 = 0; 
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
-	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_CONSOLE_PUTB, (uint64_t)buf, (uint64_t)len, 0, 0, 0, 0, 0);
+	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_CONSOLE_PUTB, (u64)buf, (u64)len, 0, 0, 0, 0, 0);
 
 	if ( ret_stuff.status = 0 ) {
 		return ret_stuff.v0;
@@ -309,7 +309,7 @@ ia64_sn_plat_specific_err_print(int (*ho
 	ret_stuff.v0 = 0;
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
-	SAL_CALL_REENTRANT(ret_stuff, SN_SAL_PRINT_ERROR, (uint64_t)hook, (uint64_t)rec, 0, 0, 0, 0, 0);
+	SAL_CALL_REENTRANT(ret_stuff, SN_SAL_PRINT_ERROR, (u64)hook, (u64)rec, 0, 0, 0, 0, 0);
 
 	return ret_stuff.status;
 }
@@ -397,7 +397,7 @@ ia64_sn_console_intr_status(void)
  * Enable an interrupt on the SAL console device.
  */
 static inline void
-ia64_sn_console_intr_enable(uint64_t intr)
+ia64_sn_console_intr_enable(u64 intr)
 {
 	struct ia64_sal_retval ret_stuff;
 
@@ -414,7 +414,7 @@ ia64_sn_console_intr_enable(uint64_t int
  * Disable an interrupt on the SAL console device.
  */
 static inline void
-ia64_sn_console_intr_disable(uint64_t intr)
+ia64_sn_console_intr_disable(u64 intr)
 {
 	struct ia64_sal_retval ret_stuff;
 
@@ -440,7 +440,7 @@ ia64_sn_console_xmit_chars(char *buf, in
 	ret_stuff.v1 = 0;
 	ret_stuff.v2 = 0;
 	SAL_CALL_NOLOCK(ret_stuff, SN_SAL_CONSOLE_XMIT_CHARS,
-		 (uint64_t)buf, (uint64_t)len,
+		 (u64)buf, (u64)len,
 		 0, 0, 0, 0, 0);
 
 	if (ret_stuff.status = 0) {
diff --git a/include/asm-ia64/sn/tioca.h b/include/asm-ia64/sn/tioca.h
--- a/include/asm-ia64/sn/tioca.h
+++ b/include/asm-ia64/sn/tioca.h
@@ -19,47 +19,47 @@
  */
 
 struct tioca {
-	uint64_t	ca_id;				/* 0x000000 */
-	uint64_t	ca_control1;			/* 0x000008 */
-	uint64_t	ca_control2;			/* 0x000010 */
-	uint64_t	ca_status1;			/* 0x000018 */
-	uint64_t	ca_status2;			/* 0x000020 */
-	uint64_t	ca_gart_aperature;		/* 0x000028 */
-	uint64_t	ca_gfx_detach;			/* 0x000030 */
-	uint64_t	ca_inta_dest_addr;		/* 0x000038 */
-	uint64_t	ca_intb_dest_addr;		/* 0x000040 */
-	uint64_t	ca_err_int_dest_addr;		/* 0x000048 */
-	uint64_t	ca_int_status;			/* 0x000050 */
-	uint64_t	ca_int_status_alias;		/* 0x000058 */
-	uint64_t	ca_mult_error;			/* 0x000060 */
-	uint64_t	ca_mult_error_alias;		/* 0x000068 */
-	uint64_t	ca_first_error;			/* 0x000070 */
-	uint64_t	ca_int_mask;			/* 0x000078 */
-	uint64_t	ca_crm_pkterr_type;		/* 0x000080 */
-	uint64_t	ca_crm_pkterr_type_alias;	/* 0x000088 */
-	uint64_t	ca_crm_ct_error_detail_1;	/* 0x000090 */
-	uint64_t	ca_crm_ct_error_detail_2;	/* 0x000098 */
-	uint64_t	ca_crm_tnumto;			/* 0x0000A0 */
-	uint64_t	ca_gart_err;			/* 0x0000A8 */
-	uint64_t	ca_pcierr_type;			/* 0x0000B0 */
-	uint64_t	ca_pcierr_addr;			/* 0x0000B8 */
-
-	uint64_t	ca_pad_0000C0[3];		/* 0x0000{C0..D0} */
-
-	uint64_t	ca_pci_rd_buf_flush;		/* 0x0000D8 */
-	uint64_t	ca_pci_dma_addr_extn;		/* 0x0000E0 */
-	uint64_t	ca_agp_dma_addr_extn;		/* 0x0000E8 */
-	uint64_t	ca_force_inta;			/* 0x0000F0 */
-	uint64_t	ca_force_intb;			/* 0x0000F8 */
-	uint64_t	ca_debug_vector_sel;		/* 0x000100 */
-	uint64_t	ca_debug_mux_core_sel;		/* 0x000108 */
-	uint64_t	ca_debug_mux_pci_sel;		/* 0x000110 */
-	uint64_t	ca_debug_domain_sel;		/* 0x000118 */
+	u64	ca_id;				/* 0x000000 */
+	u64	ca_control1;			/* 0x000008 */
+	u64	ca_control2;			/* 0x000010 */
+	u64	ca_status1;			/* 0x000018 */
+	u64	ca_status2;			/* 0x000020 */
+	u64	ca_gart_aperature;		/* 0x000028 */
+	u64	ca_gfx_detach;			/* 0x000030 */
+	u64	ca_inta_dest_addr;		/* 0x000038 */
+	u64	ca_intb_dest_addr;		/* 0x000040 */
+	u64	ca_err_int_dest_addr;		/* 0x000048 */
+	u64	ca_int_status;			/* 0x000050 */
+	u64	ca_int_status_alias;		/* 0x000058 */
+	u64	ca_mult_error;			/* 0x000060 */
+	u64	ca_mult_error_alias;		/* 0x000068 */
+	u64	ca_first_error;			/* 0x000070 */
+	u64	ca_int_mask;			/* 0x000078 */
+	u64	ca_crm_pkterr_type;		/* 0x000080 */
+	u64	ca_crm_pkterr_type_alias;	/* 0x000088 */
+	u64	ca_crm_ct_error_detail_1;	/* 0x000090 */
+	u64	ca_crm_ct_error_detail_2;	/* 0x000098 */
+	u64	ca_crm_tnumto;			/* 0x0000A0 */
+	u64	ca_gart_err;			/* 0x0000A8 */
+	u64	ca_pcierr_type;			/* 0x0000B0 */
+	u64	ca_pcierr_addr;			/* 0x0000B8 */
+
+	u64	ca_pad_0000C0[3];		/* 0x0000{C0..D0} */
+
+	u64	ca_pci_rd_buf_flush;		/* 0x0000D8 */
+	u64	ca_pci_dma_addr_extn;		/* 0x0000E0 */
+	u64	ca_agp_dma_addr_extn;		/* 0x0000E8 */
+	u64	ca_force_inta;			/* 0x0000F0 */
+	u64	ca_force_intb;			/* 0x0000F8 */
+	u64	ca_debug_vector_sel;		/* 0x000100 */
+	u64	ca_debug_mux_core_sel;		/* 0x000108 */
+	u64	ca_debug_mux_pci_sel;		/* 0x000110 */
+	u64	ca_debug_domain_sel;		/* 0x000118 */
 
-	uint64_t	ca_pad_000120[28];		/* 0x0001{20..F8} */
+	u64	ca_pad_000120[28];		/* 0x0001{20..F8} */
 
-	uint64_t	ca_gart_ptr_table;		/* 0x200 */
-	uint64_t	ca_gart_tlb_addr[8];		/* 0x2{08..40} */
+	u64	ca_gart_ptr_table;		/* 0x200 */
+	u64	ca_gart_tlb_addr[8];		/* 0x2{08..40} */
 };
 
 /*
diff --git a/include/asm-ia64/sn/tioca_provider.h b/include/asm-ia64/sn/tioca_provider.h
--- a/include/asm-ia64/sn/tioca_provider.h
+++ b/include/asm-ia64/sn/tioca_provider.h
@@ -56,31 +56,31 @@ struct tioca_kernel {
 	/*
 	 * General GART stuff
 	 */
-	uint64_t	ca_ap_size;		/* size of aperature in bytes */
-	uint32_t	ca_gart_entries;	/* # uint64_t entries in gart */
-	uint32_t	ca_ap_pagesize; 	/* aperature page size in bytes */
-	uint64_t	ca_ap_bus_base; 	/* bus address of CA aperature */
-	uint64_t	ca_gart_size;		/* gart size in bytes */
-	uint64_t	*ca_gart;		/* gart table vaddr */
-	uint64_t	ca_gart_coretalk_addr;	/* gart coretalk addr */
-	uint8_t		ca_gart_iscoherent;	/* used in tioca_tlbflush */
+	u64	ca_ap_size;		/* size of aperature in bytes */
+	u32	ca_gart_entries;	/* # u64 entries in gart */
+	u32	ca_ap_pagesize; 	/* aperature page size in bytes */
+	u64	ca_ap_bus_base; 	/* bus address of CA aperature */
+	u64	ca_gart_size;		/* gart size in bytes */
+	u64	*ca_gart;		/* gart table vaddr */
+	u64	ca_gart_coretalk_addr;	/* gart coretalk addr */
+	u8		ca_gart_iscoherent;	/* used in tioca_tlbflush */
 
 	/* PCI GART convenience values */
-	uint64_t	ca_pciap_base;		/* pci aperature bus base address */
-	uint64_t	ca_pciap_size;		/* pci aperature size (bytes) */
-	uint64_t	ca_pcigart_base;	/* gfx GART bus base address */
-	uint64_t	*ca_pcigart;		/* gfx GART vm address */
-	uint32_t	ca_pcigart_entries;
-	uint32_t	ca_pcigart_start;	/* PCI start index in ca_gart */
+	u64	ca_pciap_base;		/* pci aperature bus base address */
+	u64	ca_pciap_size;		/* pci aperature size (bytes) */
+	u64	ca_pcigart_base;	/* gfx GART bus base address */
+	u64	*ca_pcigart;		/* gfx GART vm address */
+	u32	ca_pcigart_entries;
+	u32	ca_pcigart_start;	/* PCI start index in ca_gart */
 	void		*ca_pcigart_pagemap;
 
 	/* AGP GART convenience values */
-	uint64_t	ca_gfxap_base;		/* gfx aperature bus base address */
-	uint64_t	ca_gfxap_size;		/* gfx aperature size (bytes) */
-	uint64_t	ca_gfxgart_base;	/* gfx GART bus base address */
-	uint64_t	*ca_gfxgart;		/* gfx GART vm address */
-	uint32_t	ca_gfxgart_entries;
-	uint32_t	ca_gfxgart_start;	/* agpgart start index in ca_gart */
+	u64	ca_gfxap_base;		/* gfx aperature bus base address */
+	u64	ca_gfxap_size;		/* gfx aperature size (bytes) */
+	u64	ca_gfxgart_base;	/* gfx GART bus base address */
+	u64	*ca_gfxgart;		/* gfx GART vm address */
+	u32	ca_gfxgart_entries;
+	u32	ca_gfxgart_start;	/* agpgart start index in ca_gart */
 };
 
 /*
@@ -93,11 +93,11 @@ struct tioca_kernel {
 struct tioca_common {
 	struct pcibus_bussoft	ca_common;	/* common pciio header */
 
-	uint32_t		ca_rev;
-	uint32_t		ca_closest_nasid;
+	u32		ca_rev;
+	u32		ca_closest_nasid;
 
-	uint64_t		ca_prom_private;
-	uint64_t		ca_kernel_private;
+	u64		ca_prom_private;
+	u64		ca_kernel_private;
 };
 
 /**
@@ -139,9 +139,9 @@ tioca_paddr_to_gart(unsigned long paddr)
  */
 
 static inline unsigned long
-tioca_physpage_to_gart(uint64_t page_addr)
+tioca_physpage_to_gart(u64 page_addr)
 {
-	uint64_t coretalk_addr;
+	u64 coretalk_addr;
 
 	coretalk_addr = PHYS_TO_TIODMA(page_addr);
 	if (!coretalk_addr) {
@@ -161,7 +161,7 @@ tioca_physpage_to_gart(uint64_t page_add
 static inline void
 tioca_tlbflush(struct tioca_kernel *tioca_kernel)
 {
-	volatile uint64_t tmp;
+	volatile u64 tmp;
 	volatile struct tioca *ca_base;
 	struct tioca_common *tioca_common;
 
@@ -200,7 +200,7 @@ tioca_tlbflush(struct tioca_kernel *tioc
 	tmp = __sn_readq_relaxed(&ca_base->ca_control2);
 }
 
-extern uint32_t	tioca_gart_found;
+extern u32	tioca_gart_found;
 extern struct list_head tioca_list;
 extern int tioca_init_provider(void);
 extern void tioca_fastwrite_enable(struct tioca_kernel *tioca_kern);
diff --git a/include/asm-ia64/sn/tioce_provider.h b/include/asm-ia64/sn/tioce_provider.h
--- a/include/asm-ia64/sn/tioce_provider.h
+++ b/include/asm-ia64/sn/tioce_provider.h
@@ -21,9 +21,9 @@
 struct tioce_common {
 	struct pcibus_bussoft	ce_pcibus;	/* common pciio header */
 
-	uint32_t		ce_rev;
-	uint64_t		ce_kernel_private;
-	uint64_t		ce_prom_private;
+	u32		ce_rev;
+	u64		ce_kernel_private;
+	u64		ce_prom_private;
 };
 
 struct tioce_kernel {
@@ -31,31 +31,31 @@ struct tioce_kernel {
 	spinlock_t		ce_lock;
 	struct list_head	ce_dmamap_list;
 
-	uint64_t		ce_ate40_shadow[TIOCE_NUM_M40_ATES];
-	uint64_t		ce_ate3240_shadow[TIOCE_NUM_M3240_ATES];
-	uint32_t		ce_ate3240_pagesize;
+	u64		ce_ate40_shadow[TIOCE_NUM_M40_ATES];
+	u64		ce_ate3240_shadow[TIOCE_NUM_M3240_ATES];
+	u32		ce_ate3240_pagesize;
 
-	uint8_t			ce_port1_secondary;
+	u8			ce_port1_secondary;
 
 	/* per-port resources */
 	struct {
 		int 		dirmap_refcnt;
-		uint64_t	dirmap_shadow;
+		u64	dirmap_shadow;
 	} ce_port[TIOCE_NUM_PORTS];
 };
 
 struct tioce_dmamap {
 	struct list_head	ce_dmamap_list;	/* headed by tioce_kernel */
-	uint32_t		refcnt;
+	u32		refcnt;
 
-	uint64_t		nbytes;		/* # bytes mapped */
+	u64		nbytes;		/* # bytes mapped */
 
-	uint64_t		ct_start;	/* coretalk start address */
-	uint64_t		pci_start;	/* bus start address */
+	u64		ct_start;	/* coretalk start address */
+	u64		pci_start;	/* bus start address */
 
-	uint64_t		*ate_hw;	/* hw ptr of first ate in map */
-	uint64_t		*ate_shadow;	/* shadow ptr of firat ate */
-	uint16_t		ate_count;	/* # ate's in the map */
+	u64		*ate_hw;	/* hw ptr of first ate in map */
+	u64		*ate_shadow;	/* shadow ptr of firat ate */
+	u16		ate_count;	/* # ate's in the map */
 };
 
 extern int tioce_init_provider(void);
diff --git a/include/asm-ia64/sn/tiocp.h b/include/asm-ia64/sn/tiocp.h
--- a/include/asm-ia64/sn/tiocp.h
+++ b/include/asm-ia64/sn/tiocp.h
@@ -21,189 +21,189 @@ struct tiocp{
     /* 0x000000-0x00FFFF -- Local Registers */
 
     /* 0x000000-0x000057 -- (Legacy Widget Space) Configuration */
-    uint64_t		cp_id;				/* 0x000000 */
-    uint64_t		cp_stat;			/* 0x000008 */
-    uint64_t		cp_err_upper;			/* 0x000010 */
-    uint64_t		cp_err_lower;			/* 0x000018 */
+    u64		cp_id;				/* 0x000000 */
+    u64		cp_stat;			/* 0x000008 */
+    u64		cp_err_upper;			/* 0x000010 */
+    u64		cp_err_lower;			/* 0x000018 */
     #define cp_err cp_err_lower
-    uint64_t		cp_control;			/* 0x000020 */
-    uint64_t		cp_req_timeout;			/* 0x000028 */
-    uint64_t		cp_intr_upper;			/* 0x000030 */
-    uint64_t		cp_intr_lower;			/* 0x000038 */
+    u64		cp_control;			/* 0x000020 */
+    u64		cp_req_timeout;			/* 0x000028 */
+    u64		cp_intr_upper;			/* 0x000030 */
+    u64		cp_intr_lower;			/* 0x000038 */
     #define cp_intr cp_intr_lower
-    uint64_t		cp_err_cmdword;			/* 0x000040 */
-    uint64_t		_pad_000048;			/* 0x000048 */
-    uint64_t		cp_tflush;			/* 0x000050 */
+    u64		cp_err_cmdword;			/* 0x000040 */
+    u64		_pad_000048;			/* 0x000048 */
+    u64		cp_tflush;			/* 0x000050 */
 
     /* 0x000058-0x00007F -- Bridge-specific Configuration */
-    uint64_t		cp_aux_err;			/* 0x000058 */
-    uint64_t		cp_resp_upper;			/* 0x000060 */
-    uint64_t		cp_resp_lower;			/* 0x000068 */
+    u64		cp_aux_err;			/* 0x000058 */
+    u64		cp_resp_upper;			/* 0x000060 */
+    u64		cp_resp_lower;			/* 0x000068 */
     #define cp_resp cp_resp_lower
-    uint64_t		cp_tst_pin_ctrl;		/* 0x000070 */
-    uint64_t		cp_addr_lkerr;			/* 0x000078 */
+    u64		cp_tst_pin_ctrl;		/* 0x000070 */
+    u64		cp_addr_lkerr;			/* 0x000078 */
 
     /* 0x000080-0x00008F -- PMU & MAP */
-    uint64_t		cp_dir_map;			/* 0x000080 */
-    uint64_t		_pad_000088;			/* 0x000088 */
+    u64		cp_dir_map;			/* 0x000080 */
+    u64		_pad_000088;			/* 0x000088 */
 
     /* 0x000090-0x00009F -- SSRAM */
-    uint64_t		cp_map_fault;			/* 0x000090 */
-    uint64_t		_pad_000098;			/* 0x000098 */
+    u64		cp_map_fault;			/* 0x000090 */
+    u64		_pad_000098;			/* 0x000098 */
 
     /* 0x0000A0-0x0000AF -- Arbitration */
-    uint64_t		cp_arb;				/* 0x0000A0 */
-    uint64_t		_pad_0000A8;			/* 0x0000A8 */
+    u64		cp_arb;				/* 0x0000A0 */
+    u64		_pad_0000A8;			/* 0x0000A8 */
 
     /* 0x0000B0-0x0000BF -- Number In A Can or ATE Parity Error */
-    uint64_t		cp_ate_parity_err;		/* 0x0000B0 */
-    uint64_t		_pad_0000B8;			/* 0x0000B8 */
+    u64		cp_ate_parity_err;		/* 0x0000B0 */
+    u64		_pad_0000B8;			/* 0x0000B8 */
 
     /* 0x0000C0-0x0000FF -- PCI/GIO */
-    uint64_t		cp_bus_timeout;			/* 0x0000C0 */
-    uint64_t		cp_pci_cfg;			/* 0x0000C8 */
-    uint64_t		cp_pci_err_upper;		/* 0x0000D0 */
-    uint64_t		cp_pci_err_lower;		/* 0x0000D8 */
+    u64		cp_bus_timeout;			/* 0x0000C0 */
+    u64		cp_pci_cfg;			/* 0x0000C8 */
+    u64		cp_pci_err_upper;		/* 0x0000D0 */
+    u64		cp_pci_err_lower;		/* 0x0000D8 */
     #define cp_pci_err cp_pci_err_lower
-    uint64_t		_pad_0000E0[4];			/* 0x0000{E0..F8} */
+    u64		_pad_0000E0[4];			/* 0x0000{E0..F8} */
 
     /* 0x000100-0x0001FF -- Interrupt */
-    uint64_t		cp_int_status;			/* 0x000100 */
-    uint64_t		cp_int_enable;			/* 0x000108 */
-    uint64_t		cp_int_rst_stat;		/* 0x000110 */
-    uint64_t		cp_int_mode;			/* 0x000118 */
-    uint64_t		cp_int_device;			/* 0x000120 */
-    uint64_t		cp_int_host_err;		/* 0x000128 */
-    uint64_t		cp_int_addr[8];			/* 0x0001{30,,,68} */
-    uint64_t		cp_err_int_view;		/* 0x000170 */
-    uint64_t		cp_mult_int;			/* 0x000178 */
-    uint64_t		cp_force_always[8];		/* 0x0001{80,,,B8} */
-    uint64_t		cp_force_pin[8];		/* 0x0001{C0,,,F8} */
+    u64		cp_int_status;			/* 0x000100 */
+    u64		cp_int_enable;			/* 0x000108 */
+    u64		cp_int_rst_stat;		/* 0x000110 */
+    u64		cp_int_mode;			/* 0x000118 */
+    u64		cp_int_device;			/* 0x000120 */
+    u64		cp_int_host_err;		/* 0x000128 */
+    u64		cp_int_addr[8];			/* 0x0001{30,,,68} */
+    u64		cp_err_int_view;		/* 0x000170 */
+    u64		cp_mult_int;			/* 0x000178 */
+    u64		cp_force_always[8];		/* 0x0001{80,,,B8} */
+    u64		cp_force_pin[8];		/* 0x0001{C0,,,F8} */
 
     /* 0x000200-0x000298 -- Device */
-    uint64_t		cp_device[4];			/* 0x0002{00,,,18} */
-    uint64_t		_pad_000220[4];			/* 0x0002{20,,,38} */
-    uint64_t		cp_wr_req_buf[4];		/* 0x0002{40,,,58} */
-    uint64_t		_pad_000260[4];			/* 0x0002{60,,,78} */
-    uint64_t		cp_rrb_map[2];			/* 0x0002{80,,,88} */
+    u64		cp_device[4];			/* 0x0002{00,,,18} */
+    u64		_pad_000220[4];			/* 0x0002{20,,,38} */
+    u64		cp_wr_req_buf[4];		/* 0x0002{40,,,58} */
+    u64		_pad_000260[4];			/* 0x0002{60,,,78} */
+    u64		cp_rrb_map[2];			/* 0x0002{80,,,88} */
     #define cp_even_resp cp_rrb_map[0]			/* 0x000280 */
     #define cp_odd_resp  cp_rrb_map[1]			/* 0x000288 */
-    uint64_t		cp_resp_status;			/* 0x000290 */
-    uint64_t		cp_resp_clear;			/* 0x000298 */
+    u64		cp_resp_status;			/* 0x000290 */
+    u64		cp_resp_clear;			/* 0x000298 */
 
-    uint64_t		_pad_0002A0[12];		/* 0x0002{A0..F8} */
+    u64		_pad_0002A0[12];		/* 0x0002{A0..F8} */
 
     /* 0x000300-0x0003F8 -- Buffer Address Match Registers */
     struct {
-	uint64_t	upper;				/* 0x0003{00,,,F0} */
-	uint64_t	lower;				/* 0x0003{08,,,F8} */
+	u64	upper;				/* 0x0003{00,,,F0} */
+	u64	lower;				/* 0x0003{08,,,F8} */
     } cp_buf_addr_match[16];
 
     /* 0x000400-0x0005FF -- Performance Monitor Registers (even only) */
     struct {
-	uint64_t	flush_w_touch;			/* 0x000{400,,,5C0} */
-	uint64_t	flush_wo_touch;			/* 0x000{408,,,5C8} */
-	uint64_t	inflight;			/* 0x000{410,,,5D0} */
-	uint64_t	prefetch;			/* 0x000{418,,,5D8} */
-	uint64_t	total_pci_retry;		/* 0x000{420,,,5E0} */
-	uint64_t	max_pci_retry;			/* 0x000{428,,,5E8} */
-	uint64_t	max_latency;			/* 0x000{430,,,5F0} */
-	uint64_t	clear_all;			/* 0x000{438,,,5F8} */
+	u64	flush_w_touch;			/* 0x000{400,,,5C0} */
+	u64	flush_wo_touch;			/* 0x000{408,,,5C8} */
+	u64	inflight;			/* 0x000{410,,,5D0} */
+	u64	prefetch;			/* 0x000{418,,,5D8} */
+	u64	total_pci_retry;		/* 0x000{420,,,5E0} */
+	u64	max_pci_retry;			/* 0x000{428,,,5E8} */
+	u64	max_latency;			/* 0x000{430,,,5F0} */
+	u64	clear_all;			/* 0x000{438,,,5F8} */
     } cp_buf_count[8];
 
 
     /* 0x000600-0x0009FF -- PCI/X registers */
-    uint64_t		cp_pcix_bus_err_addr;		/* 0x000600 */
-    uint64_t		cp_pcix_bus_err_attr;		/* 0x000608 */
-    uint64_t		cp_pcix_bus_err_data;		/* 0x000610 */
-    uint64_t		cp_pcix_pio_split_addr;		/* 0x000618 */
-    uint64_t		cp_pcix_pio_split_attr;		/* 0x000620 */
-    uint64_t		cp_pcix_dma_req_err_attr;	/* 0x000628 */
-    uint64_t		cp_pcix_dma_req_err_addr;	/* 0x000630 */
-    uint64_t		cp_pcix_timeout;		/* 0x000638 */
+    u64		cp_pcix_bus_err_addr;		/* 0x000600 */
+    u64		cp_pcix_bus_err_attr;		/* 0x000608 */
+    u64		cp_pcix_bus_err_data;		/* 0x000610 */
+    u64		cp_pcix_pio_split_addr;		/* 0x000618 */
+    u64		cp_pcix_pio_split_attr;		/* 0x000620 */
+    u64		cp_pcix_dma_req_err_attr;	/* 0x000628 */
+    u64		cp_pcix_dma_req_err_addr;	/* 0x000630 */
+    u64		cp_pcix_timeout;		/* 0x000638 */
 
-    uint64_t		_pad_000640[24];		/* 0x000{640,,,6F8} */
+    u64		_pad_000640[24];		/* 0x000{640,,,6F8} */
 
     /* 0x000700-0x000737 -- Debug Registers */
-    uint64_t		cp_ct_debug_ctl;		/* 0x000700 */
-    uint64_t		cp_br_debug_ctl;		/* 0x000708 */
-    uint64_t		cp_mux3_debug_ctl;		/* 0x000710 */
-    uint64_t		cp_mux4_debug_ctl;		/* 0x000718 */
-    uint64_t		cp_mux5_debug_ctl;		/* 0x000720 */
-    uint64_t		cp_mux6_debug_ctl;		/* 0x000728 */
-    uint64_t		cp_mux7_debug_ctl;		/* 0x000730 */
+    u64		cp_ct_debug_ctl;		/* 0x000700 */
+    u64		cp_br_debug_ctl;		/* 0x000708 */
+    u64		cp_mux3_debug_ctl;		/* 0x000710 */
+    u64		cp_mux4_debug_ctl;		/* 0x000718 */
+    u64		cp_mux5_debug_ctl;		/* 0x000720 */
+    u64		cp_mux6_debug_ctl;		/* 0x000728 */
+    u64		cp_mux7_debug_ctl;		/* 0x000730 */
 
-    uint64_t		_pad_000738[89];		/* 0x000{738,,,9F8} */
+    u64		_pad_000738[89];		/* 0x000{738,,,9F8} */
 
     /* 0x000A00-0x000BFF -- PCI/X Read&Write Buffer */
     struct {
-	uint64_t	cp_buf_addr;			/* 0x000{A00,,,AF0} */
-	uint64_t	cp_buf_attr;			/* 0X000{A08,,,AF8} */
+	u64	cp_buf_addr;			/* 0x000{A00,,,AF0} */
+	u64	cp_buf_attr;			/* 0X000{A08,,,AF8} */
     } cp_pcix_read_buf_64[16];
 
     struct {
-	uint64_t	cp_buf_addr;			/* 0x000{B00,,,BE0} */
-	uint64_t	cp_buf_attr;			/* 0x000{B08,,,BE8} */
-	uint64_t	cp_buf_valid;			/* 0x000{B10,,,BF0} */
-	uint64_t	__pad1;				/* 0x000{B18,,,BF8} */
+	u64	cp_buf_addr;			/* 0x000{B00,,,BE0} */
+	u64	cp_buf_attr;			/* 0x000{B08,,,BE8} */
+	u64	cp_buf_valid;			/* 0x000{B10,,,BF0} */
+	u64	__pad1;				/* 0x000{B18,,,BF8} */
     } cp_pcix_write_buf_64[8];
 
     /* End of Local Registers -- Start of Address Map space */
 
-    char		_pad_000c00[0x010000 - 0x000c00];
+    char	_pad_000c00[0x010000 - 0x000c00];
 
     /* 0x010000-0x011FF8 -- Internal ATE RAM (Auto Parity Generation) */
-    uint64_t		cp_int_ate_ram[1024];		/* 0x010000-0x011FF8 */
+    u64		cp_int_ate_ram[1024];		/* 0x010000-0x011FF8 */
 
-    char		_pad_012000[0x14000 - 0x012000];
+    char	_pad_012000[0x14000 - 0x012000];
 
     /* 0x014000-0x015FF8 -- Internal ATE RAM (Manual Parity Generation) */
-    uint64_t		cp_int_ate_ram_mp[1024];	/* 0x014000-0x015FF8 */
+    u64		cp_int_ate_ram_mp[1024];	/* 0x014000-0x015FF8 */
 
-    char		_pad_016000[0x18000 - 0x016000];
+    char	_pad_016000[0x18000 - 0x016000];
 
     /* 0x18000-0x197F8 -- TIOCP Write Request Ram */
-    uint64_t		cp_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
-    uint64_t		cp_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
-    uint64_t		cp_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
+    u64		cp_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
+    u64		cp_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
+    u64		cp_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
 
-    char		_pad_019800[0x1C000 - 0x019800];
+    char	_pad_019800[0x1C000 - 0x019800];
 
     /* 0x1C000-0x1EFF8 -- TIOCP Read Response Ram */
-    uint64_t		cp_rd_resp_lower[512];		/* 0x1C000 - 0x1CFF8 */
-    uint64_t		cp_rd_resp_upper[512];		/* 0x1D000 - 0x1DFF8 */
-    uint64_t		cp_rd_resp_parity[512];		/* 0x1E000 - 0x1EFF8 */
+    u64		cp_rd_resp_lower[512];		/* 0x1C000 - 0x1CFF8 */
+    u64		cp_rd_resp_upper[512];		/* 0x1D000 - 0x1DFF8 */
+    u64		cp_rd_resp_parity[512];		/* 0x1E000 - 0x1EFF8 */
 
-    char		_pad_01F000[0x20000 - 0x01F000];
+    char	_pad_01F000[0x20000 - 0x01F000];
 
     /* 0x020000-0x021FFF -- Host Device (CP) Configuration Space (not used)  */
-    char		_pad_020000[0x021000 - 0x20000];
+    char	_pad_020000[0x021000 - 0x20000];
 
     /* 0x021000-0x027FFF -- PCI Device Configuration Spaces */
     union {
-	uint8_t		c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
-	uint16_t	s[0x1000 / 2];			/* 0x02{0000,,,7FFF} */
-	uint32_t	l[0x1000 / 4];			/* 0x02{0000,,,7FFF} */
-	uint64_t	d[0x1000 / 8];			/* 0x02{0000,,,7FFF} */
+	u8	c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
+	u16	s[0x1000 / 2];			/* 0x02{0000,,,7FFF} */
+	u32	l[0x1000 / 4];			/* 0x02{0000,,,7FFF} */
+	u64	d[0x1000 / 8];			/* 0x02{0000,,,7FFF} */
 	union {
-	    uint8_t	c[0x100 / 1];
-	    uint16_t	s[0x100 / 2];
-	    uint32_t	l[0x100 / 4];
-	    uint64_t	d[0x100 / 8];
+	    u8	c[0x100 / 1];
+	    u16	s[0x100 / 2];
+	    u32	l[0x100 / 4];
+	    u64	d[0x100 / 8];
 	} f[8];
     } cp_type0_cfg_dev[7];				/* 0x02{1000,,,7FFF} */
 
     /* 0x028000-0x028FFF -- PCI Type 1 Configuration Space */
     union {
-	uint8_t		c[0x1000 / 1];			/* 0x028000-0x029000 */
-	uint16_t	s[0x1000 / 2];			/* 0x028000-0x029000 */
-	uint32_t	l[0x1000 / 4];			/* 0x028000-0x029000 */
-	uint64_t	d[0x1000 / 8];			/* 0x028000-0x029000 */
+	u8	c[0x1000 / 1];			/* 0x028000-0x029000 */
+	u16	s[0x1000 / 2];			/* 0x028000-0x029000 */
+	u32	l[0x1000 / 4];			/* 0x028000-0x029000 */
+	u64	d[0x1000 / 8];			/* 0x028000-0x029000 */
 	union {
-	    uint8_t	c[0x100 / 1];
-	    uint16_t	s[0x100 / 2];
-	    uint32_t	l[0x100 / 4];
-	    uint64_t	d[0x100 / 8];
+	    u8	c[0x100 / 1];
+	    u16	s[0x100 / 2];
+	    u32	l[0x100 / 4];
+	    u64	d[0x100 / 8];
 	} f[8];
     } cp_type1_cfg;					/* 0x028000-0x029000 */
 
@@ -211,30 +211,30 @@ struct tiocp{
 
     /* 0x030000-0x030007 -- PCI Interrupt Acknowledge Cycle */
     union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
+	u8	c[8 / 1];
+	u16	s[8 / 2];
+	u32	l[8 / 4];
+	u64	d[8 / 8];
     } cp_pci_iack;					/* 0x030000-0x030007 */
 
     char		_pad_030007[0x040000-0x030008];
 
     /* 0x040000-0x040007 -- PCIX Special Cycle */
     union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
+	u8	c[8 / 1];
+	u16	s[8 / 2];
+	u32	l[8 / 4];
+	u64	d[8 / 8];
     } cp_pcix_cycle;					/* 0x040000-0x040007 */
 
     char		_pad_040007[0x200000-0x040008];
 
     /* 0x200000-0x7FFFFF -- PCI/GIO Device Spaces */
     union {
-	uint8_t		c[0x100000 / 1];
-	uint16_t	s[0x100000 / 2];
-	uint32_t	l[0x100000 / 4];
-	uint64_t	d[0x100000 / 8];
+	u8	c[0x100000 / 1];
+	u16	s[0x100000 / 2];
+	u32	l[0x100000 / 4];
+	u64	d[0x100000 / 8];
     } cp_devio_raw[6];					/* 0x200000-0x7FFFFF */
 
     #define cp_devio(n)  cp_devio_raw[((n)<2)?(n*2):(n+2)]
@@ -243,10 +243,10 @@ struct tiocp{
 
     /* 0xA00000-0xBFFFFF -- PCI/GIO Device Spaces w/flush  */
     union {
-	uint8_t		c[0x100000 / 1];
-	uint16_t	s[0x100000 / 2];
-	uint32_t	l[0x100000 / 4];
-	uint64_t	d[0x100000 / 8];
+	u8	c[0x100000 / 1];
+	u16	s[0x100000 / 2];
+	u32	l[0x100000 / 4];
+	u64	d[0x100000 / 8];
     } cp_devio_raw_flush[6];				/* 0xA00000-0xBFFFFF */
 
     #define cp_devio_flush(n)  cp_devio_raw_flush[((n)<2)?(n*2):(n+2)]
diff --git a/include/asm-ia64/sn/tiocx.h b/include/asm-ia64/sn/tiocx.h
--- a/include/asm-ia64/sn/tiocx.h
+++ b/include/asm-ia64/sn/tiocx.h
@@ -40,10 +40,10 @@ struct cx_drv {
 };
 
 /* create DMA address by stripping AS bits */
-#define TIOCX_DMA_ADDR(a) (uint64_t)((uint64_t)(a) & 0xffffcfffffffffUL)
+#define TIOCX_DMA_ADDR(a) (u64)((u64)(a) & 0xffffcfffffffffUL)
 
-#define TIOCX_TO_TIOCX_DMA_ADDR(a) (uint64_t)(((uint64_t)(a) & 0xfffffffff) |  \
-                                  ((((uint64_t)(a)) & 0xffffc000000000UL) <<2))
+#define TIOCX_TO_TIOCX_DMA_ADDR(a) (u64)(((u64)(a) & 0xfffffffff) |  \
+                                  ((((u64)(a)) & 0xffffc000000000UL) <<2))
 
 #define TIO_CE_ASIC_PARTNUM 0xce00
 #define TIOCX_CORELET 3
@@ -63,10 +63,10 @@ extern int cx_device_unregister(struct c
 extern int cx_device_register(nasid_t, int, int, struct hubdev_info *, int);
 extern int cx_driver_unregister(struct cx_drv *);
 extern int cx_driver_register(struct cx_drv *);
-extern uint64_t tiocx_dma_addr(uint64_t addr);
-extern uint64_t tiocx_swin_base(int nasid);
-extern void tiocx_mmr_store(int nasid, uint64_t offset, uint64_t value);
-extern uint64_t tiocx_mmr_load(int nasid, uint64_t offset);
+extern u64 tiocx_dma_addr(u64 addr);
+extern u64 tiocx_swin_base(int nasid);
+extern void tiocx_mmr_store(int nasid, u64 offset, u64 value);
+extern u64 tiocx_mmr_load(int nasid, u64 offset);
 
 #endif				//  __KERNEL__
 #endif				// _ASM_IA64_SN_TIO_TIOCX__
