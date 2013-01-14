From: Cong Ding <dinggnu@gmail.com>
Date: Mon, 14 Jan 2013 20:56:04 +0000
Subject: [PATCH v2] ia64: sn/pci/pcibr/pcibr_reg.c: remove unnecessary check null pointer
Message-Id: <20130114205604.GA7066@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1358185998-5997-1-git-send-email-dinggnu@gmail.com>
 <CAErSpo6AfLBGZpdByuUeqbD5pUc1o-YD-EyVekOgWP5m6Yv-pw@mail.gmail.com>
 <20130114184706.GA3383@gmail.com>
 <CAErSpo5zhQijO_-GfFnRt3zaWgcuC7F1uaGi+eEBoxnyczdZvg@mail.gmail.com>
In-Reply-To: <CAErSpo5zhQijO_-GfFnRt3zaWgcuC7F1uaGi+eEBoxnyczdZvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

At first, all the null pointer checks are after the pointer is dereferenced in
the same function. The followings are evidences of all the unnecessary null
pointer checks.

These functions pcireg_control_bit_clr and pcireg_control_bit_set are called
only from pcibr_bus_fixup() in pcibr_provider.c, and it's impossible for it to
pass a null pointer due to null pointer check.

The function pcireg_tflush_get is called only from ate_write() (ate_write()
is called by pcibr_ate_free()) in pcibr_ate.c, and it's impossible for it to
pass a null pointer due to pointer dereference before the calling.

The functions pcireg_intr_status_get, pcireg_intr_enable_bit_clr and
pcireg_force_intr_set get the parameter from
pcidev_info->pdi_host_pcidev_info->pdi_pcibus_info, which is impossible to be
null because the pcidev_info is from sn_irq_info->irq_pciioinfo and the
irq_pciioinfo is checked in file irq.c and msi_sn.c.

The functions pcireg_intr_enable_bit_set and pcireg_intr_addr_addr_set are
called after pcireg_intr_enable_bit_clr, so there are also impossible to be
null.

The function pcireg_wrb_flush_get get the parameter from sn_dma_flush() in
file pcibr_dma.c, where the parameter common->sfdl_pcibus_info is passed. The
common->sfdl_pcibus_info is guaranteed to be not null by function
pcibr_bus_fixup() in file pcibr_provider.c.

The functions pcireg_int_ate_set and pcireg_int_ate_addr are similar as
pcireg_int_ate_set.


Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 arch/ia64/sn/pci/pcibr/pcibr_reg.c |  271 ++++++++++++++++--------------------
 1 files changed, 120 insertions(+), 151 deletions(-)

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_reg.c b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
index 8b8bbd5..ae16be3c 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_reg.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
@@ -27,19 +27,16 @@ void pcireg_control_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			__sn_clrq_relaxed(&ptr->tio.cp_control, bits);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			__sn_clrq_relaxed(&ptr->pic.p_wid_control, bits);
-			break;
-		default:
-			panic
-			    ("pcireg_control_bit_clr: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		__sn_clrq_relaxed(&ptr->tio.cp_control, bits);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		__sn_clrq_relaxed(&ptr->pic.p_wid_control, bits);
+		break;
+	default:
+		panic("pcireg_control_bit_clr: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 }
 
@@ -47,19 +44,16 @@ void pcireg_control_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			__sn_setq_relaxed(&ptr->tio.cp_control, bits);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			__sn_setq_relaxed(&ptr->pic.p_wid_control, bits);
-			break;
-		default:
-			panic
-			    ("pcireg_control_bit_set: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		__sn_setq_relaxed(&ptr->tio.cp_control, bits);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		__sn_setq_relaxed(&ptr->pic.p_wid_control, bits);
+		break;
+	default:
+		panic("pcireg_control_bit_set: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 }
 
@@ -71,19 +65,16 @@ u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			ret = __sn_readq_relaxed(&ptr->tio.cp_tflush);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			ret = __sn_readq_relaxed(&ptr->pic.p_wid_tflush);
-			break;
-		default:
-			panic
-			    ("pcireg_tflush_get: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		ret = __sn_readq_relaxed(&ptr->tio.cp_tflush);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		ret = __sn_readq_relaxed(&ptr->pic.p_wid_tflush);
+		break;
+	default:
+		panic("pcireg_tflush_get: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 
 	/* Read of the Target Flush should always return zero */
@@ -96,24 +87,21 @@ u64 pcireg_tflush_get(struct pcibus_info *pcibus_info)
 /*
  * Interrupt Status Register Access -- Read Only		    0000_0100
  */
-u64 pcireg_intr_status_get(struct pcibus_info * pcibus_info)
+u64 pcireg_intr_status_get(struct pcibus_info *pcibus_info)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			ret = __sn_readq_relaxed(&ptr->tio.cp_int_status);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			ret = __sn_readq_relaxed(&ptr->pic.p_int_status);
-			break;
-		default:
-			panic
-			    ("pcireg_intr_status_get: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		ret = __sn_readq_relaxed(&ptr->tio.cp_int_status);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		ret = __sn_readq_relaxed(&ptr->pic.p_int_status);
+		break;
+	default:
+		panic("pcireg_intr_status_get: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 	return ret;
 }
@@ -125,19 +113,16 @@ void pcireg_intr_enable_bit_clr(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			__sn_clrq_relaxed(&ptr->tio.cp_int_enable, bits);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			__sn_clrq_relaxed(&ptr->pic.p_int_enable, bits);
-			break;
-		default:
-			panic
-			    ("pcireg_intr_enable_bit_clr: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		__sn_clrq_relaxed(&ptr->tio.cp_int_enable, bits);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		__sn_clrq_relaxed(&ptr->pic.p_int_enable, bits);
+		break;
+	default:
+		panic("pcireg_intr_enable_bit_clr: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 }
 
@@ -145,19 +130,16 @@ void pcireg_intr_enable_bit_set(struct pcibus_info *pcibus_info, u64 bits)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			__sn_setq_relaxed(&ptr->tio.cp_int_enable, bits);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			__sn_setq_relaxed(&ptr->pic.p_int_enable, bits);
-			break;
-		default:
-			panic
-			    ("pcireg_intr_enable_bit_set: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		__sn_setq_relaxed(&ptr->tio.cp_int_enable, bits);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		__sn_setq_relaxed(&ptr->pic.p_int_enable, bits);
+		break;
+	default:
+		panic("pcireg_intr_enable_bit_set: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 }
 
@@ -169,25 +151,22 @@ void pcireg_intr_addr_addr_set(struct pcibus_info *pcibus_info, int int_n,
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			__sn_clrq_relaxed(&ptr->tio.cp_int_addr[int_n],
-			    TIOCP_HOST_INTR_ADDR);
-			__sn_setq_relaxed(&ptr->tio.cp_int_addr[int_n],
-			    (addr & TIOCP_HOST_INTR_ADDR));
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			__sn_clrq_relaxed(&ptr->pic.p_int_addr[int_n],
-			    PIC_HOST_INTR_ADDR);
-			__sn_setq_relaxed(&ptr->pic.p_int_addr[int_n],
-			    (addr & PIC_HOST_INTR_ADDR));
-			break;
-		default:
-			panic
-			    ("pcireg_intr_addr_addr_get: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		__sn_clrq_relaxed(&ptr->tio.cp_int_addr[int_n],
+		    TIOCP_HOST_INTR_ADDR);
+		__sn_setq_relaxed(&ptr->tio.cp_int_addr[int_n],
+		    (addr & TIOCP_HOST_INTR_ADDR));
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		__sn_clrq_relaxed(&ptr->pic.p_int_addr[int_n],
+		    PIC_HOST_INTR_ADDR);
+		__sn_setq_relaxed(&ptr->pic.p_int_addr[int_n],
+		    (addr & PIC_HOST_INTR_ADDR));
+		break;
+	default:
+		panic("pcireg_intr_addr_addr_get: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 }
 
@@ -198,19 +177,16 @@ void pcireg_force_intr_set(struct pcibus_info *pcibus_info, int int_n)
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			writeq(1, &ptr->tio.cp_force_pin[int_n]);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			writeq(1, &ptr->pic.p_force_pin[int_n]);
-			break;
-		default:
-			panic
-			    ("pcireg_force_intr_set: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		writeq(1, &ptr->tio.cp_force_pin[int_n]);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		writeq(1, &ptr->pic.p_force_pin[int_n]);
+		break;
+	default:
+		panic("pcireg_force_intr_set: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 }
 
@@ -222,21 +198,20 @@ u64 pcireg_wrb_flush_get(struct pcibus_info *pcibus_info, int device)
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 ret = 0;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			ret -			    __sn_readq_relaxed(&ptr->tio.cp_wr_req_buf[device]);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			ret -			    __sn_readq_relaxed(&ptr->pic.p_wr_req_buf[device]);
-			break;
-		default:
-		      panic("pcireg_wrb_flush_get: unknown bridgetype bridge 0x%p", ptr);
-		}
-
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		ret +		    __sn_readq_relaxed(&ptr->tio.cp_wr_req_buf[device]);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		ret +		    __sn_readq_relaxed(&ptr->pic.p_wr_req_buf[device]);
+		break;
+	default:
+	      panic("pcireg_wrb_flush_get: unknown bridgetype bridge 0x%p",
+			      ptr);
 	}
+
 	/* Read of the Write Buffer Flush should always return zero */
 	return ret;
 }
@@ -246,19 +221,16 @@ void pcireg_int_ate_set(struct pcibus_info *pcibus_info, int ate_index,
 {
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			writeq(val, &ptr->tio.cp_int_ate_ram[ate_index]);
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			writeq(val, &ptr->pic.p_int_ate_ram[ate_index]);
-			break;
-		default:
-			panic
-			    ("pcireg_int_ate_set: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		writeq(val, &ptr->tio.cp_int_ate_ram[ate_index]);
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		writeq(val, &ptr->pic.p_int_ate_ram[ate_index]);
+		break;
+	default:
+		panic("pcireg_int_ate_set: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 }
 
@@ -267,19 +239,16 @@ u64 __iomem *pcireg_int_ate_addr(struct pcibus_info *pcibus_info, int ate_index)
 	union br_ptr __iomem *ptr = (union br_ptr __iomem *)pcibus_info->pbi_buscommon.bs_base;
 	u64 __iomem *ret = NULL;
 
-	if (pcibus_info) {
-		switch (pcibus_info->pbi_bridge_type) {
-		case PCIBR_BRIDGETYPE_TIOCP:
-			ret = &ptr->tio.cp_int_ate_ram[ate_index];
-			break;
-		case PCIBR_BRIDGETYPE_PIC:
-			ret = &ptr->pic.p_int_ate_ram[ate_index];
-			break;
-		default:
-			panic
-			    ("pcireg_int_ate_addr: unknown bridgetype bridge 0x%p",
-			     ptr);
-		}
+	switch (pcibus_info->pbi_bridge_type) {
+	case PCIBR_BRIDGETYPE_TIOCP:
+		ret = &ptr->tio.cp_int_ate_ram[ate_index];
+		break;
+	case PCIBR_BRIDGETYPE_PIC:
+		ret = &ptr->pic.p_int_ate_ram[ate_index];
+		break;
+	default:
+		panic("pcireg_int_ate_addr: unknown bridgetype bridge 0x%p",
+				ptr);
 	}
 	return ret;
 }
-- 
1.7.4.5

