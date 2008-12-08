From: John Keller <jpk@sgi.com>
Date: Mon, 08 Dec 2008 17:44:11 +0000
Subject: [PATCH] ia64: SN: prevent IRQ retargetting in request_irq()
Message-Id: <20081208174411.119278.58670.83945@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: tglx@linutronix.de, mingo@elte.hu, yinghai@kernel.org, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

With the introduction of the generic affinity autoselector,
irq_select_affinity(), IRQs are now being retargetted,
using a default mask, via the request_irq() path.
This results in all IRQs targetted at CPU 0.

SN Altix assigns affinity in the SN PROM, and does not
expect that to be changed as part of request_irq().

Set the IRQ_AFFINITY_SET flag to prevent
request_irq() from resetting affinity.


Signed-off-by: John Keller <jpk@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/irq.c	2008-12-03 14:19:41.000000000 -0600
+++ linux-2.6/arch/ia64/sn/kernel/irq.c	2008-12-08 11:03:19.116963490 -0600
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2008 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/irq.h>
@@ -375,6 +375,7 @@ void sn_irq_fixup(struct pci_dev *pci_de
 	int cpu = nasid_slice_to_cpuid(nasid, slice);
 #ifdef CONFIG_SMP
 	int cpuphys;
+	irq_desc_t *desc;
 #endif
 
 	pci_dev_get(pci_dev);
@@ -391,6 +392,12 @@ void sn_irq_fixup(struct pci_dev *pci_de
 #ifdef CONFIG_SMP
 	cpuphys = cpu_physical_id(cpu);
 	set_irq_affinity_info(sn_irq_info->irq_irq, cpuphys, 0);
+	desc = irq_to_desc(sn_irq_info->irq_irq);
+	/*
+	 * Affinity was set by the PROM, prevent it from
+	 * being reset by the request_irq() path.
+	 */
+	desc->status |= IRQ_AFFINITY_SET;
 #endif
 }
 
