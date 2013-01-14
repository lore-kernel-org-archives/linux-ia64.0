From: Cong Ding <dinggnu@gmail.com>
Date: Mon, 14 Jan 2013 17:53:12 +0000
Subject: [PATCH] ia64: sn/pci/pcibr/pcibr_reg.c: check null pointer dereference
Message-Id: <1358185998-5997-1-git-send-email-dinggnu@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Cong Ding <dinggnu@gmail.com>

we should ensure the pointer is not null before the first use, rather than
after it.

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 arch/ia64/sn/pci/pcibr/pcibr_reg.c |   29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_reg.c b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
index 8b8bbd5..b33ee60 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_reg.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
@@ -25,9 +25,8 @@ union br_ptr {
  */
 void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_clrq_relaxed(&ptr->tio.cp_control, bits);
@@ -45,9 +44,8 @@ void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 
 void pcireg_control_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_setq_relaxed(&ptr->tio.cp_control, bits);
@@ -68,10 +66,10 @@ void pcireg_control_bit_set(struct pcibus_info *pcibus_info, u64 bits)
  */
 u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret = __sn_readq_relaxed(&ptr->tio.cp_tflush);
@@ -98,10 +96,10 @@ u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
  */
 u64 pcireg_intr_status_get(struct pcibus_info * pcibus_info)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret = __sn_readq_relaxed(&ptr->tio.cp_int_status);
@@ -123,9 +121,8 @@ u64 pcireg_intr_status_get(struct pcibus_info * pcibus_info)
  */
 void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_clrq_relaxed(&ptr->tio.cp_int_enable, bits);
@@ -143,9 +140,8 @@ void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 
 void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_setq_relaxed(&ptr->tio.cp_int_enable, bits);
@@ -167,9 +163,8 @@ void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
 			       u64 addr)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			__sn_clrq_relaxed(&ptr->tio.cp_int_addr[int_n],
@@ -196,9 +191,8 @@ void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
  */
 void pcireg_force_intr_set(struct pcibus_info *pcibus_info, int int_n)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			writeq(1, &ptr->tio.cp_force_pin[int_n]);
@@ -219,10 +213,10 @@ void pcireg_force_intr_set(struct pcibus_info *pcibus_info, int int_n)
  */
 u64 pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret @@ -244,9 +238,8 @@ u64 pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
 void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
 			u64 val)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
-
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			writeq(val, &ptr->tio.cp_int_ate_ram[ate_index]);
@@ -264,10 +257,10 @@ void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
 
 u64 __iomem *pcireg_int_ate_addr(struct pcibus_info *pcibus_info, int ate_index)
 {
-	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 __iomem *ret = NULL;
 
 	if (pcibus_info) {
+		union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 		switch (pcibus_info->pbi_bridge_type) {
 		case PCIBR_BRIDGETYPE_TIOCP:
 			ret = &ptr->tio.cp_int_ate_ram[ate_index];
-- 
1.7.9.5

