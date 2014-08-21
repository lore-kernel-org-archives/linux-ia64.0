From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Thu, 21 Aug 2014 18:29:13 +0000
Subject: [PATCH 1/1] [IA64] pcibr: possible NULL pointer dereference
Message-Id: <1408645753-28982-1-git-send-email-xypron.glpk@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-kernel@vger.kernel.org, Heinrich Schuchardt <xypron.glpk@gmx.de>

A component of pcibus_info is accessed.
Afterwards a check is made if pcibus_info is NULL.

The patch changes this sequence.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 arch/ia64/sn/pci/pcibr/pcibr_reg.c | 40 +++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_reg.c b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
index 8b8bbd5..b1bd412 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_reg.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
@@ -25,9 +25,9 @@ union br_ptr {
  */
 void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_clrq_relaxed(&ptr->tio.cp_control, bits);
@@ -45,9 +45,9 @@ void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 
 void pcireg_control_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_setq_relaxed(&ptr->tio.cp_control, bits);
@@ -68,10 +68,11 @@ void pcireg_control_bit_set(struct pcibus_info *pcibus_info, u64 bits)
  */
 u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret = __sn_readq_relaxed(&ptr->tio.cp_tflush);
@@ -98,10 +99,11 @@ u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
  */
 u64 pcireg_intr_status_get(struct pcibus_info * pcibus_info)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret = __sn_readq_relaxed(&ptr->tio.cp_int_status);
@@ -123,9 +125,9 @@ u64 pcireg_intr_status_get(struct pcibus_info * pcibus_info)
  */
 void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_clrq_relaxed(&ptr->tio.cp_int_enable, bits);
@@ -143,9 +145,9 @@ void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 
 void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_setq_relaxed(&ptr->tio.cp_int_enable, bits);
@@ -167,9 +169,9 @@ void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
 			       u64 addr)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_clrq_relaxed(&ptr->tio.cp_int_addr[int_n],
@@ -196,9 +198,9 @@ void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
  */
 void pcireg_force_intr_set(struct pcibus_info *pcibus_info, int int_n)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			writeq(1, &ptr->tio.cp_force_pin[int_n]);
@@ -219,10 +221,11 @@ void pcireg_force_intr_set(struct pcibus_info *pcibus_info, int int_n)
  */
 u64 pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret @@ -244,9 +247,9 @@ u64 pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
 void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
 			u64 val)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			writeq(val, &ptr->tio.cp_int_ate_ram[ate_index]);
@@ -264,10 +267,11 @@ void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
 
 u64 __iomem *pcireg_int_ate_addr(struct pcibus_info *pcibus_info, int ate_index)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 __iomem *ret = NULL;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
+
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret = &ptr->tio.cp_int_ate_ram[ate_index];
-- 
2.1.0.rc1

