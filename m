From: Mike Rapoport <rppt@linux.ibm.com>
Date: Mon, 21 Jan 2019 08:03:57 +0000
Subject: [PATCH v2 10/21] memblock: refactor internal allocation functions
Message-Id: <1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

Currently, memblock has several internal functions with overlapping
functionality. They all call memblock_find_in_range_node() to find free
memory and then reserve the allocated range and mark it with kmemleak.
However, there is difference in the allocation constraints and in fallback
strategies.

The allocations returning physical address first attempt to find free
memory on the specified node within mirrored memory regions, then retry on
the same node without the requirement for memory mirroring and finally fall
back to all available memory.

The allocations returning virtual address start with clamping the allowed
range to memblock.current_limit, attempt to allocate from the specified
node from regions with mirroring and with user defined minimal address. If
such allocation fails, next attempt is done with node restriction lifted.
Next, the allocation is retried with minimal address reset to zero and at
last without the requirement for mirrored regions.

Let's consolidate various fallbacks handling and make them more consistent
for physical and virtual variants. Most of the fallback handling is moved
to memblock_alloc_range_nid() and it now handles node and mirror fallbacks.

The memblock_alloc_internal() uses memblock_alloc_range_nid() to get a
physical address of the allocated range and converts it to virtual address.

The fallback for allocation below the specified minimal address remains in
memblock_alloc_internal() because memblock_alloc_range_nid() is used by CMA
with exact requirement for lower bounds.

The memblock_phys_alloc_nid() function is completely dropped as it is not
used anywhere outside memblock and its only usage can be replaced by a call
to memblock_alloc_range_nid().

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/memblock.h |   1 -
 mm/memblock.c            | 173 +++++++++++++++++++++--------------------------
 2 files changed, 78 insertions(+), 96 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 6874fdc..cf4cd9c 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -371,7 +371,6 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
 
 phys_addr_t memblock_phys_alloc_range(phys_addr_t size, phys_addr_t align,
 				      phys_addr_t start, phys_addr_t end);
-phys_addr_t memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 phys_addr_t memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
 
 static inline phys_addr_t memblock_phys_alloc(phys_addr_t size,
diff --git a/mm/memblock.c b/mm/memblock.c
index 531fa77..739f769 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1312,30 +1312,84 @@ __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
 
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
+/**
+ * memblock_alloc_range_nid - allocate boot memory block
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @start: the lower bound of the memory region to allocate (phys address)
+ * @end: the upper bound of the memory region to allocate (phys address)
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
+ *
+ * The allocation is performed from memory region limited by
+ * memblock.current_limit if @max_addr = %MEMBLOCK_ALLOC_ACCESSIBLE.
+ *
+ * If the specified node can not hold the requested memory the
+ * allocation falls back to any node in the system
+ *
+ * For systems with memory mirroring, the allocation is attempted first
+ * from the regions with mirroring enabled and then retried from any
+ * memory region.
+ *
+ * In addition, function sets the min_count to 0 using kmemleak_alloc_phys for
+ * allocated boot memory block, so that it is never reported as leaks.
+ *
+ * Return:
+ * Physical address of allocated memory block on success, %0 on failure.
+ */
 static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 					phys_addr_t align, phys_addr_t start,
-					phys_addr_t end, int nid,
-					enum memblock_flags flags)
+					phys_addr_t end, int nid)
 {
+	enum memblock_flags flags = choose_memblock_flags();
 	phys_addr_t found;
 
+	if (WARN_ONCE(nid = MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+		nid = NUMA_NO_NODE;
+
 	if (!align) {
 		/* Can't use WARNs this early in boot on powerpc */
 		dump_stack();
 		align = SMP_CACHE_BYTES;
 	}
 
+	if (end > memblock.current_limit)
+		end = memblock.current_limit;
+
+again:
 	found = memblock_find_in_range_node(size, align, start, end, nid,
 					    flags);
-	if (found && !memblock_reserve(found, size)) {
+	if (found && !memblock_reserve(found, size))
+		goto done;
+
+	if (nid != NUMA_NO_NODE) {
+		found = memblock_find_in_range_node(size, align, start,
+						    end, NUMA_NO_NODE,
+						    flags);
+		if (found && !memblock_reserve(found, size))
+			goto done;
+	}
+
+	if (flags & MEMBLOCK_MIRROR) {
+		flags &= ~MEMBLOCK_MIRROR;
+		pr_warn("Could not allocate %pap bytes of mirrored memory\n",
+			&size);
+		goto again;
+	}
+
+	return 0;
+
+done:
+	/* Skip kmemleak for kasan_init() due to high volume. */
+	if (end != MEMBLOCK_ALLOC_KASAN)
 		/*
-		 * The min_count is set to 0 so that memblock allocations are
-		 * never reported as leaks.
+		 * The min_count is set to 0 so that memblock allocated
+		 * blocks are never reported as leaks. This is because many
+		 * of these blocks are only referred via the physical
+		 * address which is not looked up by kmemleak.
 		 */
 		kmemleak_alloc_phys(found, size, 0, 0);
-		return found;
-	}
-	return 0;
+
+	return found;
 }
 
 phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
@@ -1343,35 +1397,13 @@ phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
 					     phys_addr_t start,
 					     phys_addr_t end)
 {
-	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE,
-					MEMBLOCK_NONE);
-}
-
-phys_addr_t __init memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
-{
-	enum memblock_flags flags = choose_memblock_flags();
-	phys_addr_t ret;
-
-again:
-	ret = memblock_alloc_range_nid(size, align, 0,
-				       MEMBLOCK_ALLOC_ACCESSIBLE, nid, flags);
-
-	if (!ret && (flags & MEMBLOCK_MIRROR)) {
-		flags &= ~MEMBLOCK_MIRROR;
-		goto again;
-	}
-	return ret;
+	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE);
 }
 
 phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	phys_addr_t res = memblock_phys_alloc_nid(size, align, nid);
-
-	if (res)
-		return res;
-	return memblock_alloc_range_nid(size, align, 0,
-					MEMBLOCK_ALLOC_ACCESSIBLE,
-					NUMA_NO_NODE, MEMBLOCK_NONE);
+	return memblock_alloc_range_nid(size, align, 0, nid,
+					MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
 /**
@@ -1382,19 +1414,13 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
  * @max_addr: the upper bound of the memory region to allocate (phys address)
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
- * The @min_addr limit is dropped if it can not be satisfied and the allocation
- * will fall back to memory below @min_addr. Also, allocation may fall back
- * to any node in the system if the specified node can not
- * hold the requested memory.
- *
- * The allocation is performed from memory region limited by
- * memblock.current_limit if @max_addr = %MEMBLOCK_ALLOC_ACCESSIBLE.
- *
- * The phys address of allocated boot memory block is converted to virtual and
- * allocated memory is reset to 0.
+ * Allocates memory block using memblock_alloc_range_nid() and
+ * converts the returned physical address to virtual.
  *
- * In addition, function sets the min_count to 0 using kmemleak_alloc for
- * allocated boot memory block, so that it is never reported as leaks.
+ * The @min_addr limit is dropped if it can not be satisfied and the allocation
+ * will fall back to memory below @min_addr. Other constraints, such
+ * as node and mirrored memory will be handled again in
+ * memblock_alloc_range_nid().
  *
  * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
@@ -1405,11 +1431,6 @@ static void * __init memblock_alloc_internal(
 				int nid)
 {
 	phys_addr_t alloc;
-	void *ptr;
-	enum memblock_flags flags = choose_memblock_flags();
-
-	if (WARN_ONCE(nid = MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
-		nid = NUMA_NO_NODE;
 
 	/*
 	 * Detect any accidental use of these APIs after slab is ready, as at
@@ -1419,54 +1440,16 @@ static void * __init memblock_alloc_internal(
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, nid);
 
-	if (!align) {
-		dump_stack();
-		align = SMP_CACHE_BYTES;
-	}
-
-	if (max_addr > memblock.current_limit)
-		max_addr = memblock.current_limit;
-again:
-	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
-					    nid, flags);
-	if (alloc && !memblock_reserve(alloc, size))
-		goto done;
-
-	if (nid != NUMA_NO_NODE) {
-		alloc = memblock_find_in_range_node(size, align, min_addr,
-						    max_addr, NUMA_NO_NODE,
-						    flags);
-		if (alloc && !memblock_reserve(alloc, size))
-			goto done;
-	}
-
-	if (min_addr) {
-		min_addr = 0;
-		goto again;
-	}
-
-	if (flags & MEMBLOCK_MIRROR) {
-		flags &= ~MEMBLOCK_MIRROR;
-		pr_warn("Could not allocate %pap bytes of mirrored memory\n",
-			&size);
-		goto again;
-	}
+	alloc = memblock_alloc_range_nid(size, align, min_addr, max_addr, nid);
 
-	return NULL;
-done:
-	ptr = phys_to_virt(alloc);
+	/* retry allocation without lower limit */
+	if (!alloc && min_addr)
+		alloc = memblock_alloc_range_nid(size, align, 0, max_addr, nid);
 
-	/* Skip kmemleak for kasan_init() due to high volume. */
-	if (max_addr != MEMBLOCK_ALLOC_KASAN)
-		/*
-		 * The min_count is set to 0 so that bootmem allocated
-		 * blocks are never reported as leaks. This is because many
-		 * of these blocks are only referred via the physical
-		 * address which is not looked up by kmemleak.
-		 */
-		kmemleak_alloc(ptr, size, 0, 0);
+	if (!alloc)
+		return NULL;
 
-	return ptr;
+	return phys_to_virt(alloc);
 }
 
 /**
-- 
2.7.4
