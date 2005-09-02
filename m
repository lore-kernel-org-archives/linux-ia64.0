From: Mark Maule <maule@sgi.com>
Date: Fri, 02 Sep 2005 15:36:12 +0000
Subject: [PATCH] altix: Add volatile qualifiers in places where it seems necessary
Message-Id: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add missing volatile qualifier to hardware MMR pointers in various SN files.
Cosmetic code rearranging in pcibr_reg.c to avoid line-wraps.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: volatile/arch/ia64/sn/pci/pcibr/pcibr_reg.c
=================================--- volatile.orig/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-09-02 09:13:09.993588678 -0500
+++ volatile/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-09-02 09:29:01.898113823 -0500
@@ -24,8 +24,9 @@
  */
 void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, uint64_t bits)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -44,8 +45,9 @@
 
 void pcireg_control_bit_set(struct pcibus_info *pcibus_info, uint64_t bits)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -67,9 +69,10 @@
  */
 uint64_t pcireg_tflush_get(struct pcibus_info *pcibus_info)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 	uint64_t ret = 0;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -97,9 +100,10 @@
  */
 uint64_t pcireg_intr_status_get(struct pcibus_info * pcibus_info)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 	uint64_t ret = 0;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -122,8 +126,9 @@
  */
 void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, uint64_t bits)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -142,8 +147,9 @@
 
 void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, uint64_t bits)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -166,8 +172,9 @@
 void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
 			       uint64_t addr)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -193,8 +200,9 @@
  */
 void pcireg_force_intr_set(struct pcibus_info *pcibus_info, int int_n)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -216,9 +224,10 @@
  */
 uint64_t pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 	uint64_t ret = 0;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -239,8 +248,9 @@
 void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
 			uint64_t val)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
@@ -259,9 +269,10 @@
 
 uint64_t *pcireg_int_ate_addr(struct pcibus_info *pcibus_info, int ate_index)
 {
-	union br_ptr *ptr = (union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
+	volatile union br_ptr *ptr;
 	uint64_t *ret = (uint64_t *) 0;
 
+	ptr = (volatile union br_ptr *)pcibus_info->pbi_buscommon.bs_base;
 	if (pcibus_info) {
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
Index: volatile/arch/ia64/sn/pci/tioca_provider.c
=================================--- volatile.orig/arch/ia64/sn/pci/tioca_provider.c	2005-09-02 09:13:09.993588678 -0500
+++ volatile/arch/ia64/sn/pci/tioca_provider.c	2005-09-02 09:19:32.419128175 -0500
@@ -40,7 +40,7 @@
 	volatile struct tioca *ca_base;
 
 	tioca_common = tioca_kern->ca_common;
-	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;
+	ca_base = (volatile struct tioca *)tioca_common->ca_common.bs_base;
 
 	if (list_empty(tioca_kern->ca_devices))
 		return 0;
@@ -213,7 +213,7 @@
 	int cap_ptr;
 	uint64_t ca_control1;
 	uint32_t reg;
-	struct tioca *tioca_base;
+	volatile struct tioca *tioca_base;
 	struct pci_dev *pdev;
 	struct tioca_common *common;
 
@@ -255,7 +255,7 @@
 	 * Set ca's fw to match
 	 */
 
-	tioca_base = (struct tioca *)common->ca_common.bs_base;
+	tioca_base = (volatile struct tioca *)common->ca_common.bs_base;
 	ca_control1 = tioca_base->ca_control1;
 	ca_control1 |= CA_AGP_FW_ENABLE;
 	tioca_base->ca_control1 = ca_control1;
@@ -322,7 +322,7 @@
 tioca_dma_d48(struct pci_dev *pdev, uint64_t paddr)
 {
 	struct tioca_common *tioca_common;
-	struct tioca *ca_base;
+	volatile struct tioca *ca_base;
 	uint64_t ct_addr;
 	dma_addr_t bus_addr;
 	uint32_t node_upper;
@@ -330,7 +330,7 @@
 	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(pdev);
 
 	tioca_common = (struct tioca_common *)pcidev_info->pdi_pcibus_info;
-	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;
+	ca_base = (volatile struct tioca *)tioca_common->ca_common.bs_base;
 
 	ct_addr = PHYS_TO_TIODMA(paddr);
 	if (!ct_addr)
Index: volatile/arch/ia64/sn/pci/tioce_provider.c
=================================--- volatile.orig/arch/ia64/sn/pci/tioce_provider.c	2005-09-02 09:13:09.994565143 -0500
+++ volatile/arch/ia64/sn/pci/tioce_provider.c	2005-09-02 09:20:18.725033662 -0500
@@ -154,11 +154,11 @@
 	uint64_t *ate_shadow;
 	uint64_t *ate_reg;
 	uint64_t addr;
-	struct tioce *ce_mmr;
+	volatile struct tioce *ce_mmr;
 	uint64_t bus_base;
 	struct tioce_dmamap *map;
 
-	ce_mmr = (struct tioce *)ce_kern->ce_common->ce_pcibus.bs_base;
+	ce_mmr = (volatile struct tioce *)ce_kern->ce_common->ce_pcibus.bs_base;
 
 	switch (type) {
 	case TIOCE_ATE_M32:
@@ -256,7 +256,7 @@
 {
 	int dma_ok;
 	int port;
-	struct tioce *ce_mmr;
+	volatile struct tioce *ce_mmr;
 	struct tioce_kernel *ce_kern;
 	uint64_t ct_upper;
 	uint64_t ct_lower;
@@ -327,7 +327,7 @@
 	int i;
 	int port;
 	struct tioce_kernel *ce_kern;
-	struct tioce *ce_mmr;
+	volatile struct tioce *ce_mmr;
 	unsigned long flags;
 
 	bus_addr = tioce_dma_barrier(bus_addr, 0);
@@ -551,7 +551,7 @@
 {
 	int i;
 	uint32_t tmp;
-	struct tioce *tioce_mmr;
+	volatile struct tioce *tioce_mmr;
 	struct tioce_kernel *tioce_kern;
 
 	tioce_kern = kcalloc(1, sizeof(struct tioce_kernel), GFP_KERNEL);
@@ -581,7 +581,7 @@
 	 * the ate's.
 	 */
 
-	tioce_mmr = (struct tioce *)tioce_common->ce_pcibus.bs_base;
+	tioce_mmr = (volatile struct tioce *)tioce_common->ce_pcibus.bs_base;
 	tioce_mmr->ce_ure_page_map &= ~CE_URE_PAGESIZE_MASK;
 	tioce_mmr->ce_ure_page_map |= CE_URE_256K_PAGESIZE;
 	tioce_kern->ce_ate3240_pagesize = KB(256);
@@ -613,7 +613,7 @@
 {
 	struct pcidev_info *pcidev_info;
 	struct tioce_common *ce_common;
-	struct tioce *ce_mmr;
+	volatile struct tioce *ce_mmr;
 	uint64_t force_int_val;
 
 	if (!sn_irq_info->irq_bridge)
@@ -627,7 +627,7 @@
 		return;
 
 	ce_common = (struct tioce_common *)pcidev_info->pdi_pcibus_info;
-	ce_mmr = (struct tioce *)ce_common->ce_pcibus.bs_base;
+	ce_mmr = (volatile struct tioce *)ce_common->ce_pcibus.bs_base;
 
 	/*
 	 * irq_int_bit is originally set up by prom, and holds the interrupt
@@ -684,7 +684,7 @@
 {
 	struct pcidev_info *pcidev_info;
 	struct tioce_common *ce_common;
-	struct tioce *ce_mmr;
+	volatile struct tioce *ce_mmr;
 	int bit;
 
 	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
@@ -692,7 +692,7 @@
 		return;
 
 	ce_common = (struct tioce_common *)pcidev_info->pdi_pcibus_info;
-	ce_mmr = (struct tioce *)ce_common->ce_pcibus.bs_base;
+	ce_mmr = (volatile struct tioce *)ce_common->ce_pcibus.bs_base;
 
 	bit = sn_irq_info->irq_int_bit;
 
