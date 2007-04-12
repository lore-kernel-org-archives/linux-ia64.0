From: Milind Arun Choudhary <milindchoudhary@gmail.com>
Date: Thu, 12 Apr 2007 20:44:05 +0000
Subject: [KJ][PATCH 03/03]ROUND_UP|DOWN macro cleanup in arch/ia64,x86_64
Message-Id: <20070412203205.GC9353@arun.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704122237.20779.ak@suse.de>
In-Reply-To: <200704122237.20779.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@lists.osdl.org, linux-ia64@vger.kernel.org, discuss@x86-64.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, ak@suse.de

ROUND_UP macro cleanup in arch/x86_64
ALIGN, ALIGN_DOWN  where ever appropriate.

Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>

---
 arch/x86_64/kernel/e820.c   |   16 ++++++++--------
 arch/x86_64/kernel/signal.c |    4 ++--
 arch/x86_64/mm/init.c       |    8 ++++----
 arch/x86_64/mm/numa.c       |    8 ++++----
 include/asm-x86_64/proto.h  |    3 ---
 5 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/arch/x86_64/kernel/e820.c b/arch/x86_64/kernel/e820.c
index a490fab..d556177 100644
--- a/arch/x86_64/kernel/e820.c
+++ b/arch/x86_64/kernel/e820.c
@@ -207,11 +207,11 @@ unsigned long __init e820_hole_size(unsigned long start, unsigned long end)
 		    ei->addr >= end)
 			continue;
 
-		addr = round_up(ei->addr, PAGE_SIZE);
+		addr = ALIGN(ei->addr, PAGE_SIZE);
 		if (addr < start)
 			addr = start;
 
-		last = round_down(ei->addr + ei->size, PAGE_SIZE);
+		last = ALIGN_DOWN(ei->addr + ei->size, PAGE_SIZE);
 		if (last >= end)
 			last = end;
 
@@ -284,17 +284,17 @@ void __init e820_mark_nosave_regions(void)
 	int i;
 	unsigned long paddr;
 
-	paddr = round_down(e820.map[0].addr + e820.map[0].size, PAGE_SIZE);
+	paddr = ALIGN_DOWN(e820.map[0].addr + e820.map[0].size, PAGE_SIZE);
 	for (i = 1; i < e820.nr_map; i++) {
 		struct e820entry *ei = &e820.map[i];
 
 		if (paddr < ei->addr)
 			e820_mark_nosave_range(paddr,
-					round_up(ei->addr, PAGE_SIZE));
+					ALIGN(ei->addr, PAGE_SIZE));
 
-		paddr = round_down(ei->addr + ei->size, PAGE_SIZE);
+		paddr = ALIGN_DOWN(ei->addr + ei->size, PAGE_SIZE);
 		if (ei->type != E820_RAM)
-			e820_mark_nosave_range(round_up(ei->addr, PAGE_SIZE),
+			e820_mark_nosave_range(ALIGN(ei->addr, PAGE_SIZE),
 					paddr);
 
 		if (paddr >= (end_pfn << PAGE_SHIFT))
@@ -311,8 +311,8 @@ e820_register_active_regions(int nid, unsigned long start_pfn,
 	unsigned long ei_startpfn, ei_endpfn;
 	for (i = 0; i < e820.nr_map; i++) {
 		struct e820entry *ei = &e820.map[i];
-		ei_startpfn = round_up(ei->addr, PAGE_SIZE) >> PAGE_SHIFT;
-		ei_endpfn = round_down(ei->addr + ei->size, PAGE_SIZE)
+		ei_startpfn = ALIGN(ei->addr, PAGE_SIZE) >> PAGE_SHIFT;
+		ei_endpfn = ALIGN_DOWN(ei->addr + ei->size, PAGE_SIZE)
 								>> PAGE_SHIFT;
 
 		/* Skip map entries smaller than a page */
diff --git a/arch/x86_64/kernel/signal.c b/arch/x86_64/kernel/signal.c
index 49ec324..b89de2b 100644
--- a/arch/x86_64/kernel/signal.c
+++ b/arch/x86_64/kernel/signal.c
@@ -211,7 +211,7 @@ get_stack(struct k_sigaction *ka, struct pt_regs *regs, unsigned long size)
 			rsp = current->sas_ss_sp + current->sas_ss_size;
 	}
 
-	return (void __user *)round_down(rsp - size, 16); 
+	return (void __user *)ALIGN_DOWN(rsp - size, 16); 
 }
 
 static int setup_rt_frame(int sig, struct k_sigaction *ka, siginfo_t *info,
@@ -224,7 +224,7 @@ static int setup_rt_frame(int sig, struct k_sigaction *ka, siginfo_t *info,
 
 	if (used_math()) {
 		fp = get_stack(ka, regs, sizeof(struct _fpstate)); 
-		frame = (void __user *)round_down(
+		frame = (void __user *)ALIGN_DOWN(
 			(unsigned long)fp - sizeof(struct rt_sigframe), 16) - 8;
 
 		if (!access_ok(VERIFY_WRITE, fp, sizeof(struct _fpstate)))
diff --git a/arch/x86_64/mm/init.c b/arch/x86_64/mm/init.c
index ec31534..d573f63 100644
--- a/arch/x86_64/mm/init.c
+++ b/arch/x86_64/mm/init.c
@@ -225,7 +225,7 @@ static __meminit void unmap_low_page(int i)
 /* Must run before zap_low_mappings */
 __init void *early_ioremap(unsigned long addr, unsigned long size)
 {
-	unsigned long map = round_down(addr, LARGE_PAGE_SIZE); 
+	unsigned long map = ALIGN_DOWN(addr, LARGE_PAGE_SIZE); 
 
 	/* actually usually some more */
 	if (size >= LARGE_PAGE_SIZE) { 
@@ -241,7 +241,7 @@ __init void *early_ioremap(unsigned long addr, unsigned long size)
 /* To avoid virtual aliases later */
 __init void early_iounmap(void *addr, unsigned long size)
 {
-	if ((void *)round_down((unsigned long)addr, LARGE_PAGE_SIZE) != temp_mappings[0].address)
+	if ((void *)ALIGN_DOWN((unsigned long)addr, LARGE_PAGE_SIZE) != temp_mappings[0].address)
 		printk("early_iounmap: bad address %p\n", addr);
 	set_pmd(temp_mappings[0].pmd, __pmd(0));
 	set_pmd(temp_mappings[1].pmd, __pmd(0));
@@ -323,8 +323,8 @@ static void __init find_early_table_space(unsigned long end)
 
 	puds = (end + PUD_SIZE - 1) >> PUD_SHIFT;
 	pmds = (end + PMD_SIZE - 1) >> PMD_SHIFT;
-	tables = round_up(puds * sizeof(pud_t), PAGE_SIZE) +
-		 round_up(pmds * sizeof(pmd_t), PAGE_SIZE);
+	tables = ALIGN(puds * sizeof(pud_t), PAGE_SIZE) +
+		 ALIGN(pmds * sizeof(pmd_t), PAGE_SIZE);
 
  	/* RED-PEN putting page tables only on node 0 could
  	   cause a hotspot and fill up ZONE_DMA. The page tables
diff --git a/arch/x86_64/mm/numa.c b/arch/x86_64/mm/numa.c
index 41b8fb0..3d98ecf 100644
--- a/arch/x86_64/mm/numa.c
+++ b/arch/x86_64/mm/numa.c
@@ -180,9 +180,9 @@ void __init setup_node_bootmem(int nodeid, unsigned long start, unsigned long en
 	unsigned long start_pfn, end_pfn, bootmap_pages, bootmap_size, bootmap_start; 
 	unsigned long nodedata_phys;
 	void *bootmap;
-	const int pgdat_size = round_up(sizeof(pg_data_t), PAGE_SIZE);
+	const int pgdat_size = ALIGN(sizeof(pg_data_t), PAGE_SIZE);
 
-	start = round_up(start, ZONE_ALIGN); 
+	start = ALIGN(start, ZONE_ALIGN); 
 
 	printk(KERN_INFO "Bootmem setup node %d %016lx-%016lx\n", nodeid, start, end);
 
@@ -201,7 +201,7 @@ void __init setup_node_bootmem(int nodeid, unsigned long start, unsigned long en
 
 	/* Find a place for the bootmem map */
 	bootmap_pages = bootmem_bootmap_pages(end_pfn - start_pfn); 
-	bootmap_start = round_up(nodedata_phys + pgdat_size, PAGE_SIZE);
+	bootmap_start = ALIGN(nodedata_phys + pgdat_size, PAGE_SIZE);
 	bootmap = early_node_mem(nodeid, bootmap_start, end,
 					bootmap_pages<<PAGE_SHIFT);
 	if (bootmap = NULL)  {
@@ -246,7 +246,7 @@ void __init setup_node_zones(int nodeid)
 	NODE_DATA(nodeid)->node_mem_map = 
 		__alloc_bootmem_core(NODE_DATA(nodeid)->bdata, 
 				memmapsize, SMP_CACHE_BYTES, 
-				round_down(limit - memmapsize, PAGE_SIZE), 
+				ALIGN_DOWN(limit - memmapsize, PAGE_SIZE), 
 				limit);
 #endif
 } 
diff --git a/include/asm-x86_64/proto.h b/include/asm-x86_64/proto.h
index b6e65a6..7e63559 100644
--- a/include/asm-x86_64/proto.h
+++ b/include/asm-x86_64/proto.h
@@ -123,7 +123,4 @@ extern void smp_local_timer_interrupt(void);
 
 long do_arch_prctl(struct task_struct *task, int code, unsigned long addr);
 
-#define round_up(x,y) (((x) + (y) - 1) & ~((y)-1))
-#define round_down(x,y) ((x) & ~((y)-1))
-
 #endif
-- 
Milind Arun Choudhary
