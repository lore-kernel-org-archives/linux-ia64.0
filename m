From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 15 Mar 2005 20:32:47 +0000
Subject: [PATCH/RFC]: Clean up of sn_irq_info list for PCI Hotplug
Message-Id: <4237466F.90004@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040300030404000301050406"
List-Id: <linux-ia64.vger.kernel.org>
References: <42276523.3060107@sgi.com>
In-Reply-To: <42276523.3060107@sgi.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040300030404000301050406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I propose the following change to the sn/kernel arch SN IRQ handling.

The central issue here is that the current unidirectional list 
implementation in sn_irq_info does not easily allow sn_irq_info struct 
removals when PCI devices are hotplug removed from the system.

After input from a few others I changed my approach in the patch.  
Please reconsider it for submission to the community.

P.

--------------040300030404000301050406
Content-Type: text/plain;
 name="bksn.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bksn.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/15 20:21:28-05:00 prarit@sgi.com 
#   intr.h, irq.c, io_init.c, pcidev.h:
#     sn IRQ modifications required for PCI Hotplug
# 
# include/asm-ia64/sn/intr.h
#   2005/03/15 20:19:06-05:00 prarit@sgi.com +5 -0
#   sn IRQ modifications required for PCI Hotplug
# 
# arch/ia64/sn/kernel/irq.c
#   2005/03/15 20:17:45-05:00 prarit@sgi.com +93 -57
#   sn IRQ modifications required for PCI Hotplug
# 
# arch/ia64/sn/kernel/io_init.c
#   2005/03/15 20:17:36-05:00 prarit@sgi.com +14 -7
#   sn IRQ modifications required for PCI Hotplug
# 
# arch/ia64/sn/include/pci/pcidev.h
#   2005/03/15 20:17:08-05:00 prarit@sgi.com +1 -1
#   sn IRQ modifications required for PCI Hotplug
# 
diff -Nru a/arch/ia64/sn/include/pci/pcidev.h b/arch/ia64/sn/include/pci/pcidev.h
--- a/arch/ia64/sn/include/pci/pcidev.h	2005-03-15 20:23:19 -05:00
+++ b/arch/ia64/sn/include/pci/pcidev.h	2005-03-15 20:23:19 -05:00
@@ -10,7 +10,7 @@
 
 #include <linux/pci.h>
 
-extern struct sn_irq_info **sn_irq;
+extern struct list_head **sn_irq_lh;
 
 #define SN_PCIDEV_INFO(pci_dev) \
         ((struct pcidev_info *)(pci_dev)->sysdata)
diff -Nru a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c	2005-03-15 20:23:19 -05:00
+++ b/arch/ia64/sn/kernel/io_init.c	2005-03-15 20:23:19 -05:00
@@ -343,10 +343,18 @@
 	 */
 	ia64_max_iommu_merge_mask = ~PAGE_MASK;
 	sn_fixup_ionodes();
-	sn_irq = kmalloc(sizeof(struct sn_irq_info *) * NR_IRQS, GFP_KERNEL);
-	if (sn_irq <= 0)
-		BUG();		/* Canno afford to run out of memory. */
-	memset(sn_irq, 0, sizeof(struct sn_irq_info *) * NR_IRQS);
+
+	sn_irq_lh = kmalloc(sizeof(struct list_head *) * NR_IRQS, GFP_KERNEL);
+	if (!sn_irq_lh)
+		BUG();
+
+	for (i = 0; i < NR_IRQS; i++) {
+		sn_irq_lh[i] = kmalloc(sizeof(struct list_head), GFP_KERNEL);
+		if (!sn_irq_lh[i])
+			BUG();
+
+		INIT_LIST_HEAD(sn_irq_lh[i]);
+	}
 
 	sn_init_cpei_timer();
 
@@ -365,9 +373,8 @@
 	 */
 
 	while ((pci_dev =
-		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
-		sn_pci_fixup_slot(pci_dev);
-	}
+		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL)
+			sn_pci_fixup_slot(pci_dev);
 
 	sn_ioif_inited = 1;	/* sn I/O infrastructure now initialized */
 
diff -Nru a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c	2005-03-15 20:23:19 -05:00
+++ b/arch/ia64/sn/kernel/irq.c	2005-03-15 20:23:19 -05:00
@@ -9,6 +9,7 @@
  */
 
 #include <linux/irq.h>
+#include <linux/spinlock.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/addrs.h>
 #include <asm/sn/arch.h>
@@ -25,7 +26,8 @@
 
 extern int sn_force_interrupt_flag;
 extern int sn_ioif_inited;
-struct sn_irq_info **sn_irq;
+struct list_head **sn_irq_lh;
+static spinlock_t sn_irq_info_lock = SPIN_LOCK_UNLOCKED; /* non-IRQ lock */
 
 static inline uint64_t sn_intr_alloc(nasid_t local_nasid, int local_widget,
 				     u64 sn_irq_info,
@@ -126,13 +128,13 @@
 		force_interrupt(irq);
 }
 
+static void sn_irq_info_free(struct rcu_head *head);
+
 static void sn_set_affinity_irq(unsigned int irq, cpumask_t mask)
 {
-	struct sn_irq_info *sn_irq_info = sn_irq[irq];
+	struct sn_irq_info *sn_irq_info, *sn_irq_info_safe;
 	struct sn_irq_info *tmp_sn_irq_info;
 	int cpuid, cpuphys;
-	nasid_t t_nasid;	/* nasid to target */
-	int t_slice;		/* slice to target */
 
 	/* allocate a temp sn_irq_info struct to get new target info */
 	tmp_sn_irq_info = kmalloc(sizeof(*tmp_sn_irq_info), GFP_KERNEL);
@@ -141,56 +143,61 @@
 
 	cpuid = first_cpu(mask);
 	cpuphys = cpu_physical_id(cpuid);
-	t_nasid = cpuid_to_nasid(cpuid);
-	t_slice = cpuid_to_slice(cpuid);
 
-	while (sn_irq_info) {
-		int status;
-		int local_widget;
-		uint64_t bridge = (uint64_t) sn_irq_info->irq_bridge;
-		nasid_t local_nasid = NASID_GET(bridge);
+	list_for_each_entry_safe(sn_irq_info, sn_irq_info_safe, 
+						sn_irq_lh[irq], list) {
+		uint64_t bridge;
+		int local_widget, status;
+		nasid_t local_nasid;
+		struct sn_irq_info *tmp_irq_info;
+
+		tmp_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_ATOMIC);
+		if (tmp_irq_info == NULL)
+			break;
+		memcpy(tmp_irq_info, sn_irq_info, sizeof(struct sn_irq_info));
 
+		bridge = (uint64_t) tmp_irq_info->irq_bridge;
 		if (!bridge)
-			break;	/* irq is not a device interrupt */
+			break; /* irq is not a device interrupt */
+
+		local_nasid = NASID_GET(bridge);
 
 		if (local_nasid & 1)
 			local_widget = TIO_SWIN_WIDGETNUM(bridge);
 		else
 			local_widget = SWIN_WIDGETNUM(bridge);
 
-		/* Free the old PROM sn_irq_info structure */
-		sn_intr_free(local_nasid, local_widget, sn_irq_info);
+		/* Free the old PROM tmp_irq_info structure */
+		sn_intr_free(local_nasid, local_widget, tmp_irq_info);
+		/* Update kernels tmp_irq_info with new target info */
+		unregister_intr_pda(tmp_irq_info);
 
-		/* allocate a new PROM sn_irq_info struct */
+		/* allocate a new PROM tmp_irq_info struct */
 		status = sn_intr_alloc(local_nasid, local_widget,
-				       __pa(tmp_sn_irq_info), irq, t_nasid,
-				       t_slice);
+				       __pa(tmp_irq_info), irq,
+				       cpuid_to_nasid(cpuid),
+				       cpuid_to_slice(cpuid));
+
+		/* SAL call failed */	
+		if (status)
+			break;
 
-		if (status == 0) {
-			/* Update kernels sn_irq_info with new target info */
-			unregister_intr_pda(sn_irq_info);
-			sn_irq_info->irq_cpuid = cpuid;
-			sn_irq_info->irq_nasid = t_nasid;
-			sn_irq_info->irq_slice = t_slice;
-			sn_irq_info->irq_xtalkaddr =
-			    tmp_sn_irq_info->irq_xtalkaddr;
-			sn_irq_info->irq_cookie = tmp_sn_irq_info->irq_cookie;
-			register_intr_pda(sn_irq_info);
+		tmp_irq_info->irq_cpuid = cpuid;
+		register_intr_pda(tmp_irq_info);
 
-			if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type)) {
-				pcibr_change_devices_irq(sn_irq_info);
-			}
+		if (IS_PCI_BRIDGE_ASIC(tmp_irq_info->irq_bridge_type)) {
+			pcibr_change_devices_irq(tmp_irq_info);
+		}
 
-			sn_irq_info = sn_irq_info->irq_next;
+		spin_lock(&sn_irq_info_lock);
+		list_replace_rcu(&sn_irq_info->list, &tmp_irq_info->list);
+		spin_unlock(&sn_irq_info_lock);
+		call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
 
 #ifdef CONFIG_SMP
-			set_irq_affinity_info((irq & 0xff), cpuphys, 0);
+		set_irq_affinity_info((irq & 0xff), cpuphys, 0);
 #endif
-		} else {
-			break;	/* snp_affinity failed the intr_alloc */
-		}
 	}
-	kfree(tmp_sn_irq_info);
 }
 
 struct hw_interrupt_type irq_type_sn = {
@@ -242,20 +249,19 @@
 	struct sn_irq_info *tmp_irq_info;
 	int i, foundmatch;
 
+	rcu_read_lock();
 	if (pdacpu(cpu)->sn_last_irq == irq) {
 		foundmatch = 0;
 		for (i = pdacpu(cpu)->sn_last_irq - 1; i; i--) {
-			tmp_irq_info = sn_irq[i];
-			while (tmp_irq_info) {
+			list_for_each_entry_rcu(tmp_irq_info, sn_irq_lh[i], list) {
 				if (tmp_irq_info->irq_cpuid == cpu) {
 					foundmatch++;
 					break;
 				}
-				tmp_irq_info = tmp_irq_info->irq_next;
 			}
-			if (foundmatch) {
+
+			if (foundmatch)
 				break;
-			}
 		}
 		pdacpu(cpu)->sn_last_irq = i;
 	}
@@ -263,20 +269,19 @@
 	if (pdacpu(cpu)->sn_first_irq == irq) {
 		foundmatch = 0;
 		for (i = pdacpu(cpu)->sn_first_irq + 1; i < NR_IRQS; i++) {
-			tmp_irq_info = sn_irq[i];
-			while (tmp_irq_info) {
+			list_for_each_entry_rcu(tmp_irq_info, sn_irq_lh[i], list) {
 				if (tmp_irq_info->irq_cpuid == cpu) {
 					foundmatch++;
 					break;
 				}
-				tmp_irq_info = tmp_irq_info->irq_next;
 			}
-			if (foundmatch) {
+
+			if (foundmatch)
 				break;
-			}
 		}
 		pdacpu(cpu)->sn_first_irq = ((i == NR_IRQS) ? 0 : i);
 	}
+	rcu_read_unlock();
 }
 
 struct sn_irq_info *sn_irq_alloc(nasid_t local_nasid, int local_widget, int irq,
@@ -303,6 +308,15 @@
 	}
 }
 
+static void sn_irq_info_free(struct rcu_head *head)
+{
+	struct sn_irq_info *sn_irq_info = container_of(head,
+						struct sn_irq_info, rcu);
+
+	kfree(sn_irq_info);
+}
+
+
 void sn_irq_free(struct sn_irq_info *sn_irq_info)
 {
 	uint64_t bridge = (uint64_t) sn_irq_info->irq_bridge;
@@ -329,26 +343,46 @@
 	sn_irq_info->irq_pciioinfo = SN_PCIDEV_INFO(pci_dev);
 
 	/* link it into the sn_irq[irq] list */
-	sn_irq_info->irq_next = sn_irq[sn_irq_info->irq_irq];
-	sn_irq[sn_irq_info->irq_irq] = sn_irq_info;
+
+	spin_lock(&sn_irq_info_lock);
+	list_add_rcu(&sn_irq_info->list, sn_irq_lh[sn_irq_info->irq_irq]);
+	spin_unlock(&sn_irq_info_lock);
 
 	(void)register_intr_pda(sn_irq_info);
 }
 
+void sn_irq_unfixup(struct pci_dev *pci_dev)
+{
+	struct sn_irq_info *sn_irq_info;
+
+	/* Only cleanup IRQ stuff if this device has a host bus context */
+	if (!SN_PCIDEV_BUSSOFT(pci_dev))
+		return;
+
+	sn_irq_info = SN_PCIDEV_INFO(pci_dev)->pdi_sn_irq_info;
+
+	unregister_intr_pda(sn_irq_info);
+	spin_lock(&sn_irq_info_lock);
+	list_del_rcu(&sn_irq_info->list);
+	spin_unlock(&sn_irq_info_lock);
+	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
+}
+
 static void force_interrupt(int irq)
 {
 	struct sn_irq_info *sn_irq_info;
 
 	if (!sn_ioif_inited)
 		return;
-	sn_irq_info = sn_irq[irq];
-	while (sn_irq_info) {
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[irq], list)
+	{
 		if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
-		    (sn_irq_info->irq_bridge != NULL)) {
-			pcibr_force_interrupt(sn_irq_info);
-		}
-		sn_irq_info = sn_irq_info->irq_next;
+			(sn_irq_info->irq_bridge != NULL))
+				pcibr_force_interrupt(sn_irq_info);
 	}
+	rcu_read_unlock();
 }
 
 /*
@@ -413,19 +447,21 @@
 
 void sn_lb_int_war_check(void)
 {
+	struct sn_irq_info *sn_irq_info;
 	int i;
 
 	if (!sn_ioif_inited || pda->sn_first_irq == 0)
 		return;
+
+	rcu_read_lock();
 	for (i = pda->sn_first_irq; i <= pda->sn_last_irq; i++) {
-		struct sn_irq_info *sn_irq_info = sn_irq[i];
-		while (sn_irq_info) {
+		list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[i], list) {
 			/* Only call for PCI bridges that are fully initialized. */
 			if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
 			    (sn_irq_info->irq_bridge != NULL)) {
 				sn_check_intr(i, sn_irq_info);
 			}
-			sn_irq_info = sn_irq_info->irq_next;
 		}
 	}
+	rcu_read_unlock();
 }
diff -Nru a/include/asm-ia64/sn/intr.h b/include/asm-ia64/sn/intr.h
--- a/include/asm-ia64/sn/intr.h	2005-03-15 20:23:19 -05:00
+++ b/include/asm-ia64/sn/intr.h	2005-03-15 20:23:19 -05:00
@@ -9,6 +9,8 @@
 #ifndef _ASM_IA64_SN_INTR_H
 #define _ASM_IA64_SN_INTR_H
 
+#include <linux/rcupdate.h>
+
 #define SGI_UART_VECTOR		(0xe9)
 #define SGI_PCIBR_ERROR		(0x33)
 
@@ -47,6 +49,9 @@
 	int		irq_cookie;	/* unique cookie 	     */
 	int		irq_flags;	/* flags */
 	int		irq_share_cnt;	/* num devices sharing IRQ   */
+	struct list_head	list;	/* list of sn_irq_info structs */
+	struct rcu_head		rcu;	/* rcu callback list */
+	
 };
 
 extern void sn_send_IPI_phys(int, long, int, int);

--------------040300030404000301050406--
