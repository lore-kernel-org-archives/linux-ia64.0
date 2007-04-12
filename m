From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Date: Thu, 12 Apr 2007 20:43:40 +0000
Subject: [KJ][PATCH 02/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <20070412203140.GB9353@arun.site>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, ak@suse.de

ROUND_UP|DOWN macro cleanup in arch/ia64,
 use ALIGN ALIGN_DOWN and round_down where ever appropriate.

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>

---
 arch/ia64/hp/common/sba_iommu.c  |    8 +++-----
 arch/ia64/ia32/sys_ia32.c        |    4 +---
 arch/ia64/kernel/efi.c           |   14 +++++++-------
 arch/ia64/kernel/machine_kexec.c |    3 ++-
 arch/ia64/kernel/mca.c           |    3 ++-
 arch/ia64/mm/discontig.c         |   10 +++++-----
 arch/ia64/mm/init.c              |    4 ++--
 arch/ia64/mm/ioremap.c           |    6 ++++--
 include/asm-ia64/meminit.h       |    7 -------
 9 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index c1dca22..2c49322 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -265,8 +265,6 @@ static u64 prefetch_spill_page;
 */
 #define DMA_CHUNK_SIZE  (BITS_PER_LONG*iovp_size)
 
-#define ROUNDUP(x,y) ((x + ((y)-1)) & ~((y)-1))
-
 /************************************
 ** SBA register read and write support
 **
@@ -520,7 +518,7 @@ sba_search_bitmap(struct ioc *ioc, unsigned long bits_wanted, int use_hint)
 		** SBA HW features in the unmap path.
 		*/
 		unsigned long o = 1 << get_iovp_order(bits_wanted << iovp_shift);
-		uint bitshiftcnt = ROUNDUP(ioc->res_bitshift, o);
+		uint bitshiftcnt = ALIGN(ioc->res_bitshift, o);
 		unsigned long mask, base_mask;
 
 		base_mask = RESMAP_MASK(bits_wanted);
@@ -1031,7 +1029,7 @@ void sba_unmap_single(struct device *dev, dma_addr_t iova, size_t size, int dir)
 
 	iova ^= offset;        /* clear offset bits */
 	size += offset;
-	size = ROUNDUP(size, iovp_size);
+	size = ALIGN(size, iovp_size);
 
 #ifdef ENABLE_MARK_CLEAN
 	if (dir = DMA_FROM_DEVICE)
@@ -1217,7 +1215,7 @@ sba_fill_pdir(
 			dma_sg->dma_length += cnt;
 			cnt += dma_offset;
 			dma_offset=0;	/* only want offset on first chunk */
-			cnt = ROUNDUP(cnt, iovp_size);
+			cnt = ALIGN(cnt, iovp_size);
 			do {
 				sba_io_pdir_entry(pdirp, vaddr);
 				vaddr += iovp_size;
diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
index 0afb4fe..842b329 100644
--- a/arch/ia64/ia32/sys_ia32.c
+++ b/arch/ia64/ia32/sys_ia32.c
@@ -70,8 +70,6 @@
 # define DBG(fmt...)
 #endif
 
-#define ROUND_UP(x,a)	((__typeof__(x))(((unsigned long)(x) + ((a) - 1)) & ~((a) - 1)))
-
 #define OFFSET4K(a)		((a) & 0xfff)
 #define PAGE_START(addr)	((addr) & PAGE_MASK)
 #define MINSIGSTKSZ_IA32	2048
@@ -1232,7 +1230,7 @@ filldir32 (void *__buf, const char *name, int namlen, loff_t offset, u64 ino,
 {
 	struct compat_dirent __user * dirent;
 	struct getdents32_callback * buf = (struct getdents32_callback *) __buf;
-	int reclen = ROUND_UP(offsetof(struct compat_dirent, d_name) + namlen + 1, 4);
+	int reclen = ALIGN(offsetof(struct compat_dirent, d_name) + namlen + 1, 4);
 	u32 d_ino;
 
 	buf->error = -EINVAL;	/* only used if we fail.. */
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index f45f91d..65ae5bb 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -399,7 +399,7 @@ efi_map_pal_code (void)
 	 * Cannot write to CRx with PSR.ic=1
 	 */
 	psr = ia64_clear_ic();
-	ia64_itr(0x1, IA64_TR_PALCODE, GRANULEROUNDDOWN((unsigned long) pal_vaddr),
+	ia64_itr(0x1, IA64_TR_PALCODE, ALIGN_DOWN((unsigned long) pal_vaddr, IA64_GRANULE_SIZE),
 		 pte_val(pfn_pte(__pa(pal_vaddr) >> PAGE_SHIFT, PAGE_KERNEL)),
 		 IA64_GRANULE_SHIFT);
 	ia64_set_psr(psr);		/* restore psr */
@@ -421,9 +421,9 @@ efi_init (void)
 		if (memcmp(cp, "mem=", 4) = 0) {
 			mem_limit = memparse(cp + 4, &cp);
 		} else if (memcmp(cp, "max_addr=", 9) = 0) {
-			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
+			max_addr = ALIGN_DOWN(memparse(cp + 9, &cp), IA64_GRANULE_SIZE);
 		} else if (memcmp(cp, "min_addr=", 9) = 0) {
-			min_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
+			min_addr = ALIGN_DOWN(memparse(cp + 9, &cp), IA64_GRANULE_SIZE);
 		} else {
 			while (*cp != ' ' && *cp)
 				++cp;
@@ -880,7 +880,7 @@ find_memmap_space (void)
 			continue;
 		}
 		if (pmd = NULL || !efi_wb(pmd) || efi_md_end(pmd) != md->phys_addr) {
-			contig_low = GRANULEROUNDUP(md->phys_addr);
+			contig_low = ALIGN(md->phys_addr, IA64_GRANULE_SIZE);
 			contig_high = efi_md_end(md);
 			for (q = p + efi_desc_size; q < efi_map_end; q += efi_desc_size) {
 				check_md = q;
@@ -890,7 +890,7 @@ find_memmap_space (void)
 					break;
 				contig_high = efi_md_end(check_md);
 			}
-			contig_high = GRANULEROUNDDOWN(contig_high);
+			contig_high = ALIGN_DOWN(contig_high, IA64_GRANULE_SIZE);
 		}
 		if (!is_memory_available(md) || md->type = EFI_LOADER_DATA)
 			continue;
@@ -956,7 +956,7 @@ efi_memmap_init(unsigned long *s, unsigned long *e)
 			continue;
 		}
 		if (pmd = NULL || !efi_wb(pmd) || efi_md_end(pmd) != md->phys_addr) {
-			contig_low = GRANULEROUNDUP(md->phys_addr);
+			contig_low = ALIGN(md->phys_addr, IA64_GRANULE_SIZE);
 			contig_high = efi_md_end(md);
 			for (q = p + efi_desc_size; q < efi_map_end; q += efi_desc_size) {
 				check_md = q;
@@ -966,7 +966,7 @@ efi_memmap_init(unsigned long *s, unsigned long *e)
 					break;
 				contig_high = efi_md_end(check_md);
 			}
-			contig_high = GRANULEROUNDDOWN(contig_high);
+			contig_high = ALIGN_DOWN(contig_high, IA64_GRANULE_SIZE);
 		}
 		if (!is_memory_available(md))
 			continue;
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 4f0f3b8..9fb86f6 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -10,6 +10,7 @@
  * Version 2.  See the file COPYING for more details.
  */
 
+#include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/kexec.h>
 #include <linux/cpu.h>
@@ -115,7 +116,7 @@ static void ia64_machine_kexec(struct unw_frame_info *info, void *arg)
 	platform_kernel_launch_event();
 	rnk = (relocate_new_kernel_t)&code_addr;
 	(*rnk)(image->head, image->start, ia64_boot_param,
-		     GRANULEROUNDDOWN((unsigned long) pal_addr));
+		     ALIGN_DOWN((unsigned long) pal_addr), IA64_GRANULE_SIZE);
 	BUG();
 }
 
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 491687f..8e2cf23 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -79,6 +79,7 @@
 #include <asm/meminit.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
+#include <asm/pgtable.h>
 #include <asm/system.h>
 #include <asm/sal.h>
 #include <asm/mca.h>
@@ -1753,7 +1754,7 @@ ia64_mca_cpu_init(void *cpu_data)
 	if (!pal_vaddr)
 		return;
 	__get_cpu_var(ia64_mca_pal_base) -		GRANULEROUNDDOWN((unsigned long) pal_vaddr);
+		ALIGN_DOWN((unsigned long) pal_vaddr, IA64_GRANULE_SIZE);
 	__get_cpu_var(ia64_mca_pal_pte) = pte_val(mk_pte_phys(__pa(pal_vaddr),
 							      PAGE_KERNEL));
 }
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 872da7a..f8cd0ec 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -77,8 +77,8 @@ static int __init build_node_maps(unsigned long start, unsigned long len,
 	unsigned long cstart, epfn, end = start + len;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
 
-	epfn = GRANULEROUNDUP(end) >> PAGE_SHIFT;
-	cstart = GRANULEROUNDDOWN(start);
+	epfn = ALIGN(end, IA64_GRANULE_SIZE) >> PAGE_SHIFT;
+	cstart = ALIGN_DOWN(start, IA64_GRANULE_SIZE);
 
 	if (!bdp->node_low_pfn) {
 		bdp->node_boot_start = cstart;
@@ -632,9 +632,9 @@ static __init int count_node_pages(unsigned long start, unsigned long len, int n
 		mem_data[node].num_dma_physpages + 			(min(end, __pa(MAX_DMA_ADDRESS)) - start) >>PAGE_SHIFT;
 #endif
-	start = GRANULEROUNDDOWN(start);
-	start = ORDERROUNDDOWN(start);
-	end = GRANULEROUNDUP(end);
+	start = ALIGN_DOWN(start, IA64_GRANULE_SIZE);
+	start = ALIGN_DOWN(start, (PAGE_SIZE<<MAX_ORDER));
+	end = ALIGN(end, IA64_GRANULE_SIZE);
 	mem_data[node].max_pfn = max(mem_data[node].max_pfn,
 				     end >> PAGE_SHIFT);
 	mem_data[node].min_pfn = min(mem_data[node].min_pfn,
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 4f36987..38d0dba 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -656,8 +656,8 @@ find_max_min_low_pfn (unsigned long start, unsigned long end, void *arg)
 	pfn_start = (PAGE_ALIGN(__pa(start))) >> PAGE_SHIFT;
 	pfn_end = (PAGE_ALIGN(__pa(end - 1))) >> PAGE_SHIFT;
 #else
-	pfn_start = GRANULEROUNDDOWN(__pa(start)) >> PAGE_SHIFT;
-	pfn_end = GRANULEROUNDUP(__pa(end - 1)) >> PAGE_SHIFT;
+	pfn_start = ALIGN_DOWN(__pa(start), IA64_GRANULE_SIZE) >> PAGE_SHIFT;
+	pfn_end = ALIGN(__pa(end - 1), IA64_GRANULE_SIZE) >> PAGE_SHIFT;
 #endif
 	min_low_pfn = min(min_low_pfn, pfn_start);
 	max_low_pfn = max(max_low_pfn, pfn_end);
diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index 4280c07..7647027 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -7,11 +7,13 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/kernel.h>
 #include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/efi.h>
 #include <asm/io.h>
 #include <asm/meminit.h>
+#include <asm/pgtable.h>
 
 static inline void __iomem *
 __ioremap (unsigned long offset, unsigned long size)
@@ -40,8 +42,8 @@ ioremap (unsigned long offset, unsigned long size)
 	 * Some chipsets don't support UC access to memory.  If
 	 * WB is supported for the whole granule, we prefer that.
 	 */
-	gran_base = GRANULEROUNDDOWN(offset);
-	gran_size = GRANULEROUNDUP(offset + size) - gran_base;
+	gran_base = ALIGN_DOWN(offset, IA64_GRANULE_SIZE);
+	gran_size = ALIGN(offset + size, IA64_GRANULE_SIZE) - gran_base;
 	if (efi_mem_attribute(gran_base, gran_size) & EFI_MEMORY_WB)
 		return (void __iomem *) phys_to_virt(offset);
 
diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index 3a62878..1b8d9d5 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -41,13 +41,6 @@ extern int find_max_min_low_pfn (unsigned long , unsigned long, void *);
 extern unsigned long vmcore_find_descriptor_size(unsigned long address);
 extern int reserve_elfcorehdr(unsigned long *start, unsigned long *end);
 
-/*
- * For rounding an address to the next IA64_GRANULE_SIZE or order
- */
-#define GRANULEROUNDDOWN(n)	((n) & ~(IA64_GRANULE_SIZE-1))
-#define GRANULEROUNDUP(n)	(((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
-#define ORDERROUNDDOWN(n)	((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
-
 #ifdef CONFIG_NUMA
   extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
 #else
-- 
Milind Arun Choudhary
