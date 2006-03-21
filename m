From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 21 Mar 2006 17:44:07 +0000
Subject: [PATCH] ia64: sn_check_intr: use ia64_get_irr()
Message-Id: <200603211044.07101.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Use the recently-added ia64_get_irr() rather than duplicating the code.

I don't have hardware to test this.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: work-mm4/arch/ia64/sn/kernel/irq.c
=================================--- work-mm4.orig/arch/ia64/sn/kernel/irq.c	2006-02-22 09:55:49.000000000 -0700
+++ work-mm4/arch/ia64/sn/kernel/irq.c	2006-02-22 10:12:09.000000000 -0700
@@ -376,9 +376,6 @@
 static void sn_check_intr(int irq, struct sn_irq_info *sn_irq_info)
 {
 	u64 regval;
-	int irr_reg_num;
-	int irr_bit;
-	u64 irr_reg;
 	struct pcidev_info *pcidev_info;
 	struct pcibus_info *pcibus_info;
 
@@ -399,23 +396,7 @@
 	    pdi_pcibus_info;
 	regval = pcireg_intr_status_get(pcibus_info);
 
-	irr_reg_num = irq_to_vector(irq) / 64;
-	irr_bit = irq_to_vector(irq) % 64;
-	switch (irr_reg_num) {
-	case 0:
-		irr_reg = ia64_getreg(_IA64_REG_CR_IRR0);
-		break;
-	case 1:
-		irr_reg = ia64_getreg(_IA64_REG_CR_IRR1);
-		break;
-	case 2:
-		irr_reg = ia64_getreg(_IA64_REG_CR_IRR2);
-		break;
-	case 3:
-		irr_reg = ia64_getreg(_IA64_REG_CR_IRR3);
-		break;
-	}
-	if (!test_bit(irr_bit, &irr_reg)) {
+	if (!ia64_get_irr(irq_to_vector(irq))) {
 		if (!test_bit(irq, pda->sn_in_service_ivecs)) {
 			regval &= 0xff;
 			if (sn_irq_info->irq_int_bit & regval &
