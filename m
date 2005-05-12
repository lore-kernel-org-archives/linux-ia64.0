From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 12 May 2005 13:46:47 +0000
Subject: [PATCH 1/6]: hotplug/ia64: SN Hotplug Driver: SN IRQ Fixes
Message-Id: <42835E47.1010600@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch  fixes the SN IRQ code such that cpu affinity and
Hotplug can modify IRQ values.  The sn_irq_info structures are now locked
using a RCU lock mechanism to avoid lock contention in the lost interrupt
WAR code.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 278b70abe5b0a30267bd80b4f49fc8027e36d3ad
tree d53d603c8c1a083db8df0c479b9bf296288dbc74
parent 88d7bd8cb9eb8d64bf7997600b0d64f7834047c5
author Prarit Bhargava <prarit@sgi.com> 1810126346 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810126346 -0400

Index: arch/ia64/sn/kernel/io_init.c
=================================--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/arch/ia64/sn/kernel/io_init.c
(mode:100644 sha1:9e07f5463f21d53fcac34ec658f443ca550b4222)
+++ d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/kernel/io_init.c
(mode:100644 sha1:cb29bd1d475d1be98d32aa02f81f576e77b327d2)
@@ -21,7 +21,6 @@
  #include <asm/sn/simulator.h>
  #include <asm/sn/tioca_provider.h>

-char master_baseio_wid;
  nasid_t master_nasid = INVALID_NASID;	/* Partition Master */

  struct slab_info {
@@ -231,11 +230,13 @@
  {
  	int idx;
  	int segment = 0;
-	uint64_t size;
-	struct sn_irq_info *sn_irq_info;
-	struct pci_dev *host_pci_dev;
  	int status = 0;
  	struct pcibus_bussoft *bs;
+ 	struct pci_bus *host_pci_bus;
+ 	struct pci_dev *host_pci_dev;
+ 	struct sn_irq_info *sn_irq_info;
+ 	unsigned long size;
+ 	unsigned int bus_no, devfn;

  	dev->sysdata = kmalloc(sizeof(struct pcidev_info), GFP_KERNEL);
  	if (SN_PCIDEV_INFO(dev) <= 0)
@@ -253,7 +254,7 @@
  				     (u64) __pa(SN_PCIDEV_INFO(dev)),
  				     (u64) __pa(sn_irq_info));
  	if (status)
-		BUG();		/* Cannot get platform pci device information information */
+		BUG(); /* Cannot get platform pci device information */

  	/* Copy over PIO Mapped Addresses */
  	for (idx = 0; idx <= PCI_ROM_RESOURCE; idx++) {
@@ -275,15 +276,20 @@
  			dev->resource[idx].parent = &iomem_resource;
  	}

-	/* set up host bus linkages */
-	bs = SN_PCIBUS_BUSSOFT(dev->bus);
-	host_pci_dev -	    pci_find_slot(SN_PCIDEV_INFO(dev)->pdi_slot_host_handle >> 32,
-			  SN_PCIDEV_INFO(dev)->
-			  pdi_slot_host_handle & 0xffffffff);
+ 	/* Using the PROMs values for the PCI host bus, get the Linux
+ 	 * PCI host_pci_dev struct and set up host bus linkages
+ 	 */
+
+ 	bus_no = SN_PCIDEV_INFO(dev)->pdi_slot_host_handle >> 32;
+ 	devfn = SN_PCIDEV_INFO(dev)->pdi_slot_host_handle & 0xffffffff;
+ 	host_pci_bus = pci_find_bus(pci_domain_nr(dev->bus), bus_no);
+ 	host_pci_dev = pci_get_slot(host_pci_bus, devfn);
+
+	SN_PCIDEV_INFO(dev)->host_pci_dev = host_pci_dev;
  	SN_PCIDEV_INFO(dev)->pdi_host_pcidev_info -	    SN_PCIDEV_INFO(host_pci_dev);
+	    					SN_PCIDEV_INFO(host_pci_dev);
  	SN_PCIDEV_INFO(dev)->pdi_linux_pcidev = dev;
+	bs = SN_PCIBUS_BUSSOFT(dev->bus);
  	SN_PCIDEV_INFO(dev)->pdi_pcibus_info = bs;

  	if (bs && bs->bs_asic_type < PCIIO_ASIC_MAX_TYPES) {
@@ -297,6 +303,9 @@
  		SN_PCIDEV_INFO(dev)->pdi_sn_irq_info = sn_irq_info;
  		dev->irq = SN_PCIDEV_INFO(dev)->pdi_sn_irq_info->irq_irq;
  		sn_irq_fixup(dev, sn_irq_info);
+	} else {
+		SN_PCIDEV_INFO(dev)->pdi_sn_irq_info = NULL;
+		kfree(sn_irq_info);
  	}
  }

@@ -403,11 +412,7 @@
  	 */
  	ia64_max_iommu_merge_mask = ~PAGE_MASK;
  	sn_fixup_ionodes();
-	sn_irq = kmalloc(sizeof(struct sn_irq_info *) * NR_IRQS, GFP_KERNEL);
-	if (sn_irq <= 0)
-		BUG();		/* Canno afford to run out of memory. */
-	memset(sn_irq, 0, sizeof(struct sn_irq_info *) * NR_IRQS);
-
+	sn_irq_lh_init();
  	sn_init_cpei_timer();

  #ifdef CONFIG_PROC_FS
Index: arch/ia64/sn/kernel/irq.c
=================================--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/arch/ia64/sn/kernel/irq.c
(mode:100644 sha1:0f4e8138658f2cb0ac1ce5757736906f8d7ba0b6)
+++ d53d603c8c1a083db8df0c479b9bf296288dbc74/arch/ia64/sn/kernel/irq.c
(mode:100644 sha1:e6f7551edfda49e8d22e9378a7d09a63ff009d0d)
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
+static struct list_head **sn_irq_lh;
+static spinlock_t sn_irq_info_lock = SPIN_LOCK_UNLOCKED; /* non-IRQ lock */

  static inline uint64_t sn_intr_alloc(nasid_t local_nasid, int local_widget,
  				     u64 sn_irq_info,
@@ -101,7 +103,7 @@
  		nasid = get_nasid();
  		event_occurred = HUB_L((uint64_t *) GLOBAL_MMR_ADDR
  				       (nasid, SH_EVENT_OCCURRED));
-		/* If the UART bit is set here, we may have received an
+		/* If the UART bit is set here, we may have received an
  		 * interrupt from the UART that the driver missed.  To
  		 * make sure, we IPI ourselves to force us to look again.
  		 */
@@ -115,82 +117,84 @@
  		force_interrupt(irq);
  }

+static void sn_irq_info_free(struct rcu_head *head);
+
  static void sn_set_affinity_irq(unsigned int irq, cpumask_t mask)
  {
-	struct sn_irq_info *sn_irq_info = sn_irq[irq];
-	struct sn_irq_info *tmp_sn_irq_info;
+	struct sn_irq_info *sn_irq_info, *sn_irq_info_safe;
  	int cpuid, cpuphys;
-	nasid_t t_nasid;	/* nasid to target */
-	int t_slice;		/* slice to target */
-
-	/* allocate a temp sn_irq_info struct to get new target info */
-	tmp_sn_irq_info = kmalloc(sizeof(*tmp_sn_irq_info), GFP_KERNEL);
-	if (!tmp_sn_irq_info)
-		return;

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
+				 sn_irq_lh[irq], list) {
+		uint64_t bridge;
+		int local_widget, status;
+		nasid_t local_nasid;
+		struct sn_irq_info *new_irq_info;
+
+		new_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_ATOMIC);
+		if (new_irq_info = NULL)
+			break;
+		memcpy(new_irq_info, sn_irq_info, sizeof(struct sn_irq_info));
+
+		bridge = (uint64_t) new_irq_info->irq_bridge;
+		if (!bridge) {
+			kfree(new_irq_info);
+			break; /* irq is not a device interrupt */
+		}

-		if (!bridge)
-			break;	/* irq is not a device interrupt */
+		local_nasid = NASID_GET(bridge);

  		if (local_nasid & 1)
  			local_widget = TIO_SWIN_WIDGETNUM(bridge);
  		else
  			local_widget = SWIN_WIDGETNUM(bridge);

-		/* Free the old PROM sn_irq_info structure */
-		sn_intr_free(local_nasid, local_widget, sn_irq_info);
+		/* Free the old PROM new_irq_info structure */
+		sn_intr_free(local_nasid, local_widget, new_irq_info);
+		/* Update kernels new_irq_info with new target info */
+		unregister_intr_pda(new_irq_info);

-		/* allocate a new PROM sn_irq_info struct */
+		/* allocate a new PROM new_irq_info struct */
  		status = sn_intr_alloc(local_nasid, local_widget,
-				       __pa(tmp_sn_irq_info), irq, t_nasid,
-				       t_slice);
+				       __pa(new_irq_info), irq,
+				       cpuid_to_nasid(cpuid),
+				       cpuid_to_slice(cpuid));
+
+		/* SAL call failed */
+		if (status) {
+			kfree(new_irq_info);
+			break;
+		}

-		if (status = 0) {
-			/* Update kernels sn_irq_info with new target info */
-			unregister_intr_pda(sn_irq_info);
-			sn_irq_info->irq_cpuid = cpuid;
-			sn_irq_info->irq_nasid = t_nasid;
-			sn_irq_info->irq_slice = t_slice;
-			sn_irq_info->irq_xtalkaddr -			    tmp_sn_irq_info->irq_xtalkaddr;
-			sn_irq_info->irq_cookie = tmp_sn_irq_info->irq_cookie;
-			register_intr_pda(sn_irq_info);
+		new_irq_info->irq_cpuid = cpuid;
+		register_intr_pda(new_irq_info);

-			if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type)) {
-				pcibr_change_devices_irq(sn_irq_info);
-			}
+		if (IS_PCI_BRIDGE_ASIC(new_irq_info->irq_bridge_type))
+			pcibr_change_devices_irq(new_irq_info);

-			sn_irq_info = sn_irq_info->irq_next;
+		spin_lock(&sn_irq_info_lock);
+		list_replace_rcu(&sn_irq_info->list, &new_irq_info->list);
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
-	"SN hub",
-	sn_startup_irq,
-	sn_shutdown_irq,
-	sn_enable_irq,
-	sn_disable_irq,
-	sn_ack_irq,
-	sn_end_irq,
-	sn_set_affinity_irq
+	.typename	= "SN hub",
+	.startup	= sn_startup_irq,
+	.shutdown	= sn_shutdown_irq,
+	.enable		= sn_enable_irq,
+	.disable	= sn_disable_irq,
+	.ack		= sn_ack_irq,
+	.end		= sn_end_irq,
+	.set_affinity	= sn_set_affinity_irq
  };

  unsigned int sn_local_vector_to_irq(u8 vector)
@@ -231,19 +235,18 @@
  	struct sn_irq_info *tmp_irq_info;
  	int i, foundmatch;

+	rcu_read_lock();
  	if (pdacpu(cpu)->sn_last_irq = irq) {
  		foundmatch = 0;
-		for (i = pdacpu(cpu)->sn_last_irq - 1; i; i--) {
-			tmp_irq_info = sn_irq[i];
-			while (tmp_irq_info) {
+		for (i = pdacpu(cpu)->sn_last_irq - 1;
+		     i && !foundmatch; i--) {
+			list_for_each_entry_rcu(tmp_irq_info,
+						sn_irq_lh[i],
+						list) {
  				if (tmp_irq_info->irq_cpuid = cpu) {
-					foundmatch++;
+					foundmatch = 1;
  					break;
  				}
-				tmp_irq_info = tmp_irq_info->irq_next;
-			}
-			if (foundmatch) {
-				break;
  			}
  		}
  		pdacpu(cpu)->sn_last_irq = i;
@@ -251,60 +254,27 @@

  	if (pdacpu(cpu)->sn_first_irq = irq) {
  		foundmatch = 0;
-		for (i = pdacpu(cpu)->sn_first_irq + 1; i < NR_IRQS; i++) {
-			tmp_irq_info = sn_irq[i];
-			while (tmp_irq_info) {
+		for (i = pdacpu(cpu)->sn_first_irq + 1;
+		     i < NR_IRQS && !foundmatch; i++) {
+			list_for_each_entry_rcu(tmp_irq_info,
+						sn_irq_lh[i],
+						list) {
  				if (tmp_irq_info->irq_cpuid = cpu) {
-					foundmatch++;
+					foundmatch = 1;
  					break;
  				}
-				tmp_irq_info = tmp_irq_info->irq_next;
-			}
-			if (foundmatch) {
-				break;
  			}
  		}
  		pdacpu(cpu)->sn_first_irq = ((i = NR_IRQS) ? 0 : i);
  	}
+	rcu_read_unlock();
  }

-struct sn_irq_info *sn_irq_alloc(nasid_t local_nasid, int local_widget, int irq,
-				 nasid_t nasid, int slice)
+static void sn_irq_info_free(struct rcu_head *head)
  {
  	struct sn_irq_info *sn_irq_info;
-	int status;
-
-	sn_irq_info = kmalloc(sizeof(*sn_irq_info), GFP_KERNEL);
-	if (sn_irq_info = NULL)
-		return NULL;
-
-	memset(sn_irq_info, 0x0, sizeof(*sn_irq_info));
-
-	status -	    sn_intr_alloc(local_nasid, local_widget, __pa(sn_irq_info), irq,
-			  nasid, slice);
-
-	if (status) {
-		kfree(sn_irq_info);
-		return NULL;
-	} else {
-		return sn_irq_info;
-	}
-}
-
-void sn_irq_free(struct sn_irq_info *sn_irq_info)
-{
-	uint64_t bridge = (uint64_t) sn_irq_info->irq_bridge;
-	nasid_t local_nasid = NASID_GET(bridge);
-	int local_widget;
-
-	if (local_nasid & 1)	/* tio check */
-		local_widget = TIO_SWIN_WIDGETNUM(bridge);
-	else
-		local_widget = SWIN_WIDGETNUM(bridge);
-
-	sn_intr_free(local_nasid, local_widget, sn_irq_info);

+	sn_irq_info = container_of(head, struct sn_irq_info, rcu);
  	kfree(sn_irq_info);
  }

@@ -314,30 +284,54 @@
  	int slice = sn_irq_info->irq_slice;
  	int cpu = nasid_slice_to_cpuid(nasid, slice);

+	pci_dev_get(pci_dev);
+
  	sn_irq_info->irq_cpuid = cpu;
  	sn_irq_info->irq_pciioinfo = SN_PCIDEV_INFO(pci_dev);

  	/* link it into the sn_irq[irq] list */
-	sn_irq_info->irq_next = sn_irq[sn_irq_info->irq_irq];
-	sn_irq[sn_irq_info->irq_irq] = sn_irq_info;
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
+	if (!sn_irq_info || !sn_irq_info->irq_irq)
+		return;
+
+	unregister_intr_pda(sn_irq_info);
+	spin_lock(&sn_irq_info_lock);
+	list_del_rcu(&sn_irq_info->list);
+	spin_unlock(&sn_irq_info_lock);
+	call_rcu(&sn_irq_info->rcu, sn_irq_info_free);
+
+	pci_dev_put(pci_dev);
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
+	list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[irq], list) {
  		if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
-		    (sn_irq_info->irq_bridge != NULL)) {
+		    (sn_irq_info->irq_bridge != NULL))
  			pcibr_force_interrupt(sn_irq_info);
-		}
-		sn_irq_info = sn_irq_info->irq_next;
  	}
+	rcu_read_unlock();
  }

  /*
@@ -402,19 +396,41 @@

  void sn_lb_int_war_check(void)
  {
+	struct sn_irq_info *sn_irq_info;
  	int i;

  	if (!sn_ioif_inited || pda->sn_first_irq = 0)
  		return;
+
+	rcu_read_lock();
  	for (i = pda->sn_first_irq; i <= pda->sn_last_irq; i++) {
-		struct sn_irq_info *sn_irq_info = sn_irq[i];
-		while (sn_irq_info) {
-			/* Only call for PCI bridges that are fully initialized. */
+		list_for_each_entry_rcu(sn_irq_info, sn_irq_lh[i], list) {
+			/*
+			 * Only call for PCI bridges that are fully
+			 * initialized.
+			 */
  			if (IS_PCI_BRIDGE_ASIC(sn_irq_info->irq_bridge_type) &&
-			    (sn_irq_info->irq_bridge != NULL)) {
+			    (sn_irq_info->irq_bridge != NULL))
  				sn_check_intr(i, sn_irq_info);
-			}
-			sn_irq_info = sn_irq_info->irq_next;
  		}
  	}
+	rcu_read_unlock();
+}
+
+void sn_irq_lh_init(void)
+{
+	int i;
+
+	sn_irq_lh = kmalloc(sizeof(struct list_head *) * NR_IRQS, GFP_KERNEL);
+	if (!sn_irq_lh)
+		panic("SN PCI INIT: Failed to allocate memory for PCI init\n");
+
+	for (i = 0; i < NR_IRQS; i++) {
+		sn_irq_lh[i] = kmalloc(sizeof(struct list_head), GFP_KERNEL);
+		if (!sn_irq_lh[i])
+			panic("SN PCI INIT: Failed IRQ memory allocation\n");
+
+		INIT_LIST_HEAD(sn_irq_lh[i]);
+	}
+
  }
Index: include/asm-ia64/sn/intr.h
=================================--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/include/asm-ia64/sn/intr.h
(mode:100644 sha1:e51471fb0867e0226eccf85c2000639b6a3c5884)
+++ d53d603c8c1a083db8df0c479b9bf296288dbc74/include/asm-ia64/sn/intr.h
(mode:100644 sha1:e190dd4213d56233938104e66cd1b93958abd99e)
@@ -9,6 +9,8 @@
  #ifndef _ASM_IA64_SN_INTR_H
  #define _ASM_IA64_SN_INTR_H

+#include <linux/rcupdate.h>
+
  #define SGI_UART_VECTOR		(0xe9)
  #define SGI_PCIBR_ERROR		(0x33)

@@ -33,7 +35,7 @@

  // The SN PROM irq struct
  struct sn_irq_info {
-	struct sn_irq_info *irq_next;	/* sharing irq list	     */
+	struct sn_irq_info *irq_next;	/* deprecated DO NOT USE     */
  	short		irq_nasid;	/* Nasid IRQ is assigned to  */
  	int		irq_slice;	/* slice IRQ is assigned to  */
  	int		irq_cpuid;	/* kernel logical cpuid	     */
@@ -47,6 +49,8 @@
  	int		irq_cookie;	/* unique cookie 	     */
  	int		irq_flags;	/* flags */
  	int		irq_share_cnt;	/* num devices sharing IRQ   */
+	struct list_head	list;	/* list of sn_irq_info structs */
+	struct rcu_head		rcu;	/* rcu callback list */
  };

  extern void sn_send_IPI_phys(int, long, int, int);
Index: include/asm-ia64/sn/pcidev.h
=================================--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/include/asm-ia64/sn/pcidev.h
(mode:100644 sha1:ed4031d808113c17029477f2308b42e065d4d5eb)
+++ d53d603c8c1a083db8df0c479b9bf296288dbc74/include/asm-ia64/sn/pcidev.h
(mode:100644 sha1:42aea21ee18710b060cd2d3be8df0defb830468f)
@@ -10,8 +10,6 @@

  #include <linux/pci.h>

-extern struct sn_irq_info **sn_irq;
-
  #define SN_PCIDEV_INFO(pci_dev) \
          ((struct pcidev_info *)(pci_dev)->sysdata)

@@ -50,9 +48,11 @@

  	struct sn_irq_info	*pdi_sn_irq_info;
  	struct sn_pcibus_provider *pdi_provider;	/* sn pci ops */
+	struct pci_dev 		*host_pci_dev;		/* host bus link */
  };

  extern void sn_irq_fixup(struct pci_dev *pci_dev,
  			 struct sn_irq_info *sn_irq_info);

+extern void sn_irq_lh_init(void);
  #endif				/* _ASM_IA64_SN_PCI_PCIDEV_H */



