From: Robin Holt <holt@sgi.com>
Date: Thu, 09 Sep 2004 17:54:25 +0000
Subject: [RFC 2/2] Add SN2 Special Memory driver.
Message-Id: <20040909175425.GB23863@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Introduce the SGI SN2 Special Memory driver.

Index: linux-2.6/include/asm-ia64/sn/mspec.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/mspec.h	2004-09-09 09:28:21.000000000 -0500
+++ linux-2.6/include/asm-ia64/sn/mspec.h	2004-09-09 10:53:55.000000000 -0500
@@ -4,19 +4,14 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2001-2003 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2001-2004 Silicon Graphics, Inc.  All rights reserved.
  */
 
-#ifndef _ASM_IA64_SN_FETCHOP_H
-#define _ASM_IA64_SN_FETCHOP_H
+#ifndef _ASM_IA64_SN_MSPECH_H
+#define _ASM_IA64_SN_MSPECH_H
 
 #include <linux/config.h>
 
-#define FETCHOP_BASENAME	"sgi_fetchop"
-#define FETCHOP_FULLNAME	"/dev/sgi_fetchop"
-
-
-
 #define FETCHOP_VAR_SIZE 64 /* 64 byte per fetchop variable */
 
 #define FETCHOP_LOAD		0
@@ -39,12 +34,6 @@
 #ifdef __KERNEL__
 
 /*
- * Convert a region 6 (kaddr) address to the address of the fetchop variable
- */
-#define FETCHOP_KADDR_TO_MSPEC_ADDR(kaddr)	TO_MSPEC(kaddr)
-
-
-/*
  * Each Atomic Memory Operation (AMO formerly known as fetchop)
  * variable is 64 bytes long.  The first 8 bytes are used.  The
  * remaining 56 bytes are unaddressable due to the operation taking
@@ -81,5 +70,5 @@
 
 #endif /* __KERNEL__ */
 
-#endif /* _ASM_IA64_SN_FETCHOP_H */
+#endif /* _ASM_IA64_SN_MSPECH_H */
 
Index: linux-2.6/arch/ia64/sn/kernel/mspec.c
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/arch/ia64/sn/kernel/mspec.c	2004-09-09 10:53:55.000000000 -0500
@@ -0,0 +1,658 @@
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
+/*
+ * Copyright (C) 2001-2004 Silicon Graphics, Inc.  All rights
+ * reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
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
+#include <linux/seq_file.h>
+#include <linux/efi.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+#include <asm/uaccess.h>
+#include <asm/atomic.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/arch.h>
+#include <asm/sn/sn2/arch.h>
+#include <asm/sn/mspec.h>
+#include <asm/sn/sn_cpuid.h>
+#include <asm/sn/io.h>
+#include <asm/sn/bte.h>
+
+
+#define FETCHOP_DRIVER_ID_STR	"SGI Fetchop Device Driver"
+#define CACHED_DRIVER_ID_STR	"SGI Cached Device Driver"
+#define UNCACHED_DRIVER_ID_STR	"SGI Uncached Device Driver"
+#define REVISION		"2.0"
+#define MSPEC_BASENAME		"sgi_sn/sgi_mspec"
+
+
+#define MSPEC_TO_NID(maddr)	nasid_to_cnodeid(NASID_GET(maddr))
+
+#define BTE_ZERO_BLOCK(_maddr, _len) \
+	bte_copy(0, __pa(_maddr), _len, BTE_WACQUIRE | BTE_ZERO_FILL, NULL)
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
+	SGI_FETCHOP = 1,
+	SGI_CACHED,
+	SGI_UNCACHED
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
+	int		count;		/* Number of pages allocated. */
+	atomic_t	refcnt;		/* Number of vmas sharing the data. */
+	spinlock_t	lock;		/* Serialize access to the vma. */
+	int		type;		/* Type of pages allocated. */
+	unsigned long	maddr[1];	/* Array of MSPEC addresses. */
+};
+
+
+/*
+ * Memory Special statistics.
+ */
+struct mspec_stats {
+	spinlock_t	lock;
+	unsigned long	map_count;	/* Number of active mmap's */
+	unsigned long	pages_in_use;	/* Number of mspec pages in use */
+	unsigned long	pages_total;	/* Total number of mspec pages */
+};
+
+static struct mspec_stats	mspec_stats = {
+	.lock		SPIN_LOCK_UNLOCKED,
+};
+static struct node_mspecs	*node_mspecs[MAX_COMPACT_NODES];
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
+	int i, bit;
+	struct node_mspecs *mspecs;
+	unsigned long maddr;
+
+	if (nid < 0 || nid >= numnodes)
+		nid = numa_node_id();
+	for (i=0; i < numnodes; i++) {
+		mspecs = node_mspecs[nid];
+		while (mspecs && (bit = find_first_zero_bit(mspecs->bits, mspecs->count)) < mspecs->count) {
+			if (test_and_set_bit(bit, mspecs->bits) = 0) {
+				atomic_dec(&node_mspecs[nid]->free);
+				maddr = mspecs->maddr + (bit<<PAGE_SHIFT);
+				return maddr;
+			}
+		}
+		nid = (nid+1 < numnodes) ? nid+1 : 0;
+	}
+	return 0;
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
+	int nid, bit;
+
+	nid = MSPEC_TO_NID(maddr);
+	bit = (maddr - node_mspecs[nid]->maddr) >> PAGE_SHIFT;
+	clear_bit(bit, node_mspecs[nid]->bits);
+	atomic_inc(&node_mspecs[nid]->free);
+}
+
+
+/*
+ * mspec_update_stats
+ *
+ * Update statistics of the number of mspec mappings & pages.
+ * If creating a new mapping, ensure that we don't exceed the maximum allowed
+ * number of mspec pages.
+ */
+static int
+mspec_update_stats(int mmap, long count)
+{
+	int ret = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&mspec_stats.lock, flags);
+	if (count > 0 &&
+	    mspec_stats.pages_in_use + count > mspec_stats.pages_total) {
+		ret = -1;
+	} else {
+		mspec_stats.map_count += mmap;
+		mspec_stats.pages_in_use += count;
+	}
+	spin_unlock_irqrestore(&mspec_stats.lock, flags);
+
+	return ret;
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
+	if (vdata->type = SGI_FETCHOP || vdata->type = SGI_UNCACHED)
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	vma->vm_ops = &mspec_vm_ops;
+
+	mspec_update_stats(1, 0);
+
+	return 0;
+}
+
+static int
+fetchop_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return mspec_mmap(file, vma, SGI_FETCHOP);
+}
+
+static int
+cached_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return mspec_mmap(file, vma, SGI_CACHED);
+}
+
+static int
+uncached_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return mspec_mmap(file, vma, SGI_UNCACHED);
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
+		for (i=0; i<pages; i++) {
+			if (vdata->maddr[i] != 0) {
+				/*
+				 * Use the bte to ensure cache lines
+				 * are actually pulled from the
+				 * processor back to the md.
+				 */
+				br = BTE_ZERO_BLOCK(vdata->maddr[i], PAGE_SIZE);
+				if (br = BTE_SUCCESS)
+					mspec_free_page(vdata->maddr[i]);
+			}
+		}
+		if (vdata->count)
+			mspec_update_stats(-1, -vdata->count);
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
+
+
+	pgd = pgd_offset(mm, address);
+	if (pgd_present(*pgd)) {
+		pmd = pmd_offset(pgd, address);
+		if (pmd_present(*pmd)) {
+			*pte = pte_offset_map(pmd, address);
+			if (pte_present(**pte)) {
+				return 0;
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
+	int index;
+	pte_t *pte;
+	struct page *page;
+	struct vma_data *vdata = vma->vm_private_data;
+
+
+	spin_lock(&vdata->lock);
+
+	index = (address - vma->vm_start) >> PAGE_SHIFT;
+	if (vdata->maddr[index] = 0) {
+		if (mspec_update_stats(0, 1) < 0)
+			goto error;
+		vdata->count++;
+		maddr = mspec_alloc_page(numa_node_id(), vdata->type);
+		if (maddr = 0)
+			BUG();
+		vdata->maddr[index] = maddr;
+	} else if (mspec_get_one_pte(vma->vm_mm, address, &pte) = 0) {
+		/*
+		 * The page may have already been faulted by another
+		 * pthread.  If so, we need to avoid remapping the
+		 * page or we will trip a BUG check in the
+		 * remap_page_range() path.
+		 */
+		goto getpage;
+	}
+
+	if (vdata->type = SGI_FETCHOP)
+		paddr = vdata->maddr[index] | AMO_PHYS_SPACE;
+	else
+		paddr = __pa(TO_CAC(vdata->maddr[index]));
+
+	if (remap_page_range(vma, address, paddr, PAGE_SIZE, vma->vm_page_prot))
+		goto error;
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
+		++vma->vm_mm->rss;
+		spin_unlock(&vma->vm_mm->page_table_lock);
+
+		set_pte(pte, pte_mkwrite(pte_mkdirty(*pte)));
+getpage:
+		page = alloc_pages(GFP_USER, 0);
+
+		spin_unlock(&vdata->lock);
+		return page;
+	}
+
+error:
+	if (maddr) {
+		mspec_free_page(vdata->maddr[index]);
+		vdata->maddr[index] = 0;
+		vdata->count--;
+		mspec_update_stats(0, -1);
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
+	if (*offset < numnodes)
+		return offset;
+	return NULL;			
+}
+
+static void *
+mspec_seq_next(struct seq_file *file, void *data, loff_t *offset)
+{
+	(*offset)++;
+	if (*offset < numnodes)
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
+
+	if (!i) {
+		seq_printf(file, "mappings               : %lu\n",
+			   mspec_stats.map_count);
+		seq_printf(file, "current mspec pages  : %lu\n",
+			   mspec_stats.pages_in_use);
+		seq_printf(file, "maximum mspec pages  : %lu\n",
+			   mspec_stats.pages_total);
+		seq_printf(file, "%4s %7s %7s\n", "node", "total", "free");
+	}
+
+	if (i < numnodes) {
+		int free, count;
+		mspecs = node_mspecs[i];
+		free = atomic_read(&mspecs->free);
+		count = mspecs->count;
+		seq_printf(file, "%4d %7d %7d\n", i, count, free);
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
+mspec_build_memmap(unsigned long start, unsigned long end, void *arg)
+{
+	struct node_mspecs *mspecs;
+	long count, bytes, length;
+	bte_result_t br;
+
+	length = end - start;
+
+	br = BTE_ZERO_BLOCK(start, length);
+	if (br != BTE_SUCCESS)
+		panic("BTE Failed while trying to zero mspec page.  bte_result_t = %d\n", (int) br);
+
+	count = length >> PAGE_SHIFT;
+	bytes = sizeof(struct node_mspecs) + count/8;
+	mspecs = vmalloc(bytes);
+	if (mspecs = NULL)
+		return 0;
+	memset(mspecs, 0, bytes);
+	mspecs->maddr = TO_PHYS(start);
+	mspecs->count = count;
+	atomic_add(count, &mspecs->free);
+	mspec_stats.pages_total += count;
+	node_mspecs[MSPEC_TO_NID(start)] = mspecs;
+	return 0;
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
+	int ret;
+
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
+	if ((ret = misc_register(&fetchop_miscdev))) {
+		printk(KERN_ERR "%s: failed to register device\n", FETCHOP_DRIVER_ID_STR);
+		return ret;
+	}
+	if ((ret = misc_register(&cached_miscdev))) {
+		printk(KERN_ERR "%s: failed to register device\n", CACHED_DRIVER_ID_STR);
+		misc_deregister(&fetchop_miscdev);
+		return ret;
+	}
+	if ((ret = misc_register(&uncached_miscdev))) {
+		printk(KERN_ERR "%s: failed to register device\n", UNCACHED_DRIVER_ID_STR);
+		misc_deregister(&cached_miscdev);
+		misc_deregister(&fetchop_miscdev);
+		return ret;
+	}
+
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
+	efi_memmap_walk_uc(mspec_build_memmap, 0);
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
+	BUG_ON(mspec_stats.pages_in_use > 0);
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
+	if (mspec_update_stats(1, 1) < 0)
+		return 0;
+	return TO_MSPEC(mspec_alloc_page(nid, SGI_FETCHOP));
+}
+EXPORT_SYMBOL(mspec_kalloc_page);
+
+
+void
+mspec_kfree_page(unsigned long maddr)
+{
+	mspec_free_page(TO_PHYS(maddr));
+	mspec_update_stats(-1, -1);
+}
+EXPORT_SYMBOL(mspec_kfree_page);
+
+module_init(mspec_init);
+module_exit(mspec_exit);
+
+MODULE_AUTHOR("Silicon Graphics, Inc.");
+MODULE_DESCRIPTION("Driver for SGI SN special memory operations");
+MODULE_LICENSE("GPL");
Index: linux-2.6/arch/ia64/configs/sn2_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/sn2_defconfig	2004-09-09 09:22:25.000000000 -0500
+++ linux-2.6/arch/ia64/configs/sn2_defconfig	2004-09-09 10:53:55.000000000 -0500
@@ -72,6 +72,7 @@
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
 CONFIG_IA64_SGI_SN_SIM=y
+CONFIG_SGI_MSPEC=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
Index: linux-2.6/mm/page_alloc.c
=================================--- linux-2.6.orig/mm/page_alloc.c	2004-09-09 09:22:31.000000000 -0500
+++ linux-2.6/mm/page_alloc.c	2004-09-09 10:53:55.000000000 -0500
@@ -42,6 +42,7 @@
 int numnodes = 1;
 int sysctl_lower_zone_protection = 0;
 
+EXPORT_SYMBOL(numnodes);
 EXPORT_SYMBOL(totalram_pages);
 EXPORT_SYMBOL(nr_swap_pages);
 
Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2004-09-09 09:22:28.000000000 -0500
+++ linux-2.6/arch/ia64/kernel/efi.c	2004-09-09 10:53:55.000000000 -0500
@@ -292,6 +292,33 @@
 }
 
 /*
+ * Walks the EFI memory map and calls 'callback' once for each EFI memory
+ * descriptor that has memory marked as only EFI_MEMORY_UC.
+ */
+void
+efi_memmap_walk_uc (efi_freemem_callback_t callback, void *arg)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size, start, end;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+		if (md->attribute = EFI_MEMORY_UC) {
+			start = PAGE_ALIGN(md->phys_addr);
+			end = PAGE_ALIGN((md->phys_addr+(md->num_pages << EFI_PAGE_SHIFT)) & PAGE_MASK);
+			if ((*callback)(start, end, arg) < 0)
+				return;
+		}
+	}
+}
+EXPORT_SYMBOL(efi_memmap_walk_uc);
+
+/*
  * Walks the EFI memory map and calls CALLBACK once for each EFI memory descriptor that
  * has memory that is available for OS use.
  */
Index: linux-2.6/include/linux/efi.h
=================================--- linux-2.6.orig/include/linux/efi.h	2004-09-09 09:23:51.000000000 -0500
+++ linux-2.6/include/linux/efi.h	2004-09-09 10:53:55.000000000 -0500
@@ -374,4 +374,6 @@
 	u16 length;
 } __attribute ((packed));
 
+extern void efi_memmap_walk_uc (efi_freemem_callback_t, void *);
+
 #endif /* _LINUX_EFI_H */
Index: linux-2.6/include/asm-ia64/sn/sn2/addrs.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn2/addrs.h	2004-09-09 09:22:31.000000000 -0500
+++ linux-2.6/include/asm-ia64/sn/sn2/addrs.h	2004-09-09 10:53:55.000000000 -0500
@@ -57,11 +57,13 @@
 #define GLOBAL_MMR_SPACE	0xc000000800000000	/* Global MMR space */
 #define GLOBAL_PHYS_MMR_SPACE	0x0000000800000000	/* Global Physical MMR space */
 #define GET_SPACE		0xe000001000000000	/* GET space */
-#define AMO_SPACE		0xc000002000000000	/* AMO space */
+#define AMO_PHYS_SPACE		0x0000002000000000	/* AMO Space as a phys addr */
 #define CACHEABLE_MEM_SPACE	0xe000003000000000	/* Cacheable memory space */
 #define UNCACHED                0xc000000000000000      /* UnCacheable memory space */
 #define UNCACHED_PHYS           0x8000000000000000      /* UnCacheable physical memory space */
 
+#define AMO_SPACE		(AMO_PHYS_SPACE | UNCACHED)
+
 #define PHYS_MEM_SPACE		0x0000003000000000	/* physical memory space */
 
 /* SN2 address macros */
Index: linux-2.6/arch/ia64/sn/kernel/Makefile
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/Makefile	2004-09-09 09:22:36.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/Makefile	2004-09-09 10:53:55.000000000 -0500
@@ -9,3 +9,4 @@
 
 obj-y				+= probe.o setup.o bte.o irq.o mca.o idle.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
+obj-$(CONFIG_SGI_MSPEC) += mspec.o
Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2004-09-09 09:23:52.000000000 -0500
+++ linux-2.6/arch/ia64/Kconfig	2004-09-09 10:53:55.000000000 -0500
@@ -196,6 +196,15 @@
 	  If you are compiling a kernel that will run under SGI's IA-64
 	  simulator (Medusa) then say Y, otherwise say N.
 
+config SGI_MSPEC
+	tristate "SGI SN2 Special Memory support"
+	depends on IA64_GENERIC || IA64_SGI_SN2
+	help
+	  This driver exports special memory capabilities of the SGI SN
+	  architecture such as the fetchop facility to user processes.
+	  Fetchops are atomic memory operations that are implemented in the
+	  memory controller on SGI SN hardware.
+
 config FORCE_MAX_ZONEORDER
 	int
 	default "18"
Index: linux-2.6/arch/ia64/configs/generic_defconfig
=================================--- linux-2.6.orig/arch/ia64/configs/generic_defconfig	2004-09-09 09:22:59.000000000 -0500
+++ linux-2.6/arch/ia64/configs/generic_defconfig	2004-09-09 10:56:11.000000000 -0500
@@ -72,6 +72,7 @@
 CONFIG_DISCONTIGMEM=y
 CONFIG_IA64_CYCLONE=y
 CONFIG_IOSAPIC=y
+CONFIG_SGI_MSPEC=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
 CONFIG_NR_CPUSQ2
