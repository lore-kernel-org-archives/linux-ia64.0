From: Mark Maule <maule@sgi.com>
Date: Mon, 07 Nov 2005 21:48:50 +0000
Subject: [PATCH] altix: misc pci interrupt related fixes
Message-Id: <20051107214913.25462.11449.96886@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a couple of altix interrupt related bugs.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: linux-2.6-test/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- linux-2.6-test.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-09-02 08:55:17.155755290 -0500
+++ linux-2.6-test/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-11-07 15:30:56.876481613 -0600
@@ -212,13 +212,13 @@
 		    pdi_pcibus_info;
 
 		/* Disable the device's IRQ   */
-		pcireg_intr_enable_bit_clr(pcibus_info, bit);
+		pcireg_intr_enable_bit_clr(pcibus_info, (1 << bit));
 
 		/* Change the device's IRQ    */
 		pcireg_intr_addr_addr_set(pcibus_info, bit, xtalk_addr);
 
 		/* Re-enable the device's IRQ */
-		pcireg_intr_enable_bit_set(pcibus_info, bit);
+		pcireg_intr_enable_bit_set(pcibus_info, (1 << bit));
 
 		pcibr_force_interrupt(sn_irq_info);
 	}
Index: linux-2.6-test/arch/ia64/sn/pci/pcibr/pcibr_reg.c
=================================--- linux-2.6-test.orig/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-09-23 09:43:53.423587903 -0500
+++ linux-2.6-test/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-11-07 15:30:56.885269799 -0600
@@ -131,7 +131,7 @@
 			__sn_clrq_relaxed(&ptr->tio.cp_int_enable, bits);
 			break;
 		case PCIBR_BRIDGETYPE_PIC:
-			__sn_clrq_relaxed(&ptr->pic.p_int_enable, ~bits);
+			__sn_clrq_relaxed(&ptr->pic.p_int_enable, bits);
 			break;
 		default:
 			panic
