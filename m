From: jes@trained-monkey.org (Jes Sorensen)
Date: Wed, 18 May 2005 18:30:07 +0000
Subject: [patch] 2.6.12-rc4-mm2 uncached + generic allocator
Message-Id: <17035.35247.591139.841268@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

As promised here is the patch for the uncached allocator. I split it off
from the mspec driver since there's now several users of it and Keith
mentioned earlier that he also needs such an allocator. I also updated
the XPC code that is already in the -mm tree to make it use the updated
uncached allocator interface as well.

I left the uncached EFI scan code as a seperate function as the walk of
the uncached memmap is fundamentally different from the generic walk
code that it doesn't really make sense to try and merge them.

The patch is against 2.6.12-rc4-mm2 but it should be pretty simple to
pull out the parts if one wants to apply it to Linus' tree.

The XPC code will not compile with this, it still needs the mspec.h file
which I will push as a seperate patch.

Tony, do you have any objections to this? Otherwise I'd like to push it
to Andrew.

Andrew let me know if this patch is ok as is or if you prefer it split
up into smaller chunks.

Cheers,
Jes

This patch contains the ia64 uncached page allocator and the generic
allocator (genalloc). The uncached allocator was formerly part of the
SN2 mspec driver but there are several other users of it so it has
been split off from the driver. 

The generic allocator can be used by device driver to manage special
memory etc. The allocator is based on the allocator from the
sym53c8xx_2 driver.

In addition this patch contains the bits to make the XPC code use the
uncached allocator rather than calling into the mspec driver.

Signed-off-by: Jes Sorensen <jes@wildopensource.com>

diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/arch/ia64/Kconfig linux-2.6.12-rc4-mm2-uncached/arch/ia64/Kconfig
--- linux-2.6.12-rc4-mm2-vanilla/arch/ia64/Kconfig	2005-05-16 04:57:47 -07:00
+++ linux-2.6.12-rc4-mm2-uncached/arch/ia64/Kconfig	2005-05-18 08:41:59 -07:00
@@ -50,6 +50,10 @@
 	bool
 	default y
 
+config IA64_UNCACHED_ALLOCATOR
+	bool
+	select GENERIC_ALLOCATOR
+
 choice
 	prompt "System type"
 	default IA64_GENERIC
@@ -223,7 +227,7 @@
 
 config IA64_SGI_SN_XP
 	tristate "Support communication between SGI SSIs"
-	depends on MSPEC
+	select IA64_UNCACHED_ALLOCATOR
 	help
 	  An SGI machine can be divided into multiple Single System
 	  Images which act independently of each other and have
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/arch/ia64/kernel/Makefile linux-2.6.12-rc4-mm2-uncached/arch/ia64/kernel/Makefile
--- linux-2.6.12-rc4-mm2-vanilla/arch/ia64/kernel/Makefile	2005-03-01 23:38:33 -08:00
+++ linux-2.6.12-rc4-mm2-uncached/arch/ia64/kernel/Makefile	2005-05-18 08:41:23 -07:00
@@ -20,6 +20,7 @@
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
+obj-$(CONFIG_IA64_UNCACHED_ALLOCATOR)	+= uncached.o
 mca_recovery-y			+= mca_drv.o mca_drv_asm.o
 
 # The gate DSO image is built using a special linker script.
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/arch/ia64/kernel/efi.c linux-2.6.12-rc4-mm2-uncached/arch/ia64/kernel/efi.c
--- linux-2.6.12-rc4-mm2-vanilla/arch/ia64/kernel/efi.c	2005-03-01 23:37:47 -08:00
+++ linux-2.6.12-rc4-mm2-uncached/arch/ia64/kernel/efi.c	2005-05-18 08:41:23 -07:00
@@ -410,6 +410,38 @@
 }
 
 /*
+ * Walk the EFI memory map to pull out leftover pages in the lower
+ * memory regions which do not end up in the regular memory map and
+ * stick them into the uncached allocator
+ *
+ * The regular walk function is significantly more complex than the
+ * uncached walk which means it really doesn't make sense to try and
+ * marge the two.
+ */
+void __init
+efi_memmap_walk_uc (efi_freemem_callback_t callback)
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
+			if ((*callback)(start, end, NULL) < 0)
+				return;
+		}
+	}
+}
+
+
+/*
  * Look for the PAL_CODE region reported by EFI and maps it using an
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/arch/ia64/kernel/uncached.c linux-2.6.12-rc4-mm2-uncached/arch/ia64/kernel/uncached.c
--- linux-2.6.12-rc4-mm2-vanilla/arch/ia64/kernel/uncached.c	1969-12-31 16:00:00 -08:00
+++ linux-2.6.12-rc4-mm2-uncached/arch/ia64/kernel/uncached.c	2005-05-18 08:41:23 -07:00
@@ -0,0 +1,246 @@
+/*
+ * Copyright (C) 2001-2005 Silicon Graphics, Inc.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * A simple uncached page allocator using the generic allocator. This
+ * allocator first utilizes the spare (spill) pages found in the EFI
+ * memmap and will then start converting cached pages to uncached ones
+ * at a granule at a time. Node awareness is implemented by having a
+ * pool of pages per node.
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+#include <linux/efi.h>
+#include <linux/genalloc.h>
+#include <asm/page.h>
+#include <asm/pal.h>
+#include <asm/system.h>
+#include <asm/pgtable.h>
+#include <asm/atomic.h>
+#include <asm/tlbflush.h>
+#include <asm/sn/arch.h>
+
+#define DEBUG	0
+
+#if DEBUG
+#define dprintk			printk
+#else
+#define dprintk(x...)		do { } while (0)
+#endif
+
+void __init efi_memmap_walk_uc (efi_freemem_callback_t callback);
+
+#define MAX_UNCACHED_GRANULES	5
+static int allocated_granules;
+
+struct gen_pool *uncached_pool[MAX_NUMNODES];
+
+
+static void uncached_ipi_visibility(void *data)
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
+static void uncached_ipi_mc_drain(void *data)
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
+uncached_get_new_chunk(struct gen_pool *poolp)
+{
+	struct page *page;
+	void *tmp;
+	int status, i;
+	unsigned long addr, node;
+
+	if (allocated_granules >= MAX_UNCACHED_GRANULES)
+		return 0;
+
+	node = poolp->private;
+	page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO,
+				IA64_GRANULE_SHIFT-PAGE_SHIFT);
+
+	dprintk(KERN_INFO "get_new_chunk page %p, addr %lx\n",
+		page, (unsigned long)(page-vmem_map) << PAGE_SHIFT);
+
+	/*
+	 * Do magic if no mem on local node! XXX
+	 */
+	if (!page)
+		return 0;
+	tmp = page_address(page);
+
+	/*
+	 * There's a small race here where it's possible for someone to
+	 * access the page through /dev/mem halfway through the conversion
+	 * to uncached - not sure it's really worth bothering about
+	 */
+	for (i = 0; i < (IA64_GRANULE_SIZE / PAGE_SIZE); i++)
+		SetPageUncached(&page[i]);
+
+	flush_tlb_kernel_range(tmp, tmp + IA64_GRANULE_SIZE);
+
+	status = ia64_pal_prefetch_visibility(PAL_VISIBILITY_PHYSICAL);
+
+	dprintk(KERN_INFO "pal_prefetch_visibility() returns %i on cpu %i\n",
+		status, get_cpu());
+
+	if (!status) {
+		status = smp_call_function(uncached_ipi_visibility, NULL, 0, 1);
+		if (status)
+			printk(KERN_WARNING "smp_call_function failed for "
+			       "uncached_ipi_visibility! (%i)\n", status);
+	}
+
+	if (ia64_platform_is("sn2"))
+		sn_flush_all_caches((unsigned long)tmp, IA64_GRANULE_SIZE);
+	else
+		flush_icache_range((unsigned long)tmp,
+				   (unsigned long)tmp+IA64_GRANULE_SIZE);
+
+	ia64_pal_mc_drain();
+	status = smp_call_function(uncached_ipi_mc_drain, NULL, 0, 1);
+	if (status)
+		printk(KERN_WARNING "smp_call_function failed for "
+		       "uncached_ipi_mc_drain! (%i)\n", status);
+
+	addr = (unsigned long)tmp - PAGE_OFFSET + __IA64_UNCACHED_OFFSET;
+
+	allocated_granules++;
+	return addr;
+}
+
+
+/*
+ * uncached_alloc_page
+ *
+ * Allocate 1 uncached page. Allocates on the requested node. If no
+ * uncached pages are available on the requested node, roundrobin starting
+ * with higher nodes.
+ */
+unsigned long
+uncached_alloc_page(int nid)
+{
+	unsigned long maddr;
+
+	maddr = gen_pool_alloc(uncached_pool[nid], PAGE_SIZE);
+
+	dprintk(KERN_DEBUG "uncached_alloc_page returns %lx on node %i\n",
+		maddr, nid);
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
+			maddr = gen_pool_alloc(uncached_pool[i], PAGE_SIZE);
+			dprintk(KERN_DEBUG "uncached_alloc_page alternate search "
+				"returns %lx on node %i\n", maddr, i);
+			if (maddr) {
+				break;
+			}
+		}
+	}
+
+	return maddr;
+}
+EXPORT_SYMBOL(uncached_alloc_page);
+
+
+/*
+ * uncached_free_page
+ *
+ * Free a single uncached page.
+ */
+void
+uncached_free_page(unsigned long maddr)
+{
+	int node;
+
+	node = nasid_to_cnodeid(NASID_GET(maddr));
+
+	dprintk(KERN_DEBUG "uncached_free_page(%lx) on node %i\n", maddr, node);
+
+	if ((maddr & (0XFUL << 60)) != __IA64_UNCACHED_OFFSET)
+		panic("uncached_free_page invalid address %lx\n", maddr); 
+
+	gen_pool_free(uncached_pool[node], maddr, PAGE_SIZE);
+}
+EXPORT_SYMBOL(uncached_free_page);
+
+
+/*
+ * uncached_build_memmap,
+ *
+ * Called at boot time to build a map of pages that can be used for
+ * memory special operations.
+ */
+static int __init
+uncached_build_memmap(unsigned long start, unsigned long end, void *arg)
+{
+	long length;
+	unsigned long vstart, vend;
+	int node;
+
+	length = end - start;
+	vstart = start + __IA64_UNCACHED_OFFSET;
+	vend = end + __IA64_UNCACHED_OFFSET;
+
+	dprintk(KERN_ERR "uncached_build_memmap(%lx %lx)\n", start, end);
+
+	memset((char *)vstart, 0, length);
+
+	node = nasid_to_cnodeid(NASID_GET(start));
+
+	for (; vstart < vend ; vstart += PAGE_SIZE) {
+		dprintk(KERN_INFO "sticking %lx into the pool!\n", vstart);
+		gen_pool_free(uncached_pool[node], vstart, PAGE_SIZE);
+	}
+
+	return 0;
+}
+
+
+static int __init uncached_init(void) {
+	int i;
+
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		if (!node_online(i))
+			continue;
+		uncached_pool[i] = gen_pool_create(0, IA64_GRANULE_SHIFT,
+						   &uncached_get_new_chunk, i);
+	}
+
+	efi_memmap_walk_uc(uncached_build_memmap);
+
+	return 0;
+}
+
+__initcall(uncached_init);
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/arch/ia64/sn/kernel/xpc_partition.c linux-2.6.12-rc4-mm2-uncached/arch/ia64/sn/kernel/xpc_partition.c
--- linux-2.6.12-rc4-mm2-vanilla/arch/ia64/sn/kernel/xpc_partition.c	2005-05-12 04:06:22 -07:00
+++ linux-2.6.12-rc4-mm2-uncached/arch/ia64/sn/kernel/xpc_partition.c	2005-05-18 08:41:23 -07:00
@@ -22,6 +22,7 @@
 #include <linux/cache.h>
 #include <linux/mmzone.h>
 #include <linux/nodemask.h>
+#include <asm/uncached.h>
 #include <asm/sn/bte.h>
 #include <asm/sn/intr.h>
 #include <asm/sn/sn_sal.h>
@@ -183,7 +184,7 @@
 	 * memory protections are never restricted.
 	 */
 	if ((amos_page = xpc_vars->amos_page) = NULL) {
-		amos_page = (AMO_t *) mspec_kalloc_page(0);
+		amos_page = (AMO_t *) TO_AMO(uncached_alloc_page(0));
 		if (amos_page = NULL) {
 			dev_err(xpc_part, "can't allocate page of AMOs\n");
 			return NULL;
@@ -200,7 +201,8 @@
 			if (ret != 0) {
 				dev_err(xpc_part, "can't change memory "
 					"protections\n");
-				mspec_kfree_page((unsigned long) amos_page);
+				uncached_free_page(__IA64_UNCACHED_OFFSET |
+						   TO_PHYS((u64) amos_page));
 				return NULL;
 			}
 		}
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/include/asm-ia64/uncached.h linux-2.6.12-rc4-mm2-uncached/include/asm-ia64/uncached.h
--- linux-2.6.12-rc4-mm2-vanilla/include/asm-ia64/uncached.h	1969-12-31 16:00:00 -08:00
+++ linux-2.6.12-rc4-mm2-uncached/include/asm-ia64/uncached.h	2005-05-18 08:41:23 -07:00
@@ -0,0 +1,12 @@
+/*
+ * Copyright (C) 2001-2005 Silicon Graphics, Inc.  All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * Prototypes for the uncached page allocator
+ */
+
+extern unsigned long uncached_alloc_page(int nid);
+extern void uncached_free_page(unsigned long);
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/include/linux/genalloc.h linux-2.6.12-rc4-mm2-uncached/include/linux/genalloc.h
--- linux-2.6.12-rc4-mm2-vanilla/include/linux/genalloc.h	1969-12-31 16:00:00 -08:00
+++ linux-2.6.12-rc4-mm2-uncached/include/linux/genalloc.h	2005-05-18 08:41:23 -07:00
@@ -0,0 +1,40 @@
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
+ *  Memory pool descriptor.
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
+struct gen_pool *gen_pool_create(int nr_chunks, int max_chunk_shift,
+				 unsigned long (*fp)(struct gen_pool *),
+				 unsigned long data);
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/lib/Kconfig linux-2.6.12-rc4-mm2-uncached/lib/Kconfig
--- linux-2.6.12-rc4-mm2-vanilla/lib/Kconfig	2005-03-01 23:38:10 -08:00
+++ linux-2.6.12-rc4-mm2-uncached/lib/Kconfig	2005-05-18 08:41:23 -07:00
@@ -40,6 +40,12 @@
 	tristate
 
 #
+# Generic allocator support is selected if needed
+#
+config GENERIC_ALLOCATOR
+	boolean
+
+#
 # reed solomon support is select'ed if needed
 #
 config REED_SOLOMON
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/lib/Makefile linux-2.6.12-rc4-mm2-uncached/lib/Makefile
--- linux-2.6.12-rc4-mm2-vanilla/lib/Makefile	2005-05-16 04:57:50 -07:00
+++ linux-2.6.12-rc4-mm2-uncached/lib/Makefile	2005-05-18 08:41:23 -07:00
@@ -29,6 +29,7 @@
 obj-$(CONFIG_CRC32)	+= crc32.o
 obj-$(CONFIG_LIBCRC32C)	+= libcrc32c.o
 obj-$(CONFIG_GENERIC_IOMAP) += iomap.o
+obj-$(CONFIG_GENERIC_ALLOCATOR) += genalloc.o
 
 obj-$(CONFIG_ZLIB_INFLATE) += zlib_inflate/
 obj-$(CONFIG_ZLIB_DEFLATE) += zlib_deflate/
diff -urN -X /usr/people/jes/exclude-linux linux-2.6.12-rc4-mm2-vanilla/lib/genalloc.c linux-2.6.12-rc4-mm2-uncached/lib/genalloc.c
--- linux-2.6.12-rc4-mm2-vanilla/lib/genalloc.c	1969-12-31 16:00:00 -08:00
+++ linux-2.6.12-rc4-mm2-uncached/lib/genalloc.c	2005-05-18 08:41:23 -07:00
@@ -0,0 +1,188 @@
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
+ * Copyright 2005 (C) Jes Sorensen <jes@trained-monkey.org>
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2.  See the file COPYING for more details.
+ */
+
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
+
+
+struct gen_pool *gen_pool_create(int nr_chunks, int max_chunk_shift,
+				 unsigned long (*fp)(struct gen_pool *),
+				 unsigned long data)
+{
+	struct gen_pool *poolp;
+	unsigned long tmp;
+	int i;
+
+	/*
+	 * This is really an arbitrary limit, +10 is enough for
+	 * IA64_GRANULE_SHIFT, aka 16MB. If anyone needs a large limit
+	 * this can be increased without problems.
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
+EXPORT_SYMBOL(gen_pool_create);
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
+	
+	size = max(size, 1 << ALLOC_MIN_SHIFT);
+	s = roundup_pow_of_two(size);
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
+			j -= 1;
+			s >>= 1;
+			h[j].next = (struct gen_pool_link *) (a + s);
+			h[j].next->next = NULL;
+		}
+	}
+	spin_unlock_irqrestore(&poolp->lock, flags);
+	return a;
+}
+EXPORT_SYMBOL(gen_pool_alloc);
+
+
+/*
+ *  Counter-part of the generic allocator.
+ */
+void gen_pool_free(struct gen_pool *poolp, unsigned long ptr, int size)
+{
+	struct gen_pool_link *q;
+	struct gen_pool_link *h = poolp->h;
+	unsigned long a, b, flags;
+	int i, s, max_chunk_size;
+
+	max_chunk_size = 1 << poolp->max_chunk_shift;
+
+	if (size > max_chunk_size)
+		return;
+
+	i = 0;
+
+	size = max(size, 1 << ALLOC_MIN_SHIFT);
+	s = roundup_pow_of_two(size);
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
+		while (q->next && q->next != (struct gen_pool_link *)b)
+			q = q->next;
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
+EXPORT_SYMBOL(gen_pool_free);
