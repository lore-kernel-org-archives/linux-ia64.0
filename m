From: Tejun Heo <tj@kernel.org>
Date: Tue, 22 Sep 2009 07:40:14 +0000
Subject: [PATCH 4/4] percpu: kill legacy percpu allocator
Message-Id: <1253605214-23210-5-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253605214-23210-1-git-send-email-tj@kernel.org>
In-Reply-To: <1253605214-23210-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>

With ia64 converted, there's no arch left which still uses legacy
percpu allocator.  Kill it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/percpu.h |   24 -------
 kernel/module.c        |  150 ----------------------------------------
 mm/Makefile            |    4 -
 mm/allocpercpu.c       |  177 ------------------------------------------------
 mm/percpu.c            |    2 -
 5 files changed, 0 insertions(+), 357 deletions(-)
 delete mode 100644 mm/allocpercpu.c

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 878836c..5baf5b8 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -34,8 +34,6 @@
 
 #ifdef CONFIG_SMP
 
-#ifndef CONFIG_HAVE_LEGACY_PER_CPU_AREA
-
 /* minimum unit size, also is the maximum supported allocation size */
 #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(64 << 10)
 
@@ -130,28 +128,6 @@ extern int __init pcpu_page_first_chunk(size_t reserved_size,
 #define per_cpu_ptr(ptr, cpu)	SHIFT_PERCPU_PTR((ptr), per_cpu_offset((cpu)))
 
 extern void *__alloc_reserved_percpu(size_t size, size_t align);
-
-#else /* CONFIG_HAVE_LEGACY_PER_CPU_AREA */
-
-struct percpu_data {
-	void *ptrs[1];
-};
-
-/* pointer disguising messes up the kmemleak objects tracking */
-#ifndef CONFIG_DEBUG_KMEMLEAK
-#define __percpu_disguise(pdata) (struct percpu_data *)~(unsigned long)(pdata)
-#else
-#define __percpu_disguise(pdata) (struct percpu_data *)(pdata)
-#endif
-
-#define per_cpu_ptr(ptr, cpu)						\
-({									\
-        struct percpu_data *__p = __percpu_disguise(ptr);		\
-        (__typeof__(ptr))__p->ptrs[(cpu)];				\
-})
-
-#endif /* CONFIG_HAVE_LEGACY_PER_CPU_AREA */
-
 extern void *__alloc_percpu(size_t size, size_t align);
 extern void free_percpu(void *__pdata);
 
diff --git a/kernel/module.c b/kernel/module.c
index b6ee424..bac3fe8 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -369,8 +369,6 @@ EXPORT_SYMBOL_GPL(find_module);
 
 #ifdef CONFIG_SMP
 
-#ifndef CONFIG_HAVE_LEGACY_PER_CPU_AREA
-
 static void *percpu_modalloc(unsigned long size, unsigned long align,
 			     const char *name)
 {
@@ -394,154 +392,6 @@ static void percpu_modfree(void *freeme)
 	free_percpu(freeme);
 }
 
-#else /* ... CONFIG_HAVE_LEGACY_PER_CPU_AREA */
-
-/* Number of blocks used and allocated. */
-static unsigned int pcpu_num_used, pcpu_num_allocated;
-/* Size of each block.  -ve means used. */
-static int *pcpu_size;
-
-static int split_block(unsigned int i, unsigned short size)
-{
-	/* Reallocation required? */
-	if (pcpu_num_used + 1 > pcpu_num_allocated) {
-		int *new;
-
-		new = krealloc(pcpu_size, sizeof(new[0])*pcpu_num_allocated*2,
-			       GFP_KERNEL);
-		if (!new)
-			return 0;
-
-		pcpu_num_allocated *= 2;
-		pcpu_size = new;
-	}
-
-	/* Insert a new subblock */
-	memmove(&pcpu_size[i+1], &pcpu_size[i],
-		sizeof(pcpu_size[0]) * (pcpu_num_used - i));
-	pcpu_num_used++;
-
-	pcpu_size[i+1] -= size;
-	pcpu_size[i] = size;
-	return 1;
-}
-
-static inline unsigned int block_size(int val)
-{
-	if (val < 0)
-		return -val;
-	return val;
-}
-
-static void *percpu_modalloc(unsigned long size, unsigned long align,
-			     const char *name)
-{
-	unsigned long extra;
-	unsigned int i;
-	void *ptr;
-	int cpu;
-
-	if (align > PAGE_SIZE) {
-		printk(KERN_WARNING "%s: per-cpu alignment %li > %li\n",
-		       name, align, PAGE_SIZE);
-		align = PAGE_SIZE;
-	}
-
-	ptr = __per_cpu_start;
-	for (i = 0; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
-		/* Extra for alignment requirement. */
-		extra = ALIGN((unsigned long)ptr, align) - (unsigned long)ptr;
-		BUG_ON(i = 0 && extra != 0);
-
-		if (pcpu_size[i] < 0 || pcpu_size[i] < extra + size)
-			continue;
-
-		/* Transfer extra to previous block. */
-		if (pcpu_size[i-1] < 0)
-			pcpu_size[i-1] -= extra;
-		else
-			pcpu_size[i-1] += extra;
-		pcpu_size[i] -= extra;
-		ptr += extra;
-
-		/* Split block if warranted */
-		if (pcpu_size[i] - size > sizeof(unsigned long))
-			if (!split_block(i, size))
-				return NULL;
-
-		/* add the per-cpu scanning areas */
-		for_each_possible_cpu(cpu)
-			kmemleak_alloc(ptr + per_cpu_offset(cpu), size, 0,
-				       GFP_KERNEL);
-
-		/* Mark allocated */
-		pcpu_size[i] = -pcpu_size[i];
-		return ptr;
-	}
-
-	printk(KERN_WARNING "Could not allocate %lu bytes percpu data\n",
-	       size);
-	return NULL;
-}
-
-static void percpu_modfree(void *freeme)
-{
-	unsigned int i;
-	void *ptr = __per_cpu_start + block_size(pcpu_size[0]);
-	int cpu;
-
-	/* First entry is core kernel percpu data. */
-	for (i = 1; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
-		if (ptr = freeme) {
-			pcpu_size[i] = -pcpu_size[i];
-			goto free;
-		}
-	}
-	BUG();
-
- free:
-	/* remove the per-cpu scanning areas */
-	for_each_possible_cpu(cpu)
-		kmemleak_free(freeme + per_cpu_offset(cpu));
-
-	/* Merge with previous? */
-	if (pcpu_size[i-1] >= 0) {
-		pcpu_size[i-1] += pcpu_size[i];
-		pcpu_num_used--;
-		memmove(&pcpu_size[i], &pcpu_size[i+1],
-			(pcpu_num_used - i) * sizeof(pcpu_size[0]));
-		i--;
-	}
-	/* Merge with next? */
-	if (i+1 < pcpu_num_used && pcpu_size[i+1] >= 0) {
-		pcpu_size[i] += pcpu_size[i+1];
-		pcpu_num_used--;
-		memmove(&pcpu_size[i+1], &pcpu_size[i+2],
-			(pcpu_num_used - (i+1)) * sizeof(pcpu_size[0]));
-	}
-}
-
-static int percpu_modinit(void)
-{
-	pcpu_num_used = 2;
-	pcpu_num_allocated = 2;
-	pcpu_size = kmalloc(sizeof(pcpu_size[0]) * pcpu_num_allocated,
-			    GFP_KERNEL);
-	/* Static in-kernel percpu data (used). */
-	pcpu_size[0] = -(__per_cpu_end-__per_cpu_start);
-	/* Free room. */
-	pcpu_size[1] = PERCPU_ENOUGH_ROOM + pcpu_size[0];
-	if (pcpu_size[1] < 0) {
-		printk(KERN_ERR "No per-cpu room for modules.\n");
-		pcpu_num_used = 1;
-	}
-
-	return 0;
-}
-__initcall(percpu_modinit);
-
-#endif /* CONFIG_HAVE_LEGACY_PER_CPU_AREA */
-
 static unsigned int find_pcpusec(Elf_Ehdr *hdr,
 				 Elf_Shdr *sechdrs,
 				 const char *secstrings)
diff --git a/mm/Makefile b/mm/Makefile
index ea4b18b..1195920 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,11 +33,7 @@ obj-$(CONFIG_FAILSLAB) += failslab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
-ifndef CONFIG_HAVE_LEGACY_PER_CPU_AREA
 obj-$(CONFIG_SMP) += percpu.o
-else
-obj-$(CONFIG_SMP) += allocpercpu.o
-endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
diff --git a/mm/allocpercpu.c b/mm/allocpercpu.c
deleted file mode 100644
index df34cea..0000000
--- a/mm/allocpercpu.c
+++ /dev/null
@@ -1,177 +0,0 @@
-/*
- * linux/mm/allocpercpu.c
- *
- * Separated from slab.c August 11, 2006 Christoph Lameter
- */
-#include <linux/mm.h>
-#include <linux/module.h>
-#include <linux/bootmem.h>
-#include <asm/sections.h>
-
-#ifndef cache_line_size
-#define cache_line_size()	L1_CACHE_BYTES
-#endif
-
-/**
- * percpu_depopulate - depopulate per-cpu data for given cpu
- * @__pdata: per-cpu data to depopulate
- * @cpu: depopulate per-cpu data for this cpu
- *
- * Depopulating per-cpu data for a cpu going offline would be a typical
- * use case. You need to register a cpu hotplug handler for that purpose.
- */
-static void percpu_depopulate(void *__pdata, int cpu)
-{
-	struct percpu_data *pdata = __percpu_disguise(__pdata);
-
-	kfree(pdata->ptrs[cpu]);
-	pdata->ptrs[cpu] = NULL;
-}
-
-/**
- * percpu_depopulate_mask - depopulate per-cpu data for some cpu's
- * @__pdata: per-cpu data to depopulate
- * @mask: depopulate per-cpu data for cpu's selected through mask bits
- */
-static void __percpu_depopulate_mask(void *__pdata, const cpumask_t *mask)
-{
-	int cpu;
-	for_each_cpu_mask_nr(cpu, *mask)
-		percpu_depopulate(__pdata, cpu);
-}
-
-#define percpu_depopulate_mask(__pdata, mask) \
-	__percpu_depopulate_mask((__pdata), &(mask))
-
-/**
- * percpu_populate - populate per-cpu data for given cpu
- * @__pdata: per-cpu data to populate further
- * @size: size of per-cpu object
- * @gfp: may sleep or not etc.
- * @cpu: populate per-data for this cpu
- *
- * Populating per-cpu data for a cpu coming online would be a typical
- * use case. You need to register a cpu hotplug handler for that purpose.
- * Per-cpu object is populated with zeroed buffer.
- */
-static void *percpu_populate(void *__pdata, size_t size, gfp_t gfp, int cpu)
-{
-	struct percpu_data *pdata = __percpu_disguise(__pdata);
-	int node = cpu_to_node(cpu);
-
-	/*
-	 * We should make sure each CPU gets private memory.
-	 */
-	size = roundup(size, cache_line_size());
-
-	BUG_ON(pdata->ptrs[cpu]);
-	if (node_online(node))
-		pdata->ptrs[cpu] = kmalloc_node(size, gfp|__GFP_ZERO, node);
-	else
-		pdata->ptrs[cpu] = kzalloc(size, gfp);
-	return pdata->ptrs[cpu];
-}
-
-/**
- * percpu_populate_mask - populate per-cpu data for more cpu's
- * @__pdata: per-cpu data to populate further
- * @size: size of per-cpu object
- * @gfp: may sleep or not etc.
- * @mask: populate per-cpu data for cpu's selected through mask bits
- *
- * Per-cpu objects are populated with zeroed buffers.
- */
-static int __percpu_populate_mask(void *__pdata, size_t size, gfp_t gfp,
-				  cpumask_t *mask)
-{
-	cpumask_t populated;
-	int cpu;
-
-	cpus_clear(populated);
-	for_each_cpu_mask_nr(cpu, *mask)
-		if (unlikely(!percpu_populate(__pdata, size, gfp, cpu))) {
-			__percpu_depopulate_mask(__pdata, &populated);
-			return -ENOMEM;
-		} else
-			cpu_set(cpu, populated);
-	return 0;
-}
-
-#define percpu_populate_mask(__pdata, size, gfp, mask) \
-	__percpu_populate_mask((__pdata), (size), (gfp), &(mask))
-
-/**
- * alloc_percpu - initial setup of per-cpu data
- * @size: size of per-cpu object
- * @align: alignment
- *
- * Allocate dynamic percpu area.  Percpu objects are populated with
- * zeroed buffers.
- */
-void *__alloc_percpu(size_t size, size_t align)
-{
-	/*
-	 * We allocate whole cache lines to avoid false sharing
-	 */
-	size_t sz = roundup(nr_cpu_ids * sizeof(void *), cache_line_size());
-	void *pdata = kzalloc(sz, GFP_KERNEL);
-	void *__pdata = __percpu_disguise(pdata);
-
-	/*
-	 * Can't easily make larger alignment work with kmalloc.  WARN
-	 * on it.  Larger alignment should only be used for module
-	 * percpu sections on SMP for which this path isn't used.
-	 */
-	WARN_ON_ONCE(align > SMP_CACHE_BYTES);
-
-	if (unlikely(!pdata))
-		return NULL;
-	if (likely(!__percpu_populate_mask(__pdata, size, GFP_KERNEL,
-					   &cpu_possible_map)))
-		return __pdata;
-	kfree(pdata);
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(__alloc_percpu);
-
-/**
- * free_percpu - final cleanup of per-cpu data
- * @__pdata: object to clean up
- *
- * We simply clean up any per-cpu object left. No need for the client to
- * track and specify through a bis mask which per-cpu objects are to free.
- */
-void free_percpu(void *__pdata)
-{
-	if (unlikely(!__pdata))
-		return;
-	__percpu_depopulate_mask(__pdata, cpu_possible_mask);
-	kfree(__percpu_disguise(__pdata));
-}
-EXPORT_SYMBOL_GPL(free_percpu);
-
-/*
- * Generic percpu area setup.
- */
-#ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
-unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
-
-EXPORT_SYMBOL(__per_cpu_offset);
-
-void __init setup_per_cpu_areas(void)
-{
-	unsigned long size, i;
-	char *ptr;
-	unsigned long nr_possible_cpus = num_possible_cpus();
-
-	/* Copy section for each CPU (we discard the original) */
-	size = ALIGN(PERCPU_ENOUGH_ROOM, PAGE_SIZE);
-	ptr = alloc_bootmem_pages(size * nr_possible_cpus);
-
-	for_each_possible_cpu(i) {
-		__per_cpu_offset[i] = ptr - __per_cpu_start;
-		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
-		ptr += size;
-	}
-}
-#endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
diff --git a/mm/percpu.c b/mm/percpu.c
index 43d8cac..adbc5a4 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -46,8 +46,6 @@
  *
  * To use this allocator, arch code should do the followings.
  *
- * - drop CONFIG_HAVE_LEGACY_PER_CPU_AREA
- *
  * - define __addr_to_pcpu_ptr() and __pcpu_ptr_to_addr() to translate
  *   regular address to percpu pointer and back if they need to be
  *   different from the default
-- 
1.6.4.2

