From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 06 Feb 2006 17:51:59 +0000
Subject: bugfix git pull on ia64 linux tree
Message-Id: <200602061751.k16HpxCG027547@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
In-Reply-To: <200509142223.j8EMN0qk011773@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig                 |    4 
 arch/ia64/kernel/sal.c            |   75 ++++++++++++++
 arch/ia64/sn/Makefile             |    2 
 arch/ia64/sn/kernel/Makefile      |    2 
 arch/ia64/sn/kernel/bte.c         |   17 +--
 arch/ia64/sn/kernel/io_init.c     |    9 +
 arch/ia64/sn/kernel/irq.c         |   21 +---
 arch/ia64/sn/kernel/klconflib.c   |   29 ++---
 arch/ia64/sn/kernel/setup.c       |   19 ++-
 arch/ia64/sn/kernel/sn2/Makefile  |    2 
 arch/ia64/sn/kernel/sn2/sn2_smp.c |  196 ++++++++++++++------------------------
 arch/ia64/sn/kernel/xpc_main.c    |   19 ++-
 arch/ia64/sn/pci/Makefile         |    2 
 arch/ia64/sn/pci/pcibr/Makefile   |    2 
 drivers/Makefile                  |    2 
 include/asm-ia64/processor.h      |   17 +++
 include/asm-ia64/sal.h            |   10 -
 include/asm-ia64/sn/bte.h         |   23 +++-
 include/asm-ia64/sn/intr.h        |   38 +++----
 include/asm-ia64/system.h         |   25 ----
 20 files changed, 278 insertions(+), 236 deletions(-)

Bjorn Helgaas:
      [IA64] avoid broken SAL_CACHE_FLUSH implementations

Chen, Kenneth W:
      [IA64] remove staled comments in asm/system.h

Jack Steiner:
      [IA64-SGI] Update TLB flushing code for SN platform

Jes Sorensen:
      drivers/sn/ must be entered for CONFIG_SGI_IOC3
      [IA64-SGI] sn2 housekeeping
      [IA64-SGI] include/asm-ia64/sn/intr.h more sn2 housekeeping

Keith Owens:
      [IA64-SGI] Recursive flags do not work for selective builds

Kyle McMartin:
      [IA64] Remove stale comment from ia64/Kconfig

Mark Maule:
      [IA64-SGI] fix smp_affinity redirection when using CONFIG_PCI_MSI
      [IA64-SGI] disable msi for all altix pci devices

Robin Holt:
      [IA64-SGI] Fix XPC code which sleeps with spin_lock_irqsave().

Russ Anderson:
      [IA64-SGI] Shub2 BTE address fix


diff-tree 913e4a75572354995b330f57082d9a86250cd75f (from 27ee6e0592c7d624836835dd8d2f0f74e9d289f6)
Author: Russ Anderson <rja@efs.americas.sgi.com>
Date:   Fri Feb 3 14:47:15 2006 -0600

    [IA64-SGI] Shub2 BTE address fix
    
    After converting the cpu physical address to shub2 physical
    addressing, the address was run through TO_PHYS() which
    clobbered a high node offset bit causing the BTE to fail
    on shub2 nodes with large memory.  This fix corrects
    that problem.
    
    Signed-off-by: Russ Anderson (rja@sgi.com)
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/bte.c b/arch/ia64/sn/kernel/bte.c
index dd73c0c..1f11db4 100644
--- a/arch/ia64/sn/kernel/bte.c
+++ b/arch/ia64/sn/kernel/bte.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/config.h>
@@ -186,18 +186,13 @@ retry_bteop:
 
 	/* Initialize the notification to a known value. */
 	*bte->most_rcnt_na = BTE_WORD_BUSY;
-	notif_phys_addr = TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na));
+	notif_phys_addr = (u64)bte->most_rcnt_na;
 
-	if (is_shub2()) {
-		src = SH2_TIO_PHYS_TO_DMA(src);
-		dest = SH2_TIO_PHYS_TO_DMA(dest);
-		notif_phys_addr = SH2_TIO_PHYS_TO_DMA(notif_phys_addr);
-	}
 	/* Set the source and destination registers */
-	BTE_PRINTKV(("IBSA = 0x%lx)\n", (TO_PHYS(src))));
-	BTE_SRC_STORE(bte, TO_PHYS(src));
-	BTE_PRINTKV(("IBDA = 0x%lx)\n", (TO_PHYS(dest))));
-	BTE_DEST_STORE(bte, TO_PHYS(dest));
+	BTE_PRINTKV(("IBSA = 0x%lx)\n", src));
+	BTE_SRC_STORE(bte, src);
+	BTE_PRINTKV(("IBDA = 0x%lx)\n", dest));
+	BTE_DEST_STORE(bte, dest);
 
 	/* Set the notification register */
 	BTE_PRINTKV(("IBNA = 0x%lx)\n", notif_phys_addr));
diff --git a/include/asm-ia64/sn/bte.h b/include/asm-ia64/sn/bte.h
index f50da3d..01e5b41 100644
--- a/include/asm-ia64/sn/bte.h
+++ b/include/asm-ia64/sn/bte.h
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -100,13 +100,28 @@
 #define BTE_LNSTAT_STORE(_bte, _x)					\
 			HUB_S(_bte->bte_base_addr, (_x))
 #define BTE_SRC_STORE(_bte, _x)						\
-			HUB_S(_bte->bte_source_addr, (_x))
+({									\
+		u64 __addr = ((_x) & ~AS_MASK);				\
+		if (is_shub2()) 					\
+			__addr = SH2_TIO_PHYS_TO_DMA(__addr);		\
+		HUB_S(_bte->bte_source_addr, __addr);			\
+})
 #define BTE_DEST_STORE(_bte, _x)					\
-			HUB_S(_bte->bte_destination_addr, (_x))
+({									\
+		u64 __addr = ((_x) & ~AS_MASK);				\
+		if (is_shub2()) 					\
+			__addr = SH2_TIO_PHYS_TO_DMA(__addr);		\
+		HUB_S(_bte->bte_destination_addr, __addr);		\
+})
 #define BTE_CTRL_STORE(_bte, _x)					\
 			HUB_S(_bte->bte_control_addr, (_x))
 #define BTE_NOTIF_STORE(_bte, _x)					\
-			HUB_S(_bte->bte_notify_addr, (_x))
+({									\
+		u64 __addr = ia64_tpa((_x) & ~AS_MASK);			\
+		if (is_shub2()) 					\
+			__addr = SH2_TIO_PHYS_TO_DMA(__addr);		\
+		HUB_S(_bte->bte_notify_addr, __addr);			\
+})
 
 #define BTE_START_TRANSFER(_bte, _len, _mode)				\
 	is_shub2() ? BTE_CTRL_STORE(_bte, IBLS_BUSY | (_mode << 24) | _len) \

diff-tree 7c6c66362941df847957766ad133ff5fde67579c (from 9a52bbed905fa41ca10f4db2e845b588f0fdfbef)
Author: Robin Holt <holt@sgi.com>
Date:   Thu Feb 2 12:30:21 2006 -0600

    [IA64-SGI] Fix XPC code which sleeps with spin_lock_irqsave().
    
    During some testing, we got a warning about trying to allocate
    memory while holding a lock.  This fixes that problem.
    
    Signed-off-by: Robin Holt <holt@sgi.com>
    Acked-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/xpc_main.c b/arch/ia64/sn/kernel/xpc_main.c
index c75f8ae..9cd460d 100644
--- a/arch/ia64/sn/kernel/xpc_main.c
+++ b/arch/ia64/sn/kernel/xpc_main.c
@@ -575,18 +575,21 @@ xpc_activate_partition(struct xpc_partit
 
 	spin_lock_irqsave(&part->act_lock, irq_flags);
 
-	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), 0);
-
 	DBUG_ON(part->act_state != XPC_P_INACTIVE);
 
-	if (pid > 0) {
-		part->act_state = XPC_P_ACTIVATION_REQ;
-		XPC_SET_REASON(part, xpcCloneKThread, __LINE__);
-	} else {
-		XPC_SET_REASON(part, xpcCloneKThreadFailed, __LINE__);
-	}
+	part->act_state = XPC_P_ACTIVATION_REQ;
+	XPC_SET_REASON(part, xpcCloneKThread, __LINE__);
 
 	spin_unlock_irqrestore(&part->act_lock, irq_flags);
+
+	pid = kernel_thread(xpc_activating, (void *) ((u64) partid), 0);
+
+	if (unlikely(pid <= 0)) {
+		spin_lock_irqsave(&part->act_lock, irq_flags);
+		part->act_state = XPC_P_INACTIVE;
+		XPC_SET_REASON(part, xpcCloneKThreadFailed, __LINE__);
+		spin_unlock_irqrestore(&part->act_lock, irq_flags);
+	}
 }
 
 

diff-tree 9a52bbed905fa41ca10f4db2e845b588f0fdfbef (from 2fcc3db0ccee9b47df7a4f732e6624f4f643c035)
Author: Jes Sorensen <jes@sgi.com>
Date:   Thu Feb 2 05:50:05 2006 -0500

    [IA64-SGI] include/asm-ia64/sn/intr.h more sn2 housekeeping
    
    House keeping - eliminate unneeded parenthesis in macro defines.
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/sn/intr.h b/include/asm-ia64/sn/intr.h
index a343137..60a51a4 100644
--- a/include/asm-ia64/sn/intr.h
+++ b/include/asm-ia64/sn/intr.h
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #ifndef _ASM_IA64_SN_INTR_H
@@ -11,26 +11,26 @@
 
 #include <linux/rcupdate.h>
 
-#define SGI_UART_VECTOR		(0xe9)
+#define SGI_UART_VECTOR		0xe9
 
 /* Reserved IRQs : Note, not to exceed IA64_SN2_FIRST_DEVICE_VECTOR */
-#define SGI_XPC_ACTIVATE                (0x30)
-#define SGI_II_ERROR                    (0x31)
-#define SGI_XBOW_ERROR                  (0x32)
-#define SGI_PCIASIC_ERROR               (0x33)
-#define SGI_ACPI_SCI_INT                (0x34)
-#define SGI_TIOCA_ERROR                 (0x35)
-#define SGI_TIO_ERROR                   (0x36)
-#define SGI_TIOCX_ERROR                 (0x37)
-#define SGI_MMTIMER_VECTOR              (0x38)
-#define SGI_XPC_NOTIFY                  (0xe7)
-
-#define IA64_SN2_FIRST_DEVICE_VECTOR    (0x3c)
-#define IA64_SN2_LAST_DEVICE_VECTOR     (0xe6)
-
-#define SN2_IRQ_RESERVED        (0x1)
-#define SN2_IRQ_CONNECTED       (0x2)
-#define SN2_IRQ_SHARED          (0x4)
+#define SGI_XPC_ACTIVATE	0x30
+#define SGI_II_ERROR		0x31
+#define SGI_XBOW_ERROR		0x32
+#define SGI_PCIASIC_ERROR	0x33
+#define SGI_ACPI_SCI_INT	0x34
+#define SGI_TIOCA_ERROR		0x35
+#define SGI_TIO_ERROR		0x36
+#define SGI_TIOCX_ERROR		0x37
+#define SGI_MMTIMER_VECTOR	0x38
+#define SGI_XPC_NOTIFY		0xe7
+
+#define IA64_SN2_FIRST_DEVICE_VECTOR	0x3c
+#define IA64_SN2_LAST_DEVICE_VECTOR	0xe6
+
+#define SN2_IRQ_RESERVED	0x1
+#define SN2_IRQ_CONNECTED	0x2
+#define SN2_IRQ_SHARED		0x4
 
 // The SN PROM irq struct
 struct sn_irq_info {

diff-tree 2fcc3db0ccee9b47df7a4f732e6624f4f643c035 (from 41db6112a5558bd09c8ec5b0e61566db11f0d86d)
Author: Jes Sorensen <jes@sgi.com>
Date:   Thu Feb 2 05:15:51 2006 -0500

    [IA64-SGI] sn2 housekeeping
    
    Maintenance patch:
     - Add missing __init calls
     - Do not zero initialize global variables
     - No need to typecast function call returns to void
     - Some formatting
    
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 6dbb7fc..d7e4d79 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -208,7 +208,7 @@ static s64 sn_device_fixup_war(u64 nasid
  * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for
  *	each node in the system.
  */
-static void sn_fixup_ionodes(void)
+static void __init sn_fixup_ionodes(void)
 {
 	struct sn_flush_device_kernel *sn_flush_device_kernel;
 	struct sn_flush_device_kernel *dev_entry;
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 928b4ac..74d87d9 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
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
@@ -76,14 +77,12 @@ static void sn_enable_irq(unsigned int i
 
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
 
 	move_native_irq(irq);
@@ -219,9 +218,8 @@ static void register_intr_pda(struct sn_
 		pdacpu(cpu)->sn_last_irq = irq;
 	}
 
-	if (pdacpu(cpu)->sn_first_irq = 0 || pdacpu(cpu)->sn_first_irq > irq) {
+	if (pdacpu(cpu)->sn_first_irq = 0 || pdacpu(cpu)->sn_first_irq > irq)
 		pdacpu(cpu)->sn_first_irq = irq;
-	}
 }
 
 static void unregister_intr_pda(struct sn_irq_info *sn_irq_info)
@@ -289,7 +287,7 @@ void sn_irq_fixup(struct pci_dev *pci_de
 	list_add_rcu(&sn_irq_info->list, sn_irq_lh[sn_irq_info->irq_irq]);
 	spin_unlock(&sn_irq_info_lock);
 
-	(void)register_intr_pda(sn_irq_info);
+	register_intr_pda(sn_irq_info);
 }
 
 void sn_irq_unfixup(struct pci_dev *pci_dev)
@@ -419,7 +417,7 @@ void sn_lb_int_war_check(void)
 	rcu_read_unlock();
 }
 
-void sn_irq_lh_init(void)
+void __init sn_irq_lh_init(void)
 {
 	int i;
 
@@ -434,5 +432,4 @@ void sn_irq_lh_init(void)
 
 		INIT_LIST_HEAD(sn_irq_lh[i]);
 	}
-
 }
diff --git a/arch/ia64/sn/kernel/klconflib.c b/arch/ia64/sn/kernel/klconflib.c
index 0f11a32..87682b4 100644
--- a/arch/ia64/sn/kernel/klconflib.c
+++ b/arch/ia64/sn/kernel/klconflib.c
@@ -78,31 +78,30 @@ format_module_id(char *buffer, moduleid_
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
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index e510dce..ee36bff 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -209,7 +209,7 @@ void __init early_sn_setup(void)
 }
 
 extern int platform_intr_list[];
-static int __initdata shub_1_1_found = 0;
+static int __initdata shub_1_1_found;
 
 /*
  * sn_check_for_wars
@@ -578,13 +578,17 @@ void __init sn_cpu_init(void)
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
 
@@ -716,7 +720,8 @@ void __init build_cnode_tables(void)
 	for_each_online_node(node) {
 		kl_config_hdr_t *klgraph_header;
 		nasid = cnodeid_to_nasid(node);
-		if ((klgraph_header = ia64_sn_get_klconfig_addr(nasid)) = NULL)
+		klgraph_header = ia64_sn_get_klconfig_addr(nasid);
+		if (klgraph_header = NULL)
 			BUG();
 		brd = NODE_OFFSET_TO_LBOARD(nasid, klgraph_header->ch_board_info);
 		while (brd) {
@@ -734,7 +739,7 @@ nasid_slice_to_cpuid(int nasid, int slic
 {
 	long cpu;
 
-	for (cpu=0; cpu < NR_CPUS; cpu++)
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
 		if (cpuid_to_nasid(cpu) = nasid &&
 					cpuid_to_slice(cpu) = slice)
 			return cpu;

diff-tree a58786917ce23c2a26c3e099c3cdba32a35eeceb (from af14aca90e0cdfccd71f9947c45b6ea2cf321dcb)
Author: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date:   Mon Jan 30 16:32:31 2006 -0700

    [IA64] avoid broken SAL_CACHE_FLUSH implementations
    
    If SAL_CACHE_FLUSH drops interrupts, complain about it and fall back to
    using PAL_CACHE_FLUSH instead.
    
    This is to work around a defect in HP rx5670 firmware: when an interrupt
    occurs during SAL_CACHE_FLUSH, SAL drops the interrupt but leaves it marked
    "in-service", which leaves the interrupt (and others of equal or lower
    priority) masked.
    
    Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index acc0f13..056f7a6 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -14,6 +14,7 @@
 #include <linux/spinlock.h>
 #include <linux/string.h>
 
+#include <asm/delay.h>
 #include <asm/page.h>
 #include <asm/sal.h>
 #include <asm/pal.h>
@@ -214,6 +215,78 @@ chk_nointroute_opt(void)
 static void __init sal_desc_ap_wakeup(void *p) { }
 #endif
 
+/*
+ * HP rx5670 firmware polls for interrupts during SAL_CACHE_FLUSH by reading
+ * cr.ivr, but it never writes cr.eoi.  This leaves any interrupt marked as
+ * "in-service" and masks other interrupts of equal or lower priority.
+ *
+ * HP internal defect reports: F1859, F2775, F3031.
+ */
+static int sal_cache_flush_drops_interrupts;
+
+static void __init
+check_sal_cache_flush (void)
+{
+	unsigned long flags, itv;
+	int cpu;
+	u64 vector;
+
+	cpu = get_cpu();
+	local_irq_save(flags);
+
+	/*
+	 * Schedule a timer interrupt, wait until it's reported, and see if
+	 * SAL_CACHE_FLUSH drops it.
+	 */
+	itv = ia64_get_itv();
+	BUG_ON((itv & (1 << 16)) = 0);
+
+	ia64_set_itv(IA64_TIMER_VECTOR);
+	ia64_set_itm(ia64_get_itc() + 1000);
+
+	while (!ia64_get_irr(IA64_TIMER_VECTOR))
+		cpu_relax();
+
+	ia64_sal_cache_flush(3);
+
+	if (ia64_get_irr(IA64_TIMER_VECTOR)) {
+		vector = ia64_get_ivr();
+		ia64_eoi();
+		WARN_ON(vector != IA64_TIMER_VECTOR);
+	} else {
+		sal_cache_flush_drops_interrupts = 1;
+		printk(KERN_ERR "SAL: SAL_CACHE_FLUSH drops interrupts; "
+			"PAL_CACHE_FLUSH will be used instead\n");
+		ia64_eoi();
+	}
+
+	ia64_set_itv(itv);
+	local_irq_restore(flags);
+	put_cpu();
+}
+
+s64
+ia64_sal_cache_flush (u64 cache_type)
+{
+	struct ia64_sal_retval isrv;
+
+	if (sal_cache_flush_drops_interrupts) {
+		unsigned long flags;
+		u64 progress;
+		s64 rc;
+
+		progress = 0;
+		local_irq_save(flags);
+		rc = ia64_pal_cache_flush(cache_type,
+			PAL_CACHE_FLUSH_INVALIDATE, &progress, NULL);
+		local_irq_restore(flags);
+		return rc;
+	}
+
+	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
+	return isrv.status;
+}
+
 void __init
 ia64_sal_init (struct ia64_sal_systab *systab)
 {
@@ -262,6 +335,8 @@ ia64_sal_init (struct ia64_sal_systab *s
 		}
 		p += SAL_DESC_SIZE(*p);
 	}
+
+	check_sal_cache_flush();
 }
 
 int
diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
index 09b9902..23c8e1b 100644
--- a/include/asm-ia64/processor.h
+++ b/include/asm-ia64/processor.h
@@ -559,6 +559,23 @@ ia64_eoi (void)
 
 #define cpu_relax()	ia64_hint(ia64_hint_pause)
 
+static inline int
+ia64_get_irr(unsigned int vector)
+{
+	unsigned int reg = vector / 64;
+	unsigned int bit = vector % 64;
+	u64 irr;
+
+	switch (reg) {
+	case 0: irr = ia64_getreg(_IA64_REG_CR_IRR0); break;
+	case 1: irr = ia64_getreg(_IA64_REG_CR_IRR1); break;
+	case 2: irr = ia64_getreg(_IA64_REG_CR_IRR2); break;
+	case 3: irr = ia64_getreg(_IA64_REG_CR_IRR3); break;
+	}
+
+	return test_bit(bit, &irr);
+}
+
 static inline void
 ia64_set_lrr0 (unsigned long val)
 {
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 313cad0..0b210ab 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -658,15 +658,7 @@ ia64_sal_freq_base (unsigned long which,
 	return isrv.status;
 }
 
-/* Flush all the processor and platform level instruction and/or data caches */
-static inline s64
-ia64_sal_cache_flush (u64 cache_type)
-{
-	struct ia64_sal_retval isrv;
-	SAL_CALL(isrv, SAL_CACHE_FLUSH, cache_type, 0, 0, 0, 0, 0, 0);
-	return isrv.status;
-}
-
+extern s64 ia64_sal_cache_flush (u64 cache_type);
 
 /* Initialize all the processor and platform level instruction and data caches */
 static inline s64

diff-tree af14aca90e0cdfccd71f9947c45b6ea2cf321dcb (from a80dcc0b9660b01a2cc1c0faa8f6095970f38730)
Author: Kyle McMartin <kyle@mcmartin.ca>
Date:   Sat Jan 28 00:02:52 2006 -0500

    [IA64] Remove stale comment from ia64/Kconfig
    
    Somehow I doubt this comment is meant to be here anymore... It's
    been floating after the L1_CACHE_SHIFT entry since before Linux
    moved to bitkeeper.
    
    Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 199eeaf..a1942f7 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -194,7 +194,6 @@ config IA64_L1_CACHE_SHIFT
 	default "7" if MCKINLEY
 	default "6" if ITANIUM
 
-# align cache-sensitive data to 64 bytes
 config IA64_CYCLONE
 	bool "Cyclone (EXA) Time Source support"
 	help

diff-tree a80dcc0b9660b01a2cc1c0faa8f6095970f38730 (from 689388bbf8c5c1966b6a67fa427299f90cf83b99)
Author: Mark Maule <maule@sgi.com>
Date:   Fri Jan 27 13:59:07 2006 -0600

    [IA64-SGI] disable msi for all altix pci devices
    
    Temporary patch to make pci_enable_msi() fail gracefully on altix.  Will be
    removed after 2.6.16 releases and the msi abstraction patches start flowing.
    
    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index a4c7815..6dbb7fc 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -467,6 +467,13 @@ void sn_pci_fixup_slot(struct pci_dev *d
 		pcidev_info->pdi_sn_irq_info = NULL;
 		kfree(sn_irq_info);
 	}
+
+	/*
+	 * MSI currently not supported on altix.  Remove this when
+	 * the MSI abstraction patches are integrated into the kernel
+	 * (sometime after 2.6.16 releases)
+	 */
+	dev->no_msi = 1;
 }
 
 /*

diff-tree 689388bbf8c5c1966b6a67fa427299f90cf83b99 (from f8efa27662532ad5adb2790bfc3f4c78e019cfad)
Author: Mark Maule <maule@sgi.com>
Date:   Fri Jan 27 11:55:34 2006 -0600

    [IA64-SGI] fix smp_affinity redirection when using CONFIG_PCI_MSI
    
    Redirecting interrupts using smp_affinity on altix does not work on kernels
    built with CONFIG_PCI_MSI.  The problem is that move_irq() turns into a noop
    if MSI is built in.  This patch calls move_native_irq() instead of move_irq()
    to get around that.
    
    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index ec37084..928b4ac 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -86,7 +86,7 @@ static void sn_ack_irq(unsigned int irq)
 	      mask);
 	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
 
-	move_irq(irq);
+	move_native_irq(irq);
 }
 
 static void sn_end_irq(unsigned int irq)

diff-tree f8efa27662532ad5adb2790bfc3f4c78e019cfad (from df080e7c94c8f4b8334614159fa079aaeece5670)
Author: Chen, Kenneth W <kenneth.w.chen@intel.com>
Date:   Thu Jan 26 18:24:59 2006 -0800

    [IA64] remove staled comments in asm/system.h
    
    With the recent optimization made to wrap_mmu_context function,
    we don't hold tasklist_lock anymore when wrapping context id.
    The comments in asm/system.h must fall through the crack earlier.
    Remove staled comments.
    
    I believe it is still beneficial to unlock the runqueue lock
    across context switch. So leave __ARCH_WANT_UNLOCKED_CTXSW on.
    
    Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
index 80c5a23..0625387 100644
--- a/include/asm-ia64/system.h
+++ b/include/asm-ia64/system.h
@@ -249,32 +249,7 @@ extern void ia64_load_extra (struct task
 # define switch_to(prev,next,last)	__switch_to(prev, next, last)
 #endif
 
-/*
- * On IA-64, we don't want to hold the runqueue's lock during the low-level context-switch,
- * because that could cause a deadlock.  Here is an example by Erich Focht:
- *
- * Example:
- * CPU#0:
- * schedule()
- *    -> spin_lock_irq(&rq->lock)
- *    -> context_switch()
- *       -> wrap_mmu_context()
- *          -> read_lock(&tasklist_lock)
- *
- * CPU#1:
- * sys_wait4() or release_task() or forget_original_parent()
- *    -> write_lock(&tasklist_lock)
- *    -> do_notify_parent()
- *       -> wake_up_parent()
- *          -> try_to_wake_up()
- *             -> spin_lock_irq(&parent_rq->lock)
- *
- * If the parent's rq happens to be on CPU#0, we'll wait for the rq->lock
- * of that CPU which will not be released, because there we wait for the
- * tasklist_lock to become available.
- */
 #define __ARCH_WANT_UNLOCKED_CTXSW
-
 #define ARCH_HAS_PREFETCH_SWITCH_STACK
 #define ia64_platform_is(x) (strcmp(x, platform_name) = 0)
 

diff-tree 61a34a024fcd61ef7207405b2e4cef2c073b220c (from 3ee68c4af3fd7228c1be63254b9f884614f9ebb2)
Author: Jack Steiner <steiner@sgi.com>
Date:   Thu Jan 26 15:03:41 2006 -0800

    [IA64-SGI] Update TLB flushing code for SN platform
    
    This patch finishes support for SHUB2 (the new chipset). Most of the
    changes are performance related. A few changes are workarounds for
    "interesting" chipset features.
    
    Some temporary debugging code has also been deleted.
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 471bbaa..f153a4c 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -5,7 +5,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/init.h>
@@ -46,104 +46,28 @@ DECLARE_PER_CPU(struct ptc_stats, ptcsta
 
 static  __cacheline_aligned DEFINE_SPINLOCK(sn2_global_ptc_lock);
 
-void sn2_ptc_deadlock_recovery(short *, short, int, volatile unsigned long *, unsigned long data0,
-	volatile unsigned long *, unsigned long data1);
+void sn2_ptc_deadlock_recovery(short *, short, short, int, volatile unsigned long *, unsigned long,
+	volatile unsigned long *, unsigned long);
 
-#ifdef DEBUG_PTC
 /*
- * ptctest:
- *
- * 	xyz - 3 digit hex number:
- * 		x - Force PTC purges to use shub:
- * 			0 - no force
- * 			1 - force
- * 		y - interupt enable
- * 			0 - disable interrupts
- * 			1 - leave interuupts enabled
- * 		z - type of lock:
- * 			0 - global lock
- * 			1 - node local lock
- * 			2 - no lock
- *
- *   	Note: on shub1, only ptctest = 0 is supported. Don't try other values!
+ * Note: some is the following is captured here to make degugging easier
+ * (the macros make more sense if you see the debug patch - not posted)
  */
-
-static unsigned int sn2_ptctest = 0;
-
-static int __init ptc_test(char *str)
-{
-	get_option(&str, &sn2_ptctest);
-	return 1;
-}
-__setup("ptctest=", ptc_test);
-
-static inline int ptc_lock(unsigned long *flagp)
-{
-	unsigned long opt = sn2_ptctest & 255;
-
-	switch (opt) {
-	case 0x00:
-		spin_lock_irqsave(&sn2_global_ptc_lock, *flagp);
-		break;
-	case 0x01:
-		spin_lock_irqsave(&sn_nodepda->ptc_lock, *flagp);
-		break;
-	case 0x02:
-		local_irq_save(*flagp);
-		break;
-	case 0x10:
-		spin_lock(&sn2_global_ptc_lock);
-		break;
-	case 0x11:
-		spin_lock(&sn_nodepda->ptc_lock);
-		break;
-	case 0x12:
-		break;
-	default:
-		BUG();
-	}
-	return opt;
-}
-
-static inline void ptc_unlock(unsigned long flags, int opt)
-{
-	switch (opt) {
-	case 0x00:
-		spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
-		break;
-	case 0x01:
-		spin_unlock_irqrestore(&sn_nodepda->ptc_lock, flags);
-		break;
-	case 0x02:
-		local_irq_restore(flags);
-		break;
-	case 0x10:
-		spin_unlock(&sn2_global_ptc_lock);
-		break;
-	case 0x11:
-		spin_unlock(&sn_nodepda->ptc_lock);
-		break;
-	case 0x12:
-		break;
-	default:
-		BUG();
-	}
-}
-#else
-
 #define sn2_ptctest	0
+#define local_node_uses_ptc_ga(sh1)	((sh1) ? 1 : 0)
+#define max_active_pio(sh1)		((sh1) ? 32 : 7)
+#define reset_max_active_on_deadlock()	1
+#define PTC_LOCK(sh1)			((sh1) ? &sn2_global_ptc_lock : &sn_nodepda->ptc_lock)
 
-static inline int ptc_lock(unsigned long *flagp)
+static inline void ptc_lock(int sh1, unsigned long *flagp)
 {
-	spin_lock_irqsave(&sn2_global_ptc_lock, *flagp);
-	return 0;
+	spin_lock_irqsave(PTC_LOCK(sh1), *flagp);
 }
 
-static inline void ptc_unlock(unsigned long flags, int opt)
+static inline void ptc_unlock(int sh1, unsigned long flags)
 {
-	spin_unlock_irqrestore(&sn2_global_ptc_lock, flags);
+	spin_unlock_irqrestore(PTC_LOCK(sh1), flags);
 }
-#endif
 
 struct ptc_stats {
 	unsigned long ptc_l;
@@ -151,27 +75,30 @@ struct ptc_stats {
 	unsigned long shub_ptc_flushes;
 	unsigned long nodes_flushed;
 	unsigned long deadlocks;
+	unsigned long deadlocks2;
 	unsigned long lock_itc_clocks;
 	unsigned long shub_itc_clocks;
 	unsigned long shub_itc_clocks_max;
+	unsigned long shub_ptc_flushes_not_my_mm;
 };
 
 static inline unsigned long wait_piowc(void)
 {
-	volatile unsigned long *piows, zeroval;
-	unsigned long ws;
+	volatile unsigned long *piows;
+	unsigned long zeroval, ws;
 
 	piows = pda->pio_write_status_addr;
 	zeroval = pda->pio_write_status_val;
 	do {
 		cpu_relax();
 	} while (((ws = *piows) & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != zeroval);
-	return ws;
+	return (ws & SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK) != 0;
 }
 
 void sn_tlb_migrate_finish(struct mm_struct *mm)
 {
-	if (mm = current->mm)
+	/* flush_tlb_mm is inefficient if more than 1 users of mm */
+	if (mm = current->mm && mm && atomic_read(&mm->mm_users) = 1)
 		flush_tlb_mm(mm);
 }
 
@@ -201,12 +128,14 @@ void
 sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 		     unsigned long end, unsigned long nbits)
 {
-	int i, opt, shub1, cnode, mynasid, cpu, lcpu = 0, nasid, flushed = 0;
-	int mymm = (mm = current->active_mm && current->mm);
+	int i, ibegin, shub1, cnode, mynasid, cpu, lcpu = 0, nasid;
+	int mymm = (mm = current->active_mm && mm = current->mm);
+	int use_cpu_ptcga;
 	volatile unsigned long *ptc0, *ptc1;
-	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value;
+	unsigned long itc, itc2, flags, data0 = 0, data1 = 0, rr_value, old_rr = 0;
 	short nasids[MAX_NUMNODES], nix;
 	nodemask_t nodes_flushed;
+	int active, max_active, deadlock;
 
 	nodes_clear(nodes_flushed);
 	i = 0;
@@ -267,41 +196,56 @@ sn2_global_tlb_purge(struct mm_struct *m
 	
 
 	mynasid = get_nasid();
+	use_cpu_ptcga = local_node_uses_ptc_ga(shub1);
+	max_active = max_active_pio(shub1);
 
 	itc = ia64_get_itc();
-	opt = ptc_lock(&flags);
+	ptc_lock(shub1, &flags);
 	itc2 = ia64_get_itc();
+
 	__get_cpu_var(ptcstats).lock_itc_clocks += itc2 - itc;
 	__get_cpu_var(ptcstats).shub_ptc_flushes++;
 	__get_cpu_var(ptcstats).nodes_flushed += nix;
+	if (!mymm)
+		 __get_cpu_var(ptcstats).shub_ptc_flushes_not_my_mm++;
 
+	if (use_cpu_ptcga && !mymm) {
+		old_rr = ia64_get_rr(start);
+		ia64_set_rr(start, (old_rr & 0xff) | (rr_value << 8));
+		ia64_srlz_d();
+	}
+
+	wait_piowc();
 	do {
 		if (shub1)
 			data1 = start | (1UL << SH1_PTC_1_START_SHFT);
 		else
 			data0 = (data0 & ~SH2_PTC_ADDR_MASK) | (start & SH2_PTC_ADDR_MASK);
-		for (i = 0; i < nix; i++) {
+		deadlock = 0;
+		active = 0;
+		for (ibegin = 0, i = 0; i < nix; i++) {
 			nasid = nasids[i];
-			if ((!(sn2_ptctest & 3)) && unlikely(nasid = mynasid && mymm)) {
+			if (use_cpu_ptcga && unlikely(nasid = mynasid)) {
 				ia64_ptcga(start, nbits << 2);
 				ia64_srlz_i();
 			} else {
 				ptc0 = CHANGE_NASID(nasid, ptc0);
 				if (ptc1)
 					ptc1 = CHANGE_NASID(nasid, ptc1);
-				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1,
-							   data1);
-				flushed = 1;
+				pio_atomic_phys_write_mmrs(ptc0, data0, ptc1, data1);
+				active++;
+			}
+			if (active >= max_active || i = (nix - 1)) {
+				if ((deadlock = wait_piowc())) {
+					sn2_ptc_deadlock_recovery(nasids, ibegin, i, mynasid, ptc0, data0, ptc1, data1);
+					if (reset_max_active_on_deadlock())
+						max_active = 1;
+				}
+				active = 0;
+				ibegin = i + 1;
 			}
 		}
-		if (flushed
-		    && (wait_piowc() &
-				(SH_PIO_WRITE_STATUS_WRITE_DEADLOCK_MASK))) {
-			sn2_ptc_deadlock_recovery(nasids, nix, mynasid, ptc0, data0, ptc1, data1);
-		}
-
 		start += (1UL << nbits);
-
 	} while (start < end);
 
 	itc2 = ia64_get_itc() - itc2;
@@ -309,7 +253,12 @@ sn2_global_tlb_purge(struct mm_struct *m
 	if (itc2 > __get_cpu_var(ptcstats).shub_itc_clocks_max)
 		__get_cpu_var(ptcstats).shub_itc_clocks_max = itc2;
 
-	ptc_unlock(flags, opt);
+	if (old_rr) {
+		ia64_set_rr(start, old_rr);
+		ia64_srlz_d();
+	}
+
+	ptc_unlock(shub1, flags);
 
 	preempt_enable();
 }
@@ -321,27 +270,30 @@ sn2_global_tlb_purge(struct mm_struct *m
  * TLB flush transaction.  The recovery sequence is somewhat tricky & is
  * coded in assembly language.
  */
-void sn2_ptc_deadlock_recovery(short *nasids, short nix, int mynasid, volatile unsigned long *ptc0, unsigned long data0,
+void sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid, volatile unsigned long *ptc0, unsigned long data0,
 	volatile unsigned long *ptc1, unsigned long data1)
 {
-	extern void sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
+	extern unsigned long sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
 	        volatile unsigned long *, unsigned long, volatile unsigned long *, unsigned long);
 	short nasid, i;
-	unsigned long *piows, zeroval;
+	unsigned long *piows, zeroval, n;
 
 	__get_cpu_var(ptcstats).deadlocks++;
 
 	piows = (unsigned long *) pda->pio_write_status_addr;
 	zeroval = pda->pio_write_status_val;
 
-	for (i=0; i < nix; i++) {
+
+	for (i=ib; i <= ie; i++) {
 		nasid = nasids[i];
-		if (!(sn2_ptctest & 3) && nasid = mynasid)
+		if (local_node_uses_ptc_ga(is_shub1()) && nasid = mynasid)
 			continue;
 		ptc0 = CHANGE_NASID(nasid, ptc0);
 		if (ptc1)
 			ptc1 = CHANGE_NASID(nasid, ptc1);
-		sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
+
+		n = sn2_ptc_deadlock_recovery_core(ptc0, data0, ptc1, data1, piows, zeroval);
+		__get_cpu_var(ptcstats).deadlocks2 += n;
 	}
 
 }
@@ -452,20 +404,22 @@ static int sn2_ptc_seq_show(struct seq_f
 	cpu = *(loff_t *) data;
 
 	if (!cpu) {
-		seq_printf(file, "# ptc_l change_rid shub_ptc_flushes shub_nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max\n");
+		seq_printf(file,
+			   "# cpu ptc_l newrid ptc_flushes nodes_flushed deadlocks lock_nsec shub_nsec shub_nsec_max not_my_mm deadlock2\n");
 		seq_printf(file, "# ptctest %d\n", sn2_ptctest);
 	}
 
 	if (cpu < NR_CPUS && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
-		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
+		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
 				stat->change_rid, stat->shub_ptc_flushes, stat->nodes_flushed,
 				stat->deadlocks,
 				1000 * stat->lock_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
 				1000 * stat->shub_itc_clocks / per_cpu(cpu_info, cpu).cyc_per_usec,
-				1000 * stat->shub_itc_clocks_max / per_cpu(cpu_info, cpu).cyc_per_usec);
+				1000 * stat->shub_itc_clocks_max / per_cpu(cpu_info, cpu).cyc_per_usec,
+				stat->shub_ptc_flushes_not_my_mm,
+				stat->deadlocks2);
 	}
-
 	return 0;
 }
 
@@ -476,7 +430,7 @@ static struct seq_operations sn2_ptc_seq
 	.show = sn2_ptc_seq_show
 };
 
-int sn2_ptc_proc_open(struct inode *inode, struct file *file)
+static int sn2_ptc_proc_open(struct inode *inode, struct file *file)
 {
 	return seq_open(file, &sn2_ptc_seq_ops);
 }

diff-tree 466575f4e975db1207c5e1a7be34aeaec6ddba1e (from 3ee68c4af3fd7228c1be63254b9f884614f9ebb2)
Author: Jes Sorensen <jes@sgi.com>
Date:   Thu Jan 19 04:54:00 2006 -0500

    [PATCH] drivers/sn/ must be entered for CONFIG_SGI_IOC3
    
    Actually I think this is more appropriate so we don't end up with 17
    cases that add drivers/sn to the build lib.
    Include drivers/sn when CONFIG_IA64_SGI_SN2 or CONFIG_IA64_GENERIC
    is enabled.
    
    Acked-by: Dave Jones <davej@redhat.com>
    Signed-off-by: Jes Sorensen <jes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 199eeaf..8e5517e 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -374,6 +374,9 @@ config IA64_PALINFO
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
+config SGI_SN
+	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC)
+
 source "drivers/firmware/Kconfig"
 
 source "fs/Kconfig.binfmt"
diff --git a/drivers/Makefile b/drivers/Makefile
index 619dd96..5c69b86 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -69,7 +69,7 @@ obj-$(CONFIG_EISA)		+= eisa/
 obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_MMC)		+= mmc/
 obj-$(CONFIG_INFINIBAND)	+= infiniband/
-obj-$(CONFIG_SGI_IOC4)		+= sn/
+obj-$(CONFIG_SGI_SN)		+= sn/
 obj-y				+= firmware/
 obj-$(CONFIG_CRYPTO)		+= crypto/
 obj-$(CONFIG_SUPERH)		+= sh/

diff-tree 103ec0910d6b9401b7f72ba3ac71fed88306d2d0 (from 3ee68c4af3fd7228c1be63254b9f884614f9ebb2)
Author: Keith Owens <kaos@sgi.com>
Date:   Wed Jan 18 15:38:14 2006 +1100

    [IA64-SGI] Recursive flags do not work for selective builds
    
    arch/ia64/sn/Makefile sets CPPFLAGS, expecting that setting to
    propogate to all the subdirectories.  For a normal build with its
    recursive descent it does work, but doing a selective build like
    'make arch/ia64/sn/kernel/io_init.i' does not do a recursive descent,
    it goes directly to arch/ia64/sn/kernel/Makefile so the flags do not
    get set.
    
    To support selective builds, set the flags in all the subordinate Makefiles.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/sn/Makefile b/arch/ia64/sn/Makefile
index a269f6d..79a7df0 100644
--- a/arch/ia64/sn/Makefile
+++ b/arch/ia64/sn/Makefile
@@ -9,6 +9,4 @@
 # Makefile for the sn ia64 subplatform
 #
 
-CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
-
 obj-y += kernel/ pci/
diff --git a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
index 4351c4f..3e9b4ee 100644
--- a/arch/ia64/sn/kernel/Makefile
+++ b/arch/ia64/sn/kernel/Makefile
@@ -7,6 +7,8 @@
 # Copyright (C) 1999,2001-2005 Silicon Graphics, Inc.  All Rights Reserved.
 #
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
 				   huberror.o io_init.o iomv.o klconflib.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
diff --git a/arch/ia64/sn/kernel/sn2/Makefile b/arch/ia64/sn/kernel/sn2/Makefile
index 170bde4..99e1776 100644
--- a/arch/ia64/sn/kernel/sn2/Makefile
+++ b/arch/ia64/sn/kernel/sn2/Makefile
@@ -9,5 +9,7 @@
 # sn2 specific kernel files
 #
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y += cache.o io.o ptc_deadlock.o sn2_smp.o sn_proc_fs.o \
 	 prominfo_proc.o timer.o timer_interrupt.o sn_hwperf.o
diff --git a/arch/ia64/sn/pci/Makefile b/arch/ia64/sn/pci/Makefile
index 321576b..c694678 100644
--- a/arch/ia64/sn/pci/Makefile
+++ b/arch/ia64/sn/pci/Makefile
@@ -7,4 +7,6 @@
 #
 # Makefile for the sn pci general routines.
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y := pci_dma.o tioca_provider.o tioce_provider.o pcibr/
diff --git a/arch/ia64/sn/pci/pcibr/Makefile b/arch/ia64/sn/pci/pcibr/Makefile
index 1850c4a..3b403ea 100644
--- a/arch/ia64/sn/pci/pcibr/Makefile
+++ b/arch/ia64/sn/pci/pcibr/Makefile
@@ -7,5 +7,7 @@
 #
 # Makefile for the sn2 io routines.
 
+CPPFLAGS += -I$(srctree)/arch/ia64/sn/include
+
 obj-y				+=  pcibr_dma.o pcibr_reg.o \
 				    pcibr_ate.o pcibr_provider.o
