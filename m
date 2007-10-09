From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 Oct 2007 16:23:04 +0000
Subject: RE: [PATCH] Register memory ranges in a consistent manner on IA64
Message-Id: <617E1C2C70743745A92448908E030B2A02A239A6@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070117131832.GA27728@localhost>
In-Reply-To: <20070117131832.GA27728@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Perhaps we should change the calling convention for call_pernode_memory()
> (It currently takes [start,len] as physical addresses rather than [start,end]
> as virtual addresses) so it can be used as a first argument to
> efi_memmap_walk() ... so the code can be:
>
>	efi_memmap_walk(call_pernode_memory, register_active_ranges);

Like this.  The CONFIG_KEXEC bit in register_active_ranges() appears
to have not handled the case that the block being registered completely
spans the (crashk_res.start,crashk_res.end) block ... so I fixed that
to add the range before and after the block.  I hope that's right.

-Tony

---

commit f222c71522b84de3e6331438a908bfbd02458aed
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Oct 9 09:17:57 2007 -0700

    [IA64] efi memmap blocks may cross node boundaries
    
    In 139b830477ccdca21b68c40f9a83ec327e65eb56 Bob Picco rationalized
    the code that registers memory so that the same basic path is
    followed on contiguous, discontiguous and sparse configurations.
    But the new code no longer passes through "call_pernode_memory()"
    which used to break memory blocks up across nodes. Instead it looks
    at the first address of a block of memory, which does the wrong
    thing if a block extends across a node boundary.
    
    Change the calling convention for call_pernode_memory() so that it
    can be used directly as an argument to efi_memory_walk() and then
    use it.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 9e392a3..8027e31 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -163,7 +163,7 @@ filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
 		range_end   = min(end, rsvd_region[i].start);
 
 		if (range_start < range_end)
-			call_pernode_memory(__pa(range_start), range_end - range_start, func);
+			call_pernode_memory(range_start, range_end, func);
 
 		/* nothing more available in this segment */
 		if (range_end = end) return 0;
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index d3c538b..7d05757 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -227,6 +227,25 @@ count_pages (u64 start, u64 end, void *arg)
 }
 
 /*
+ * Matching function to the discontig.c version.  This one just
+ * converts arguments from (vstart, vend) to (pstart, len).
+ */
+int call_pernode_memory(unsigned long start, unsigned long end, void *arg)
+{
+	void (*func)(unsigned long, unsigned long, int);
+
+	start = PAGE_ALIGN(__pa(start));
+	end = __pa(end) & PAGE_MASK;
+	if (start >= end)
+		return 0;
+
+	func = arg;
+
+	(*func)(start, end - start, 0);
+	return 0;
+}
+
+/*
  * Set up the page tables.
  */
 
@@ -247,7 +266,7 @@ paging_init (void)
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-	efi_memmap_walk(register_active_ranges, NULL);
+	efi_memmap_walk(call_pernode_memory, register_active_ranges);
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map = (struct page *) 0;
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 0d34585..6879a0e 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -444,7 +444,7 @@ void __init find_memory(void)
 			mem_data[node].min_pfn = ~0UL;
 		}
 
-	efi_memmap_walk(register_active_ranges, NULL);
+	efi_memmap_walk(call_pernode_memory, register_active_ranges);
 
 	/*
 	 * Initialize the boot memory maps in reverse order since that's
@@ -570,8 +570,8 @@ void show_mem(void)
 
 /**
  * call_pernode_memory - use SRAT to call callback functions with node info
- * @start: physical start of range
- * @len: length of range
+ * @start: kernel virtual start of range
+ * @end: kernel virtual end of range
  * @arg: function to call for each range
  *
  * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
@@ -581,16 +581,16 @@ void show_mem(void)
  * Take this opportunity to round the start address up and the end address
  * down to page boundaries.
  */
-void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
+int call_pernode_memory(unsigned long start, unsigned long end, void *arg)
 {
-	unsigned long rs, re, end = start + len;
+	unsigned long rs, re;
 	void (*func)(unsigned long, unsigned long, int);
 	int i;
 
-	start = PAGE_ALIGN(start);
-	end &= PAGE_MASK;
+	start = PAGE_ALIGN(__pa(start));
+	end = __pa(end) & PAGE_MASK;
 	if (start >= end)
-		return;
+		return 0;
 
 	func = arg;
 
@@ -598,7 +598,7 @@ void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
 		/* No SRAT table, so assume one node (node 0) */
 		if (start < end)
 			(*func)(start, end - start, 0);
-		return;
+		return 0;
 	}
 
 	for (i = 0; i < num_node_memblks; i++) {
@@ -612,6 +612,7 @@ void call_pernode_memory(unsigned long start, unsigned long len, void *arg)
 		if (re = end)
 			break;
 	}
+	return 0;
 }
 
 /**
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index c14abef..f4172fb 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -556,22 +556,30 @@ find_largest_hole (u64 start, u64 end, void *arg)
 #endif /* CONFIG_VIRTUAL_MEM_MAP */
 
 int __init
-register_active_ranges(u64 start, u64 end, void *arg)
+register_active_ranges(u64 start, u64 len, int nid)
 {
-	int nid = paddr_to_nid(__pa(start));
-
-	if (nid < 0)
-		nid = 0;
 #ifdef CONFIG_KEXEC
-	if (start > crashk_res.start && start < crashk_res.end)
-		start = crashk_res.end;
-	if (end > crashk_res.start && end < crashk_res.end)
-		end = crashk_res.start;
+	u64 vstart = (u64)__va(start), vend = (u64)__va(start + len);
+
+	if (vstart < crashk_res.start && vend > crashk_res.end) {
+		add_active_range(nid, start >> PAGE_SHIFT,
+				 __pa(crashk_res.start) >> PAGE_SHIFT);
+		add_active_range(nid, __pa(crashk_res.end) >> PAGE_SHIFT,
+				 (start + len) >> PAGE_SHIFT);
+		return 0;
+	}
+	if (vstart > crashk_res.start && vstart < crashk_res.end)
+		vstart = crashk_res.end;
+	if (vend > crashk_res.start && vend < crashk_res.end)
+		vend = crashk_res.start;
+	if (vstart < vend)
+		add_active_range(nid, __pa(vstart) >> PAGE_SHIFT,
+			__pa(vend) >> PAGE_SHIFT);
+#else
+	if (len != 0)
+		add_active_range(nid, start >> PAGE_SHIFT,
+			(start + len) >> PAGE_SHIFT);
 #endif
-
-	if (start < end)
-		add_active_range(nid, __pa(start) >> PAGE_SHIFT,
-			__pa(end) >> PAGE_SHIFT);
 	return 0;
 }
 
diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
index 3a62878..88edd28 100644
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -48,15 +48,11 @@ extern int reserve_elfcorehdr(unsigned long *start, unsigned long *end);
 #define GRANULEROUNDUP(n)	(((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
 #define ORDERROUNDDOWN(n)	((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
 
-#ifdef CONFIG_NUMA
-  extern void call_pernode_memory (unsigned long start, unsigned long len, void *func);
-#else
-# define call_pernode_memory(start, len, func)	(*func)(start, len, 0)
-#endif
+extern int call_pernode_memory (unsigned long start, unsigned long end, void *func);
 
 #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
 
-extern int register_active_ranges(u64 start, u64 end, void *arg);
+extern int register_active_ranges(u64 start, u64 len, int nid);
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 # define LARGE_GAP	0x40000000 /* Use virtual mem map if hole is > than this */
