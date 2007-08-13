From: Mike Habeck <habeck@sgi.com>
Date: Mon, 13 Aug 2007 22:13:08 +0000
Subject: [PATCH] SGI Altix : fix a force_interrupt bug on altix
Message-Id: <20070813221307.6811.23995.29924@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


If the interrupt has been disabled, don't call the force_interrupt provider.
Doing so can result in an infinite runaway interrupt loop.

Signed-off-by: Mike Habeck <habeck@sgi.com>

---

This patch is based off the aegl/linux-2.6.git tree.

 arch/ia64/sn/kernel/irq.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/irq.c	2007-08-13 13:26:56.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/irq.c	2007-08-13 15:28:39.102454968 -0500
@@ -398,7 +398,10 @@ sn_call_force_intr_provider(struct sn_ir
 	struct sn_pcibus_provider *pci_provider;
 
 	pci_provider = sn_pci_provider[sn_irq_info->irq_bridge_type];
-	if (pci_provider && pci_provider->force_interrupt)
+
+	/* Don't force an interrupt if the irq has been disabled */
+	if (!(irq_desc[sn_irq_info->irq_irq].status & IRQ_DISABLED) &&
+	    pci_provider && pci_provider->force_interrupt)
 		(*pci_provider->force_interrupt)(sn_irq_info);
 }
 
