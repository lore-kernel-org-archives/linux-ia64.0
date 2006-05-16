From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 16 May 2006 23:29:00 +0000
Subject: [patch] fix broken irq affinity
Message-Id: <4t153d$13msv4@azsmga001.ch.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It's been broken for a while ...

When CONFIG_PCI_MSI is set, move_irq() is an empty function, causing
grief when sys admin tries to bind interrupt to CPU.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- ./arch/ia64/kernel/iosapic.c.orig	2006-05-16 17:06:12.000000000 -0700
+++ ./arch/ia64/kernel/iosapic.c	2006-05-16 17:06:36.000000000 -0700
@@ -385,7 +385,7 @@ iosapic_end_level_irq (unsigned int irq)
 	ia64_vector vec = irq_to_vector(irq);
 	struct iosapic_rte_info *rte;
 
-	move_irq(irq);
+	move_native_irq(irq);
 	list_for_each_entry(rte, &iosapic_intr_info[vec].rtes, rte_list)
 		iosapic_eoi(rte->addr, vec);
 }
@@ -427,7 +427,7 @@ iosapic_ack_edge_irq (unsigned int irq)
 {
 	irq_desc_t *idesc = irq_descp(irq);
 
-	move_irq(irq);
+	move_native_irq(irq);
 	/*
 	 * Once we have recorded IRQ_PENDING already, we can mask the
 	 * interrupt for real. This prevents IRQ storms from unhandled


