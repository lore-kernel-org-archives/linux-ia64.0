From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 04 Mar 2005 16:37:20 +0000
Subject: Re: [PATCH/RFC]: Clean up of sn_irq_info list
Message-Id: <42288EC0.8090701@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42276523.3060107@sgi.com>
In-Reply-To: <42276523.3060107@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

NAKing this patch after further input.  Will resubmit new patch later 
next week ;)

P.

Prarit Bhargava wrote:

> After input from Jesse Barnes, jbarnes@sgi.com here's a new patch.
>
> P.
>
>------------------------------------------------------------------------
>
>=== arch/ia64/sn/kernel/io_init.c 1.9 vs edited ==>--- 1.9/arch/ia64/sn/kernel/io_init.c	2005-01-11 19:22:08 -05:00
>+++ edited/arch/ia64/sn/kernel/io_init.c	2005-03-02 13:52:37 -05:00
>@@ -343,10 +343,6 @@
> 	 */
> 	ia64_max_iommu_merge_mask = ~PAGE_MASK;
> 	sn_fixup_ionodes();
>-	sn_irq = kmalloc(sizeof(struct sn_irq_info *) * NR_IRQS, GFP_KERNEL);
>-	if (sn_irq <= 0)
>-		BUG();		/* Canno afford to run out of memory. */
>-	memset(sn_irq, 0, sizeof(struct sn_irq_info *) * NR_IRQS);
> 
> 	sn_init_cpei_timer();
> 
>=== arch/ia64/sn/kernel/irq.c 1.31 vs edited ==>--- 1.31/arch/ia64/sn/kernel/irq.c	2005-01-22 18:54:50 -05:00
>+++ edited/arch/ia64/sn/kernel/irq.c	2005-03-03 14:52:39 -05:00
>@@ -9,6 +9,7 @@
>  */
> 
> #include <linux/irq.h>
>+#include <linux/spinlock.h>
> #include <asm/sn/intr.h>
> #include <asm/sn/addrs.h>
> #include <asm/sn/arch.h>
>@@ -22,10 +23,11 @@
> static void force_interrupt(int irq);
> static void register_intr_pda(struct sn_irq_info *sn_irq_info);
> static void unregister_intr_pda(struct sn_irq_info *sn_irq_info);
>+static spinlock_t sn_irq_info_lock = SPIN_LOCK_UNLOCKED; /* non-IRQ lock */
> 
> extern int sn_force_interrupt_flag;
> extern int sn_ioif_inited;
>-struct sn_irq_info **sn_irq;
>+static LIST_HEAD(sn_irq_info_list);
> 
> static inline uint64_t sn_intr_alloc(nasid_t local_nasid, int local_widget,
> 				     u64 sn_irq_info,
>@@ -128,69 +130,71 @@
> 
> static void sn_set_affinity_irq(unsigned int irq, cpumask_t mask)
> {
>-	struct sn_irq_info *sn_irq_info = sn_irq[irq];
>-	struct sn_irq_info *tmp_sn_irq_info;
>+	struct sn_irq_info *sn_irq_info;
> 	int cpuid, cpuphys;
> 	nasid_t t_nasid;	/* nasid to target */
> 	int t_slice;		/* slice to target */
>-
>-	/* allocate a temp sn_irq_info struct to get new target info */
>-	tmp_sn_irq_info = kmalloc(sizeof(*tmp_sn_irq_info), GFP_KERNEL);
>-	if (!tmp_sn_irq_info)
>-		return;
>+	int status;
>+	int local_widget;
> 
> 	cpuid = first_cpu(mask);
> 	cpuphys = cpu_physical_id(cpuid);
> 	t_nasid = cpuid_to_nasid(cpuid);
> 	t_slice = cpuid_to_slice(cpuid);
> 
>-	while (sn_irq_info) {
>-		int status;
>-		int local_widget;
>-		uint64_t bridge = (uint64_t) sn_irq_info->irq_bridge;
>-		nasid_t local_nasid = NASID_GET(bridge);
>+	list_for_each_entry(sn_irq_info, &sn_irq_info_list, list) {
>+		uint64_t bridge;
>+		nasid_t local_nasid;
>+		struct sn_irq_info *tmp_irq_info;
>+
>+		tmp_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_ATOMIC);
>+		if (tmp_irq_info = NULL)
>+			break;
>+		memcpy(tmp_irq_info, sn_irq_info, sizeof(struct sn_irq_info));
> 
>+		bridge = (uint64_t) tmp_irq_info->irq_bridge;
> 		if (!bridge)
>-			break;	/* irq is not a device interrupt */
>+			break; /* irq is not a device interrupt */
>+
>+		local_nasid = NASID_GET(bridge);
> 
> 		if (local_nasid & 1)
> 			local_widget = TIO_SWIN_WIDGETNUM(bridge);
> 		else
> 			local_widget = SWIN_WIDGETNUM(bridge);
> 
>-		/* Free the old PROM sn_irq_info structure */
>-		sn_intr_free(local_nasid, local_widget, sn_irq_info);
>+		/* Free the old PROM tmp_irq_info structure */
>+		sn_intr_free(local_nasid, local_widget, tmp_irq_info);
>+		/* Update kernels tmp_irq_info with new target info */
>+		unregister_intr_pda(tmp_irq_info);
> 
>-		/* allocate a new PROM sn_irq_info struct */
>+		/* allocate a new PROM tmp_irq_info struct */
> 		status = sn_intr_alloc(local_nasid, local_widget,
>-				       __pa(tmp_sn_irq_info), irq, t_nasid,
>+				       __pa(tmp_irq_info), irq, t_nasid,
> 				       t_slice);
> 
>-		if (status = 0) {
>-			/* Update kernels sn_irq_info with new target info */
>-			unregister_intr_pda(sn_irq_info);
>-			sn_irq_info->irq_cpuid = cpuid;
>-			sn_irq_info->irq_nasid = t_nasid;
>-			sn_irq_info->irq_slice = t_slice;
>-			sn_irq_info->irq_xtalkaddr >-			    tmp_sn_irq_info->irq_xtalkaddr;
>-			sn_irq_info->irq_cookie = tmp_sn_irq_info->irq_cookie;
>-			register_intr_pda(sn_irq_info);
>-
>-			if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type)) {
>-				pcibr_change_devices_irq(sn_irq_info);
>-			}
>-
>-			sn_irq_info = sn_irq_info->irq_next;
>+		/* SAL call failed */	
>+		if (status)
>+			break;
>+
>+		tmp_irq_info->irq_cpuid = cpuid;
>+		tmp_irq_info->irq_nasid = t_nasid;
>+		tmp_irq_info->irq_slice = t_slice;
>+		register_intr_pda(tmp_irq_info);
>+
>+		if (IS_PCI_BRIDGE_ASIC(tmp_irq_info->irq_bridge_type))
>+			pcibr_change_devices_irq(tmp_irq_info);
>+
>+		spin_lock(&sn_irq_info_lock);
>+		list_add_rcu(&tmp_irq_info->list, &sn_irq_info->list);
>+		list_del_rcu(&sn_irq_info->list);
>+		spin_unlock(&sn_irq_info_lock);
>+		call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
> 
> #ifdef CONFIG_SMP
>-			set_irq_affinity_info((irq & 0xff), cpuphys, 0);
>+		set_irq_affinity_info((irq & 0xff), cpuphys, 0);
> #endif
>-		} else {
>-			break;	/* snp_affinity failed the intr_alloc */
>-		}
> 	}
>-	kfree(tmp_sn_irq_info);
> }
> 
> struct hw_interrupt_type irq_type_sn = {
>@@ -223,60 +227,42 @@
> 
> static void register_intr_pda(struct sn_irq_info *sn_irq_info)
> {
>-	int irq = sn_irq_info->irq_irq;
> 	int cpu = sn_irq_info->irq_cpuid;
> 
>-	if (pdacpu(cpu)->sn_last_irq < irq) {
>-		pdacpu(cpu)->sn_last_irq = irq;
>-	}
>+	pdacpu(cpu)->sn_last_irq = max(sn_irq_info->irq_irq, 
>+					pdacpu(cpu)->sn_last_irq);
> 
>-	if (pdacpu(cpu)->sn_first_irq = 0 || pdacpu(cpu)->sn_first_irq > irq) {
>-		pdacpu(cpu)->sn_first_irq = irq;
>-	}
>+	pdacpu(cpu)->sn_first_irq = min(sn_irq_info->irq_irq, 
>+					pdacpu(cpu)->sn_last_irq);
> }
> 
> static void unregister_intr_pda(struct sn_irq_info *sn_irq_info)
> {
>-	int irq = sn_irq_info->irq_irq;
>-	int cpu = sn_irq_info->irq_cpuid;
> 	struct sn_irq_info *tmp_irq_info;
>-	int i, foundmatch;
>+	int cpu = sn_irq_info->irq_cpuid;
>+	int irq = sn_irq_info->irq_irq;
> 
>-	if (pdacpu(cpu)->sn_last_irq = irq) {
>-		foundmatch = 0;
>-		for (i = pdacpu(cpu)->sn_last_irq - 1; i; i--) {
>-			tmp_irq_info = sn_irq[i];
>-			while (tmp_irq_info) {
>-				if (tmp_irq_info->irq_cpuid = cpu) {
>-					foundmatch++;
>-					break;
>-				}
>-				tmp_irq_info = tmp_irq_info->irq_next;
>-			}
>-			if (foundmatch) {
>-				break;
>-			}
>-		}
>-		pdacpu(cpu)->sn_last_irq = i;
>-	}
>+	rcu_read_lock();
>+	list_for_each_entry_rcu(tmp_irq_info, &sn_irq_info_list, list) {
> 
>-	if (pdacpu(cpu)->sn_first_irq = irq) {
>-		foundmatch = 0;
>-		for (i = pdacpu(cpu)->sn_first_irq + 1; i < NR_IRQS; i++) {
>-			tmp_irq_info = sn_irq[i];
>-			while (tmp_irq_info) {
>-				if (tmp_irq_info->irq_cpuid = cpu) {
>-					foundmatch++;
>-					break;
>-				}
>-				tmp_irq_info = tmp_irq_info->irq_next;
>-			}
>-			if (foundmatch) {
>-				break;
>-			}
>+		spin_lock(&tmp_irq_info->lock);
>+
>+		if (tmp_irq_info->irq_cpuid = cpu) {
>+		/* I'm only interested in irq's on cpus
>+		   that correspond to sn_irq_info */
>+			if (tmp_irq_info->irq_irq < irq)
>+				pdacpu(cpu)->sn_last_irq = 
>+					max(tmp_irq_info->irq_irq, 
>+					pdacpu(cpu)->sn_last_irq);
>+
>+			if (tmp_irq_info->irq_irq >= irq)
>+				pdacpu(cpu)->sn_first_irq = 
>+					min(tmp_irq_info->irq_irq, 
>+					pdacpu(cpu)->sn_first_irq);
> 		}
>-		pdacpu(cpu)->sn_first_irq = ((i = NR_IRQS) ? 0 : i);
>+		spin_unlock(&tmp_irq_info->lock);
> 	}
>+	rcu_read_unlock();
> }
> 
> struct sn_irq_info *sn_irq_alloc(nasid_t local_nasid, int local_widget, int irq,
>@@ -285,11 +271,11 @@
> 	struct sn_irq_info *sn_irq_info;
> 	int status;
> 
>-	sn_irq_info = kmalloc(sizeof(*sn_irq_info), GFP_KERNEL);
>+	sn_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
> 	if (sn_irq_info = NULL)
> 		return NULL;
> 
>-	memset(sn_irq_info, 0x0, sizeof(*sn_irq_info));
>+	memset(sn_irq_info, 0x0, sizeof(struct sn_irq_info));
> 
> 	status > 	    sn_intr_alloc(local_nasid, local_widget, __pa(sn_irq_info), irq,
>@@ -303,6 +289,13 @@
> 	}
> }
> 
>+static void sn_irq_info_free(struct rcu_head *head)
>+{
>+	struct sn_irq_info *sn_irq_info = container_of(head, 
>+						struct sn_irq_info, rcu);
>+	kfree(sn_irq_info);
>+}
>+
> void sn_irq_free(struct sn_irq_info *sn_irq_info)
> {
> 	uint64_t bridge = (uint64_t) sn_irq_info->irq_bridge;
>@@ -328,26 +321,49 @@
> 	sn_irq_info->irq_cpuid = cpu;
> 	sn_irq_info->irq_pciioinfo = SN_PCIDEV_INFO(pci_dev);
> 
>-	/* link it into the sn_irq[irq] list */
>-	sn_irq_info->irq_next = sn_irq[sn_irq_info->irq_irq];
>-	sn_irq[sn_irq_info->irq_irq] = sn_irq_info;
>-
>+	/* link it into sn_irq_info_list */
>+	spin_lock(&sn_irq_info_lock);
>+	spin_lock(&sn_irq_info->lock);
>+	list_add_rcu(&sn_irq_info->list, &sn_irq_info_list);
>+	spin_unlock(&sn_irq_info->lock);
>+	spin_unlock(&sn_irq_info_lock);
> 	(void)register_intr_pda(sn_irq_info);
> }
> 
>+void sn_irq_unfixup(struct pci_dev *pci_dev)
>+{
>+	struct sn_irq_info *sn_irq_info;
>+
>+	/* Only cleanup IRQ stuff if this device has a host bus context */
>+	if (!SN_PCIDEV_BUSSOFT(pci_dev))
>+		return;
>+
>+	sn_irq_info = SN_PCIDEV_INFO(pci_dev)->pdi_sn_irq_info;
>+
>+	unregister_intr_pda(sn_irq_info);
>+	spin_lock(&sn_irq_info_lock);
>+	spin_lock(&sn_irq_info->lock);
>+	list_del_rcu(&sn_irq_info->list);
>+	spin_unlock(&sn_irq_info->lock);
>+	spin_unlock(&sn_irq_info_lock);
>+	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
>+}
>+
> static void force_interrupt(int irq)
> {
> 	struct sn_irq_info *sn_irq_info;
> 
> 	if (!sn_ioif_inited)
> 		return;
>-	sn_irq_info = sn_irq[irq];
>-	while (sn_irq_info) {
>-		if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
>-		    (sn_irq_info->irq_bridge != NULL)) {
>-			pcibr_force_interrupt(sn_irq_info);
>-		}
>-		sn_irq_info = sn_irq_info->irq_next;
>+
>+	rcu_read_lock();
>+	list_for_each_entry_rcu(sn_irq_info, &sn_irq_info_list, list) {
>+
>+		if ((sn_irq_info->irq_irq >= irq) &&
>+			(IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type)) &&
>+			(sn_irq_info->irq_bridge != NULL))
>+				pcibr_force_interrupt(sn_irq_info);
>+
> 	}
> }
> 
>@@ -360,7 +376,7 @@
>  * the interrupt is in flight, so we may generate a spurious interrupt,
>  * but we should never miss a real lost interrupt.
>  */
>-static void sn_check_intr(int irq, struct sn_irq_info *sn_irq_info)
>+static void sn_check_intr(struct sn_irq_info *sn_irq_info)
> {
> 	uint64_t regval;
> 	int irr_reg_num;
>@@ -368,6 +384,7 @@
> 	uint64_t irr_reg;
> 	struct pcidev_info *pcidev_info;
> 	struct pcibus_info *pcibus_info;
>+	int irq = sn_irq_info->irq_irq;
> 
> 	pcidev_info = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
> 	if (!pcidev_info)
>@@ -413,19 +430,18 @@
> 
> void sn_lb_int_war_check(void)
> {
>-	int i;
>+	struct sn_irq_info *sn_irq_info;
> 
> 	if (!sn_ioif_inited || pda->sn_first_irq = 0)
> 		return;
>-	for (i = pda->sn_first_irq; i <= pda->sn_last_irq; i++) {
>-		struct sn_irq_info *sn_irq_info = sn_irq[i];
>-		while (sn_irq_info) {
>-			/* Only call for PCI bridges that are fully initialized. */
>-			if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
>-			    (sn_irq_info->irq_bridge != NULL)) {
>-				sn_check_intr(i, sn_irq_info);
>-			}
>-			sn_irq_info = sn_irq_info->irq_next;
>-		}
>+
>+	rcu_read_lock();
>+	list_for_each_entry_rcu(sn_irq_info, &sn_irq_info_list, list) {
>+
>+		/* Only call for PCI bridges that are fully initialized. */
>+		if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
>+		    (sn_irq_info->irq_bridge != NULL))
>+			sn_check_intr(sn_irq_info);
> 	}
>+	rcu_read_unlock();
> }
>=== include/asm-ia64/sn/intr.h 1.12 vs edited ==>--- 1.12/include/asm-ia64/sn/intr.h	2004-11-19 02:03:12 -05:00
>+++ edited/include/asm-ia64/sn/intr.h	2005-03-02 13:53:46 -05:00
>@@ -9,6 +9,8 @@
> #ifndef _ASM_IA64_SN_INTR_H
> #define _ASM_IA64_SN_INTR_H
> 
>+#include <linux/rcupdate.h>
>+
> #define SGI_UART_VECTOR		(0xe9)
> #define SGI_PCIBR_ERROR		(0x33)
> 
>@@ -47,6 +49,9 @@
> 	int		irq_cookie;	/* unique cookie 	     */
> 	int		irq_flags;	/* flags */
> 	int		irq_share_cnt;	/* num devices sharing IRQ   */
>+	spinlock_t	lock;		/* lock for access */
>+	struct list_head list; 		/* sharing irq list */
>+	struct rcu_head rcu;		/* rcu callback list */
> };
> 
> extern void sn_send_IPI_phys(int, long, int, int);
>  
>
