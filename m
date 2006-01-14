From: Prarit Bhargava <prarit@sgi.com>
Date: Sat, 14 Jan 2006 23:17:40 +0000
Subject: [PATCH 3/6 ]: include/asm-ia64/sn/pic.h [u]intX_t cleanup
Message-Id: <20060114231652.12238.11651.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In include/asm-ia64/sn/pic.h

Replace uintX_t declarations with uX declarations.
Replace intX_t declarations with sX declarations.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>
---
commit 0104a6b84640972e665519f4184b5aa67de20cff
tree f3d109cfcea51b76109772c70a1b12e7c44426a2
parent 388e2e7769a5e7d4e2cfe3f90dbf33568ff78170
author Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:58:19 -0500
committer Prarit Bhargava <prarit@sgi.com> Sat, 14 Jan 2006 18:58:19 -0500

 include/asm-ia64/sn/pic.h |  204 +++++++++++++++++++++++----------------------
 1 files changed, 102 insertions(+), 102 deletions(-)

diff --git a/include/asm-ia64/sn/pic.h b/include/asm-ia64/sn/pic.h
--- a/include/asm-ia64/sn/pic.h
+++ b/include/asm-ia64/sn/pic.h
@@ -74,120 +74,120 @@ struct pic {
     /* 0x000000-0x00FFFF -- Local Registers */
 
     /* 0x000000-0x000057 -- Standard Widget Configuration */
-    uint64_t		p_wid_id;			/* 0x000000 */
-    uint64_t		p_wid_stat;			/* 0x000008 */
-    uint64_t		p_wid_err_upper;		/* 0x000010 */
-    uint64_t		p_wid_err_lower;		/* 0x000018 */
+    u64		p_wid_id;			/* 0x000000 */
+    u64		p_wid_stat;			/* 0x000008 */
+    u64		p_wid_err_upper;		/* 0x000010 */
+    u64		p_wid_err_lower;		/* 0x000018 */
     #define p_wid_err p_wid_err_lower
-    uint64_t		p_wid_control;			/* 0x000020 */
-    uint64_t		p_wid_req_timeout;		/* 0x000028 */
-    uint64_t		p_wid_int_upper;		/* 0x000030 */
-    uint64_t		p_wid_int_lower;		/* 0x000038 */
+    u64		p_wid_control;			/* 0x000020 */
+    u64		p_wid_req_timeout;		/* 0x000028 */
+    u64		p_wid_int_upper;		/* 0x000030 */
+    u64		p_wid_int_lower;		/* 0x000038 */
     #define p_wid_int p_wid_int_lower
-    uint64_t		p_wid_err_cmdword;		/* 0x000040 */
-    uint64_t		p_wid_llp;			/* 0x000048 */
-    uint64_t		p_wid_tflush;			/* 0x000050 */
+    u64		p_wid_err_cmdword;		/* 0x000040 */
+    u64		p_wid_llp;			/* 0x000048 */
+    u64		p_wid_tflush;			/* 0x000050 */
 
     /* 0x000058-0x00007F -- Bridge-specific Widget Configuration */
-    uint64_t		p_wid_aux_err;			/* 0x000058 */
-    uint64_t		p_wid_resp_upper;		/* 0x000060 */
-    uint64_t		p_wid_resp_lower;		/* 0x000068 */
+    u64		p_wid_aux_err;			/* 0x000058 */
+    u64		p_wid_resp_upper;		/* 0x000060 */
+    u64		p_wid_resp_lower;		/* 0x000068 */
     #define p_wid_resp p_wid_resp_lower
-    uint64_t		p_wid_tst_pin_ctrl;		/* 0x000070 */
-    uint64_t		p_wid_addr_lkerr;		/* 0x000078 */
+    u64		p_wid_tst_pin_ctrl;		/* 0x000070 */
+    u64		p_wid_addr_lkerr;		/* 0x000078 */
 
     /* 0x000080-0x00008F -- PMU & MAP */
-    uint64_t		p_dir_map;			/* 0x000080 */
-    uint64_t		_pad_000088;			/* 0x000088 */
+    u64		p_dir_map;			/* 0x000080 */
+    u64		_pad_000088;			/* 0x000088 */
 
     /* 0x000090-0x00009F -- SSRAM */
-    uint64_t		p_map_fault;			/* 0x000090 */
-    uint64_t		_pad_000098;			/* 0x000098 */
+    u64		p_map_fault;			/* 0x000090 */
+    u64		_pad_000098;			/* 0x000098 */
 
     /* 0x0000A0-0x0000AF -- Arbitration */
-    uint64_t		p_arb;				/* 0x0000A0 */
-    uint64_t		_pad_0000A8;			/* 0x0000A8 */
+    u64		p_arb;				/* 0x0000A0 */
+    u64		_pad_0000A8;			/* 0x0000A8 */
 
     /* 0x0000B0-0x0000BF -- Number In A Can or ATE Parity Error */
-    uint64_t		p_ate_parity_err;		/* 0x0000B0 */
-    uint64_t		_pad_0000B8;			/* 0x0000B8 */
+    u64		p_ate_parity_err;		/* 0x0000B0 */
+    u64		_pad_0000B8;			/* 0x0000B8 */
 
     /* 0x0000C0-0x0000FF -- PCI/GIO */
-    uint64_t		p_bus_timeout;			/* 0x0000C0 */
-    uint64_t		p_pci_cfg;			/* 0x0000C8 */
-    uint64_t		p_pci_err_upper;		/* 0x0000D0 */
-    uint64_t		p_pci_err_lower;		/* 0x0000D8 */
+    u64		p_bus_timeout;			/* 0x0000C0 */
+    u64		p_pci_cfg;			/* 0x0000C8 */
+    u64		p_pci_err_upper;		/* 0x0000D0 */
+    u64		p_pci_err_lower;		/* 0x0000D8 */
     #define p_pci_err p_pci_err_lower
-    uint64_t		_pad_0000E0[4];			/* 0x0000{E0..F8} */
+    u64		_pad_0000E0[4];			/* 0x0000{E0..F8} */
 
     /* 0x000100-0x0001FF -- Interrupt */
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
+    u64		p_int_status;			/* 0x000100 */
+    u64		p_int_enable;			/* 0x000108 */
+    u64		p_int_rst_stat;			/* 0x000110 */
+    u64		p_int_mode;			/* 0x000118 */
+    u64		p_int_device;			/* 0x000120 */
+    u64		p_int_host_err;			/* 0x000128 */
+    u64		p_int_addr[8];			/* 0x0001{30,,,68} */
+    u64		p_err_int_view;			/* 0x000170 */
+    u64		p_mult_int;			/* 0x000178 */
+    u64		p_force_always[8];		/* 0x0001{80,,,B8} */
+    u64		p_force_pin[8];			/* 0x0001{C0,,,F8} */
 
     /* 0x000200-0x000298 -- Device */
-    uint64_t		p_device[4];			/* 0x0002{00,,,18} */
-    uint64_t		_pad_000220[4];			/* 0x0002{20,,,38} */
-    uint64_t		p_wr_req_buf[4];		/* 0x0002{40,,,58} */
-    uint64_t		_pad_000260[4];			/* 0x0002{60,,,78} */
-    uint64_t		p_rrb_map[2];			/* 0x0002{80,,,88} */
+    u64		p_device[4];			/* 0x0002{00,,,18} */
+    u64		_pad_000220[4];			/* 0x0002{20,,,38} */
+    u64		p_wr_req_buf[4];		/* 0x0002{40,,,58} */
+    u64		_pad_000260[4];			/* 0x0002{60,,,78} */
+    u64		p_rrb_map[2];			/* 0x0002{80,,,88} */
     #define p_even_resp p_rrb_map[0]			/* 0x000280 */
     #define p_odd_resp  p_rrb_map[1]			/* 0x000288 */
-    uint64_t		p_resp_status;			/* 0x000290 */
-    uint64_t		p_resp_clear;			/* 0x000298 */
+    u64		p_resp_status;			/* 0x000290 */
+    u64		p_resp_clear;			/* 0x000298 */
 
-    uint64_t		_pad_0002A0[12];		/* 0x0002{A0..F8} */
+    u64		_pad_0002A0[12];		/* 0x0002{A0..F8} */
 
     /* 0x000300-0x0003F8 -- Buffer Address Match Registers */
     struct {
-	uint64_t	upper;				/* 0x0003{00,,,F0} */
-	uint64_t	lower;				/* 0x0003{08,,,F8} */
+	u64	upper;				/* 0x0003{00,,,F0} */
+	u64	lower;				/* 0x0003{08,,,F8} */
     } p_buf_addr_match[16];
 
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
     } p_buf_count[8];
 
 
     /* 0x000600-0x0009FF -- PCI/X registers */
-    uint64_t		p_pcix_bus_err_addr;		/* 0x000600 */
-    uint64_t		p_pcix_bus_err_attr;		/* 0x000608 */
-    uint64_t		p_pcix_bus_err_data;		/* 0x000610 */
-    uint64_t		p_pcix_pio_split_addr;		/* 0x000618 */
-    uint64_t		p_pcix_pio_split_attr;		/* 0x000620 */
-    uint64_t		p_pcix_dma_req_err_attr;	/* 0x000628 */
-    uint64_t		p_pcix_dma_req_err_addr;	/* 0x000630 */
-    uint64_t		p_pcix_timeout;			/* 0x000638 */
+    u64		p_pcix_bus_err_addr;		/* 0x000600 */
+    u64		p_pcix_bus_err_attr;		/* 0x000608 */
+    u64		p_pcix_bus_err_data;		/* 0x000610 */
+    u64		p_pcix_pio_split_addr;		/* 0x000618 */
+    u64		p_pcix_pio_split_attr;		/* 0x000620 */
+    u64		p_pcix_dma_req_err_attr;	/* 0x000628 */
+    u64		p_pcix_dma_req_err_addr;	/* 0x000630 */
+    u64		p_pcix_timeout;			/* 0x000638 */
 
-    uint64_t		_pad_000640[120];		/* 0x000{640,,,9F8} */
+    u64		_pad_000640[120];		/* 0x000{640,,,9F8} */
 
     /* 0x000A00-0x000BFF -- PCI/X Read&Write Buffer */
     struct {
-	uint64_t	p_buf_addr;			/* 0x000{A00,,,AF0} */
-	uint64_t	p_buf_attr;			/* 0X000{A08,,,AF8} */
+	u64	p_buf_addr;			/* 0x000{A00,,,AF0} */
+	u64	p_buf_attr;			/* 0X000{A08,,,AF8} */
     } p_pcix_read_buf_64[16];
 
     struct {
-	uint64_t	p_buf_addr;			/* 0x000{B00,,,BE0} */
-	uint64_t	p_buf_attr;			/* 0x000{B08,,,BE8} */
-	uint64_t	p_buf_valid;			/* 0x000{B10,,,BF0} */
-	uint64_t	__pad1;				/* 0x000{B18,,,BF8} */
+	u64	p_buf_addr;			/* 0x000{B00,,,BE0} */
+	u64	p_buf_attr;			/* 0x000{B08,,,BE8} */
+	u64	p_buf_valid;			/* 0x000{B10,,,BF0} */
+	u64	__pad1;				/* 0x000{B18,,,BF8} */
     } p_pcix_write_buf_64[8];
 
     /* End of Local Registers -- Start of Address Map space */
@@ -195,45 +195,45 @@ struct pic {
     char		_pad_000c00[0x010000 - 0x000c00];
 
     /* 0x010000-0x011fff -- Internal ATE RAM (Auto Parity Generation) */
-    uint64_t		p_int_ate_ram[1024];		/* 0x010000-0x011fff */
+    u64		p_int_ate_ram[1024];		/* 0x010000-0x011fff */
 
     /* 0x012000-0x013fff -- Internal ATE RAM (Manual Parity Generation) */
-    uint64_t		p_int_ate_ram_mp[1024];		/* 0x012000-0x013fff */
+    u64		p_int_ate_ram_mp[1024];		/* 0x012000-0x013fff */
 
     char		_pad_014000[0x18000 - 0x014000];
 
     /* 0x18000-0x197F8 -- PIC Write Request Ram */
-    uint64_t		p_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
-    uint64_t		p_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
-    uint64_t		p_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
+    u64		p_wr_req_lower[256];		/* 0x18000 - 0x187F8 */
+    u64		p_wr_req_upper[256];		/* 0x18800 - 0x18FF8 */
+    u64		p_wr_req_parity[256];		/* 0x19000 - 0x197F8 */
 
     char		_pad_019800[0x20000 - 0x019800];
 
     /* 0x020000-0x027FFF -- PCI Device Configuration Spaces */
     union {
-	uint8_t		c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
-	uint16_t	s[0x1000 / 2];			/* 0x02{0000,,,7FFF} */
-	uint32_t	l[0x1000 / 4];			/* 0x02{0000,,,7FFF} */
-	uint64_t	d[0x1000 / 8];			/* 0x02{0000,,,7FFF} */
+	u8		c[0x1000 / 1];			/* 0x02{0000,,,7FFF} */
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
     } p_type0_cfg_dev[8];				/* 0x02{0000,,,7FFF} */
 
     /* 0x028000-0x028FFF -- PCI Type 1 Configuration Space */
     union {
-	uint8_t		c[0x1000 / 1];			/* 0x028000-0x029000 */
-	uint16_t	s[0x1000 / 2];			/* 0x028000-0x029000 */
-	uint32_t	l[0x1000 / 4];			/* 0x028000-0x029000 */
-	uint64_t	d[0x1000 / 8];			/* 0x028000-0x029000 */
+	u8		c[0x1000 / 1];			/* 0x028000-0x029000 */
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
     } p_type1_cfg;					/* 0x028000-0x029000 */
 
@@ -241,20 +241,20 @@ struct pic {
 
     /* 0x030000-0x030007 -- PCI Interrupt Acknowledge Cycle */
     union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
+	u8		c[8 / 1];
+	u16	s[8 / 2];
+	u32	l[8 / 4];
+	u64	d[8 / 8];
     } p_pci_iack;					/* 0x030000-0x030007 */
 
     char		_pad_030007[0x040000-0x030008];
 
     /* 0x040000-0x030007 -- PCIX Special Cycle */
     union {
-	uint8_t		c[8 / 1];
-	uint16_t	s[8 / 2];
-	uint32_t	l[8 / 4];
-	uint64_t	d[8 / 8];
+	u8		c[8 / 1];
+	u16	s[8 / 2];
+	u32	l[8 / 4];
+	u64	d[8 / 8];
     } p_pcix_cycle;					/* 0x040000-0x040007 */
 };
 
