From: Jes Sorensen <jes@sgi.com>
Date: Thu, 02 Feb 2006 10:15:51 +0000
Subject: [patch] sn2 housekeeping
Message-Id: <yq0wtgenk14.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

A bit of SN2 housekeeping, no change in code functionality.

Cheers,
Jes

Maintenance patch: 
 - Add missing __init calls
 - Do not zero initialize global variables
 - No need to typecast function call returns to void
 - Some formatting

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 arch/ia64/sn/kernel/io_init.c   |    2 +-
 arch/ia64/sn/kernel/irq.c       |   19 ++++++++-----------
 arch/ia64/sn/kernel/klconflib.c |   29 ++++++++++++++---------------
 arch/ia64/sn/kernel/setup.c     |   19 ++++++++++++-------
 4 files changed, 35 insertions(+), 34 deletions(-)

Index: linux-2.6/arch/ia64/sn/kernel/io_init.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/io_init.c
+++ linux-2.6/arch/ia64/sn/kernel/io_init.c
@@ -208,7 +208,7 @@
  * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for
  *	each node in the system.
  */
-static void sn_fixup_ionodes(void)
+static void __init sn_fixup_ionodes(void)
 {
 	struct sn_flush_device_kernel *sn_flush_device_kernel;
 	struct sn_flush_device_kernel *dev_entry;
Index: linux-2.6/arch/ia64/sn/kernel/irq.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/irq.c
+++ linux-2.6/arch/ia64/sn/kernel/irq.c
@@ -5,11 +5,12 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/irq.h>
 #include <linux/spinlock.h>
+#include <linux/init.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/arch.h>
 #include <asm/sn/intr.h>
@@ -76,14 +77,12 @@
 
 static void sn_ack_irq(unsigned int irq)
 {
-	u64 event_occurred, mask = 0;
+	u64 event_occurred, mask;
 
 	irq = irq & 0xff;
-	event_occurred -	    HUB_L((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED));
+	event_occurred = HUB_L((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED));
 	mask = event_occurred & SH_ALL_INT_MASK;
-	HUB_S((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS),
-	      mask);
+	HUB_S((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS), mask);
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
 
 	move_irq(irq);
@@ -219,9 +218,8 @@
 		pdacpu(cpu)->sn_last_irq = irq;
 	}
 
-	if (pdacpu(cpu)->sn_first_irq = 0 || pdacpu(cpu)->sn_first_irq > irq) {
+	if (pdacpu(cpu)->sn_first_irq = 0 || pdacpu(cpu)->sn_first_irq > irq)
 		pdacpu(cpu)->sn_first_irq = irq;
-	}
 }
 
 static void unregister_intr_pda(struct sn_irq_info *sn_irq_info)
@@ -289,7 +287,7 @@
 	list_add_rcu(&sn_irq_info->list, sn_irq_lh[sn_irq_info->irq_irq]);
 	spin_unlock(&sn_irq_info_lock);
 
-	(void)register_intr_pda(sn_irq_info);
+	register_intr_pda(sn_irq_info);
 }
 
 void sn_irq_unfixup(struct pci_dev *pci_dev)
@@ -419,7 +417,7 @@
 	rcu_read_unlock();
 }
 
-void sn_irq_lh_init(void)
+void __init sn_irq_lh_init(void)
 {
 	int i;
 
@@ -434,5 +432,4 @@
 
 		INIT_LIST_HEAD(sn_irq_lh[i]);
 	}
-
 }
Index: linux-2.6/arch/ia64/sn/kernel/klconflib.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/klconflib.c
+++ linux-2.6/arch/ia64/sn/kernel/klconflib.c
@@ -78,31 +78,30 @@
 	position = MODULE_GET_BPOS(m);
 
 	if ((fmt = MODULE_FORMAT_BRIEF) || (fmt = MODULE_FORMAT_LCD)) {
-	    /* Brief module number format, eg. 002c15 */
+		/* Brief module number format, eg. 002c15 */
 
-	    /* Decompress the rack number */
-	    *buffer++ = '0' + RACK_GET_CLASS(rack);
-	    *buffer++ = '0' + RACK_GET_GROUP(rack);
-	    *buffer++ = '0' + RACK_GET_NUM(rack);
+		/* Decompress the rack number */
+		*buffer++ = '0' + RACK_GET_CLASS(rack);
+		*buffer++ = '0' + RACK_GET_GROUP(rack);
+		*buffer++ = '0' + RACK_GET_NUM(rack);
 
-	    /* Add the brick type */
-	    *buffer++ = brickchar;
+		/* Add the brick type */
+		*buffer++ = brickchar;
 	}
 	else if (fmt = MODULE_FORMAT_LONG) {
-	    /* Fuller hwgraph format, eg. rack/002/bay/15 */
+		/* Fuller hwgraph format, eg. rack/002/bay/15 */
 
-	    strcpy(buffer, "rack" "/");  buffer += strlen(buffer);
+		strcpy(buffer, "rack" "/");  buffer += strlen(buffer);
 
-	    *buffer++ = '0' + RACK_GET_CLASS(rack);
-	    *buffer++ = '0' + RACK_GET_GROUP(rack);
-	    *buffer++ = '0' + RACK_GET_NUM(rack);
+		*buffer++ = '0' + RACK_GET_CLASS(rack);
+		*buffer++ = '0' + RACK_GET_GROUP(rack);
+		*buffer++ = '0' + RACK_GET_NUM(rack);
 
-	    strcpy(buffer, "/" "bay" "/");  buffer += strlen(buffer);
+		strcpy(buffer, "/" "bay" "/");  buffer += strlen(buffer);
 	}
 
 	/* Add the bay position, using at least two digits */
 	if (position < 10)
-	    *buffer++ = '0';
+		*buffer++ = '0';
 	sprintf(buffer, "%d", position);
-
 }
Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c
+++ linux-2.6/arch/ia64/sn/kernel/setup.c
@@ -209,7 +209,7 @@
 }
 
 extern int platform_intr_list[];
-static int __initdata shub_1_1_found = 0;
+static int __initdata shub_1_1_found;
 
 /*
  * sn_check_for_wars
@@ -578,13 +578,17 @@
 			sn_prom_type = 2;
 		else
 			sn_prom_type = 1;
-		printk("Running on medusa with %s PROM\n", (sn_prom_type = 1) ? "real" : "fake");
+		printk(KERN_INFO "Running on medusa with %s PROM\n",
+		       (sn_prom_type = 1) ? "real" : "fake");
 	}
 
 	memset(pda, 0, sizeof(pda));
-	if (ia64_sn_get_sn_info(0, &sn_hub_info->shub2, &sn_hub_info->nasid_bitmask, &sn_hub_info->nasid_shift,
-				&sn_system_size, &sn_sharing_domain_size, &sn_partition_id,
-				&sn_coherency_id, &sn_region_size))
+	if (ia64_sn_get_sn_info(0, &sn_hub_info->shub2,
+				&sn_hub_info->nasid_bitmask,
+				&sn_hub_info->nasid_shift,
+				&sn_system_size, &sn_sharing_domain_size,
+				&sn_partition_id, &sn_coherency_id,
+				&sn_region_size))
 		BUG();
 	sn_hub_info->as_shift = sn_hub_info->nasid_shift - 2;
 
@@ -716,7 +720,8 @@
 	for_each_online_node(node) {
 		kl_config_hdr_t *klgraph_header;
 		nasid = cnodeid_to_nasid(node);
-		if ((klgraph_header = ia64_sn_get_klconfig_addr(nasid)) = NULL)
+		klgraph_header = ia64_sn_get_klconfig_addr(nasid);
+		if (klgraph_header = NULL)
 			BUG();
 		brd = NODE_OFFSET_TO_LBOARD(nasid, klgraph_header->ch_board_info);
 		while (brd) {
@@ -734,7 +739,7 @@
 {
 	long cpu;
 
-	for (cpu=0; cpu < NR_CPUS; cpu++)
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
 		if (cpuid_to_nasid(cpu) = nasid &&
 					cpuid_to_slice(cpu) = slice)
 			return cpu;
