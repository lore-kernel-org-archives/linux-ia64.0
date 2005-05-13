From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 13 May 2005 00:45:48 +0000
Subject: [PATCH 2/6]: hotplug/ia64: SN Hotplug Driver: moving of header files
Message-Id: <20050513004545.17135.52634.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835E67.4070207@sgi.com>
In-Reply-To: <42835E67.4070207@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch moves header files out of the arch/ia64/sn directories and into
include/asm-ia64/sn.  These files were being included by other subsystems
and should be under include/asm-ia64/sn.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 5c2b591a316b5d728d6cf16b9f44960319c37ff9
tree 609461315376faf97b95c8fded1d5df433168614
parent 278b70abe5b0a30267bd80b4f49fc8027e36d3ad
author Prarit Bhargava <prarit@sgi.com> 1810126494 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810126494 -0400

Index: arch/ia64/sn/include/pci/pcibr_provider.h
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/include/pci/pcibr_provider.h  (mode:100644 sha1:1cd291d8badd05299c4dc4114bd1e768ddd46f61)
+++ /dev/null  (tree:609461315376faf97b95c8fded1d5df433168614)
@@ -1,151 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992-1997,2000-2004 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
-#define _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
-
-/* Workarounds */
-#define PV907516 (1 << 1) /* TIOCP: Don't write the write buffer flush reg */
-
-#define BUSTYPE_MASK                    0x1
-
-/* Macros given a pcibus structure */
-#define IS_PCIX(ps)     ((ps)->pbi_bridge_mode & BUSTYPE_MASK)
-#define IS_PCI_BRIDGE_ASIC(asic) (asic = PCIIO_ASIC_TYPE_PIC || \
-                asic = PCIIO_ASIC_TYPE_TIOCP)
-#define IS_PIC_SOFT(ps)     (ps->pbi_bridge_type = PCIBR_BRIDGETYPE_PIC)
-
-
-/* 
- * The different PCI Bridge types supported on the SGI Altix platforms
- */
-#define PCIBR_BRIDGETYPE_UNKNOWN       -1
-#define PCIBR_BRIDGETYPE_PIC            2
-#define PCIBR_BRIDGETYPE_TIOCP          3
-
-/*
- * Bridge 64bit Direct Map Attributes
- */
-#define PCI64_ATTR_PREF                 (1ull << 59)
-#define PCI64_ATTR_PREC                 (1ull << 58)
-#define PCI64_ATTR_VIRTUAL              (1ull << 57)
-#define PCI64_ATTR_BAR                  (1ull << 56)
-#define PCI64_ATTR_SWAP                 (1ull << 55)
-#define PCI64_ATTR_VIRTUAL1             (1ull << 54)
-
-#define PCI32_LOCAL_BASE                0
-#define PCI32_MAPPED_BASE               0x40000000
-#define PCI32_DIRECT_BASE               0x80000000
-
-#define IS_PCI32_MAPPED(x)              ((uint64_t)(x) < PCI32_DIRECT_BASE && \
-                                         (uint64_t)(x) >= PCI32_MAPPED_BASE)
-#define IS_PCI32_DIRECT(x)              ((uint64_t)(x) >= PCI32_MAPPED_BASE)
-
-
-/*
- * Bridge PMU Address Transaltion Entry Attibutes
- */
-#define PCI32_ATE_V                     (0x1 << 0)
-#define PCI32_ATE_CO                    (0x1 << 1)
-#define PCI32_ATE_PREC                  (0x1 << 2)
-#define PCI32_ATE_PREF                  (0x1 << 3)
-#define PCI32_ATE_BAR                   (0x1 << 4)
-#define PCI32_ATE_ADDR_SHFT             12
-
-#define MINIMAL_ATES_REQUIRED(addr, size) \
-	(IOPG(IOPGOFF(addr) + (size) - 1) = IOPG((size) - 1))
-
-#define MINIMAL_ATE_FLAG(addr, size) \
-	(MINIMAL_ATES_REQUIRED((uint64_t)addr, size) ? 1 : 0)
-
-/* bit 29 of the pci address is the SWAP bit */
-#define ATE_SWAPSHIFT                   29
-#define ATE_SWAP_ON(x)                  ((x) |= (1 << ATE_SWAPSHIFT))
-#define ATE_SWAP_OFF(x)                 ((x) &= ~(1 << ATE_SWAPSHIFT))
-
-/*
- * I/O page size
- */
-#if PAGE_SIZE < 16384
-#define IOPFNSHIFT                      12      /* 4K per mapped page */
-#else
-#define IOPFNSHIFT                      14      /* 16K per mapped page */
-#endif
-
-#define IOPGSIZE                        (1 << IOPFNSHIFT)
-#define IOPG(x)                         ((x) >> IOPFNSHIFT)
-#define IOPGOFF(x)                      ((x) & (IOPGSIZE-1))
-
-#define PCIBR_DEV_SWAP_DIR              (1ull << 19)
-#define PCIBR_CTRL_PAGE_SIZE            (0x1 << 21)
-
-/*
- * PMU resources.
- */
-struct ate_resource{
-	uint64_t *ate;
-	uint64_t num_ate;
-	uint64_t lowest_free_index;
-};
-
-struct pcibus_info {
-	struct pcibus_bussoft	pbi_buscommon;   /* common header */
-	uint32_t                pbi_moduleid;
-	short                   pbi_bridge_type;
-	short                   pbi_bridge_mode;
-
-	struct ate_resource     pbi_int_ate_resource;
-	uint64_t                pbi_int_ate_size;
-	
-	uint64_t                pbi_dir_xbase;
-	char                    pbi_hub_xid;
-
-	uint64_t                pbi_devreg[8];
-	spinlock_t              pbi_lock;
-
-	uint32_t		pbi_valid_devices;
-	uint32_t		pbi_enabled_devices;
-};
-
-/*
- * pcibus_info structure locking macros
- */
-inline static unsigned long
-pcibr_lock(struct pcibus_info *pcibus_info)
-{
-	unsigned long flag;
-	spin_lock_irqsave(&pcibus_info->pbi_lock, flag);
-	return(flag);
-}
-#define pcibr_unlock(pcibus_info, flag)  spin_unlock_irqrestore(&pcibus_info->pbi_lock, flag)
-
-extern int  pcibr_init_provider(void);
-extern void *pcibr_bus_fixup(struct pcibus_bussoft *);
-extern dma_addr_t pcibr_dma_map(struct pci_dev *, unsigned long, size_t);
-extern dma_addr_t pcibr_dma_map_consistent(struct pci_dev *, unsigned long, size_t);
-extern void pcibr_dma_unmap(struct pci_dev *, dma_addr_t, int);
-
-/*
- * prototypes for the bridge asic register access routines in pcibr_reg.c
- */
-extern void             pcireg_control_bit_clr(struct pcibus_info *, uint64_t);
-extern void             pcireg_control_bit_set(struct pcibus_info *, uint64_t);
-extern uint64_t         pcireg_tflush_get(struct pcibus_info *);
-extern uint64_t         pcireg_intr_status_get(struct pcibus_info *);
-extern void             pcireg_intr_enable_bit_clr(struct pcibus_info *, uint64_t);
-extern void             pcireg_intr_enable_bit_set(struct pcibus_info *, uint64_t);
-extern void             pcireg_intr_addr_addr_set(struct pcibus_info *, int, uint64_t);
-extern void             pcireg_force_intr_set(struct pcibus_info *, int);
-extern uint64_t         pcireg_wrb_flush_get(struct pcibus_info *, int);
-extern void             pcireg_int_ate_set(struct pcibus_info *, int, uint64_t);
-extern uint64_t *	pcireg_int_ate_addr(struct pcibus_info *, int);
-extern void 		pcibr_force_interrupt(struct sn_irq_info *sn_irq_info);
-extern void 		pcibr_change_devices_irq(struct sn_irq_info *sn_irq_info);
-extern int 		pcibr_ate_alloc(struct pcibus_info *, int);
-extern void 		pcibr_ate_free(struct pcibus_info *, int);
-extern void 		ate_write(struct pcibus_info *, int, int, uint64_t);
-#endif
Index: arch/ia64/sn/include/pci/pic.h
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/include/pci/pic.h  (mode:100644 sha1:fd18acecb1e67e783c4085f27eb7e6390af0a47d)
+++ /dev/null  (tree:609461315376faf97b95c8fded1d5df433168614)
@@ -1,261 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992 - 1997, 2000-2003 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_PCI_PIC_H
-#define _ASM_IA64_SN_PCI_PIC_H
-
-/*
- * PIC AS DEVICE ZERO
- * ------------------
- *
- * PIC handles PCI/X busses.  PCI/X requires that the 'bridge' (i.e. PIC)
- * be designated as 'device 0'.   That is a departure from earlier SGI
- * PCI bridges.  Because of that we use config space 1 to access the
- * config space of the first actual PCI device on the bus. 
- * Here's what the PIC manual says:
- *
- *     The current PCI-X bus specification now defines that the parent
- *     hosts bus bridge (PIC for example) must be device 0 on bus 0. PIC
- *     reduced the total number of devices from 8 to 4 and removed the
- *     device registers and windows, now only supporting devices 0,1,2, and
- *     3. PIC did leave all 8 configuration space windows. The reason was
- *     there was nothing to gain by removing them. Here in lies the problem.
- *     The device numbering we do using 0 through 3 is unrelated to the device
- *     numbering which PCI-X requires in configuration space. In the past we
- *     correlated Configs pace and our device space 0 <-> 0, 1 <-> 1, etc.
- *     PCI-X requires we start a 1, not 0 and currently the PX brick
- *     does associate our:
- * 
- *         device 0 with configuration space window 1,
- *         device 1 with configuration space window 2, 
- *         device 2 with configuration space window 3,
- *         device 3 with configuration space window 4.
- *
- * The net effect is that all config space access are off-by-one with 
- * relation to other per-slot accesses on the PIC.   
- * Here is a table that shows some of that:
- *
- *                               Internal Slot#
- *           |
- *           |     0         1        2         3
- * ----------|---------------------------------------
- * config    |  0x21000   0x22000  0x23000   0x24000
- *           |
- * even rrb  |  0[0]      n/a      1[0]      n/a	[] = implied even/odd
- *           |
- * odd rrb   |  n/a       0[1]     n/a       1[1]
- *           |
- * int dev   |  00       01        10        11
- *           |
- * ext slot# |  1        2         3         4
- * ----------|---------------------------------------
- */
-
-#define PIC_ATE_TARGETID_SHFT           8
-#define PIC_HOST_INTR_ADDR              0x0000FFFFFFFFFFFFUL
-#define PIC_PCI64_ATTR_TARG_SHFT        60
-
-
-/*****************************************************************************
- *********************** PIC MMR structure mapping ***************************
- *****************************************************************************/
-
-/* NOTE: PIC WAR. PV#854697.  PIC does not allow writes just to [31:0]
- * of a 64-bit register.  When writing PIC registers, always write the 
- * entire 64 bits.
- */
-
-struct pic {
-
-    /* 0x000000-0x00FFFF -- Local Registers */
-
-    /* 0x000000-0x000057 -- Standard Widget Configuration */
-    uint64_t		p_wid_id;			/* 0x000000 */
-    uint64_t		p_wid_stat;			/* 0x000008 */
-    uint64_t		p_wid_err_upper;		/* 0x000010 */
-    uint64_t		p_wid_err_lower;		/* 0x000018 */
-    #define p_wid_err p_wid_err_lower
-    uint64_t		p_wid_control;			/* 0x000020 */
-    uint64_t		p_wid_req_timeout;		/* 0x000028 */
-    uint64_t		p_wid_int_upper;		/* 0x000030 */
-    uint64_t		p_wid_int_lower;		/* 0x000038 */
-    #define p_wid_int p_wid_int_lower
-    uint64_t		p_wid_err_cmdword;		/* 0x000040 */
-    uint64_t		p_wid_llp;			/* 0x000048 */
-    uint64_t		p_wid_tflush;			/* 0x000050 */
-
-    /* 0x000058-0x00007F -- Bridge-specific Widget Configuration */
-    uint64_t		p_wid_aux_err;			/* 0x000058 */
-    uint64_t		p_wid_resp_upper;		/* 0x000060 */
-    uint64_t		p_wid_resp_lower;		/* 0x000068 */
-    #define p_wid_resp p_wid_resp_lower
-    uint64_t		p_wid_tst_pin_ctrl;		/* 0x000070 */
-    uint64_t		p_wid_addr_lkerr;		/* 0x000078 */
-
-    /* 0x000080-0x00008F -- PMU & MAP */
-    uint64_t		p_dir_map;			/* 0x000080 */
-    uint64_t		_pad_000088;			/* 0x000088 */
-
-    /* 0x000090-0x00009F -- SSRAM */
-    uint64_t		p_map_fault;			/* 0x000090 */
-    uint64_t		_pad_000098;			/* 0x000098 */
-
-    /* 0x0000A0-0x0000AF -- Arbitration */
-    uint64_t		p_arb;				/* 0x0000A0 */
-    uint64_t		_pad_0000A8;			/* 0x0000A8 */
-
-    /* 0x0000B0-0x0000BF -- Number In A Can or ATE Parity Error */
-    uint64_t		p_ate_parity_err;		/* 0x0000B0 */
-    uint64_t		_pad_0000B8;			/* 0x0000B8 */
-
-    /* 0x0000C0-0x0000FF -- PCI/GIO */
-    uint64_t		p_bus_timeout;			/* 0x0000C0 */
-    uint64_t		p_pci_cfg;			/* 0x0000C8 */
-    uint64_t		p_pci_err_upper;		/* 0x0000D0 */
-    uint64_t		p_pci_err_lower;		/* 0x0000D8 */
-    #define p_pci_err p_pci_err_lower
-    uint64_t		_pad_0000E0[4];			/* 0x0000{E0..F8} */
-
-    /* 0x000100-0x0001FF -- Interrupt */
-    uint64_t		p_int_status;			/* 0x000100 */
-    uint64_t		p_int_enable;			/* 0x000108 */
-    uint64_t		p_int_rst_stat;			/* 0x000110 */
-    uint64_t		p_int_mode;			/* 0x000118 */
-    uint64_t		p_int_device;			/* 0x000120 */
-    uint64_t		p_int_host_err;			/* 0x000128 */
-    uint64_t		p_int_addr[8];			/* 0x0001{30,,,68} */
-    uint64_t		p_err_int_view;			/* 0x000170 */
-    uint64_t		p_mult_int;			/* 0x000178 */
-    uint64_t		p_force_always[8];		/* 0x0001{80,,,B8} */
-    uint64_t		p_force_pin[8];			/* 0x0001{C0,,,F8} */
-
-    /* 0x000200-0x000298 -- Device */
-    uint64_t		p_device[4];			/* 0x0002{00,,,18} */
-    uint64_t		_pad_000220[4];			/* 0x0002{20,,,38} */
-    uint64_t		p_wr_req_buf[4];		/* 0x0002{40,,,58} */
-    uint64_t		_pad_000260[4];			/* 0x0002{60,,,78} */
-    uint64_t		p_rrb_map[2];			/* 0x0002{80,,,88} */
-    #define p_even_resp p_rrb_map[0]			/* 0x000280 */
-    #define p_odd_resp  p_rrb_map[1]			/* 0x000288 */
-    uint64_t		p_resp_status;			/* 0x000290 */
-    uint64_t		p_resp_clear;			/* 0x000298 */
-
-    uint64_t		_pad_0002A0[12];		/* 0x0002{A0..F8} */
-
-    /* 0x000300-0x0003F8 -- Buffer Address Match Registers */
-    struct {
-	uint64_t	upper;				/* 0x0003{00,,,F0} */
-	uint64_t	lower;				/* 0x0003{08,,,F8} */
-    } p_buf_addr_match[16];
-
-    /* 0x000400-0x0005FF -- Performance Monitor Registers (even only) */
-    struct {
-	uint64_t	flush_w_touch;			/* 0x000{400,,,5C0} */
-	uint64_t	flush_wo_touch;			/* 0x000{408,,,5C8} */
-	uint64_t	inflight;			/* 0x000{410,,,5D0} */
-	uint64_t	prefetch;			/* 0x000{418,,,5D8} */
-	uint64_t	total_pci_retry;		/* 0x000{420,,,5E0} */
-	uint64_t	max_pci_retry;			/* 0x000{428,,,5E8} */
-	uint64_t	max_latency;			/* 0x000{430,,,5F0} */
-	uint64_t	clear_all;			/* 0x000{438,,,5F8} */
-    } p_buf_count[8];
-
-    
-    /* 0x000600-0x0009FF -- PCI/X registers */
-    uint64_t		p_pcix_bus_err_addr;		/* 0x000600 */
-    uint64_t		p_pcix_bus_err_attr;		/* 0x000608 */
-    uint64_t		p_pcix_bus_err_data;		/* 0x000610 */
-    uint64_t		p_pcix_pio_split_addr;		/* 0x000618 */
-    uint64_t		p_pcix_pio_split_attr;		/* 0x000620 */
-    uint64_t		p_pcix_dma_req_err_attr;	/* 0x000628 */
-    uint64_t		p_pcix_dma_req_err_addr;	/* 0x000630 */
-    uint64_t		p_pcix_timeout;			/* 0x000638 */
-
-    uint64_t		_pad_000640[120];		/* 0x000{640,,,9F8} */
-
-    /* 0x000A00-0x000BFF -- PCI/X Read&Write Buffer */
-    struct {
-	uint64_t	p_buf_addr;			/* 0x000{A00,,,AF0} */
-	uint64_t	p_buf_attr;			/* 0X000{A08,,,AF8} */
-    } p_pcix_read_buf_64[16];
-
-    struct {
-	uint64_t	p_buf_addr;			/* 0x000{B00,,,BE0} */
-	uint64_t	p_buf_attr;			/* 0x000{B08,,,BE8} */
-	uint64_t	p_buf_valid;			/* 0x000{B10,,,BF0} */
-	uint64_t	__pad1;				/* 0x000{B18,,,BF8} */
-    } p_pcix_write_buf_64[8];
-
-    /* End of Local Registers -- Start of Address Map space */
-
-    char		_pad_000c00[0x010000 - 0x000c00];
-
-    /* 0x010000-0x011fff -- Internal ATE RAM (Auto Parity Generation) */
-    uint64_t		p_int_ate_ram[1024];		/* 0x010000-0x011fff */
-
-    /* 0x012000-0x013fff -- Internal ATE RAM (Manual Parity Generation) */
-    uint64_t		p_int_ate_ram_mp[1024];		/* 0x012000-0x013fff */
-
-    char		_pad_014000[0x18000 - 0x014000];
-
-    /* 0x18000-0x197F8 -- PIC Write Request Ram */
-    uint64_t		p_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
-    uint64_t		p_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
-    uint64_t		p_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
-
-    char		_pad_019800[0x20000 - 0x019800];
-
-    /* 0x020000-0x027FFF -- PCI Device Configuration Spaces */
-    union {
-	uint8_t		c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
-	uint16_t	s[0x1000 / 2];			/* 0x02{0000,,,7FFF} */
-	uint32_t	l[0x1000 / 4];			/* 0x02{0000,,,7FFF} */
-	uint64_t	d[0x1000 / 8];			/* 0x02{0000,,,7FFF} */
-	union {
-	    uint8_t	c[0x100 / 1];
-	    uint16_t	s[0x100 / 2];
-	    uint32_t	l[0x100 / 4];
-	    uint64_t	d[0x100 / 8];
-	} f[8];
-    } p_type0_cfg_dev[8];				/* 0x02{0000,,,7FFF} */
-
-    /* 0x028000-0x028FFF -- PCI Type 1 Configuration Space */
-    union {
-	uint8_t		c[0x1000 / 1];			/* 0x028000-0x029000 */
-	uint16_t	s[0x1000 / 2];			/* 0x028000-0x029000 */
-	uint32_t	l[0x1000 / 4];			/* 0x028000-0x029000 */
-	uint64_t	d[0x1000 / 8];			/* 0x028000-0x029000 */
-	union {
-	    uint8_t	c[0x100 / 1];
-	    uint16_t	s[0x100 / 2];
-	    uint32_t	l[0x100 / 4];
-	    uint64_t	d[0x100 / 8];
-	} f[8];
-    } p_type1_cfg;					/* 0x028000-0x029000 */
-
-    char		_pad_029000[0x030000-0x029000];
-
-    /* 0x030000-0x030007 -- PCI Interrupt Acknowledge Cycle */
-    union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
-    } p_pci_iack;					/* 0x030000-0x030007 */
-
-    char		_pad_030007[0x040000-0x030008];
-
-    /* 0x040000-0x030007 -- PCIX Special Cycle */
-    union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
-    } p_pcix_cycle;					/* 0x040000-0x040007 */
-};
-
-#endif                          /* _ASM_IA64_SN_PCI_PIC_H */
Index: arch/ia64/sn/include/pci/tiocp.h
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/include/pci/tiocp.h  (mode:100644 sha1:f07c83b2bf6ebb8e9c907c2f9948a1169554601a)
+++ /dev/null  (tree:609461315376faf97b95c8fded1d5df433168614)
@@ -1,256 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 2003-2004 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_PCI_TIOCP_H
-#define _ASM_IA64_SN_PCI_TIOCP_H
-
-#define TIOCP_HOST_INTR_ADDR            0x003FFFFFFFFFFFFFUL
-#define TIOCP_PCI64_CMDTYPE_MEM         (0x1ull << 60)
-
-
-/*****************************************************************************
- *********************** TIOCP MMR structure mapping ***************************
- *****************************************************************************/
-
-struct tiocp{
-
-    /* 0x000000-0x00FFFF -- Local Registers */
-
-    /* 0x000000-0x000057 -- (Legacy Widget Space) Configuration */
-    uint64_t		cp_id;				/* 0x000000 */
-    uint64_t		cp_stat;			/* 0x000008 */
-    uint64_t		cp_err_upper;			/* 0x000010 */
-    uint64_t		cp_err_lower;			/* 0x000018 */
-    #define cp_err cp_err_lower
-    uint64_t		cp_control;			/* 0x000020 */
-    uint64_t		cp_req_timeout;			/* 0x000028 */
-    uint64_t		cp_intr_upper;			/* 0x000030 */
-    uint64_t		cp_intr_lower;			/* 0x000038 */
-    #define cp_intr cp_intr_lower
-    uint64_t		cp_err_cmdword;			/* 0x000040 */
-    uint64_t		_pad_000048;			/* 0x000048 */
-    uint64_t		cp_tflush;			/* 0x000050 */
-
-    /* 0x000058-0x00007F -- Bridge-specific Configuration */
-    uint64_t		cp_aux_err;			/* 0x000058 */
-    uint64_t		cp_resp_upper;			/* 0x000060 */
-    uint64_t		cp_resp_lower;			/* 0x000068 */
-    #define cp_resp cp_resp_lower
-    uint64_t		cp_tst_pin_ctrl;		/* 0x000070 */
-    uint64_t		cp_addr_lkerr;			/* 0x000078 */
-
-    /* 0x000080-0x00008F -- PMU & MAP */
-    uint64_t		cp_dir_map;			/* 0x000080 */
-    uint64_t		_pad_000088;			/* 0x000088 */
-
-    /* 0x000090-0x00009F -- SSRAM */
-    uint64_t		cp_map_fault;			/* 0x000090 */
-    uint64_t		_pad_000098;			/* 0x000098 */
-
-    /* 0x0000A0-0x0000AF -- Arbitration */
-    uint64_t		cp_arb;				/* 0x0000A0 */
-    uint64_t		_pad_0000A8;			/* 0x0000A8 */
-
-    /* 0x0000B0-0x0000BF -- Number In A Can or ATE Parity Error */
-    uint64_t		cp_ate_parity_err;		/* 0x0000B0 */
-    uint64_t		_pad_0000B8;			/* 0x0000B8 */
-
-    /* 0x0000C0-0x0000FF -- PCI/GIO */
-    uint64_t		cp_bus_timeout;			/* 0x0000C0 */
-    uint64_t		cp_pci_cfg;			/* 0x0000C8 */
-    uint64_t		cp_pci_err_upper;		/* 0x0000D0 */
-    uint64_t		cp_pci_err_lower;		/* 0x0000D8 */
-    #define cp_pci_err cp_pci_err_lower
-    uint64_t		_pad_0000E0[4];			/* 0x0000{E0..F8} */
-
-    /* 0x000100-0x0001FF -- Interrupt */
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
-
-    /* 0x000200-0x000298 -- Device */
-    uint64_t		cp_device[4];			/* 0x0002{00,,,18} */
-    uint64_t		_pad_000220[4];			/* 0x0002{20,,,38} */
-    uint64_t		cp_wr_req_buf[4];		/* 0x0002{40,,,58} */
-    uint64_t		_pad_000260[4];			/* 0x0002{60,,,78} */
-    uint64_t		cp_rrb_map[2];			/* 0x0002{80,,,88} */
-    #define cp_even_resp cp_rrb_map[0]			/* 0x000280 */
-    #define cp_odd_resp  cp_rrb_map[1]			/* 0x000288 */
-    uint64_t		cp_resp_status;			/* 0x000290 */
-    uint64_t		cp_resp_clear;			/* 0x000298 */
-
-    uint64_t		_pad_0002A0[12];		/* 0x0002{A0..F8} */
-
-    /* 0x000300-0x0003F8 -- Buffer Address Match Registers */
-    struct {
-	uint64_t	upper;				/* 0x0003{00,,,F0} */
-	uint64_t	lower;				/* 0x0003{08,,,F8} */
-    } cp_buf_addr_match[16];
-
-    /* 0x000400-0x0005FF -- Performance Monitor Registers (even only) */
-    struct {
-	uint64_t	flush_w_touch;			/* 0x000{400,,,5C0} */
-	uint64_t	flush_wo_touch;			/* 0x000{408,,,5C8} */
-	uint64_t	inflight;			/* 0x000{410,,,5D0} */
-	uint64_t	prefetch;			/* 0x000{418,,,5D8} */
-	uint64_t	total_pci_retry;		/* 0x000{420,,,5E0} */
-	uint64_t	max_pci_retry;			/* 0x000{428,,,5E8} */
-	uint64_t	max_latency;			/* 0x000{430,,,5F0} */
-	uint64_t	clear_all;			/* 0x000{438,,,5F8} */
-    } cp_buf_count[8];
-
-    
-    /* 0x000600-0x0009FF -- PCI/X registers */
-    uint64_t		cp_pcix_bus_err_addr;		/* 0x000600 */
-    uint64_t		cp_pcix_bus_err_attr;		/* 0x000608 */
-    uint64_t		cp_pcix_bus_err_data;		/* 0x000610 */
-    uint64_t		cp_pcix_pio_split_addr;		/* 0x000618 */
-    uint64_t		cp_pcix_pio_split_attr;		/* 0x000620 */
-    uint64_t		cp_pcix_dma_req_err_attr;	/* 0x000628 */
-    uint64_t		cp_pcix_dma_req_err_addr;	/* 0x000630 */
-    uint64_t		cp_pcix_timeout;		/* 0x000638 */
-
-    uint64_t		_pad_000640[24];		/* 0x000{640,,,6F8} */
-
-    /* 0x000700-0x000737 -- Debug Registers */
-    uint64_t		cp_ct_debug_ctl;		/* 0x000700 */
-    uint64_t		cp_br_debug_ctl;		/* 0x000708 */
-    uint64_t		cp_mux3_debug_ctl;		/* 0x000710 */
-    uint64_t		cp_mux4_debug_ctl;		/* 0x000718 */
-    uint64_t		cp_mux5_debug_ctl;		/* 0x000720 */
-    uint64_t		cp_mux6_debug_ctl;		/* 0x000728 */
-    uint64_t		cp_mux7_debug_ctl;		/* 0x000730 */
-
-    uint64_t		_pad_000738[89];		/* 0x000{738,,,9F8} */
-
-    /* 0x000A00-0x000BFF -- PCI/X Read&Write Buffer */
-    struct {
-	uint64_t	cp_buf_addr;			/* 0x000{A00,,,AF0} */
-	uint64_t	cp_buf_attr;			/* 0X000{A08,,,AF8} */
-    } cp_pcix_read_buf_64[16];
-
-    struct {
-	uint64_t	cp_buf_addr;			/* 0x000{B00,,,BE0} */
-	uint64_t	cp_buf_attr;			/* 0x000{B08,,,BE8} */
-	uint64_t	cp_buf_valid;			/* 0x000{B10,,,BF0} */
-	uint64_t	__pad1;				/* 0x000{B18,,,BF8} */
-    } cp_pcix_write_buf_64[8];
-
-    /* End of Local Registers -- Start of Address Map space */
-
-    char		_pad_000c00[0x010000 - 0x000c00];
-
-    /* 0x010000-0x011FF8 -- Internal ATE RAM (Auto Parity Generation) */
-    uint64_t		cp_int_ate_ram[1024];		/* 0x010000-0x011FF8 */
-
-    char		_pad_012000[0x14000 - 0x012000];
-
-    /* 0x014000-0x015FF8 -- Internal ATE RAM (Manual Parity Generation) */
-    uint64_t		cp_int_ate_ram_mp[1024];	/* 0x014000-0x015FF8 */
-
-    char		_pad_016000[0x18000 - 0x016000];
-
-    /* 0x18000-0x197F8 -- TIOCP Write Request Ram */
-    uint64_t		cp_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
-    uint64_t		cp_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
-    uint64_t		cp_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
-
-    char		_pad_019800[0x1C000 - 0x019800];
-
-    /* 0x1C000-0x1EFF8 -- TIOCP Read Response Ram */
-    uint64_t		cp_rd_resp_lower[512];		/* 0x1C000 - 0x1CFF8 */
-    uint64_t		cp_rd_resp_upper[512];		/* 0x1D000 - 0x1DFF8 */
-    uint64_t		cp_rd_resp_parity[512];		/* 0x1E000 - 0x1EFF8 */
-
-    char		_pad_01F000[0x20000 - 0x01F000];
-
-    /* 0x020000-0x021FFF -- Host Device (CP) Configuration Space (not used)  */
-    char		_pad_020000[0x021000 - 0x20000];
-
-    /* 0x021000-0x027FFF -- PCI Device Configuration Spaces */
-    union {
-	uint8_t		c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
-	uint16_t	s[0x1000 / 2];			/* 0x02{0000,,,7FFF} */
-	uint32_t	l[0x1000 / 4];			/* 0x02{0000,,,7FFF} */
-	uint64_t	d[0x1000 / 8];			/* 0x02{0000,,,7FFF} */
-	union {
-	    uint8_t	c[0x100 / 1];
-	    uint16_t	s[0x100 / 2];
-	    uint32_t	l[0x100 / 4];
-	    uint64_t	d[0x100 / 8];
-	} f[8];
-    } cp_type0_cfg_dev[7];				/* 0x02{1000,,,7FFF} */
-
-    /* 0x028000-0x028FFF -- PCI Type 1 Configuration Space */
-    union {
-	uint8_t		c[0x1000 / 1];			/* 0x028000-0x029000 */
-	uint16_t	s[0x1000 / 2];			/* 0x028000-0x029000 */
-	uint32_t	l[0x1000 / 4];			/* 0x028000-0x029000 */
-	uint64_t	d[0x1000 / 8];			/* 0x028000-0x029000 */
-	union {
-	    uint8_t	c[0x100 / 1];
-	    uint16_t	s[0x100 / 2];
-	    uint32_t	l[0x100 / 4];
-	    uint64_t	d[0x100 / 8];
-	} f[8];
-    } cp_type1_cfg;					/* 0x028000-0x029000 */
-
-    char		_pad_029000[0x030000-0x029000];
-
-    /* 0x030000-0x030007 -- PCI Interrupt Acknowledge Cycle */
-    union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
-    } cp_pci_iack;					/* 0x030000-0x030007 */
-
-    char		_pad_030007[0x040000-0x030008];
-
-    /* 0x040000-0x040007 -- PCIX Special Cycle */
-    union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
-    } cp_pcix_cycle;					/* 0x040000-0x040007 */
-
-    char		_pad_040007[0x200000-0x040008];
-
-    /* 0x200000-0x7FFFFF -- PCI/GIO Device Spaces */
-    union {
-	uint8_t		c[0x100000 / 1];
-	uint16_t	s[0x100000 / 2];
-	uint32_t	l[0x100000 / 4];
-	uint64_t	d[0x100000 / 8];
-    } cp_devio_raw[6];					/* 0x200000-0x7FFFFF */
-
-    #define cp_devio(n)  cp_devio_raw[((n)<2)?(n*2):(n+2)]
-
-    char		_pad_800000[0xA00000-0x800000];
-
-    /* 0xA00000-0xBFFFFF -- PCI/GIO Device Spaces w/flush  */
-    union {
-	uint8_t		c[0x100000 / 1];
-	uint16_t	s[0x100000 / 2];
-	uint32_t	l[0x100000 / 4];
-	uint64_t	d[0x100000 / 8];
-    } cp_devio_raw_flush[6];				/* 0xA00000-0xBFFFFF */
-
-    #define cp_devio_flush(n)  cp_devio_raw_flush[((n)<2)?(n*2):(n+2)]
-
-};
-
-#endif 	/* _ASM_IA64_SN_PCI_TIOCP_H */
Index: arch/ia64/sn/include/xtalk/hubdev.h
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/include/xtalk/hubdev.h  (mode:100644 sha1:868e7ecae84b7494628c241a26954dcd83fabd48)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/include/xtalk/hubdev.h  (mode:100644 sha1:580a1c0403a73c373c60cf34cc59f985bb5a16f0)
@@ -8,6 +8,8 @@
 #ifndef _ASM_IA64_SN_XTALK_HUBDEV_H
 #define _ASM_IA64_SN_XTALK_HUBDEV_H
 
+#include "xtalk/xwidgetdev.h"
+
 #define HUB_WIDGET_ID_MAX 0xf
 #define DEV_PER_WIDGET (2*2*8)
 #define IIO_ITTE_WIDGET_BITS    4       /* size of widget field */
Index: arch/ia64/sn/kernel/io_init.c
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/kernel/io_init.c  (mode:100644 sha1:cb29bd1d475d1be98d32aa02f81f576e77b327d2)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/kernel/io_init.c  (mode:100644 sha1:ae6628cd41f8cc2f94643fce2c4fe21bdd85d2d9)
@@ -9,17 +9,17 @@
 #include <linux/bootmem.h>
 #include <linux/nodemask.h>
 #include <asm/sn/types.h>
-#include <asm/sn/sn_sal.h>
 #include <asm/sn/addrs.h>
-#include <asm/sn/pcibus_provider_defs.h>
-#include <asm/sn/pcidev.h>
-#include "pci/pcibr_provider.h"
-#include "xtalk/xwidgetdev.h"
 #include <asm/sn/geo.h>
-#include "xtalk/hubdev.h"
 #include <asm/sn/io.h>
+#include <asm/sn/pcibr_provider.h>
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 #include <asm/sn/simulator.h>
+#include <asm/sn/sn_sal.h>
 #include <asm/sn/tioca_provider.h>
+#include "xtalk/hubdev.h"
+#include "xtalk/xwidgetdev.h"
 
 nasid_t master_nasid = INVALID_NASID;	/* Partition Master */
 
@@ -226,7 +226,7 @@
  * from our PCI provider include PIO maps to BAR space and interrupt
  * objects.
  */
-static void sn_pci_fixup_slot(struct pci_dev *dev)
+void sn_pci_fixup_slot(struct pci_dev *dev)
 {
 	int idx;
 	int segment = 0;
Index: arch/ia64/sn/kernel/irq.c
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/kernel/irq.c  (mode:100644 sha1:e6f7551edfda49e8d22e9378a7d09a63ff009d0d)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/kernel/irq.c  (mode:100644 sha1:ee4ac68d745f2c91e39d10e2f82cf624cf655edd)
@@ -10,13 +10,12 @@
 
 #include <linux/irq.h>
 #include <linux/spinlock.h>
-#include <asm/sn/intr.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/arch.h>
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/intr.h>
+#include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
-#include "pci/pcibr_provider.h"
 #include <asm/sn/shub_mmr.h>
 #include <asm/sn/sn_sal.h>
 
@@ -103,7 +102,7 @@
 		nasid = get_nasid();
 		event_occurred = HUB_L((uint64_t *) GLOBAL_MMR_ADDR
 				       (nasid, SH_EVENT_OCCURRED));
-		/* If the UART bit is set here, we may have received an
+		/* If the UART bit is set here, we may have received an 
 		 * interrupt from the UART that the driver missed.  To
 		 * make sure, we IPI ourselves to force us to look again.
 		 */
Index: arch/ia64/sn/pci/pci_dma.c
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/pci/pci_dma.c  (mode:100644 sha1:5da9bdbde7cb829dbef14774cf5bf2c9d568f8d5)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/pci/pci_dma.c  (mode:100644 sha1:a2f7a88aefbb0bd925647668acc641438ac73b5c)
@@ -11,9 +11,10 @@
 
 #include <linux/module.h>
 #include <asm/dma.h>
-#include <asm/sn/sn_sal.h>
+#include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
+#include <asm/sn/sn_sal.h>
 
 #define SG_ENT_VIRT_ADDRESS(sg)	(page_address((sg)->page) + (sg)->offset)
 #define SG_ENT_PHYS_ADDRESS(SG)	virt_to_phys(SG_ENT_VIRT_ADDRESS(SG))
Index: arch/ia64/sn/pci/pcibr/pcibr_ate.c
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/pci/pcibr/pcibr_ate.c  (mode:100644 sha1:0e47bce85f2da0e1494ff5f705c8fa91b59ae161)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/pci/pcibr/pcibr_ate.c  (mode:100644 sha1:d1647b863e6106a3d17219c4b9748633dc165630)
@@ -8,9 +8,9 @@
 
 #include <linux/types.h>
 #include <asm/sn/sn_sal.h>
+#include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
-#include "pci/pcibr_provider.h"
 
 int pcibr_invalidate_ate = 0;	/* by default don't invalidate ATE on free */
 
Index: arch/ia64/sn/pci/pcibr/pcibr_dma.c
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/pci/pcibr/pcibr_dma.c  (mode:100644 sha1:64af2b2c17879181e0610cdaa7fb10dfdb8bf26e)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/pci/pcibr/pcibr_dma.c  (mode:100644 sha1:b058dc2a0b9d3dfb7a17fe73f2ae35f72266ebd3)
@@ -8,18 +8,17 @@
 
 #include <linux/types.h>
 #include <linux/pci.h>
-#include <asm/sn/sn_sal.h>
+#include <asm/sn/addrs.h>
 #include <asm/sn/geo.h>
-#include "xtalk/xwidgetdev.h"
-#include "xtalk/hubdev.h"
+#include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
-#include "pci/tiocp.h"
-#include "pci/pic.h"
-#include "pci/pcibr_provider.h"
-#include "pci/tiocp.h"
+#include <asm/sn/pic.h>
+#include <asm/sn/sn_sal.h>
+#include <asm/sn/tiocp.h>
 #include "tio.h"
-#include <asm/sn/addrs.h>
+#include "xtalk/xwidgetdev.h"
+#include "xtalk/hubdev.h"
 
 extern int sn_ioif_inited;
 
Index: arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/pci/pcibr/pcibr_provider.c  (mode:100644 sha1:3893999d23d8871a7f5f6bf4315b24d713391411)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/pci/pcibr/pcibr_provider.c  (mode:100644 sha1:9bc4de4a3ec0778aa4724e75457bd253a6b1e45e)
@@ -6,18 +6,17 @@
  * Copyright (C) 2001-2004 Silicon Graphics, Inc. All rights reserved.
  */
 
-#include <linux/types.h>
 #include <linux/interrupt.h>
+#include <linux/types.h>
 #include <linux/pci.h>
-#include <asm/sn/sn_sal.h>
-#include "xtalk/xwidgetdev.h"
+#include <asm/sn/addrs.h>
 #include <asm/sn/geo.h>
-#include "xtalk/hubdev.h"
+#include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
-#include "pci/pcibr_provider.h"
-#include <asm/sn/addrs.h>
-
+#include <asm/sn/sn_sal.h>
+#include "xtalk/xwidgetdev.h"
+#include "xtalk/hubdev.h"
 
 static int sal_pcibr_error_interrupt(struct pcibus_info *soft)
 {
Index: arch/ia64/sn/pci/pcibr/pcibr_reg.c
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/pci/pcibr/pcibr_reg.c  (mode:100644 sha1:865c11c3b50a06cbcd31d39b1bf152bfe12e8606)
+++ 609461315376faf97b95c8fded1d5df433168614/arch/ia64/sn/pci/pcibr/pcibr_reg.c  (mode:100644 sha1:21426d02fbe6a84fa818535600d145ea850e8c1c)
@@ -6,13 +6,13 @@
  * Copyright (C) 2004 Silicon Graphics, Inc. All rights reserved.
  */
 
-#include <linux/types.h>
 #include <linux/interrupt.h>
+#include <linux/types.h>
+#include <asm/sn/pcibr_provider.h>
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
-#include "pci/tiocp.h"
-#include "pci/pic.h"
-#include "pci/pcibr_provider.h"
+#include <asm/sn/pic.h>
+#include <asm/sn/tiocp.h>
 
 union br_ptr {
 	struct tiocp tio;
Index: include/asm-ia64/sn/pcibr_provider.h
=================================--- /dev/null  (tree:d53d603c8c1a083db8df0c479b9bf296288dbc74)
+++ 609461315376faf97b95c8fded1d5df433168614/include/asm-ia64/sn/pcibr_provider.h  (mode:100644 sha1:0abf539cb0414d752fcf14d9318bf1fa00278d32)
@@ -0,0 +1,154 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 1992-1997,2000-2004 Silicon Graphics, Inc. All rights reserved.
+ */
+#ifndef _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
+#define _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
+
+#include <asm/sn/intr.h>
+#include <asm/sn/pcibus_provider_defs.h>
+
+/* Workarounds */
+#define PV907516 (1 << 1) /* TIOCP: Don't write the write buffer flush reg */
+
+#define BUSTYPE_MASK                    0x1
+
+/* Macros given a pcibus structure */
+#define IS_PCIX(ps)     ((ps)->pbi_bridge_mode & BUSTYPE_MASK)
+#define IS_PCI_BRIDGE_ASIC(asic) (asic = PCIIO_ASIC_TYPE_PIC || \
+                asic = PCIIO_ASIC_TYPE_TIOCP)
+#define IS_PIC_SOFT(ps)     (ps->pbi_bridge_type = PCIBR_BRIDGETYPE_PIC)
+
+
+/* 
+ * The different PCI Bridge types supported on the SGI Altix platforms
+ */
+#define PCIBR_BRIDGETYPE_UNKNOWN       -1
+#define PCIBR_BRIDGETYPE_PIC            2
+#define PCIBR_BRIDGETYPE_TIOCP          3
+
+/*
+ * Bridge 64bit Direct Map Attributes
+ */
+#define PCI64_ATTR_PREF                 (1ull << 59)
+#define PCI64_ATTR_PREC                 (1ull << 58)
+#define PCI64_ATTR_VIRTUAL              (1ull << 57)
+#define PCI64_ATTR_BAR                  (1ull << 56)
+#define PCI64_ATTR_SWAP                 (1ull << 55)
+#define PCI64_ATTR_VIRTUAL1             (1ull << 54)
+
+#define PCI32_LOCAL_BASE                0
+#define PCI32_MAPPED_BASE               0x40000000
+#define PCI32_DIRECT_BASE               0x80000000
+
+#define IS_PCI32_MAPPED(x)              ((uint64_t)(x) < PCI32_DIRECT_BASE && \
+                                         (uint64_t)(x) >= PCI32_MAPPED_BASE)
+#define IS_PCI32_DIRECT(x)              ((uint64_t)(x) >= PCI32_MAPPED_BASE)
+
+
+/*
+ * Bridge PMU Address Transaltion Entry Attibutes
+ */
+#define PCI32_ATE_V                     (0x1 << 0)
+#define PCI32_ATE_CO                    (0x1 << 1)
+#define PCI32_ATE_PREC                  (0x1 << 2)
+#define PCI32_ATE_PREF                  (0x1 << 3)
+#define PCI32_ATE_BAR                   (0x1 << 4)
+#define PCI32_ATE_ADDR_SHFT             12
+
+#define MINIMAL_ATES_REQUIRED(addr, size) \
+	(IOPG(IOPGOFF(addr) + (size) - 1) = IOPG((size) - 1))
+
+#define MINIMAL_ATE_FLAG(addr, size) \
+	(MINIMAL_ATES_REQUIRED((uint64_t)addr, size) ? 1 : 0)
+
+/* bit 29 of the pci address is the SWAP bit */
+#define ATE_SWAPSHIFT                   29
+#define ATE_SWAP_ON(x)                  ((x) |= (1 << ATE_SWAPSHIFT))
+#define ATE_SWAP_OFF(x)                 ((x) &= ~(1 << ATE_SWAPSHIFT))
+
+/*
+ * I/O page size
+ */
+#if PAGE_SIZE < 16384
+#define IOPFNSHIFT                      12      /* 4K per mapped page */
+#else
+#define IOPFNSHIFT                      14      /* 16K per mapped page */
+#endif
+
+#define IOPGSIZE                        (1 << IOPFNSHIFT)
+#define IOPG(x)                         ((x) >> IOPFNSHIFT)
+#define IOPGOFF(x)                      ((x) & (IOPGSIZE-1))
+
+#define PCIBR_DEV_SWAP_DIR              (1ull << 19)
+#define PCIBR_CTRL_PAGE_SIZE            (0x1 << 21)
+
+/*
+ * PMU resources.
+ */
+struct ate_resource{
+	uint64_t *ate;
+	uint64_t num_ate;
+	uint64_t lowest_free_index;
+};
+
+struct pcibus_info {
+	struct pcibus_bussoft	pbi_buscommon;   /* common header */
+	uint32_t                pbi_moduleid;
+	short                   pbi_bridge_type;
+	short                   pbi_bridge_mode;
+
+	struct ate_resource     pbi_int_ate_resource;
+	uint64_t                pbi_int_ate_size;
+	
+	uint64_t                pbi_dir_xbase;
+	char                    pbi_hub_xid;
+
+	uint64_t                pbi_devreg[8];
+	spinlock_t              pbi_lock;
+
+	uint32_t		pbi_valid_devices;
+	uint32_t		pbi_enabled_devices;
+};
+
+/*
+ * pcibus_info structure locking macros
+ */
+inline static unsigned long
+pcibr_lock(struct pcibus_info *pcibus_info)
+{
+	unsigned long flag;
+	spin_lock_irqsave(&pcibus_info->pbi_lock, flag);
+	return(flag);
+}
+#define pcibr_unlock(pcibus_info, flag)  spin_unlock_irqrestore(&pcibus_info->pbi_lock, flag)
+
+extern int  pcibr_init_provider(void);
+extern void *pcibr_bus_fixup(struct pcibus_bussoft *);
+extern dma_addr_t pcibr_dma_map(struct pci_dev *, unsigned long, size_t);
+extern dma_addr_t pcibr_dma_map_consistent(struct pci_dev *, unsigned long, size_t);
+extern void pcibr_dma_unmap(struct pci_dev *, dma_addr_t, int);
+
+/*
+ * prototypes for the bridge asic register access routines in pcibr_reg.c
+ */
+extern void             pcireg_control_bit_clr(struct pcibus_info *, uint64_t);
+extern void             pcireg_control_bit_set(struct pcibus_info *, uint64_t);
+extern uint64_t         pcireg_tflush_get(struct pcibus_info *);
+extern uint64_t         pcireg_intr_status_get(struct pcibus_info *);
+extern void             pcireg_intr_enable_bit_clr(struct pcibus_info *, uint64_t);
+extern void             pcireg_intr_enable_bit_set(struct pcibus_info *, uint64_t);
+extern void             pcireg_intr_addr_addr_set(struct pcibus_info *, int, uint64_t);
+extern void             pcireg_force_intr_set(struct pcibus_info *, int);
+extern uint64_t         pcireg_wrb_flush_get(struct pcibus_info *, int);
+extern void             pcireg_int_ate_set(struct pcibus_info *, int, uint64_t);
+extern uint64_t *	pcireg_int_ate_addr(struct pcibus_info *, int);
+extern void 		pcibr_force_interrupt(struct sn_irq_info *sn_irq_info);
+extern void 		pcibr_change_devices_irq(struct sn_irq_info *sn_irq_info);
+extern int 		pcibr_ate_alloc(struct pcibus_info *, int);
+extern void 		pcibr_ate_free(struct pcibus_info *, int);
+extern void 		ate_write(struct pcibus_info *, int, int, uint64_t);
+#endif
Index: include/asm-ia64/sn/pcidev.h
=================================--- d53d603c8c1a083db8df0c479b9bf296288dbc74/include/asm-ia64/sn/pcidev.h  (mode:100644 sha1:42aea21ee18710b060cd2d3be8df0defb830468f)
+++ 609461315376faf97b95c8fded1d5df433168614/include/asm-ia64/sn/pcidev.h  (mode:100644 sha1:9610fcc635450e57bf9be693fb8fa5e22eb60be1)
@@ -13,6 +13,8 @@
 #define SN_PCIDEV_INFO(pci_dev) \
         ((struct pcidev_info *)(pci_dev)->sysdata)
 
+#define SN_PCIBUS_BUSSOFT_INFO(pci_bus) \
+	(struct pcibus_info *)((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
 /*
  * Given a pci_bus, return the sn pcibus_bussoft struct.  Note that
  * this only works for root busses, not for busses represented by PPB's.
@@ -53,6 +55,8 @@
 
 extern void sn_irq_fixup(struct pci_dev *pci_dev,
 			 struct sn_irq_info *sn_irq_info);
-
+extern void sn_irq_unfixup(struct pci_dev *pci_dev);
+extern void sn_pci_fixup_slot(struct pci_dev *dev);
+extern void sn_pci_unfixup_slot(struct pci_dev *dev);
 extern void sn_irq_lh_init(void);
 #endif				/* _ASM_IA64_SN_PCI_PCIDEV_H */
Index: include/asm-ia64/sn/pic.h
=================================--- /dev/null  (tree:d53d603c8c1a083db8df0c479b9bf296288dbc74)
+++ 609461315376faf97b95c8fded1d5df433168614/include/asm-ia64/sn/pic.h  (mode:100644 sha1:fd18acecb1e67e783c4085f27eb7e6390af0a47d)
@@ -0,0 +1,261 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 1992 - 1997, 2000-2003 Silicon Graphics, Inc. All rights reserved.
+ */
+#ifndef _ASM_IA64_SN_PCI_PIC_H
+#define _ASM_IA64_SN_PCI_PIC_H
+
+/*
+ * PIC AS DEVICE ZERO
+ * ------------------
+ *
+ * PIC handles PCI/X busses.  PCI/X requires that the 'bridge' (i.e. PIC)
+ * be designated as 'device 0'.   That is a departure from earlier SGI
+ * PCI bridges.  Because of that we use config space 1 to access the
+ * config space of the first actual PCI device on the bus. 
+ * Here's what the PIC manual says:
+ *
+ *     The current PCI-X bus specification now defines that the parent
+ *     hosts bus bridge (PIC for example) must be device 0 on bus 0. PIC
+ *     reduced the total number of devices from 8 to 4 and removed the
+ *     device registers and windows, now only supporting devices 0,1,2, and
+ *     3. PIC did leave all 8 configuration space windows. The reason was
+ *     there was nothing to gain by removing them. Here in lies the problem.
+ *     The device numbering we do using 0 through 3 is unrelated to the device
+ *     numbering which PCI-X requires in configuration space. In the past we
+ *     correlated Configs pace and our device space 0 <-> 0, 1 <-> 1, etc.
+ *     PCI-X requires we start a 1, not 0 and currently the PX brick
+ *     does associate our:
+ * 
+ *         device 0 with configuration space window 1,
+ *         device 1 with configuration space window 2, 
+ *         device 2 with configuration space window 3,
+ *         device 3 with configuration space window 4.
+ *
+ * The net effect is that all config space access are off-by-one with 
+ * relation to other per-slot accesses on the PIC.   
+ * Here is a table that shows some of that:
+ *
+ *                               Internal Slot#
+ *           |
+ *           |     0         1        2         3
+ * ----------|---------------------------------------
+ * config    |  0x21000   0x22000  0x23000   0x24000
+ *           |
+ * even rrb  |  0[0]      n/a      1[0]      n/a	[] = implied even/odd
+ *           |
+ * odd rrb   |  n/a       0[1]     n/a       1[1]
+ *           |
+ * int dev   |  00       01        10        11
+ *           |
+ * ext slot# |  1        2         3         4
+ * ----------|---------------------------------------
+ */
+
+#define PIC_ATE_TARGETID_SHFT           8
+#define PIC_HOST_INTR_ADDR              0x0000FFFFFFFFFFFFUL
+#define PIC_PCI64_ATTR_TARG_SHFT        60
+
+
+/*****************************************************************************
+ *********************** PIC MMR structure mapping ***************************
+ *****************************************************************************/
+
+/* NOTE: PIC WAR. PV#854697.  PIC does not allow writes just to [31:0]
+ * of a 64-bit register.  When writing PIC registers, always write the 
+ * entire 64 bits.
+ */
+
+struct pic {
+
+    /* 0x000000-0x00FFFF -- Local Registers */
+
+    /* 0x000000-0x000057 -- Standard Widget Configuration */
+    uint64_t		p_wid_id;			/* 0x000000 */
+    uint64_t		p_wid_stat;			/* 0x000008 */
+    uint64_t		p_wid_err_upper;		/* 0x000010 */
+    uint64_t		p_wid_err_lower;		/* 0x000018 */
+    #define p_wid_err p_wid_err_lower
+    uint64_t		p_wid_control;			/* 0x000020 */
+    uint64_t		p_wid_req_timeout;		/* 0x000028 */
+    uint64_t		p_wid_int_upper;		/* 0x000030 */
+    uint64_t		p_wid_int_lower;		/* 0x000038 */
+    #define p_wid_int p_wid_int_lower
+    uint64_t		p_wid_err_cmdword;		/* 0x000040 */
+    uint64_t		p_wid_llp;			/* 0x000048 */
+    uint64_t		p_wid_tflush;			/* 0x000050 */
+
+    /* 0x000058-0x00007F -- Bridge-specific Widget Configuration */
+    uint64_t		p_wid_aux_err;			/* 0x000058 */
+    uint64_t		p_wid_resp_upper;		/* 0x000060 */
+    uint64_t		p_wid_resp_lower;		/* 0x000068 */
+    #define p_wid_resp p_wid_resp_lower
+    uint64_t		p_wid_tst_pin_ctrl;		/* 0x000070 */
+    uint64_t		p_wid_addr_lkerr;		/* 0x000078 */
+
+    /* 0x000080-0x00008F -- PMU & MAP */
+    uint64_t		p_dir_map;			/* 0x000080 */
+    uint64_t		_pad_000088;			/* 0x000088 */
+
+    /* 0x000090-0x00009F -- SSRAM */
+    uint64_t		p_map_fault;			/* 0x000090 */
+    uint64_t		_pad_000098;			/* 0x000098 */
+
+    /* 0x0000A0-0x0000AF -- Arbitration */
+    uint64_t		p_arb;				/* 0x0000A0 */
+    uint64_t		_pad_0000A8;			/* 0x0000A8 */
+
+    /* 0x0000B0-0x0000BF -- Number In A Can or ATE Parity Error */
+    uint64_t		p_ate_parity_err;		/* 0x0000B0 */
+    uint64_t		_pad_0000B8;			/* 0x0000B8 */
+
+    /* 0x0000C0-0x0000FF -- PCI/GIO */
+    uint64_t		p_bus_timeout;			/* 0x0000C0 */
+    uint64_t		p_pci_cfg;			/* 0x0000C8 */
+    uint64_t		p_pci_err_upper;		/* 0x0000D0 */
+    uint64_t		p_pci_err_lower;		/* 0x0000D8 */
+    #define p_pci_err p_pci_err_lower
+    uint64_t		_pad_0000E0[4];			/* 0x0000{E0..F8} */
+
+    /* 0x000100-0x0001FF -- Interrupt */
+    uint64_t		p_int_status;			/* 0x000100 */
+    uint64_t		p_int_enable;			/* 0x000108 */
+    uint64_t		p_int_rst_stat;			/* 0x000110 */
+    uint64_t		p_int_mode;			/* 0x000118 */
+    uint64_t		p_int_device;			/* 0x000120 */
+    uint64_t		p_int_host_err;			/* 0x000128 */
+    uint64_t		p_int_addr[8];			/* 0x0001{30,,,68} */
+    uint64_t		p_err_int_view;			/* 0x000170 */
+    uint64_t		p_mult_int;			/* 0x000178 */
+    uint64_t		p_force_always[8];		/* 0x0001{80,,,B8} */
+    uint64_t		p_force_pin[8];			/* 0x0001{C0,,,F8} */
+
+    /* 0x000200-0x000298 -- Device */
+    uint64_t		p_device[4];			/* 0x0002{00,,,18} */
+    uint64_t		_pad_000220[4];			/* 0x0002{20,,,38} */
+    uint64_t		p_wr_req_buf[4];		/* 0x0002{40,,,58} */
+    uint64_t		_pad_000260[4];			/* 0x0002{60,,,78} */
+    uint64_t		p_rrb_map[2];			/* 0x0002{80,,,88} */
+    #define p_even_resp p_rrb_map[0]			/* 0x000280 */
+    #define p_odd_resp  p_rrb_map[1]			/* 0x000288 */
+    uint64_t		p_resp_status;			/* 0x000290 */
+    uint64_t		p_resp_clear;			/* 0x000298 */
+
+    uint64_t		_pad_0002A0[12];		/* 0x0002{A0..F8} */
+
+    /* 0x000300-0x0003F8 -- Buffer Address Match Registers */
+    struct {
+	uint64_t	upper;				/* 0x0003{00,,,F0} */
+	uint64_t	lower;				/* 0x0003{08,,,F8} */
+    } p_buf_addr_match[16];
+
+    /* 0x000400-0x0005FF -- Performance Monitor Registers (even only) */
+    struct {
+	uint64_t	flush_w_touch;			/* 0x000{400,,,5C0} */
+	uint64_t	flush_wo_touch;			/* 0x000{408,,,5C8} */
+	uint64_t	inflight;			/* 0x000{410,,,5D0} */
+	uint64_t	prefetch;			/* 0x000{418,,,5D8} */
+	uint64_t	total_pci_retry;		/* 0x000{420,,,5E0} */
+	uint64_t	max_pci_retry;			/* 0x000{428,,,5E8} */
+	uint64_t	max_latency;			/* 0x000{430,,,5F0} */
+	uint64_t	clear_all;			/* 0x000{438,,,5F8} */
+    } p_buf_count[8];
+
+    
+    /* 0x000600-0x0009FF -- PCI/X registers */
+    uint64_t		p_pcix_bus_err_addr;		/* 0x000600 */
+    uint64_t		p_pcix_bus_err_attr;		/* 0x000608 */
+    uint64_t		p_pcix_bus_err_data;		/* 0x000610 */
+    uint64_t		p_pcix_pio_split_addr;		/* 0x000618 */
+    uint64_t		p_pcix_pio_split_attr;		/* 0x000620 */
+    uint64_t		p_pcix_dma_req_err_attr;	/* 0x000628 */
+    uint64_t		p_pcix_dma_req_err_addr;	/* 0x000630 */
+    uint64_t		p_pcix_timeout;			/* 0x000638 */
+
+    uint64_t		_pad_000640[120];		/* 0x000{640,,,9F8} */
+
+    /* 0x000A00-0x000BFF -- PCI/X Read&Write Buffer */
+    struct {
+	uint64_t	p_buf_addr;			/* 0x000{A00,,,AF0} */
+	uint64_t	p_buf_attr;			/* 0X000{A08,,,AF8} */
+    } p_pcix_read_buf_64[16];
+
+    struct {
+	uint64_t	p_buf_addr;			/* 0x000{B00,,,BE0} */
+	uint64_t	p_buf_attr;			/* 0x000{B08,,,BE8} */
+	uint64_t	p_buf_valid;			/* 0x000{B10,,,BF0} */
+	uint64_t	__pad1;				/* 0x000{B18,,,BF8} */
+    } p_pcix_write_buf_64[8];
+
+    /* End of Local Registers -- Start of Address Map space */
+
+    char		_pad_000c00[0x010000 - 0x000c00];
+
+    /* 0x010000-0x011fff -- Internal ATE RAM (Auto Parity Generation) */
+    uint64_t		p_int_ate_ram[1024];		/* 0x010000-0x011fff */
+
+    /* 0x012000-0x013fff -- Internal ATE RAM (Manual Parity Generation) */
+    uint64_t		p_int_ate_ram_mp[1024];		/* 0x012000-0x013fff */
+
+    char		_pad_014000[0x18000 - 0x014000];
+
+    /* 0x18000-0x197F8 -- PIC Write Request Ram */
+    uint64_t		p_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
+    uint64_t		p_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
+    uint64_t		p_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
+
+    char		_pad_019800[0x20000 - 0x019800];
+
+    /* 0x020000-0x027FFF -- PCI Device Configuration Spaces */
+    union {
+	uint8_t		c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
+	uint16_t	s[0x1000 / 2];			/* 0x02{0000,,,7FFF} */
+	uint32_t	l[0x1000 / 4];			/* 0x02{0000,,,7FFF} */
+	uint64_t	d[0x1000 / 8];			/* 0x02{0000,,,7FFF} */
+	union {
+	    uint8_t	c[0x100 / 1];
+	    uint16_t	s[0x100 / 2];
+	    uint32_t	l[0x100 / 4];
+	    uint64_t	d[0x100 / 8];
+	} f[8];
+    } p_type0_cfg_dev[8];				/* 0x02{0000,,,7FFF} */
+
+    /* 0x028000-0x028FFF -- PCI Type 1 Configuration Space */
+    union {
+	uint8_t		c[0x1000 / 1];			/* 0x028000-0x029000 */
+	uint16_t	s[0x1000 / 2];			/* 0x028000-0x029000 */
+	uint32_t	l[0x1000 / 4];			/* 0x028000-0x029000 */
+	uint64_t	d[0x1000 / 8];			/* 0x028000-0x029000 */
+	union {
+	    uint8_t	c[0x100 / 1];
+	    uint16_t	s[0x100 / 2];
+	    uint32_t	l[0x100 / 4];
+	    uint64_t	d[0x100 / 8];
+	} f[8];
+    } p_type1_cfg;					/* 0x028000-0x029000 */
+
+    char		_pad_029000[0x030000-0x029000];
+
+    /* 0x030000-0x030007 -- PCI Interrupt Acknowledge Cycle */
+    union {
+	uint8_t		c[8 / 1];
+	uint16_t	s[8 / 2];
+	uint32_t	l[8 / 4];
+	uint64_t	d[8 / 8];
+    } p_pci_iack;					/* 0x030000-0x030007 */
+
+    char		_pad_030007[0x040000-0x030008];
+
+    /* 0x040000-0x030007 -- PCIX Special Cycle */
+    union {
+	uint8_t		c[8 / 1];
+	uint16_t	s[8 / 2];
+	uint32_t	l[8 / 4];
+	uint64_t	d[8 / 8];
+    } p_pcix_cycle;					/* 0x040000-0x040007 */
+};
+
+#endif                          /* _ASM_IA64_SN_PCI_PIC_H */
Index: include/asm-ia64/sn/tiocp.h
=================================--- /dev/null  (tree:d53d603c8c1a083db8df0c479b9bf296288dbc74)
+++ 609461315376faf97b95c8fded1d5df433168614/include/asm-ia64/sn/tiocp.h  (mode:100644 sha1:f07c83b2bf6ebb8e9c907c2f9948a1169554601a)
@@ -0,0 +1,256 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2003-2004 Silicon Graphics, Inc. All rights reserved.
+ */
+#ifndef _ASM_IA64_SN_PCI_TIOCP_H
+#define _ASM_IA64_SN_PCI_TIOCP_H
+
+#define TIOCP_HOST_INTR_ADDR            0x003FFFFFFFFFFFFFUL
+#define TIOCP_PCI64_CMDTYPE_MEM         (0x1ull << 60)
+
+
+/*****************************************************************************
+ *********************** TIOCP MMR structure mapping ***************************
+ *****************************************************************************/
+
+struct tiocp{
+
+    /* 0x000000-0x00FFFF -- Local Registers */
+
+    /* 0x000000-0x000057 -- (Legacy Widget Space) Configuration */
+    uint64_t		cp_id;				/* 0x000000 */
+    uint64_t		cp_stat;			/* 0x000008 */
+    uint64_t		cp_err_upper;			/* 0x000010 */
+    uint64_t		cp_err_lower;			/* 0x000018 */
+    #define cp_err cp_err_lower
+    uint64_t		cp_control;			/* 0x000020 */
+    uint64_t		cp_req_timeout;			/* 0x000028 */
+    uint64_t		cp_intr_upper;			/* 0x000030 */
+    uint64_t		cp_intr_lower;			/* 0x000038 */
+    #define cp_intr cp_intr_lower
+    uint64_t		cp_err_cmdword;			/* 0x000040 */
+    uint64_t		_pad_000048;			/* 0x000048 */
+    uint64_t		cp_tflush;			/* 0x000050 */
+
+    /* 0x000058-0x00007F -- Bridge-specific Configuration */
+    uint64_t		cp_aux_err;			/* 0x000058 */
+    uint64_t		cp_resp_upper;			/* 0x000060 */
+    uint64_t		cp_resp_lower;			/* 0x000068 */
+    #define cp_resp cp_resp_lower
+    uint64_t		cp_tst_pin_ctrl;		/* 0x000070 */
+    uint64_t		cp_addr_lkerr;			/* 0x000078 */
+
+    /* 0x000080-0x00008F -- PMU & MAP */
+    uint64_t		cp_dir_map;			/* 0x000080 */
+    uint64_t		_pad_000088;			/* 0x000088 */
+
+    /* 0x000090-0x00009F -- SSRAM */
+    uint64_t		cp_map_fault;			/* 0x000090 */
+    uint64_t		_pad_000098;			/* 0x000098 */
+
+    /* 0x0000A0-0x0000AF -- Arbitration */
+    uint64_t		cp_arb;				/* 0x0000A0 */
+    uint64_t		_pad_0000A8;			/* 0x0000A8 */
+
+    /* 0x0000B0-0x0000BF -- Number In A Can or ATE Parity Error */
+    uint64_t		cp_ate_parity_err;		/* 0x0000B0 */
+    uint64_t		_pad_0000B8;			/* 0x0000B8 */
+
+    /* 0x0000C0-0x0000FF -- PCI/GIO */
+    uint64_t		cp_bus_timeout;			/* 0x0000C0 */
+    uint64_t		cp_pci_cfg;			/* 0x0000C8 */
+    uint64_t		cp_pci_err_upper;		/* 0x0000D0 */
+    uint64_t		cp_pci_err_lower;		/* 0x0000D8 */
+    #define cp_pci_err cp_pci_err_lower
+    uint64_t		_pad_0000E0[4];			/* 0x0000{E0..F8} */
+
+    /* 0x000100-0x0001FF -- Interrupt */
+    uint64_t		cp_int_status;			/* 0x000100 */
+    uint64_t		cp_int_enable;			/* 0x000108 */
+    uint64_t		cp_int_rst_stat;		/* 0x000110 */
+    uint64_t		cp_int_mode;			/* 0x000118 */
+    uint64_t		cp_int_device;			/* 0x000120 */
+    uint64_t		cp_int_host_err;		/* 0x000128 */
+    uint64_t		cp_int_addr[8];			/* 0x0001{30,,,68} */
+    uint64_t		cp_err_int_view;		/* 0x000170 */
+    uint64_t		cp_mult_int;			/* 0x000178 */
+    uint64_t		cp_force_always[8];		/* 0x0001{80,,,B8} */
+    uint64_t		cp_force_pin[8];		/* 0x0001{C0,,,F8} */
+
+    /* 0x000200-0x000298 -- Device */
+    uint64_t		cp_device[4];			/* 0x0002{00,,,18} */
+    uint64_t		_pad_000220[4];			/* 0x0002{20,,,38} */
+    uint64_t		cp_wr_req_buf[4];		/* 0x0002{40,,,58} */
+    uint64_t		_pad_000260[4];			/* 0x0002{60,,,78} */
+    uint64_t		cp_rrb_map[2];			/* 0x0002{80,,,88} */
+    #define cp_even_resp cp_rrb_map[0]			/* 0x000280 */
+    #define cp_odd_resp  cp_rrb_map[1]			/* 0x000288 */
+    uint64_t		cp_resp_status;			/* 0x000290 */
+    uint64_t		cp_resp_clear;			/* 0x000298 */
+
+    uint64_t		_pad_0002A0[12];		/* 0x0002{A0..F8} */
+
+    /* 0x000300-0x0003F8 -- Buffer Address Match Registers */
+    struct {
+	uint64_t	upper;				/* 0x0003{00,,,F0} */
+	uint64_t	lower;				/* 0x0003{08,,,F8} */
+    } cp_buf_addr_match[16];
+
+    /* 0x000400-0x0005FF -- Performance Monitor Registers (even only) */
+    struct {
+	uint64_t	flush_w_touch;			/* 0x000{400,,,5C0} */
+	uint64_t	flush_wo_touch;			/* 0x000{408,,,5C8} */
+	uint64_t	inflight;			/* 0x000{410,,,5D0} */
+	uint64_t	prefetch;			/* 0x000{418,,,5D8} */
+	uint64_t	total_pci_retry;		/* 0x000{420,,,5E0} */
+	uint64_t	max_pci_retry;			/* 0x000{428,,,5E8} */
+	uint64_t	max_latency;			/* 0x000{430,,,5F0} */
+	uint64_t	clear_all;			/* 0x000{438,,,5F8} */
+    } cp_buf_count[8];
+
+    
+    /* 0x000600-0x0009FF -- PCI/X registers */
+    uint64_t		cp_pcix_bus_err_addr;		/* 0x000600 */
+    uint64_t		cp_pcix_bus_err_attr;		/* 0x000608 */
+    uint64_t		cp_pcix_bus_err_data;		/* 0x000610 */
+    uint64_t		cp_pcix_pio_split_addr;		/* 0x000618 */
+    uint64_t		cp_pcix_pio_split_attr;		/* 0x000620 */
+    uint64_t		cp_pcix_dma_req_err_attr;	/* 0x000628 */
+    uint64_t		cp_pcix_dma_req_err_addr;	/* 0x000630 */
+    uint64_t		cp_pcix_timeout;		/* 0x000638 */
+
+    uint64_t		_pad_000640[24];		/* 0x000{640,,,6F8} */
+
+    /* 0x000700-0x000737 -- Debug Registers */
+    uint64_t		cp_ct_debug_ctl;		/* 0x000700 */
+    uint64_t		cp_br_debug_ctl;		/* 0x000708 */
+    uint64_t		cp_mux3_debug_ctl;		/* 0x000710 */
+    uint64_t		cp_mux4_debug_ctl;		/* 0x000718 */
+    uint64_t		cp_mux5_debug_ctl;		/* 0x000720 */
+    uint64_t		cp_mux6_debug_ctl;		/* 0x000728 */
+    uint64_t		cp_mux7_debug_ctl;		/* 0x000730 */
+
+    uint64_t		_pad_000738[89];		/* 0x000{738,,,9F8} */
+
+    /* 0x000A00-0x000BFF -- PCI/X Read&Write Buffer */
+    struct {
+	uint64_t	cp_buf_addr;			/* 0x000{A00,,,AF0} */
+	uint64_t	cp_buf_attr;			/* 0X000{A08,,,AF8} */
+    } cp_pcix_read_buf_64[16];
+
+    struct {
+	uint64_t	cp_buf_addr;			/* 0x000{B00,,,BE0} */
+	uint64_t	cp_buf_attr;			/* 0x000{B08,,,BE8} */
+	uint64_t	cp_buf_valid;			/* 0x000{B10,,,BF0} */
+	uint64_t	__pad1;				/* 0x000{B18,,,BF8} */
+    } cp_pcix_write_buf_64[8];
+
+    /* End of Local Registers -- Start of Address Map space */
+
+    char		_pad_000c00[0x010000 - 0x000c00];
+
+    /* 0x010000-0x011FF8 -- Internal ATE RAM (Auto Parity Generation) */
+    uint64_t		cp_int_ate_ram[1024];		/* 0x010000-0x011FF8 */
+
+    char		_pad_012000[0x14000 - 0x012000];
+
+    /* 0x014000-0x015FF8 -- Internal ATE RAM (Manual Parity Generation) */
+    uint64_t		cp_int_ate_ram_mp[1024];	/* 0x014000-0x015FF8 */
+
+    char		_pad_016000[0x18000 - 0x016000];
+
+    /* 0x18000-0x197F8 -- TIOCP Write Request Ram */
+    uint64_t		cp_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
+    uint64_t		cp_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
+    uint64_t		cp_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
+
+    char		_pad_019800[0x1C000 - 0x019800];
+
+    /* 0x1C000-0x1EFF8 -- TIOCP Read Response Ram */
+    uint64_t		cp_rd_resp_lower[512];		/* 0x1C000 - 0x1CFF8 */
+    uint64_t		cp_rd_resp_upper[512];		/* 0x1D000 - 0x1DFF8 */
+    uint64_t		cp_rd_resp_parity[512];		/* 0x1E000 - 0x1EFF8 */
+
+    char		_pad_01F000[0x20000 - 0x01F000];
+
+    /* 0x020000-0x021FFF -- Host Device (CP) Configuration Space (not used)  */
+    char		_pad_020000[0x021000 - 0x20000];
+
+    /* 0x021000-0x027FFF -- PCI Device Configuration Spaces */
+    union {
+	uint8_t		c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
+	uint16_t	s[0x1000 / 2];			/* 0x02{0000,,,7FFF} */
+	uint32_t	l[0x1000 / 4];			/* 0x02{0000,,,7FFF} */
+	uint64_t	d[0x1000 / 8];			/* 0x02{0000,,,7FFF} */
+	union {
+	    uint8_t	c[0x100 / 1];
+	    uint16_t	s[0x100 / 2];
+	    uint32_t	l[0x100 / 4];
+	    uint64_t	d[0x100 / 8];
+	} f[8];
+    } cp_type0_cfg_dev[7];				/* 0x02{1000,,,7FFF} */
+
+    /* 0x028000-0x028FFF -- PCI Type 1 Configuration Space */
+    union {
+	uint8_t		c[0x1000 / 1];			/* 0x028000-0x029000 */
+	uint16_t	s[0x1000 / 2];			/* 0x028000-0x029000 */
+	uint32_t	l[0x1000 / 4];			/* 0x028000-0x029000 */
+	uint64_t	d[0x1000 / 8];			/* 0x028000-0x029000 */
+	union {
+	    uint8_t	c[0x100 / 1];
+	    uint16_t	s[0x100 / 2];
+	    uint32_t	l[0x100 / 4];
+	    uint64_t	d[0x100 / 8];
+	} f[8];
+    } cp_type1_cfg;					/* 0x028000-0x029000 */
+
+    char		_pad_029000[0x030000-0x029000];
+
+    /* 0x030000-0x030007 -- PCI Interrupt Acknowledge Cycle */
+    union {
+	uint8_t		c[8 / 1];
+	uint16_t	s[8 / 2];
+	uint32_t	l[8 / 4];
+	uint64_t	d[8 / 8];
+    } cp_pci_iack;					/* 0x030000-0x030007 */
+
+    char		_pad_030007[0x040000-0x030008];
+
+    /* 0x040000-0x040007 -- PCIX Special Cycle */
+    union {
+	uint8_t		c[8 / 1];
+	uint16_t	s[8 / 2];
+	uint32_t	l[8 / 4];
+	uint64_t	d[8 / 8];
+    } cp_pcix_cycle;					/* 0x040000-0x040007 */
+
+    char		_pad_040007[0x200000-0x040008];
+
+    /* 0x200000-0x7FFFFF -- PCI/GIO Device Spaces */
+    union {
+	uint8_t		c[0x100000 / 1];
+	uint16_t	s[0x100000 / 2];
+	uint32_t	l[0x100000 / 4];
+	uint64_t	d[0x100000 / 8];
+    } cp_devio_raw[6];					/* 0x200000-0x7FFFFF */
+
+    #define cp_devio(n)  cp_devio_raw[((n)<2)?(n*2):(n+2)]
+
+    char		_pad_800000[0xA00000-0x800000];
+
+    /* 0xA00000-0xBFFFFF -- PCI/GIO Device Spaces w/flush  */
+    union {
+	uint8_t		c[0x100000 / 1];
+	uint16_t	s[0x100000 / 2];
+	uint32_t	l[0x100000 / 4];
+	uint64_t	d[0x100000 / 8];
+    } cp_devio_raw_flush[6];				/* 0xA00000-0xBFFFFF */
+
+    #define cp_devio_flush(n)  cp_devio_raw_flush[((n)<2)?(n*2):(n+2)]
+
+};
+
+#endif 	/* _ASM_IA64_SN_PCI_TIOCP_H */
