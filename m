From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 29 Jul 2004 16:33:15 +0000
Subject: [PATCH] fix IRQ types
Message-Id: <200407291033.15577.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix IRQ type in platform irq_to_vector functions.  Should be
"unsigned int", but some places were "u8".

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/sn/kernel/irq.c 1.24 vs edited ==--- 1.24/arch/ia64/sn/kernel/irq.c	2004-06-30 07:31:06 -06:00
+++ edited/arch/ia64/sn/kernel/irq.c	2004-07-29 10:17:28 -06:00
@@ -188,7 +188,7 @@
 }
 
 u8
-sn_irq_to_vector(u8 irq)
+sn_irq_to_vector(unsigned int irq)
 {
 	return(irq);
 }
=== include/asm-ia64/machvec.h 1.25 vs edited ==--- 1.25/include/asm-ia64/machvec.h	2004-07-10 18:14:00 -06:00
+++ edited/include/asm-ia64/machvec.h	2004-07-29 10:20:36 -06:00
@@ -29,8 +29,8 @@
 typedef void ia64_mv_global_tlb_purge_t (unsigned long, unsigned long, unsigned long);
 typedef void ia64_mv_tlb_migrate_finish_t (struct mm_struct *);
 typedef struct irq_desc *ia64_mv_irq_desc (unsigned int);
-typedef u8 ia64_mv_irq_to_vector (u8);
-typedef unsigned int ia64_mv_local_vector_to_irq (u8 vector);
+typedef u8 ia64_mv_irq_to_vector (unsigned int);
+typedef unsigned int ia64_mv_local_vector_to_irq (u8);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
