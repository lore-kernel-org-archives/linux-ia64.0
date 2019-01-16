From: Mike Rapoport <rppt@linux.ibm.com>
Date: Wed, 16 Jan 2019 13:44:12 +0000
Subject: [PATCH 12/21] arch: use memblock_alloc() instead of memblock_alloc_from(size, align, 0)
Message-Id: <1547646261-32535-13-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

The last parameter of memblock_alloc_from() is the lower limit for the
memory allocation. When it is 0, the call is equivalent to
memblock_alloc().

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/alpha/kernel/core_cia.c  |  2 +-
 arch/alpha/kernel/pci_iommu.c |  4 ++--
 arch/alpha/kernel/setup.c     |  2 +-
 arch/ia64/kernel/mca.c        |  3 +--
 arch/mips/kernel/traps.c      |  2 +-
 arch/sparc/kernel/prom_32.c   |  2 +-
 arch/sparc/mm/init_32.c       |  2 +-
 arch/sparc/mm/srmmu.c         | 10 +++++-----
 8 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/arch/alpha/kernel/core_cia.c b/arch/alpha/kernel/core_cia.c
index 867e873..466cd44 100644
--- a/arch/alpha/kernel/core_cia.c
+++ b/arch/alpha/kernel/core_cia.c
@@ -331,7 +331,7 @@ cia_prepare_tbia_workaround(int window)
 	long i;
 
 	/* Use minimal 1K map. */
-	ppte = memblock_alloc_from(CIA_BROKEN_TBIA_SIZE, 32768, 0);
+	ppte = memblock_alloc(CIA_BROKEN_TBIA_SIZE, 32768);
 	pte = (virt_to_phys(ppte) >> (PAGE_SHIFT - 1)) | 1;
 
 	for (i = 0; i < CIA_BROKEN_TBIA_SIZE / sizeof(unsigned long); ++i)
diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index aa0f50d..e4cf77b 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -87,13 +87,13 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 		printk("%s: couldn't allocate arena ptes from node %d\n"
 		       "    falling back to system-wide allocation\n",
 		       __func__, nid);
-		arena->ptes = memblock_alloc_from(mem_size, align, 0);
+		arena->ptes = memblock_alloc(mem_size, align);
 	}
 
 #else /* CONFIG_DISCONTIGMEM */
 
 	arena = memblock_alloc(sizeof(*arena), SMP_CACHE_BYTES);
-	arena->ptes = memblock_alloc_from(mem_size, align, 0);
+	arena->ptes = memblock_alloc(mem_size, align);
 
 #endif /* CONFIG_DISCONTIGMEM */
 
diff --git a/arch/alpha/kernel/setup.c b/arch/alpha/kernel/setup.c
index 4b5b1b2..5d4c76a 100644
--- a/arch/alpha/kernel/setup.c
+++ b/arch/alpha/kernel/setup.c
@@ -293,7 +293,7 @@ move_initrd(unsigned long mem_limit)
 	unsigned long size;
 
 	size = initrd_end - initrd_start;
-	start = memblock_alloc_from(PAGE_ALIGN(size), PAGE_SIZE, 0);
+	start = memblock_alloc(PAGE_ALIGN(size), PAGE_SIZE);
 	if (!start || __pa(start) + size > mem_limit) {
 		initrd_start = initrd_end = 0;
 		return NULL;
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 91bd1e1..74d148b 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1835,8 +1835,7 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 /* Caller prevents this from being called after init */
 static void * __ref mca_bootmem(void)
 {
-	return memblock_alloc_from(sizeof(struct ia64_mca_cpu),
-				   KERNEL_STACK_SIZE, 0);
+	return memblock_alloc(sizeof(struct ia64_mca_cpu), KERNEL_STACK_SIZE);
 }
 
 /* Do per-CPU MCA-related initialization.  */
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index c91097f..2bbdee5 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -2291,7 +2291,7 @@ void __init trap_init(void)
 		phys_addr_t ebase_pa;
 
 		ebase = (unsigned long)
-			memblock_alloc_from(size, 1 << fls(size), 0);
+			memblock_alloc(size, 1 << fls(size));
 
 		/*
 		 * Try to ensure ebase resides in KSeg0 if possible.
diff --git a/arch/sparc/kernel/prom_32.c b/arch/sparc/kernel/prom_32.c
index 42d7f2a..38940af 100644
--- a/arch/sparc/kernel/prom_32.c
+++ b/arch/sparc/kernel/prom_32.c
@@ -32,7 +32,7 @@ void * __init prom_early_alloc(unsigned long size)
 {
 	void *ret;
 
-	ret = memblock_alloc_from(size, SMP_CACHE_BYTES, 0UL);
+	ret = memblock_alloc(size, SMP_CACHE_BYTES);
 	if (ret != NULL)
 		memset(ret, 0, size);
 
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index d900952..a8ff298 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -264,7 +264,7 @@ void __init mem_init(void)
 	i = last_valid_pfn >> ((20 - PAGE_SHIFT) + 5);
 	i += 1;
 	sparc_valid_addr_bitmap = (unsigned long *)
-		memblock_alloc_from(i << 2, SMP_CACHE_BYTES, 0UL);
+		memblock_alloc(i << 2, SMP_CACHE_BYTES);
 
 	if (sparc_valid_addr_bitmap = NULL) {
 		prom_printf("mem_init: Cannot alloc valid_addr_bitmap.\n");
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index b609362..a400ec3 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -303,13 +303,13 @@ static void __init srmmu_nocache_init(void)
 
 	bitmap_bits = srmmu_nocache_size >> SRMMU_NOCACHE_BITMAP_SHIFT;
 
-	srmmu_nocache_pool = memblock_alloc_from(srmmu_nocache_size,
-						 SRMMU_NOCACHE_ALIGN_MAX, 0UL);
+	srmmu_nocache_pool = memblock_alloc(srmmu_nocache_size,
+					    SRMMU_NOCACHE_ALIGN_MAX);
 	memset(srmmu_nocache_pool, 0, srmmu_nocache_size);
 
 	srmmu_nocache_bitmap -		memblock_alloc_from(BITS_TO_LONGS(bitmap_bits) * sizeof(long),
-				    SMP_CACHE_BYTES, 0UL);
+		memblock_alloc(BITS_TO_LONGS(bitmap_bits) * sizeof(long),
+			       SMP_CACHE_BYTES);
 	bit_map_init(&srmmu_nocache_map, srmmu_nocache_bitmap, bitmap_bits);
 
 	srmmu_swapper_pg_dir = __srmmu_get_nocache(SRMMU_PGD_TABLE_SIZE, SRMMU_PGD_TABLE_SIZE);
@@ -467,7 +467,7 @@ static void __init sparc_context_init(int numctx)
 	unsigned long size;
 
 	size = numctx * sizeof(struct ctx_list);
-	ctx_list_pool = memblock_alloc_from(size, SMP_CACHE_BYTES, 0UL);
+	ctx_list_pool = memblock_alloc(size, SMP_CACHE_BYTES);
 
 	for (ctx = 0; ctx < numctx; ctx++) {
 		struct ctx_list *clist;
-- 
2.7.4
