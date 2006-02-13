From: Jes Sorensen <jes@sgi.com>
Date: Mon, 13 Feb 2006 10:29:57 +0000
Subject: [patch] sn2 minor fixes and cleanups
Message-Id: <yq0wtfzy2je.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

A misc round of fixes and cleanups, most importantly adding some
missing error code handling.

Cheers,
Jes


General SN2 code cleanup:
 - Do not initialize global variables to zero
 - Use kzalloc instead of kmalloc+memset
 - Check kmalloc return values
 - Do not obfuscate spin lock calls
 - Remove some unused code
 - Various formatting cleanups

Signed-off-by: Jes Sorensen <jes@sgi.com>

----

 arch/ia64/sn/kernel/io_init.c           |   96 +++++++++++++-------------------
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |   25 ++++----
 arch/ia64/sn/kernel/sn2/sn2_smp.c       |   35 +++++------
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c    |   22 +++----
 arch/ia64/sn/kernel/tiocx.c             |    4 -
 arch/ia64/sn/pci/pci_dma.c              |   16 ++---
 arch/ia64/sn/pci/pcibr/pcibr_ate.c      |   29 ++-------
 arch/ia64/sn/pci/pcibr/pcibr_dma.c      |   14 +---
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    9 ++-
 include/asm-ia64/sn/bte.h               |    6 +-
 include/asm-ia64/sn/pcibr_provider.h    |   14 ----
 include/asm-ia64/sn/sn_feature_sets.h   |    3 -
 12 files changed, 111 insertions(+), 162 deletions(-)

Index: linux-2.6/arch/ia64/sn/kernel/io_init.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/io_init.c
+++ linux-2.6/arch/ia64/sn/kernel/io_init.c
@@ -23,6 +23,10 @@
 #include "xtalk/hubdev.h"
 #include "xtalk/xwidgetdev.h"
 
+
+extern void sn_init_cpei_timer(void);
+extern void register_sn_procfs(void);
+
 static struct list_head sn_sysdata_list;
 
 /* sysdata list struct */
@@ -40,12 +44,12 @@
 	struct slab_info slab_info[MAX_SLABS + 1];
 };
 
-int sn_ioif_inited = 0;		/* SN I/O infrastructure initialized? */
+int sn_ioif_inited;		/* SN I/O infrastructure initialized? */
 
 struct sn_pcibus_provider *sn_pci_provider[PCIIO_ASIC_MAX_TYPES];	/* indexed by asic type */
 
-static int max_segment_number = 0; /* Default highest segment number */
-static int max_pcibus_number = 255; /* Default highest pci bus number */
+static int max_segment_number;		 /* Default highest segment number */
+static int max_pcibus_number = 255;	/* Default highest pci bus number */
 
 /*
  * Hooks and struct for unsupported pci providers
@@ -84,7 +88,6 @@
 sal_get_device_dmaflush_list(u64 nasid, u64 widget_num, u64 device_num,
 			     u64 address)
 {
-
 	struct ia64_sal_retval ret_stuff;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -94,7 +97,6 @@
 			(u64) nasid, (u64) widget_num,
 			(u64) device_num, (u64) address, 0, 0, 0);
 	return ret_stuff.status;
-
 }
 
 /*
@@ -102,7 +104,6 @@
  */
 static inline u64 sal_get_hubdev_info(u64 handle, u64 address)
 {
-
 	struct ia64_sal_retval ret_stuff;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -118,7 +119,6 @@
  */
 static inline u64 sal_get_pcibus_info(u64 segment, u64 busnum, u64 address)
 {
-
 	struct ia64_sal_retval ret_stuff;
 	ret_stuff.status = 0;
 	ret_stuff.v0 = 0;
@@ -215,7 +215,7 @@
 	struct hubdev_info *hubdev;
 	u64 status;
 	u64 nasid;
-	int i, widget, device;
+	int i, widget, device, size;
 
 	/*
 	 * Get SGI Specific HUB chipset information.
@@ -251,48 +251,37 @@
 		if (!hubdev->hdi_flush_nasid_list.widget_p)
 			continue;
 
+		size = (HUB_WIDGET_ID_MAX + 1) *
+			sizeof(struct sn_flush_device_kernel *);
 		hubdev->hdi_flush_nasid_list.widget_p -		    kmalloc((HUB_WIDGET_ID_MAX + 1) *
-			    sizeof(struct sn_flush_device_kernel *),
-			    GFP_KERNEL);
-		memset(hubdev->hdi_flush_nasid_list.widget_p, 0x0,
-		       (HUB_WIDGET_ID_MAX + 1) *
-		       sizeof(struct sn_flush_device_kernel *));
+			kzalloc(size, GFP_KERNEL);
+		if (!hubdev->hdi_flush_nasid_list.widget_p)
+			BUG();
 
 		for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
-			sn_flush_device_kernel = kmalloc(DEV_PER_WIDGET *
-						         sizeof(struct
-						        sn_flush_device_kernel),
-						        GFP_KERNEL);
+			size = DEV_PER_WIDGET *
+				sizeof(struct sn_flush_device_kernel);
+			sn_flush_device_kernel = kzalloc(size, GFP_KERNEL);
 			if (!sn_flush_device_kernel)
 				BUG();
-			memset(sn_flush_device_kernel, 0x0,
-			       DEV_PER_WIDGET *
-			       sizeof(struct sn_flush_device_kernel));
 
 			dev_entry = sn_flush_device_kernel;
 			for (device = 0; device < DEV_PER_WIDGET;
 			     device++,dev_entry++) {
-				dev_entry->common = kmalloc(sizeof(struct
-					      	        sn_flush_device_common),
-					                    GFP_KERNEL);
+				size = sizeof(struct sn_flush_device_common);
+				dev_entry->common = kzalloc(size, GFP_KERNEL);
 				if (!dev_entry->common)
 					BUG();
-				memset(dev_entry->common, 0x0, sizeof(struct
-					     	       sn_flush_device_common));
 
 				if (sn_prom_feature_available(
 						       PRF_DEVICE_FLUSH_LIST))
 					status = sal_get_device_dmaflush_list(
-									  nasid,
-									 widget,
-								       	 device,
-						      (u64)(dev_entry->common));
+						     nasid, widget, device,
+						     (u64)(dev_entry->common));
 				else
 					status = sn_device_fixup_war(nasid,
-								     widget,
-							    	     device,
-							     dev_entry->common);
+						     widget, device,
+						     dev_entry->common);
 				if (status != SALRET_OK)
 					panic("SAL call failed: %s\n",
 					      ia64_sal_strerror(status));
@@ -383,13 +372,12 @@
 
 	pci_dev_get(dev); /* for the sysdata pointer */
 	pcidev_info = kzalloc(sizeof(struct pcidev_info), GFP_KERNEL);
-	if (pcidev_info <= 0)
+	if (!pcidev_info)
 		BUG();		/* Cannot afford to run out of memory */
 
-	sn_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
-	if (sn_irq_info <= 0)
+	sn_irq_info = kzalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
+	if (!sn_irq_info)
 		BUG();		/* Cannot afford to run out of memory */
-	memset(sn_irq_info, 0, sizeof(struct sn_irq_info));
 
 	/* Call to retrieve pci device information needed by kernel. */
 	status = sal_get_pcidev_info((u64) segment, (u64) dev->bus->number, 
@@ -482,13 +470,13 @@
  */
 void sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 {
-	int status = 0;
+	int status;
 	int nasid, cnode;
 	struct pci_controller *controller;
 	struct sn_pci_controller *sn_controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
 	struct hubdev_info *hubdev_info;
-	void *provider_soft = NULL;
+	void *provider_soft;
 	struct sn_pcibus_provider *provider;
 
  	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
@@ -535,6 +523,8 @@
 	bus->sysdata = controller;
 	if (provider->bus_fixup)
 		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr, controller);
+	else
+		provider_soft = NULL;
 
 	if (provider_soft = NULL) {
 		/* fixup failed or not applicable */
@@ -638,13 +628,8 @@
 
 static int __init sn_pci_init(void)
 {
-	int i = 0;
-	int j = 0;
+	int i, j;
 	struct pci_dev *pci_dev = NULL;
-	extern void sn_init_cpei_timer(void);
-#ifdef CONFIG_PROC_FS
-	extern void register_sn_procfs(void);
-#endif
 
 	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
 		return 0;
@@ -700,32 +685,29 @@
  */
 void hubdev_init_node(nodepda_t * npda, cnodeid_t node)
 {
-
 	struct hubdev_info *hubdev_info;
+	int size;
+	pg_data_t *pg;
+
+	size = sizeof(struct hubdev_info);
 
 	if (node >= num_online_nodes())	/* Headless/memless IO nodes */
-		hubdev_info -		    (struct hubdev_info *)alloc_bootmem_node(NODE_DATA(0),
-							     sizeof(struct
-								    hubdev_info));
+		pg = NODE_DATA(0);
 	else
-		hubdev_info -		    (struct hubdev_info *)alloc_bootmem_node(NODE_DATA(node),
-							     sizeof(struct
-								    hubdev_info));
-	npda->pdinfo = (void *)hubdev_info;
+		pg = NODE_DATA(node);
 
+	hubdev_info = (struct hubdev_info *)alloc_bootmem_node(pg, size);
+
+	npda->pdinfo = (void *)hubdev_info;
 }
 
 geoid_t
 cnodeid_get_geoid(cnodeid_t cnode)
 {
-
 	struct hubdev_info *hubdev;
 
 	hubdev = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
 	return hubdev->hdi_geoid;
-
 }
 
 subsys_initcall(sn_pci_init);
Index: linux-2.6/arch/ia64/sn/kernel/sn2/prominfo_proc.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/prominfo_proc.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/prominfo_proc.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1999,2001-2004 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (C) 1999,2001-2004, 2006 Silicon Graphics, Inc.  All Rights Reserved.
  *
  * Module to export the system's Firmware Interface Tables, including
  * PROM revision numbers and banners, in /proc
@@ -190,7 +190,7 @@
 read_version_entry(char *page, char **start, off_t off, int count, int *eof,
 		   void *data)
 {
-	int len = 0;
+	int len;
 
 	/* data holds the NASID of the node */
 	len = dump_version(page, (unsigned long)data);
@@ -202,7 +202,7 @@
 read_fit_entry(char *page, char **start, off_t off, int count, int *eof,
 	       void *data)
 {
-	int len = 0;
+	int len;
 
 	/* data holds the NASID of the node */
 	len = dump_fit(page, (unsigned long)data);
@@ -229,13 +229,16 @@
 	struct proc_dir_entry *p;
 	cnodeid_t cnodeid;
 	unsigned long nasid;
+	int size;
 	char name[NODE_NAME_LEN];
 
 	if (!ia64_platform_is("sn2"))
 		return 0;
 
-	proc_entries = kmalloc(num_online_nodes() * sizeof(struct proc_dir_entry *),
-			       GFP_KERNEL);
+	size = num_online_nodes() * sizeof(struct proc_dir_entry *);
+	proc_entries = kzalloc(size, GFP_KERNEL);
+	if (!proc_entries)
+		return -ENOMEM;
 
 	sgi_prominfo_entry = proc_mkdir("sgi_prominfo", NULL);
 
@@ -244,14 +247,12 @@
 		sprintf(name, "node%d", cnodeid);
 		*entp = proc_mkdir(name, sgi_prominfo_entry);
 		nasid = cnodeid_to_nasid(cnodeid);
-		p = create_proc_read_entry(
-			"fit", 0, *entp, read_fit_entry,
-			(void *)nasid);
+		p = create_proc_read_entry("fit", 0, *entp, read_fit_entry,
+					   (void *)nasid);
 		if (p)
 			p->owner = THIS_MODULE;
-		p = create_proc_read_entry(
-			"version", 0, *entp, read_version_entry,
-			(void *)nasid);
+		p = create_proc_read_entry("version", 0, *entp,
+					   read_version_entry, (void *)nasid);
 		if (p)
 			p->owner = THIS_MODULE;
 		entp++;
@@ -263,7 +264,7 @@
 void __exit prominfo_exit(void)
 {
 	struct proc_dir_entry **entp;
-	unsigned cnodeid;
+	unsigned int cnodeid;
 	char name[NODE_NAME_LEN];
 
 	entp = proc_entries;
Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -46,8 +46,14 @@
 
 static  __cacheline_aligned DEFINE_SPINLOCK(sn2_global_ptc_lock);
 
-void sn2_ptc_deadlock_recovery(short *, short, short, int, volatile unsigned long *, unsigned long,
-	volatile unsigned long *, unsigned long);
+extern unsigned long
+sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
+			       volatile unsigned long *, unsigned long,
+			       volatile unsigned long *, unsigned long);
+void
+sn2_ptc_deadlock_recovery(short *, short, short, int,
+			  volatile unsigned long *, unsigned long,
+			  volatile unsigned long *, unsigned long);
 
 /*
  * Note: some is the following is captured here to make degugging easier
@@ -59,16 +65,6 @@
 #define reset_max_active_on_deadlock()	1
 #define PTC_LOCK(sh1)			((sh1) ? &sn2_global_ptc_lock : &sn_nodepda->ptc_lock)
 
-static inline void ptc_lock(int sh1, unsigned long *flagp)
-{
-	spin_lock_irqsave(PTC_LOCK(sh1), *flagp);
-}
-
-static inline void ptc_unlock(int sh1, unsigned long flags)
-{
-	spin_unlock_irqrestore(PTC_LOCK(sh1), flags);
-}
-
 struct ptc_stats {
 	unsigned long ptc_l;
 	unsigned long change_rid;
@@ -82,6 +78,8 @@
 	unsigned long shub_ptc_flushes_not_my_mm;
 };
 
+#define sn2_ptctest	0
+
 static inline unsigned long wait_piowc(void)
 {
 	volatile unsigned long *piows;
@@ -200,7 +198,7 @@
 	max_active = max_active_pio(shub1);
 
 	itc = ia64_get_itc();
-	ptc_lock(shub1, &flags);
+	spin_lock_irqsave(PTC_LOCK(shub1), flags);
 	itc2 = ia64_get_itc();
 
 	__get_cpu_var(ptcstats).lock_itc_clocks += itc2 - itc;
@@ -258,7 +256,7 @@
 		ia64_srlz_d();
 	}
 
-	ptc_unlock(shub1, flags);
+	spin_unlock_irqrestore(PTC_LOCK(shub1), flags);
 
 	preempt_enable();
 }
@@ -270,11 +268,12 @@
  * TLB flush transaction.  The recovery sequence is somewhat tricky & is
  * coded in assembly language.
  */
-void sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid, volatile unsigned long *ptc0, unsigned long data0,
-	volatile unsigned long *ptc1, unsigned long data1)
+
+void
+sn2_ptc_deadlock_recovery(short *nasids, short ib, short ie, int mynasid,
+			  volatile unsigned long *ptc0, unsigned long data0,
+			  volatile unsigned long *ptc1, unsigned long data1)
 {
-	extern unsigned long sn2_ptc_deadlock_recovery_core(volatile unsigned long *, unsigned long,
-	        volatile unsigned long *, unsigned long, volatile unsigned long *, unsigned long);
 	short nasid, i;
 	unsigned long *piows, zeroval, n;
 
Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/sn_proc_fs.c
@@ -6,11 +6,11 @@
  * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
  */
 #include <linux/config.h>
-#include <asm/uaccess.h>
 
 #ifdef CONFIG_PROC_FS
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <asm/uaccess.h>
 #include <asm/sn/sn_sal.h>
 
 static int partition_id_show(struct seq_file *s, void *p)
@@ -90,10 +90,10 @@
 	return single_open(file, coherence_id_show, NULL);
 }
 
-static struct proc_dir_entry *sn_procfs_create_entry(
-	const char *name, struct proc_dir_entry *parent,
-	int (*openfunc)(struct inode *, struct file *),
-	int (*releasefunc)(struct inode *, struct file *))
+static struct proc_dir_entry
+*sn_procfs_create_entry(const char *name, struct proc_dir_entry *parent,
+			int (*openfunc)(struct inode *, struct file *),
+			int (*releasefunc)(struct inode *, struct file *))
 {
 	struct proc_dir_entry *e = create_proc_entry(name, 0444, parent);
 
@@ -126,24 +126,24 @@
 		return;
 
 	sn_procfs_create_entry("partition_id", sgi_proc_dir,
-		partition_id_open, single_release);
+			       partition_id_open, single_release);
 
 	sn_procfs_create_entry("system_serial_number", sgi_proc_dir,
-		system_serial_number_open, single_release);
+			       system_serial_number_open, single_release);
 
 	sn_procfs_create_entry("licenseID", sgi_proc_dir, 
-		licenseID_open, single_release);
+			       licenseID_open, single_release);
 
 	e = sn_procfs_create_entry("sn_force_interrupt", sgi_proc_dir, 
-		sn_force_interrupt_open, single_release);
+				   sn_force_interrupt_open, single_release);
 	if (e) 
 		e->proc_fops->write = sn_force_interrupt_write_proc;
 
 	sn_procfs_create_entry("coherence_id", sgi_proc_dir, 
-		coherence_id_open, single_release);
+			       coherence_id_open, single_release);
 	
 	sn_procfs_create_entry("sn_topology", sgi_proc_dir,
-		sn_topology_open, sn_topology_release);
+			       sn_topology_open, sn_topology_release);
 }
 
 #endif /* CONFIG_PROC_FS */
Index: linux-2.6/arch/ia64/sn/kernel/tiocx.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/tiocx.c
+++ linux-2.6/arch/ia64/sn/kernel/tiocx.c
@@ -284,12 +284,10 @@
 	if ((nasid & 1) = 0)
 		return NULL;
 
-	sn_irq_info = kmalloc(sn_irq_size, GFP_KERNEL);
+	sn_irq_info = kzalloc(sn_irq_size, GFP_KERNEL);
 	if (sn_irq_info = NULL)
 		return NULL;
 
-	memset(sn_irq_info, 0x0, sn_irq_size);
-
 	status = tiocx_intr_alloc(nasid, widget, __pa(sn_irq_info), irq,
 				  req_nasid, slice);
 	if (status) {
Index: linux-2.6/arch/ia64/sn/pci/pci_dma.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/pci_dma.c
+++ linux-2.6/arch/ia64/sn/pci/pci_dma.c
@@ -335,10 +335,10 @@
 	 */
 
 	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
-		pci_domain_nr(bus), bus->number,
-		0, /* io */
-		0, /* read */
-		port, size, __pa(val));
+		 pci_domain_nr(bus), bus->number,
+		 0, /* io */
+		 0, /* read */
+		 port, size, __pa(val));
 
 	if (isrv.status = 0)
 		return size;
@@ -381,10 +381,10 @@
 	 */
 
 	SAL_CALL(isrv, SN_SAL_IOIF_PCI_SAFE,
-		pci_domain_nr(bus), bus->number,
-		0, /* io */
-		1, /* write */
-		port, size, __pa(&val));
+		 pci_domain_nr(bus), bus->number,
+		 0, /* io */
+		 1, /* write */
+		 port, size, __pa(&val));
 
 	if (isrv.status = 0)
 		return size;
Index: linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_ate.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/pcibr/pcibr_ate.c
+++ linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_ate.c
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2001-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2001-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/types.h>
@@ -12,7 +12,7 @@
 #include <asm/sn/pcibus_provider_defs.h>
 #include <asm/sn/pcidev.h>
 
-int pcibr_invalidate_ate = 0;	/* by default don't invalidate ATE on free */
+int pcibr_invalidate_ate;	/* by default don't invalidate ATE on free */
 
 /*
  * mark_ate: Mark the ate as either free or inuse.
@@ -20,14 +20,12 @@
 static void mark_ate(struct ate_resource *ate_resource, int start, int number,
 		     u64 value)
 {
-
 	u64 *ate = ate_resource->ate;
 	int index;
 	int length = 0;
 
 	for (index = start; length < number; index++, length++)
 		ate[index] = value;
-
 }
 
 /*
@@ -37,7 +35,6 @@
 static int find_free_ate(struct ate_resource *ate_resource, int start,
 			 int count)
 {
-
 	u64 *ate = ate_resource->ate;
 	int index;
 	int start_free;
@@ -70,12 +67,10 @@
 static inline void free_ate_resource(struct ate_resource *ate_resource,
 				     int start)
 {
-
 	mark_ate(ate_resource, start, ate_resource->ate[start], 0);
 	if ((ate_resource->lowest_free_index > start) ||
 	    (ate_resource->lowest_free_index < 0))
 		ate_resource->lowest_free_index = start;
-
 }
 
 /*
@@ -84,7 +79,6 @@
 static inline int alloc_ate_resource(struct ate_resource *ate_resource,
 				     int ate_needed)
 {
-
 	int start_index;
 
 	/*
@@ -118,19 +112,12 @@
  */
 int pcibr_ate_alloc(struct pcibus_info *pcibus_info, int count)
 {
-	int status = 0;
-	u64 flag;
+	int status;
+	unsigned long flags;
 
-	flag = pcibr_lock(pcibus_info);
+	spin_lock_irqsave(&pcibus_info->pbi_lock, flags);
 	status = alloc_ate_resource(&pcibus_info->pbi_int_ate_resource, count);
-
-	if (status < 0) {
-		/* Failed to allocate */
-		pcibr_unlock(pcibus_info, flag);
-		return -1;
-	}
-
-	pcibr_unlock(pcibus_info, flag);
+	spin_unlock_irqrestore(&pcibus_info->pbi_lock, flags);
 
 	return status;
 }
@@ -182,7 +169,7 @@
 		ate_write(pcibus_info, index, count, (ate & ~PCI32_ATE_V));
 	}
 
-	flags = pcibr_lock(pcibus_info);
+	spin_lock_irqsave(&pcibus_info->pbi_lock, flags);
 	free_ate_resource(&pcibus_info->pbi_int_ate_resource, index);
-	pcibr_unlock(pcibus_info, flags);
+	spin_unlock_irqrestore(&pcibus_info->pbi_lock, flags);
 }
Index: linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_dma.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/pcibr/pcibr_dma.c
+++ linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_dma.c
@@ -137,14 +137,12 @@
 		pci_addr |= PCI64_ATTR_VIRTUAL;
 
 	return pci_addr;
-
 }
 
 static dma_addr_t
 pcibr_dmatrans_direct32(struct pcidev_info * info,
 			u64 paddr, size_t req_size, u64 flags)
 {
-
 	struct pcidev_info *pcidev_info = info->pdi_host_pcidev_info;
 	struct pcibus_info *pcibus_info = (struct pcibus_info *)pcidev_info->
 	    pdi_pcibus_info;
@@ -171,7 +169,6 @@
 	}
 
 	return PCI32_DIRECT_BASE | offset;
-
 }
 
 /*
@@ -218,9 +215,8 @@
 	u64 flags;
 	u64 itte;
 	struct hubdev_info *hubinfo;
-	volatile struct sn_flush_device_kernel *p;
-	volatile struct sn_flush_device_common *common;
-
+	struct sn_flush_device_kernel *p;
+	struct sn_flush_device_common *common;
 	struct sn_flush_nasid_entry *flush_nasid_list;
 
 	if (!sn_ioif_inited)
@@ -310,8 +306,7 @@
 					     (common->sfdl_slot - 1));
 		}
 	} else {
-		spin_lock_irqsave((spinlock_t *)&p->sfdl_flush_lock,
-				  flags);
+		spin_lock_irqsave(&p->sfdl_flush_lock, flags);
 		*common->sfdl_flush_addr = 0;
 
 		/* force an interrupt. */
@@ -322,8 +317,7 @@
 			cpu_relax();
 
 		/* okay, everything is synched up. */
-		spin_unlock_irqrestore((spinlock_t *)&p->sfdl_flush_lock,
-				       flags);
+		spin_unlock_irqrestore(&p->sfdl_flush_lock, flags);
 	}
 	return;
 }
Index: linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c
+++ linux-2.6/arch/ia64/sn/pci/pcibr/pcibr_provider.c
@@ -163,9 +163,12 @@
 	/* Setup the PMU ATE map */
 	soft->pbi_int_ate_resource.lowest_free_index = 0;
 	soft->pbi_int_ate_resource.ate -	    kmalloc(soft->pbi_int_ate_size * sizeof(u64), GFP_KERNEL);
-	memset(soft->pbi_int_ate_resource.ate, 0,
- 	       (soft->pbi_int_ate_size * sizeof(u64)));
+	    kzalloc(soft->pbi_int_ate_size * sizeof(u64), GFP_KERNEL);
+
+	if (!soft->pbi_int_ate_resource.ate) {
+		kfree(soft);
+		return NULL;
+	}
 
 	if (prom_bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP) {
 		/* TIO PCI Bridge: find nearest node with CPUs */
Index: linux-2.6/include/asm-ia64/sn/bte.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/bte.h
+++ linux-2.6/include/asm-ia64/sn/bte.h
@@ -46,7 +46,7 @@
 #define BTES_PER_NODE (is_shub2() ? 4 : 2)
 #define MAX_BTES_PER_NODE 4
 
-#define BTE2OFF_CTRL	(0)
+#define BTE2OFF_CTRL	0
 #define BTE2OFF_SRC	(SH2_BT_ENG_SRC_ADDR_0 - SH2_BT_ENG_CSR_0)
 #define BTE2OFF_DEST	(SH2_BT_ENG_DEST_ADDR_0 - SH2_BT_ENG_CSR_0)
 #define BTE2OFF_NOTIFY	(SH2_BT_ENG_NOTIF_ADDR_0 - SH2_BT_ENG_CSR_0)
@@ -75,11 +75,11 @@
 		: base + (BTEOFF_NOTIFY/8))
 
 /* Define hardware modes */
-#define BTE_NOTIFY (IBCT_NOTIFY)
+#define BTE_NOTIFY IBCT_NOTIFY
 #define BTE_NORMAL BTE_NOTIFY
 #define BTE_ZERO_FILL (BTE_NOTIFY | IBCT_ZFIL_MODE)
 /* Use a reserved bit to let the caller specify a wait for any BTE */
-#define BTE_WACQUIRE (0x4000)
+#define BTE_WACQUIRE 0x4000
 /* Use the BTE on the node with the destination memory */
 #define BTE_USE_DEST (BTE_WACQUIRE << 1)
 /* Use any available BTE interface on any node for the transfer */
Index: linux-2.6/include/asm-ia64/sn/pcibr_provider.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/pcibr_provider.h
+++ linux-2.6/include/asm-ia64/sn/pcibr_provider.h
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992-1997,2000-2004 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992-1997,2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 #ifndef _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
 #define _ASM_IA64_SN_PCI_PCIBR_PROVIDER_H
@@ -115,18 +115,6 @@
 	spinlock_t              pbi_lock;
 };
 
-/*
- * pcibus_info structure locking macros
- */
-inline static unsigned long
-pcibr_lock(struct pcibus_info *pcibus_info)
-{
-	unsigned long flag;
-	spin_lock_irqsave(&pcibus_info->pbi_lock, flag);
-	return(flag);
-}
-#define pcibr_unlock(pcibus_info, flag)  spin_unlock_irqrestore(&pcibus_info->pbi_lock, flag)
-
 extern int  pcibr_init_provider(void);
 extern void *pcibr_bus_fixup(struct pcibus_bussoft *, struct pci_controller *);
 extern dma_addr_t pcibr_dma_map(struct pci_dev *, unsigned long, size_t);
Index: linux-2.6/include/asm-ia64/sn/sn_feature_sets.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_feature_sets.h
+++ linux-2.6/include/asm-ia64/sn/sn_feature_sets.h
@@ -12,9 +12,6 @@
  */
 
 
-#include <asm/types.h>
-#include <asm/bitops.h>
-
 /* --------------------- PROM Features -----------------------------*/
 extern int sn_prom_feature_available(int id);
 
