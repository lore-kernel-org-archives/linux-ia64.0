From: jes@trained-monkey.org (Jes Sorensen)
Date: Wed, 02 Feb 2005 19:10:32 +0000
Subject: [rfc] generic allocator and mspec driver
Message-Id: <16897.9640.160896.31584@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I've been working on a generic allocator to be used for the uncached
memory pools as needed by the mspec driver (former SGI fetchop).

I based the allocator on the one from the sym2 driver and then allowing
one to setup whatever pools one would want. Everything works pretty well
and we integrated it with the mspec (fetchop) driver which now also
allows for uncached and cached mappings on non sn2 hardware.  Right now
the driver is located in arch/ia64/sn/kernel/ however I plan to move
that to arch/ia64/kernel/ or drivers/char/.

The remaining issue I am facing is that for the uncached pool I want to
make it node aware and we want to use the spill pages from the lower
granules for this pool which is easily done on SN2. However I see no
generic way to get from a physical address to node id for pages that do
not have a struct page assigned to them. I am curious if anyone has any
suggestions for how to solve this in a generic way?

Otherwise I'd also welcome comments if anyone has any objections or
ideas for the current code before submitting it.

Patch attached includes the driver and the generic allocator in one big
patch.

Cheers,
Jes

diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/arch/ia64/Kconfig linux-2.6.11-rc2-mm2/arch/ia64/Kconfig
--- linux-2.6.11-rc2-mm2-vanilla/arch/ia64/Kconfig	2005-02-02 04:31:21 -08:00
+++ linux-2.6.11-rc2-mm2/arch/ia64/Kconfig	2005-02-02 04:52:43 -08:00
@@ -225,6 +225,15 @@
 	  If you are compiling a kernel that will run under SGI's IA-64
 	  simulator (Medusa) then say Y, otherwise say N.
 
+config MSPEC
+	tristate "SGI SN2 Special Memory support"
+	depends on IA64
+	help
+	  This driver exports special memory capabilities of the SGI SN
+	  architecture such as the fetchop facility to user processes.
+	  Fetchops are atomic memory operations that are implemented in the
+	  memory controller on SGI SN hardware.
+
 config FORCE_MAX_ZONEORDER
 	int
 	default "18"
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/arch/ia64/configs/sn2_defconfig linux-2.6.11-rc2-mm2/arch/ia64/configs/sn2_defconfig
--- linux-2.6.11-rc2-mm2-vanilla/arch/ia64/configs/sn2_defconfig	2005-02-02 04:31:21 -08:00
+++ linux-2.6.11-rc2-mm2/arch/ia64/configs/sn2_defconfig	2005-02-02 04:52:43 -08:00
@@ -82,6 +82,7 @@
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
 CONFIG_IA64_SGI_SN_SIM=y
+CONFIG_SGI_MSPEC=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/arch/ia64/defconfig linux-2.6.11-rc2-mm2/arch/ia64/defconfig
--- linux-2.6.11-rc2-mm2-vanilla/arch/ia64/defconfig	2005-02-02 04:31:05 -08:00
+++ linux-2.6.11-rc2-mm2/arch/ia64/defconfig	2005-02-02 04:52:43 -08:00
@@ -80,6 +80,7 @@
 CONFIG_DISCONTIGMEM=y
 CONFIG_IA64_CYCLONE=y
 CONFIG_IOSAPIC=y
+CONFIG_SGI_MSPEC=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/arch/ia64/sn/kernel/Makefile linux-2.6.11-rc2-mm2/arch/ia64/sn/kernel/Makefile
--- linux-2.6.11-rc2-mm2-vanilla/arch/ia64/sn/kernel/Makefile	2004-12-24 13:34:01 -08:00
+++ linux-2.6.11-rc2-mm2/arch/ia64/sn/kernel/Makefile	2005-02-02 04:52:43 -08:00
@@ -10,3 +10,4 @@
 obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
 				   huberror.o io_init.o iomv.o klconflib.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
+obj-$(CONFIG_SGI_MSPEC)		+= mspec.o
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/arch/ia64/sn/kernel/mspec.c linux-2.6.11-rc2-mm2/arch/ia64/sn/kernel/mspec.c
--- linux-2.6.11-rc2-mm2-vanilla/arch/ia64/sn/kernel/mspec.c	1969-12-31 16:00:00 -08:00
+++ linux-2.6.11-rc2-mm2/arch/ia64/sn/kernel/mspec.c	2005-02-02 05:02:49 -08:00
@@ -0,0 +1,789 @@
+/*
+ * Copyright (C) 2001-2005 Silicon Graphics, Inc.  All rights
+ * reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ */
+
+/*
+ * SN Platform Special Memory (mspec) Support
+ *
+ * This driver exports the SN special memory (mspec) facility to user processes.
+ * There are three types of memory made available thru this driver:
+ * fetchops, uncached and cached.
+ *
+ * Fetchops are atomic memory operations that are implemented in the
+ * memory controller on SGI SN hardware.
+ *
+ * Uncached are used for memory write combining feature of the ia64
+ * cpu.
+ *
+ * Cached are used for areas of memory that are used as cached addresses
+ * on our partition and used as uncached addresses from other partitions.
+ * Due to a design constraint of the SN2 Shub, you can not have processors
+ * on the same FSB perform both a cached and uncached reference to the
+ * same cache line.  These special memory cached regions prevent the
+ * kernel from ever dropping in a TLB entry and therefore prevent the
+ * processor from ever speculating a cache line from this page.
+ */
+
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/miscdevice.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/proc_fs.h>
+#include <linux/vmalloc.h>
+#include <linux/bitops.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/seq_file.h>
+#include <linux/efi.h>
+#include <linux/genalloc.h>
+#include <asm/page.h>
+#include <asm/pal.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+#include <asm/atomic.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/arch.h>
+#include <asm/sn/mspec.h>
+#include <asm/sn/sn_cpuid.h>
+#include <asm/sn/io.h>
+#include <asm/sn/bte.h>
+#include "shubio.h"
+
+
+#define DEBUG	1
+
+#define FETCHOP_DRIVER_ID_STR	"MSPEC Fetchop Device Driver"
+#define CACHED_DRIVER_ID_STR	"MSPEC Cached Device Driver"
+#define UNCACHED_DRIVER_ID_STR	"MSPEC Uncached Device Driver"
+#define REVISION		"3.0"
+#define MSPEC_BASENAME		"mspec"
+
+
+#define MSPEC_TO_NID(maddr)	nasid_to_cnodeid(NASID_GET(maddr))
+
+#define BTE_ZERO_BLOCK(_maddr, _len) \
+	bte_copy(0, _maddr - __IA64_UNCACHED_OFFSET, _len, BTE_WACQUIRE | BTE_ZERO_FILL, NULL)
+
+static int fetchop_mmap(struct file *file, struct vm_area_struct *vma);
+static int cached_mmap(struct file *file, struct vm_area_struct *vma);
+static int uncached_mmap(struct file *file, struct vm_area_struct *vma);
+static void mspec_open(struct vm_area_struct *vma);
+static void mspec_close(struct vm_area_struct *vma);
+static struct page * mspec_nopage(struct vm_area_struct *vma,
+					unsigned long address, int *unused);
+
+/*
+ * Page types allocated by the device.
+ */
+enum {
+	MSPEC_FETCHOP = 1,
+	MSPEC_CACHED,
+	MSPEC_UNCACHED
+};
+
+static struct file_operations fetchop_fops = {
+	.owner		THIS_MODULE,
+	.mmap		fetchop_mmap
+};
+static struct miscdevice fetchop_miscdev = {
+	.minor		MISC_DYNAMIC_MINOR,
+	.name		"sgi_fetchop",
+	.fops		&fetchop_fops
+};
+
+
+static struct file_operations cached_fops = {
+	.owner		THIS_MODULE,
+	.mmap		cached_mmap
+};
+static struct miscdevice cached_miscdev = {
+	.minor		MISC_DYNAMIC_MINOR,
+	.name		"sgi_cached",
+	.fops		&cached_fops
+};
+
+
+static struct file_operations uncached_fops = {
+	.owner		THIS_MODULE,
+	.mmap		uncached_mmap
+};
+static struct miscdevice uncached_miscdev = {
+	.minor		MISC_DYNAMIC_MINOR,
+	.name		"sgi_uncached",
+	.fops		&uncached_fops
+};
+
+
+static struct vm_operations_struct mspec_vm_ops = {
+	.open		mspec_open,
+	.close		mspec_close,
+	.nopage		mspec_nopage
+};
+
+/*
+ * There is one of these structs per node. It is used to manage the mspec
+ * space that is available on the node. Current assumption is that there is
+ * only 1 mspec block of memory per node.
+ */
+struct node_mspecs {
+	long		maddr;		/* phys addr of start of mspecs. */
+	int		count;		/* Total number of mspec pages. */
+	atomic_t	free;		/* Number of pages currently free. */
+	unsigned long	bits[1];	/* Bitmap for managing pages. */
+};
+
+
+/*
+ * One of these structures is allocated when an mspec region is mmaped. The
+ * structure is pointed to by the vma->vm_private_data field in the vma struct. 
+ * This structure is used to record the addresses of the mspec pages.
+ */
+struct vma_data {
+	atomic_t	refcnt;		/* Number of vmas sharing the data. */
+	spinlock_t	lock;		/* Serialize access to the vma. */
+	int		count;		/* Number of pages allocated. */
+	int		type;		/* Type of pages allocated. */
+	unsigned long	maddr[1];	/* Array of MSPEC addresses. */
+};
+
+
+/*
+ * Memory Special statistics.
+ */
+struct mspec_stats {
+	atomic_t	map_count;	/* Number of active mmap's */
+	atomic_t	pages_in_use;	/* Number of mspec pages in use */
+	unsigned long	pages_total;	/* Total number of mspec pages */
+};
+
+static struct mspec_stats	mspec_stats;
+static struct node_mspecs	*node_mspecs[MAX_NUMNODES];
+
+
+struct gen_pool *mspec_pool[MAX_NUMNODES];
+
+static void mspec_ipi_visibility(void *data)
+{
+	int status;
+
+	status = ia64_pal_prefetch_visibility(PAL_VISIBILITY_PHYSICAL);
+	if ((status != PAL_VISIBILITY_OK) &&
+	    (status != PAL_VISIBILITY_OK_REMOTE_NEEDED))
+		printk(KERN_DEBUG "pal_prefetch_visibility() returns %i on "
+		       "CPU %i\n", status, get_cpu());
+}
+
+
+static void mspec_ipi_mc_drain(void *data)
+{
+	int status;
+	status = ia64_pal_mc_drain();
+	if (status)
+		printk(KERN_WARNING "ia64_pal_mc_drain() failed with %i on "
+		       "CPU %i\n", status, get_cpu());
+}
+
+
+static unsigned long
+mspec_get_new_chunk(struct gen_pool *poolp)
+{
+	struct page *page;
+	void *tmp;
+	int status, node;
+	unsigned long addr;
+
+	node = (int)poolp->private;
+	page = alloc_pages_node(node, GFP_KERNEL,
+				IA64_GRANULE_SHIFT-PAGE_SHIFT);
+
+#if DEBUG
+	printk(KERN_INFO "get_new_chunk page %p, addr %lx\n",
+	       page, (unsigned long)(page-vmem_map) << PAGE_SHIFT);
+#endif
+
+	/*
+	 * Do magic if no mem on local node! XXX
+	 */
+	if (!page)
+		return 0;
+	tmp = page_address(page);
+	memset(tmp, 0, IA64_GRANULE_SIZE);
+
+	status = ia64_pal_prefetch_visibility(PAL_VISIBILITY_PHYSICAL);
+#if DEBUG
+	printk(KERN_INFO "pal_prefetch_visibility() returns %i on cpu %i\n",
+	       status, get_cpu());
+#endif
+	if (!status) {
+		status = smp_call_function(mspec_ipi_visibility, NULL, 0, 1);
+		if (status)
+			printk(KERN_WARNING "smp_call_function failed for "
+			       "mspec_ipi_visibility! (%i)\n", status);
+	}
+
+	sn_flush_all_caches((unsigned long)tmp, IA64_GRANULE_SIZE);
+	ia64_pal_mc_drain();
+	status = smp_call_function(mspec_ipi_mc_drain, NULL, 0, 1);
+	if (status)
+		printk(KERN_WARNING "smp_call_function failed for "
+		       "mspec_ipi_mc_drain! (%i)\n", status);
+
+	addr = (unsigned long)tmp - PAGE_OFFSET + __IA64_UNCACHED_OFFSET;
+	return addr;
+}
+
+
+/*
+ * mspec_alloc_page
+ *
+ * Allocate 1 mspec page. Allocates on the requested node. If no
+ * mspec pages are available on the requested node, roundrobin starting
+ * with higher nodes.
+ */
+static unsigned long
+mspec_alloc_page(int nid, int type)
+{
+	unsigned long maddr;
+
+	maddr = gen_pool_alloc(mspec_pool[nid], PAGE_SIZE);
+#if DEBUG
+	printk(KERN_DEBUG "mspec_alloc_page returns %lx on node %i\n",
+	       maddr, nid);
+#endif
+
+	/*
+	 * If no memory is availble on our local node, try the
+	 * remaining nodes in the system.
+	 */
+	if (!maddr) {
+		int i;
+
+		for (i = MAX_NUMNODES - 1; i >= 0; i--) {
+			if (i = nid || !node_online(i))
+				continue;
+			maddr = gen_pool_alloc(mspec_pool[i], PAGE_SIZE);
+#if DEBUG
+			printk(KERN_DEBUG "mspec_alloc_page alternate search "
+			       "returns %lx on node %i\n", maddr, i);
+#endif
+			if (maddr) {
+				break;
+			}
+		}
+	}
+
+	if (maddr)
+		atomic_inc(&mspec_stats.pages_in_use);
+
+	return maddr;
+}
+
+
+/*
+ * mspec_free_page
+ *
+ * Free a single mspec page.
+ */
+static void
+mspec_free_page(unsigned long maddr)
+{
+	int node;
+
+	node = nasid_to_cnodeid(NASID_GET(maddr));
+#if DEBUG
+	printk(KERN_DEBUG "mspec_free_page(%lx) on node %i\n", maddr, node);
+#endif
+
+	atomic_dec(&mspec_stats.pages_in_use);
+	gen_pool_free(mspec_pool[node], maddr, PAGE_SIZE);
+}
+
+
+/*
+ * mspec_mmap
+ *
+ * Called when mmaping the device.  Initializes the vma with a fault handler
+ * and private data structure necessary to allocate, track, and free the
+ * underlying pages.
+ */
+static int
+mspec_mmap(struct file *file, struct vm_area_struct *vma, int type)
+{
+	struct vma_data *vdata;
+	int pages;
+
+	if (vma->vm_pgoff != 0)
+		return -EINVAL;
+
+	if ((vma->vm_flags & VM_WRITE) = 0)
+		return -EPERM;
+
+	pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	if (!(vdata = vmalloc(sizeof(struct vma_data)+(pages-1)*sizeof(long))))
+		return -ENOMEM;
+	memset(vdata, 0, sizeof(struct vma_data)+(pages-1)*sizeof(long));
+
+	vdata->type = type;
+	vdata->lock = SPIN_LOCK_UNLOCKED;
+	vdata->refcnt = ATOMIC_INIT(1);
+	vma->vm_private_data = vdata;
+
+	vma->vm_flags |= (VM_IO | VM_SHM | VM_LOCKED);
+	if (vdata->type = MSPEC_FETCHOP || vdata->type = MSPEC_UNCACHED)
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	vma->vm_ops = &mspec_vm_ops;
+
+	atomic_inc(&mspec_stats.map_count);
+	return 0;
+}
+
+static int
+fetchop_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return mspec_mmap(file, vma, MSPEC_FETCHOP);
+}
+
+static int
+cached_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return mspec_mmap(file, vma, MSPEC_CACHED);
+}
+
+static int
+uncached_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return mspec_mmap(file, vma, MSPEC_UNCACHED);
+}
+
+/*
+ * mspec_open
+ *
+ * Called when a device mapping is created by a means other than mmap
+ * (via fork, etc.).  Increments the reference count on the underlying
+ * mspec data so it is not freed prematurely.
+ */
+static void
+mspec_open(struct vm_area_struct *vma)
+{
+	struct vma_data *vdata;
+
+	vdata = vma->vm_private_data;
+	atomic_inc(&vdata->refcnt);
+}
+
+/*
+ * mspec_close
+ *
+ * Called when unmapping a device mapping. Frees all mspec pages
+ * belonging to the vma.
+ */
+static void
+mspec_close(struct vm_area_struct *vma)
+{
+	struct vma_data *vdata;
+	int i, pages;
+	bte_result_t br;
+
+	vdata = vma->vm_private_data;
+	if (atomic_dec(&vdata->refcnt) = 0) {
+		pages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+		for (i = 0; i < pages; i++) {
+			if (vdata->maddr[i] != 0) {
+				/*
+				 * Use the bte to ensure cache lines
+				 * are actually pulled from the
+				 * processor back to the md.
+				 */
+				br = BTE_ZERO_BLOCK(vdata->maddr[i], PAGE_SIZE);
+				if (br = BTE_SUCCESS)
+					mspec_free_page(vdata->maddr[i]);
+				else
+					printk(KERN_WARNING "mspec_close(): BTE failed to zero page\n");
+			}
+		}
+		if (vdata->count) 
+			atomic_dec(&mspec_stats.map_count);
+		vfree(vdata);
+	}
+}
+
+/*
+ * mspec_get_one_pte
+ *
+ * Return the pte for a given mm and address.
+ */
+static __inline__ int
+mspec_get_one_pte(struct mm_struct *mm, u64 address, pte_t **pte)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pud_t *pud;
+
+	pgd = pgd_offset(mm, address);
+	if (pgd_present(*pgd)) {
+		pud = pud_offset(pgd, address);
+		if (pud_present(*pud)) {
+			pmd = pmd_offset(pud, address);
+			if (pmd_present(*pmd)) {
+				*pte = pte_offset_map(pmd, address);
+				if (pte_present(**pte)) {
+					return 0;
+				}
+			}
+		}
+	}
+
+	return -1;
+}
+
+/*
+ * mspec_nopage
+ *
+ * Creates a mspec page and maps it to user space.
+ */
+static struct page *
+mspec_nopage(struct vm_area_struct *vma, unsigned long address, int *unused)
+{
+	unsigned long paddr, maddr = 0;
+	unsigned long pfn;
+	int index;
+	pte_t *pte;
+	struct page *page;
+	struct vma_data *vdata = vma->vm_private_data;
+
+	spin_lock(&vdata->lock);
+
+	index = (address - vma->vm_start) >> PAGE_SHIFT;
+	if (vdata->maddr[index] = 0) {
+		vdata->count++;
+		maddr = mspec_alloc_page(numa_node_id(), vdata->type);
+		if (maddr = 0)
+			BUG();
+		vdata->maddr[index] = maddr;
+	} else if (mspec_get_one_pte(vma->vm_mm, address, &pte) = 0) {
+		printk(KERN_ERR "page already mapped\n");
+		/*
+		 * The page may have already been faulted by another
+		 * pthread.  If so, we need to avoid remapping the
+		 * page or we will trip a BUG check in the
+		 * remap_page_range() path.
+		 */
+		goto getpage;
+	}
+
+	if (vdata->type = MSPEC_FETCHOP)
+		paddr = TO_AMO(vdata->maddr[index]);
+	else
+		paddr = __pa(TO_CAC(vdata->maddr[index]));
+
+	/*
+	 * XXX - is this correct?
+	 */
+	pfn = paddr >> PAGE_SHIFT;
+	if (remap_pfn_range(vma, address, pfn, PAGE_SIZE, vma->vm_page_prot)) {
+		printk(KERN_ERR "remap_pfn_range failed!\n");
+		goto error;
+	}
+
+	/*
+	 * The kernel requires a page structure to be returned upon
+	 * success, but there are no page structures for low granule pages.
+	 * remap_page_range() creates the pte for us and we return a
+	 * bogus page back to the kernel fault handler to keep it happy
+	 * (the page is freed immediately there).
+	 */
+	if (mspec_get_one_pte(vma->vm_mm, address, &pte) = 0) {
+		spin_lock(&vma->vm_mm->page_table_lock);
+		vma->vm_mm->rss++;
+		spin_unlock(&vma->vm_mm->page_table_lock);
+
+		set_pte(pte, pte_mkwrite(pte_mkdirty(*pte)));
+	}
+getpage:
+	/*
+	 * Is this really correct?
+	 */
+	page = alloc_pages(GFP_USER, 0);
+	spin_unlock(&vdata->lock);
+	return page;
+#if 0
+	page = pfn_to_page(pfn);
+	printk(KERN_ERR "fall through!\n");
+	goto getpage;
+	return page;
+#endif
+error:
+	if (maddr) {
+		mspec_free_page(vdata->maddr[index]);
+		vdata->maddr[index] = 0;
+		vdata->count--;
+	}
+	spin_unlock(&vdata->lock);
+	return NOPAGE_SIGBUS;
+}
+
+#ifdef CONFIG_PROC_FS
+
+#define MAX_MSPEC_ENTRIES	5
+
+static void *
+mspec_seq_start(struct seq_file *file, loff_t *offset)
+{
+	if (*offset < MAX_NUMNODES)
+		return offset;
+	return NULL;			
+}
+
+static void *
+mspec_seq_next(struct seq_file *file, void *data, loff_t *offset)
+{
+	(*offset)++;
+	if (*offset < MAX_NUMNODES)
+		return offset;
+	return NULL;
+}
+
+static void
+mspec_seq_stop(struct seq_file *file, void *data)
+{
+}
+
+static int
+mspec_seq_show(struct seq_file *file, void *data)
+{
+	struct node_mspecs *mspecs;
+	int i;
+
+	i = *(loff_t *)data;
+
+	if (!i) {
+		seq_printf(file, "mappings               : %i\n",
+			   atomic_read(&mspec_stats.map_count));
+		seq_printf(file, "current mspec pages    : %i\n",
+			   atomic_read(&mspec_stats.pages_in_use));
+		seq_printf(file, "%4s %7s %7s\n", "node", "total", "free");
+	}
+
+	if (i < MAX_NUMNODES) {
+		int free, count;
+		mspecs = node_mspecs[i];
+		if (mspecs) {
+			free = atomic_read(&mspecs->free);
+			count = mspecs->count;
+			seq_printf(file, "%4d %7d %7d\n", i, count, free);
+		}
+	}
+
+	return 0;
+}
+
+
+static struct seq_operations mspec_seq_ops = {
+	.start = mspec_seq_start,
+	.next = mspec_seq_next,
+	.stop = mspec_seq_stop,
+	.show = mspec_seq_show
+};
+
+int
+mspec_proc_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &mspec_seq_ops);
+}
+
+static struct file_operations proc_mspec_operations = {
+	.open		= mspec_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+
+static struct proc_dir_entry   *proc_mspec;
+
+#endif /* CONFIG_PROC_FS */
+
+/*
+ * mspec_build_memmap,
+ *
+ * Called at boot time to build a map of pages that can be used for
+ * memory special operations.
+ */
+static int __init
+mspec_build_memmap(unsigned long start, unsigned long end)
+{
+	long length;
+	bte_result_t br;
+	unsigned long vstart, vend;
+	int node;
+
+	length = end - start;
+	vstart = start + __IA64_UNCACHED_OFFSET;
+	vend = end + __IA64_UNCACHED_OFFSET;
+
+#if DEBUG
+	printk(KERN_ERR "mspec_build_memmap(%lx %lx)\n", start, end);
+#endif
+
+	br = BTE_ZERO_BLOCK(vstart, length);
+	if (br != BTE_SUCCESS)
+		panic("BTE Failed while trying to zero mspec page.  bte_result_t = %d\n", (int) br);
+
+	node = nasid_to_cnodeid(NASID_GET(start));
+
+	for (; vstart < vend ; vstart += PAGE_SIZE) {
+#if DEBUG
+		printk(KERN_INFO "sticking %lx into the pool!\n", vstart);
+#endif
+		gen_pool_free(mspec_pool[node], vstart, PAGE_SIZE);
+	}
+
+	return 0;
+}
+
+/*
+ * Walk the EFI memory map to pull out leftover pages in the lower
+ * memory regions which do not end up in the regular memory map and
+ * stick them into the uncached allocator
+ */
+static void __init
+mspec_walk_efi_memmap_uc (void)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size, start, end;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+		if (md->attribute = EFI_MEMORY_UC) {
+			start = PAGE_ALIGN(md->phys_addr);
+			end = PAGE_ALIGN((md->phys_addr+(md->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK);
+			if (mspec_build_memmap(start, end) < 0)
+				return;
+		}
+	}
+}
+
+
+
+/*
+ * mspec_init
+ *
+ * Called at boot time to initialize the mspec facility.
+ */
+static int __init
+mspec_init(void)
+{
+	int i, ret;
+
+	/*
+	 * The fetchop device only works on SN2 hardware, uncached and cached
+	 * memory drivers should both be valid on all ia64 hardware
+	 */
+	if (ia64_platform_is("sn2")) {
+		if ((ret = misc_register(&fetchop_miscdev))) {
+			printk(KERN_ERR "%s: failed to register device %i\n",
+			       FETCHOP_DRIVER_ID_STR, ret);
+			return ret;
+		}
+	}
+	if ((ret = misc_register(&cached_miscdev))) {
+		printk(KERN_ERR "%s: failed to register device %i\n",
+		       CACHED_DRIVER_ID_STR, ret);
+		misc_deregister(&fetchop_miscdev);
+		return ret;
+	}
+	if ((ret = misc_register(&uncached_miscdev))) {
+		printk(KERN_ERR "%s: failed to register device %i\n",
+		       UNCACHED_DRIVER_ID_STR, ret);
+		misc_deregister(&cached_miscdev);
+		misc_deregister(&fetchop_miscdev);
+		return ret;
+	}
+
+	/*
+	 * /proc code needs to be updated to work with the new
+	 * allocation scheme
+	 */
+#ifdef CONFIG_PROC_FS
+	if (!(proc_mspec = create_proc_entry(MSPEC_BASENAME, 0444, NULL))){
+		printk(KERN_ERR "%s: unable to create proc entry",
+		       FETCHOP_DRIVER_ID_STR);
+		misc_deregister(&uncached_miscdev);
+		misc_deregister(&cached_miscdev);
+		misc_deregister(&fetchop_miscdev);
+		return -EINVAL;
+	}
+	proc_mspec->proc_fops = &proc_mspec_operations;
+#endif /* CONFIG_PROC_FS */
+
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		if (!node_online(i))
+			continue;
+		printk(KERN_DEBUG "Setting up pool for node %i\n", i);
+		mspec_pool[i] = alloc_gen_pool(0, IA64_GRANULE_SHIFT,
+					       &mspec_get_new_chunk, i);
+	}
+
+	mspec_walk_efi_memmap_uc();
+
+	printk(KERN_INFO "%s: v%s\n", FETCHOP_DRIVER_ID_STR, REVISION);
+	printk(KERN_INFO "%s: v%s\n", CACHED_DRIVER_ID_STR, REVISION);
+	printk(KERN_INFO "%s: v%s\n", UNCACHED_DRIVER_ID_STR, REVISION);
+
+	return 0;
+}
+
+
+static void __exit
+mspec_exit(void)
+{
+	BUG_ON(atomic_read(&mspec_stats.pages_in_use) > 0);
+
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry(MSPEC_BASENAME, NULL);
+#endif
+	misc_deregister(&uncached_miscdev);
+	misc_deregister(&cached_miscdev);
+	misc_deregister(&fetchop_miscdev);
+}
+
+
+unsigned long
+mspec_kalloc_page(int nid)
+{
+	return TO_AMO(mspec_alloc_page(nid, MSPEC_FETCHOP));
+}
+
+
+void
+mspec_kfree_page(unsigned long maddr)
+{
+	mspec_free_page(TO_PHYS(maddr));
+}
+EXPORT_SYMBOL(mspec_kalloc_page);
+EXPORT_SYMBOL(mspec_kfree_page);
+
+
+module_init(mspec_init);
+module_exit(mspec_exit);
+
+
+MODULE_AUTHOR("Silicon Graphics, Inc.");
+MODULE_DESCRIPTION("Driver for SGI SN special memory operations");
+MODULE_LICENSE("GPL");
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/include/asm-ia64/sn/fetchop.h linux-2.6.11-rc2-mm2/include/asm-ia64/sn/fetchop.h
--- linux-2.6.11-rc2-mm2-vanilla/include/asm-ia64/sn/fetchop.h	2004-12-24 13:35:00 -08:00
+++ linux-2.6.11-rc2-mm2/include/asm-ia64/sn/fetchop.h	1969-12-31 16:00:00 -08:00
@@ -1,85 +0,0 @@
-/*
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
- */
-
-#ifndef _ASM_IA64_SN_FETCHOP_H
-#define _ASM_IA64_SN_FETCHOP_H
-
-#include <linux/config.h>
-
-#define FETCHOP_BASENAME	"sgi_fetchop"
-#define FETCHOP_FULLNAME	"/dev/sgi_fetchop"
-
-
-
-#define FETCHOP_VAR_SIZE 64 /* 64 byte per fetchop variable */
-
-#define FETCHOP_LOAD		0
-#define FETCHOP_INCREMENT	8
-#define FETCHOP_DECREMENT	16
-#define FETCHOP_CLEAR		24
-
-#define FETCHOP_STORE		0
-#define FETCHOP_AND		24
-#define FETCHOP_OR		32
-
-#define FETCHOP_CLEAR_CACHE	56
-
-#define FETCHOP_LOAD_OP(addr, op) ( \
-         *(volatile long *)((char*) (addr) + (op)))
-
-#define FETCHOP_STORE_OP(addr, op, x) ( \
-         *(volatile long *)((char*) (addr) + (op)) = (long) (x))
-
-#ifdef __KERNEL__
-
-/*
- * Convert a region 6 (kaddr) address to the address of the fetchop variable
- */
-#define FETCHOP_KADDR_TO_MSPEC_ADDR(kaddr)	TO_MSPEC(kaddr)
-
-
-/*
- * Each Atomic Memory Operation (AMO formerly known as fetchop)
- * variable is 64 bytes long.  The first 8 bytes are used.  The
- * remaining 56 bytes are unaddressable due to the operation taking
- * that portion of the address.
- * 
- * NOTE: The AMO_t _MUST_ be placed in either the first or second half
- * of the cache line.  The cache line _MUST NOT_ be used for anything
- * other than additional AMO_t entries.  This is because there are two
- * addresses which reference the same physical cache line.  One will
- * be a cached entry with the memory type bits all set.  This address
- * may be loaded into processor cache.  The AMO_t will be referenced
- * uncached via the memory special memory type.  If any portion of the
- * cached cache-line is modified, when that line is flushed, it will
- * overwrite the uncached value in physical memory and lead to
- * inconsistency.
- */
-typedef struct {
-        u64 variable;
-        u64 unused[7];
-} AMO_t;
-
-
-/*
- * The following APIs are externalized to the kernel to allocate/free pages of
- * fetchop variables.
- *	fetchop_kalloc_page	- Allocate/initialize 1 fetchop page on the
- *				  specified cnode. 
- *	fetchop_kfree_page	- Free a previously allocated fetchop page
- */
-
-unsigned long fetchop_kalloc_page(int nid);
-void fetchop_kfree_page(unsigned long maddr);
-
-
-#endif /* __KERNEL__ */
-
-#endif /* _ASM_IA64_SN_FETCHOP_H */
-
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/include/asm-ia64/sn/mspec.h linux-2.6.11-rc2-mm2/include/asm-ia64/sn/mspec.h
--- linux-2.6.11-rc2-mm2-vanilla/include/asm-ia64/sn/mspec.h	1969-12-31 16:00:00 -08:00
+++ linux-2.6.11-rc2-mm2/include/asm-ia64/sn/mspec.h	2005-02-02 04:52:48 -08:00
@@ -0,0 +1,72 @@
+/*
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+#ifndef _ASM_IA64_SN_MSPEC_H
+#define _ASM_IA64_SN_MSPEC_H
+
+#define FETCHOP_VAR_SIZE 64 /* 64 byte per fetchop variable */
+
+#define FETCHOP_LOAD		0
+#define FETCHOP_INCREMENT	8
+#define FETCHOP_DECREMENT	16
+#define FETCHOP_CLEAR		24
+
+#define FETCHOP_STORE		0
+#define FETCHOP_AND		24
+#define FETCHOP_OR		32
+
+#define FETCHOP_CLEAR_CACHE	56
+
+#define FETCHOP_LOAD_OP(addr, op) ( \
+         *(volatile long *)((char*) (addr) + (op)))
+
+#define FETCHOP_STORE_OP(addr, op, x) ( \
+         *(volatile long *)((char*) (addr) + (op)) = (long) (x))
+
+#ifdef __KERNEL__
+
+/*
+ * Each Atomic Memory Operation (AMO formerly known as fetchop)
+ * variable is 64 bytes long.  The first 8 bytes are used.  The
+ * remaining 56 bytes are unaddressable due to the operation taking
+ * that portion of the address.
+ * 
+ * NOTE: The AMO_t _MUST_ be placed in either the first or second half
+ * of the cache line.  The cache line _MUST NOT_ be used for anything
+ * other than additional AMO_t entries.  This is because there are two
+ * addresses which reference the same physical cache line.  One will
+ * be a cached entry with the memory type bits all set.  This address
+ * may be loaded into processor cache.  The AMO_t will be referenced
+ * uncached via the memory special memory type.  If any portion of the
+ * cached cache-line is modified, when that line is flushed, it will
+ * overwrite the uncached value in physical memory and lead to
+ * inconsistency.
+ */
+typedef struct {
+        u64 variable;
+        u64 unused[7];
+} AMO_t;
+
+
+/*
+ * The following APIs are externalized to the kernel to allocate/free pages of
+ * fetchop variables.
+ *	mspec_kalloc_page	- Allocate/initialize 1 fetchop page on the
+ *				  specified cnode. 
+ *	mspec_kfree_page	- Free a previously allocated fetchop page
+ */
+
+extern unsigned long mspec_kalloc_page(int);
+extern void mspec_kfree_page(unsigned long);
+
+
+#endif /* __KERNEL__ */
+
+#endif /* _ASM_IA64_SN_MSPEC_H */
+
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/include/linux/genalloc.h linux-2.6.11-rc2-mm2/include/linux/genalloc.h
--- linux-2.6.11-rc2-mm2-vanilla/include/linux/genalloc.h	1969-12-31 16:00:00 -08:00
+++ linux-2.6.11-rc2-mm2/include/linux/genalloc.h	2005-02-02 04:52:48 -08:00
@@ -0,0 +1,46 @@
+/*
+ * Basic general purpose allocator for managing special purpose memory
+ * not managed by the regular kmalloc/kfree interface.
+ * Uses for this includes on-device special memory, uncached memory
+ * etc.
+ *
+ * This code is based on the buddy allocator found in the sym53c8xx_2
+ * driver, adapted for general purpose use.
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+
+#include <linux/spinlock.h>
+
+#define ALLOC_MIN_SHIFT		5 /* 32 bytes minimum */
+/*
+ *  Link between free memory chunks of a given size.
+ */
+struct gen_pool_link {
+	struct gen_pool_link *next;
+};
+
+/*
+ *  Memory pool of a given kind.
+ *  Ideally, we want to use:
+ *  1) 1 pool for memory we donnot need to involve in DMA.
+ *  2) The same pool for controllers that require same DMA 
+ *     constraints and features.
+ *     The OS specific m_pool_id_t thing and the gen_pool_match() 
+ *     method are expected to tell the driver about.
+ */
+struct gen_pool {
+	spinlock_t lock;
+	unsigned long (*get_new_chunk)(struct gen_pool *);
+	struct gen_pool *next;
+	struct gen_pool_link *h;
+	unsigned long private;
+	int max_chunk_shift;
+};
+
+unsigned long gen_pool_alloc(struct gen_pool *poolp, int size);
+void gen_pool_free(struct gen_pool *mp, unsigned long ptr, int size);
+struct gen_pool *alloc_gen_pool(int nr_chunks, int max_chunk_shift,
+				unsigned long (*fp)(struct gen_pool *),
+				unsigned long data);
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/init/main.c linux-2.6.11-rc2-mm2/init/main.c
--- linux-2.6.11-rc2-mm2-vanilla/init/main.c	2005-02-02 04:31:24 -08:00
+++ linux-2.6.11-rc2-mm2/init/main.c	2005-02-02 04:52:48 -08:00
@@ -78,6 +78,7 @@
 
 static int init(void *);
 
+extern void gen_pool_init(void);
 extern void init_IRQ(void);
 extern void sock_init(void);
 extern void fork_init(unsigned long);
@@ -482,6 +483,7 @@
 #endif
 	vfs_caches_init_early();
 	mem_init();
+	gen_pool_init();
 	kmem_cache_init();
 	numa_policy_init();
 	if (late_time_init)
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/lib/Makefile linux-2.6.11-rc2-mm2/lib/Makefile
--- linux-2.6.11-rc2-mm2-vanilla/lib/Makefile	2005-02-02 04:31:24 -08:00
+++ linux-2.6.11-rc2-mm2/lib/Makefile	2005-02-02 04:54:02 -08:00
@@ -6,7 +6,7 @@
 	 bust_spinlocks.o rbtree.o radix-tree.o dump_stack.o \
 	 kobject.o kref.o idr.o div64.o parser.o int_sqrt.o \
 	 bitmap.o extable.o kobject_uevent.o prio_tree.o \
-	 sha1.o halfmd4.o
+	 sha1.o halfmd4.o genalloc.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff -X /usr/people/jes/exclude-linux -urN linux-2.6.11-rc2-mm2-vanilla/lib/genalloc.c linux-2.6.11-rc2-mm2/lib/genalloc.c
--- linux-2.6.11-rc2-mm2-vanilla/lib/genalloc.c	1969-12-31 16:00:00 -08:00
+++ linux-2.6.11-rc2-mm2/lib/genalloc.c	2005-02-02 04:52:48 -08:00
@@ -0,0 +1,218 @@
+/*
+ * Basic general purpose allocator for managing special purpose memory
+ * not managed by the regular kmalloc/kfree interface.
+ * Uses for this includes on-device special memory, uncached memory
+ * etc.
+ *
+ * This code is based on the buddy allocator found in the sym53c8xx_2
+ * driver Copyright (C) 1999-2001  Gerard Roudier <groudier@free.fr>,
+ * and adapted for general purpose use.
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/stddef.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/spinlock.h>
+#include <linux/genalloc.h>
+
+#include <asm/page.h>
+#include <asm/pal.h>
+
+
+#define DEBUG	0
+
+struct gen_pool *alloc_gen_pool(int nr_chunks, int max_chunk_shift,
+				unsigned long (*fp)(struct gen_pool *),
+				unsigned long data)
+{
+	struct gen_pool *poolp;
+	unsigned long tmp;
+	int i;
+
+	/*
+	 * This is really an arbitrary limit, +10 is enough for
+	 * IA64_GRANULE_SHIFT.
+	 */
+	if ((max_chunk_shift > (PAGE_SHIFT + 10)) || 
+	    ((max_chunk_shift < ALLOC_MIN_SHIFT) && max_chunk_shift))
+		return NULL;
+
+	if (!max_chunk_shift)
+		max_chunk_shift = PAGE_SHIFT;
+
+	poolp = kmalloc(sizeof(struct gen_pool), GFP_KERNEL);
+	if (!poolp)
+		return NULL;
+	memset(poolp, 0, sizeof(struct gen_pool));
+	poolp->h = kmalloc(sizeof(struct gen_pool_link) *
+			   (max_chunk_shift - ALLOC_MIN_SHIFT + 1),
+			   GFP_KERNEL);
+	if (!poolp->h) {
+		printk(KERN_WARNING "gen_pool_alloc() failed to allocate\n");
+		kfree(poolp);
+		return NULL;
+	}
+	memset(poolp->h, 0, sizeof(struct gen_pool_link) *
+	       (max_chunk_shift - ALLOC_MIN_SHIFT + 1));
+
+	spin_lock_init(&poolp->lock);
+	poolp->get_new_chunk = fp;
+	poolp->max_chunk_shift = max_chunk_shift;
+	poolp->private = data;
+
+	for (i = 0; i < nr_chunks; i++) {
+		tmp = poolp->get_new_chunk(poolp);
+		printk(KERN_INFO "allocated %lx\n", tmp);
+		if (!tmp)
+			break;
+		gen_pool_free(poolp, tmp, (1 << poolp->max_chunk_shift));
+	}
+
+	return poolp;
+}
+
+
+/*
+ *  Simple power of two buddy-like generic allocator.
+ *  Provides naturally aligned memory chunks.
+ */
+unsigned long gen_pool_alloc(struct gen_pool *poolp, int size)
+{
+	int j, i, s, max_chunk_size;
+	unsigned long a, flags;
+	struct gen_pool_link *h = poolp->h;
+
+	max_chunk_size = 1 << poolp->max_chunk_shift;
+
+	if (size > max_chunk_size)
+		return 0;
+
+	i = 0;
+	s = (1 << ALLOC_MIN_SHIFT);
+	while (size > s) {
+		s <<= 1;
+		i++;
+	}
+
+#if DEBUG
+	printk(KERN_DEBUG "gen_pool_alloc: s %02x, i %i, h %p\n", s, i, h);
+#endif
+
+	j = i;
+
+	spin_lock_irqsave(&poolp->lock, flags);
+	while (!h[j].next) {
+		if (s = max_chunk_size) {
+			struct gen_pool_link *ptr;
+			spin_unlock_irqrestore(&poolp->lock, flags);
+			ptr = (struct gen_pool_link *)poolp->get_new_chunk(poolp);
+			spin_lock_irqsave(&poolp->lock, flags);
+			h[j].next = ptr;
+			if (h[j].next)
+				h[j].next->next = NULL;
+#if DEBUG
+			printk(KERN_DEBUG "gen_pool_alloc() max chunk j %i\n", j);
+#endif
+			break;
+		}
+		j++;
+		s <<= 1;
+	}
+	a = (unsigned long) h[j].next;
+	if (a) {
+		h[j].next = h[j].next->next;
+		/*
+		 * This should be split into a seperate function doing
+		 * the chunk split in order to support custom
+		 * handling memory not physically accessible by host
+		 */
+		while (j > i) {
+#if DEBUG
+			printk(KERN_DEBUG "gen_pool_alloc() splitting i %i j %i %x a %02lx\n", i, j, s, a);
+#endif
+			j -= 1;
+			s >>= 1;
+			h[j].next = (struct gen_pool_link *) (a + s);
+			h[j].next->next = NULL;
+		}
+	}
+	spin_unlock_irqrestore(&poolp->lock, flags);
+#if DEBUG
+	printk(KERN_DEBUG "gen_pool_alloc(%d) = %p\n", size, (void *) a);
+#endif
+	return a;
+}
+
+/*
+ *  Counter-part of the generic allocator.
+ */
+void gen_pool_free(struct gen_pool *poolp, unsigned long ptr, int size)
+{
+	struct gen_pool_link *q;
+	struct gen_pool_link *h = poolp->h;
+	unsigned long a, b, flags;
+	int i, max_chunk_size;
+	int s = (1 << ALLOC_MIN_SHIFT);
+
+#if DEBUG
+	printk(KERN_DEBUG "gen_pool_free(%lx, %d)\n", ptr, size);
+#endif
+
+	max_chunk_size = 1 << poolp->max_chunk_shift;
+
+	if (size > max_chunk_size)
+		return;
+
+	i = 0;
+	while (size > s) {
+		s <<= 1;
+		i++;
+	}
+
+	a = ptr;
+
+	spin_lock_irqsave(&poolp->lock, flags);
+	while (1) {
+		if (s = max_chunk_size) {
+			((struct gen_pool_link *)a)->next = h[i].next;
+			h[i].next = (struct gen_pool_link *)a;
+			break;
+		}
+		b = a ^ s;
+		q = &h[i];
+
+		while (q->next && q->next != (struct gen_pool_link *)b) {
+			q = q->next;
+		}
+
+		if (!q->next) {
+			((struct gen_pool_link *)a)->next = h[i].next;
+			h[i].next = (struct gen_pool_link *)a;
+			break;
+		}
+		q->next = q->next->next;
+		a = a & b;
+		s <<= 1;
+		i++;
+	}
+	spin_unlock_irqrestore(&poolp->lock, flags);
+}
+
+
+int __init gen_pool_init(void)
+{
+	printk(KERN_INFO "Generic memory pool allocator v1.0\n");
+	return 0;
+}
+
+EXPORT_SYMBOL(alloc_gen_pool);
+EXPORT_SYMBOL(gen_pool_alloc);
+EXPORT_SYMBOL(gen_pool_free);

