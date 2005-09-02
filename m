From: Mark Maule <maule@sgi.com>
Date: Fri, 02 Sep 2005 18:53:04 +0000
Subject: [PATCH] altix: Add volatile qualifiers in places where it seems necessary
Message-Id: <20050902185304.18545.17065.87890@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
In-Reply-To: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Resend using accessors instead of volatile qualifiers per hch comments.  Added
a __sn_rwq_relaxed() convenience macro for doing read/modify/write ops
(e.g.  &=, |=).

Patch to apply volatile semantics when accessing MMR's in various SN files.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: volatile/arch/ia64/sn/pci/pcibr/pcibr_reg.c
=================================--- volatile.orig/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-09-02 09:13:09.993588678 -0500
+++ volatile/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-09-02 13:31:17.970957143 -0500
@@ -29,10 +29,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ptr->tio.cp_control &= ~bits;
+			__sn_rwq_relaxed(&ptr->tio.cp_control, &=, ~bits);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ptr->pic.p_wid_control &= ~bits;
+			__sn_rwq_relaxed(&ptr->pic.p_wid_control, &=, ~bits);
 			break;
 		default:
 			panic
@@ -49,10 +49,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ptr->tio.cp_control |= bits;
+			__sn_rwq_relaxed(&ptr->tio.cp_control, |=, bits);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ptr->pic.p_wid_control |= bits;
+			__sn_rwq_relaxed(&ptr->pic.p_wid_control, |=, bits);
 			break;
 		default:
 			panic
@@ -73,10 +73,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ret = ptr->tio.cp_tflush;
+			ret = __sn_readq_relaxed(&ptr->tio.cp_tflush);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ret = ptr->pic.p_wid_tflush;
+			ret = __sn_readq_relaxed(&ptr->pic.p_wid_tflush);
 			break;
 		default:
 			panic
@@ -103,10 +103,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ret = ptr->tio.cp_int_status;
+			ret = __sn_readq_relaxed(&ptr->tio.cp_int_status);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ret = ptr->pic.p_int_status;
+			ret = __sn_readq_relaxed(&ptr->pic.p_int_status);
 			break;
 		default:
 			panic
@@ -127,10 +127,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ptr->tio.cp_int_enable &= ~bits;
+			__sn_rwq_relaxed(&ptr->tio.cp_int_enable, &=, ~bits);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ptr->pic.p_int_enable &= ~bits;
+			__sn_rwq_relaxed(&ptr->pic.p_int_enable, &=, ~bits);
 			break;
 		default:
 			panic
@@ -147,10 +147,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ptr->tio.cp_int_enable |= bits;
+			__sn_rwq_relaxed(&ptr->tio.cp_int_enable, |=, bits);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ptr->pic.p_int_enable |= bits;
+			__sn_rwq_relaxed(&ptr->pic.p_int_enable, |=, bits);
 			break;
 		default:
 			panic
@@ -171,14 +171,16 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ptr->tio.cp_int_addr[int_n] &= ~TIOCP_HOST_INTR_ADDR;
-			ptr->tio.cp_int_addr[int_n] |-			    (addr & TIOCP_HOST_INTR_ADDR);
+			__sn_rwq_relaxed(&ptr->tio.cp_int_addr[int_n], &=,
+			    ~TIOCP_HOST_INTR_ADDR);
+			__sn_rwq_relaxed(&ptr->tio.cp_int_addr[int_n], |=,
+			    (addr & TIOCP_HOST_INTR_ADDR));
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ptr->pic.p_int_addr[int_n] &= ~PIC_HOST_INTR_ADDR;
-			ptr->pic.p_int_addr[int_n] |-			    (addr & PIC_HOST_INTR_ADDR);
+			__sn_rwq_relaxed(&ptr->pic.p_int_addr[int_n], &=,
+			    ~PIC_HOST_INTR_ADDR);
+			__sn_rwq_relaxed(&ptr->pic.p_int_addr[int_n], |=,
+			    (addr & PIC_HOST_INTR_ADDR));
 			break;
 		default:
 			panic
@@ -198,10 +200,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ptr->tio.cp_force_pin[int_n] = 1;
+			writeq(1, &ptr->tio.cp_force_pin[int_n]);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ptr->pic.p_force_pin[int_n] = 1;
+			writeq(1, &ptr->pic.p_force_pin[int_n]);
 			break;
 		default:
 			panic
@@ -222,10 +224,12 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ret = ptr->tio.cp_wr_req_buf[device];
+			ret +			    __sn_readq_relaxed(&ptr->tio.cp_wr_req_buf[device]);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ret = ptr->pic.p_wr_req_buf[device];
+			ret +			    __sn_readq_relaxed(&ptr->pic.p_wr_req_buf[device]);
 			break;
 		default:
 		      panic("pcireg_wrb_flush_get: unknown bridgetype bridge 0x%p", (void *)ptr);
@@ -244,10 +248,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ptr->tio.cp_int_ate_ram[ate_index] = (uint64_t) val;
+			writeq(val, &ptr->tio.cp_int_ate_ram[ate_index]);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ptr->pic.p_int_ate_ram[ate_index] = (uint64_t) val;
+			writeq(val, &ptr->pic.p_int_ate_ram[ate_index]);
 			break;
 		default:
 			panic
@@ -265,12 +269,10 @@
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
-			ret -			    (uint64_t *) & (ptr->tio.cp_int_ate_ram[ate_index]);
+			ret = &ptr->tio.cp_int_ate_ram[ate_index];
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			ret -			    (uint64_t *) & (ptr->pic.p_int_ate_ram[ate_index]);
+			ret = &ptr->pic.p_int_ate_ram[ate_index];
 			break;
 		default:
 			panic
Index: volatile/arch/ia64/sn/pci/tioca_provider.c
=================================--- volatile.orig/arch/ia64/sn/pci/tioca_provider.c	2005-09-02 09:13:09.993588678 -0500
+++ volatile/arch/ia64/sn/pci/tioca_provider.c	2005-09-02 13:32:41.618729313 -0500
@@ -37,7 +37,7 @@
 	uint64_t offset;
 	struct page *tmp;
 	struct tioca_common *tioca_common;
-	volatile struct tioca *ca_base;
+	struct tioca *ca_base;
 
 	tioca_common = tioca_kern->ca_common;
 	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;
@@ -174,27 +174,30 @@
 	 * 	DISABLE GART PREFETCHING due to hw bug tracked in SGI PV930029
 	 */
 
-	ca_base->ca_control1 |= CA_AGPDMA_OP_ENB_COMBDELAY;	/* PV895469 ? */
-	ca_base->ca_control2 &= ~(CA_GART_MEM_PARAM);
-	ca_base->ca_control2 |= (0x2ull << CA_GART_MEM_PARAM_SHFT);
+	__sn_rwq_relaxed(&ca_base->ca_control1, |=,
+			CA_AGPDMA_OP_ENB_COMBDELAY);	/* PV895469 ? */
+	__sn_rwq_relaxed(&ca_base->ca_control2, &=,
+			~(CA_GART_MEM_PARAM));
+	__sn_rwq_relaxed(&ca_base->ca_control2, |=,
+			(0x2ull << CA_GART_MEM_PARAM_SHFT));
 	tioca_kern->ca_gart_iscoherent = 1;
-	ca_base->ca_control2 &-	    ~(CA_GART_WR_PREFETCH_ENB | CA_GART_RD_PREFETCH_ENB);
+	__sn_rwq_relaxed(&ca_base->ca_control2, &=,
+	    		~(CA_GART_WR_PREFETCH_ENB | CA_GART_RD_PREFETCH_ENB));
 
 	/*
 	 * Unmask GART fetch error interrupts.  Clear residual errors first.
 	 */
 
-	ca_base->ca_int_status_alias = CA_GART_FETCH_ERR;
-	ca_base->ca_mult_error_alias = CA_GART_FETCH_ERR;
-	ca_base->ca_int_mask &= ~CA_GART_FETCH_ERR;
+	writeq(CA_GART_FETCH_ERR, &ca_base->ca_int_status_alias);
+	writeq(CA_GART_FETCH_ERR, &ca_base->ca_mult_error_alias);
+	__sn_rwq_relaxed(&ca_base->ca_int_mask, &=, ~CA_GART_FETCH_ERR);
 
 	/*
 	 * Program the aperature and gart registers in TIOCA
 	 */
 
-	ca_base->ca_gart_aperature = ap_reg;
-	ca_base->ca_gart_ptr_table = tioca_kern->ca_gart_coretalk_addr | 1;
+	writeq(ap_reg, &ca_base->ca_gart_aperature);
+	writeq(tioca_kern->ca_gart_coretalk_addr|1, &ca_base->ca_gart_ptr_table);
 
 	return 0;
 }
@@ -211,7 +214,6 @@
 tioca_fastwrite_enable(struct tioca_kernel *tioca_kern)
 {
 	int cap_ptr;
-	uint64_t ca_control1;
 	uint32_t reg;
 	struct tioca *tioca_base;
 	struct pci_dev *pdev;
@@ -256,9 +258,7 @@
 	 */
 
 	tioca_base = (struct tioca *)common->ca_common.bs_base;
-	ca_control1 = tioca_base->ca_control1;
-	ca_control1 |= CA_AGP_FW_ENABLE;
-	tioca_base->ca_control1 = ca_control1;
+	__sn_rwq_relaxed(&tioca_base->ca_control1, |=, CA_AGP_FW_ENABLE);
 }
 
 EXPORT_SYMBOL(tioca_fastwrite_enable);	/* used by agp-sgi */
@@ -345,7 +345,7 @@
 		return 0;
 	}
 
-	agp_dma_extn = ca_base->ca_agp_dma_addr_extn;
+	agp_dma_extn = __sn_readq_relaxed(&ca_base->ca_agp_dma_addr_extn);
 	if (node_upper != (agp_dma_extn >> CA_AGP_DMA_NODE_ID_SHFT)) {
 		printk(KERN_ERR "%s:  coretalk upper node (%u) "
 		       "mismatch with ca_agp_dma_addr_extn (%lu)\n",
Index: volatile/arch/ia64/sn/pci/tioce_provider.c
=================================--- volatile.orig/arch/ia64/sn/pci/tioce_provider.c	2005-09-02 09:13:09.994565143 -0500
+++ volatile/arch/ia64/sn/pci/tioce_provider.c	2005-09-02 13:34:48.219167948 -0500
@@ -227,7 +227,7 @@
 
 		ate = ATE_MAKE(addr, pagesize);
 		ate_shadow[i + j] = ate;
-		ate_reg[i + j] = ate;
+		writeq(ate, &ate_reg[i + j]);
 		addr += pagesize;
 	}
 
@@ -268,10 +268,10 @@
 	pcidev_to_tioce(pdev, &ce_mmr, &ce_kern, &port);
 
 	if (ce_kern->ce_port[port].dirmap_refcnt = 0) {
-		volatile uint64_t tmp;
+		uint64_t tmp;
 
 		ce_kern->ce_port[port].dirmap_shadow = ct_upper;
-		ce_mmr->ce_ure_dir_map[port] = ct_upper;
+		writeq(ct_upper, &ce_mmr->ce_ure_dir_map[port]);
 		tmp = ce_mmr->ce_ure_dir_map[port];
 		dma_ok = 1;
 	} else
@@ -343,7 +343,7 @@
 	if (TIOCE_D32_ADDR(bus_addr)) {
 		if (--ce_kern->ce_port[port].dirmap_refcnt = 0) {
 			ce_kern->ce_port[port].dirmap_shadow = 0;
-			ce_mmr->ce_ure_dir_map[port] = 0;
+			writeq(0, &ce_mmr->ce_ure_dir_map[port]);
 		}
 	} else {
 		struct tioce_dmamap *map;
@@ -582,18 +582,18 @@
 	 */
 
 	tioce_mmr = (struct tioce *)tioce_common->ce_pcibus.bs_base;
-	tioce_mmr->ce_ure_page_map &= ~CE_URE_PAGESIZE_MASK;
-	tioce_mmr->ce_ure_page_map |= CE_URE_256K_PAGESIZE;
+	__sn_rwq_relaxed(&tioce_mmr->ce_ure_page_map, &=, ~CE_URE_PAGESIZE_MASK);
+	__sn_rwq_relaxed(&tioce_mmr->ce_ure_page_map, |=, CE_URE_256K_PAGESIZE);
 	tioce_kern->ce_ate3240_pagesize = KB(256);
 
 	for (i = 0; i < TIOCE_NUM_M40_ATES; i++) {
 		tioce_kern->ce_ate40_shadow[i] = 0;
-		tioce_mmr->ce_ure_ate40[i] = 0;
+		writeq(0, &tioce_mmr->ce_ure_ate40[i]);
 	}
 
 	for (i = 0; i < TIOCE_NUM_M3240_ATES; i++) {
 		tioce_kern->ce_ate3240_shadow[i] = 0;
-		tioce_mmr->ce_ure_ate3240[i] = 0;
+		writeq(0, &tioce_mmr->ce_ure_ate3240[i]);
 	}
 
 	return tioce_kern;
@@ -665,7 +665,7 @@
 	default:
 		return;
 	}
-	ce_mmr->ce_adm_force_int = force_int_val;
+	writeq(force_int_val, &ce_mmr->ce_adm_force_int);
 }
 
 /**
@@ -686,6 +686,7 @@
 	struct tioce_common *ce_common;
 	struct tioce *ce_mmr;
 	int bit;
+	uint64_t vector;
 
 	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	if (!pcidev_info)
@@ -696,11 +697,11 @@
 
 	bit = sn_irq_info->irq_int_bit;
 
-	ce_mmr->ce_adm_int_mask |= (1UL << bit);
-	ce_mmr->ce_adm_int_dest[bit] -		((uint64_t)sn_irq_info->irq_irq << INTR_VECTOR_SHFT) |
-			   sn_irq_info->irq_xtalkaddr;
-	ce_mmr->ce_adm_int_mask &= ~(1UL << bit);
+	__sn_rwq_relaxed(&ce_mmr->ce_adm_int_mask, |=, (1UL << bit));
+	vector = (uint64_t)sn_irq_info->irq_irq << INTR_VECTOR_SHFT;
+	vector |= sn_irq_info->irq_xtalkaddr;
+	writeq(vector, &ce_mmr->ce_adm_int_dest[bit]);
+	__sn_rwq_relaxed(&ce_mmr->ce_adm_int_mask, &=, ~(1UL << bit));
 
 	tioce_force_interrupt(sn_irq_info);
 }
Index: volatile/include/asm-ia64/sn/io.h
=================================--- volatile.orig/include/asm-ia64/sn/io.h	2005-09-02 09:13:20.730793919 -0500
+++ volatile/include/asm-ia64/sn/io.h	2005-09-02 12:35:33.897375370 -0500
@@ -36,6 +36,13 @@
 #define __sn_readq_relaxed ___sn_readq_relaxed
 
 /*
+ * Convenience macros for read/modify/write operations using above accessors
+ */
+
+#define __sn_rwq_relaxed(addr, op, val) \
+	{uint64_t r = __sn_readq_relaxed(addr); r op (val); writeq(r, addr);}
+
+/*
  * The following routines are SN Platform specific, called when
  * a reference is made to inX/outX set macros.  SN Platform
  * inX set of macros ensures that Posted DMA writes on the
Index: volatile/include/asm-ia64/sn/tioca_provider.h
=================================--- volatile.orig/include/asm-ia64/sn/tioca_provider.h	2005-09-02 09:13:20.823558060 -0500
+++ volatile/include/asm-ia64/sn/tioca_provider.h	2005-09-02 12:44:15.174868982 -0500
@@ -182,11 +182,11 @@
 			 * touch every CL aligned GART entry.
 			 */
 
-			ca_base->ca_control2 &= ~(CA_GART_MEM_PARAM);
-			ca_base->ca_control2 |= CA_GART_FLUSH_TLB;
-			ca_base->ca_control2 |-			    (0x2ull << CA_GART_MEM_PARAM_SHFT);
-			tmp = ca_base->ca_control2;
+			__sn_rwq_relaxed(&ca_base->ca_control2, &=, ~(CA_GART_MEM_PARAM));
+			__sn_rwq_relaxed(&ca_base->ca_control2, |=, CA_GART_FLUSH_TLB);
+			__sn_rwq_relaxed(&ca_base->ca_control2, |=,
+			    (0x2ull << CA_GART_MEM_PARAM_SHFT));
+			tmp = __sn_readq(&ca_base->ca_control2);
 		}
 
 		return;
@@ -196,8 +196,8 @@
 	 * Gart in uncached mode ... need an explicit flush.
 	 */
 
-	ca_base->ca_control2 |= CA_GART_FLUSH_TLB;
-	tmp = ca_base->ca_control2;
+	__sn_rwq_relaxed(&ca_base->ca_control2, |=, CA_GART_FLUSH_TLB);
+	tmp = __sn_readq(&ca_base->ca_control2);
 }
 
 extern uint32_t	tioca_gart_found;
