From: Pat Gefre <pfg@sgi.com>
Date: Wed, 28 Apr 2004 21:24:38 +0000
Subject: [2.6 PATCH] Altix
Message-Id: <200404282124.i3SLOcZu194775@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

Here's a smallish Altix patch:
   Move HW interrupt register init. to the proper place
   and don't force an interrupt if the IRQ is disabled
   or in progress.

-- Pat

Patrick Gefre
Silicon Graphics, Inc.                     (E-Mail)  pfg@sgi.com
2750 Blue Water Rd                         (Voice)   (651) 683-3127
Eagan, MN 55121-1400                       (FAX)     (651) 683-3054


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/04/28 16:17:02-05:00 pfg@sgi.com 
#   Move HW interrupt register init. to the proper place
#   and don't force an interrupt if the IRQ is disabled
#   or in progress.
# 
# arch/ia64/sn/kernel/irq.c
#   2004/04/28 16:12:44-05:00 pfg@sgi.com +5 -1
# 
# arch/ia64/sn/io/machvec/pci_bus_cvlink.c
#   2004/04/28 16:12:44-05:00 pfg@sgi.com +0 -5
# 
# arch/ia64/sn/io/io.c
#   2004/04/28 16:12:44-05:00 pfg@sgi.com +4 -0
# 
diff -Nru a/arch/ia64/sn/io/io.c b/arch/ia64/sn/io/io.c
--- a/arch/ia64/sn/io/io.c	Wed Apr 28 16:20:53 2004
+++ b/arch/ia64/sn/io/io.c	Wed Apr 28 16:20:53 2004
@@ -529,7 +529,11 @@
 void
 hub_provider_startup(vertex_hdl_t hubv)
 {
+	hubinfo_t       hubinfo;
+
+	hubinfo_get(hubv, &hubinfo);
 	hub_pio_init(hubv);
+	intr_init_vecblk(nasid_to_cnodeid(hubinfo->h_nasid));
 }
 
 /*
diff -Nru a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c
--- a/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Wed Apr 28 16:20:53 2004
+++ b/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Wed Apr 28 16:20:53 2004
@@ -813,11 +813,6 @@
 	 */
 	sgi_master_io_infr_init();
 
-	for (cnode = 0; cnode < numnodes; cnode++) {
-		extern void intr_init_vecblk(cnodeid_t);
-		intr_init_vecblk(cnode);
-	}
-
 	sn_init_cpei_timer();
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c	Wed Apr 28 16:20:53 2004
+++ b/arch/ia64/sn/kernel/irq.c	Wed Apr 28 16:20:53 2004
@@ -40,6 +40,7 @@
 static void force_interrupt(int irq);
 extern void pcibr_force_interrupt(pcibr_intr_t intr);
 extern int sn_force_interrupt_flag;
+struct irq_desc * sn_irq_desc(unsigned int irq);
 
 struct sn_intr_list_t {
 	struct sn_intr_list_t *next;
@@ -101,6 +102,8 @@
 	int nasid;
 	int ivec;
 	unsigned long event_occurred;
+	irq_desc_t *desc = sn_irq_desc(irq);
+	unsigned int status = desc->status;
 
 	ivec = irq & 0xff;
 	if (ivec = SGI_UART_VECTOR) {
@@ -115,7 +118,8 @@
 	}
 	__clear_bit(ivec, (volatile void *)pda->sn_in_service_ivecs);
 	if (sn_force_interrupt_flag)
-		force_interrupt(irq);
+		if (!(status & (IRQ_DISABLED | IRQ_INPROGRESS)))
+			force_interrupt(irq);
 }
 
 static void
