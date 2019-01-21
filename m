From: Mike Rapoport <rppt@linux.ibm.com>
Date: Mon, 21 Jan 2019 08:04:03 +0000
Subject: [PATCH v2 16/21] mm/percpu: add checks for the return value of memblock_alloc*()
Message-Id: <1548057848-15136-17-git-send-email-rppt@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

Add panic() calls if memblock_alloc() returns NULL.

The panic() format duplicates the one used by memblock itself and in order
to avoid explosion with long parameters list replace open coded allocation
size calculations with a local variable.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/percpu.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 56 insertions(+), 17 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index db86282..5998b03 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1086,6 +1086,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	struct pcpu_chunk *chunk;
 	unsigned long aligned_addr, lcm_align;
 	int start_offset, offset_bits, region_size, region_bits;
+	size_t alloc_size;
 
 	/* region calculations */
 	aligned_addr = tmp_addr & PAGE_MASK;
@@ -1101,9 +1102,12 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	region_size = ALIGN(start_offset + map_size, lcm_align);
 
 	/* allocate chunk */
-	chunk = memblock_alloc(sizeof(struct pcpu_chunk) +
-			       BITS_TO_LONGS(region_size >> PAGE_SHIFT),
-			       SMP_CACHE_BYTES);
+	alloc_size = sizeof(struct pcpu_chunk) +
+		BITS_TO_LONGS(region_size >> PAGE_SHIFT);
+	chunk = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
 
 	INIT_LIST_HEAD(&chunk->list);
 
@@ -1114,12 +1118,25 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->nr_pages = region_size >> PAGE_SHIFT;
 	region_bits = pcpu_chunk_map_bits(chunk);
 
-	chunk->alloc_map = memblock_alloc(BITS_TO_LONGS(region_bits) * sizeof(chunk->alloc_map[0]),
-					  SMP_CACHE_BYTES);
-	chunk->bound_map = memblock_alloc(BITS_TO_LONGS(region_bits + 1) * sizeof(chunk->bound_map[0]),
-					  SMP_CACHE_BYTES);
-	chunk->md_blocks = memblock_alloc(pcpu_chunk_nr_blocks(chunk) * sizeof(chunk->md_blocks[0]),
-					  SMP_CACHE_BYTES);
+	alloc_size = BITS_TO_LONGS(region_bits) * sizeof(chunk->alloc_map[0]);
+	chunk->alloc_map = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk->alloc_map)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size +		BITS_TO_LONGS(region_bits + 1) * sizeof(chunk->bound_map[0]);
+	chunk->bound_map = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk->bound_map)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = pcpu_chunk_nr_blocks(chunk) * sizeof(chunk->md_blocks[0]);
+	chunk->md_blocks = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk->md_blocks)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
 	pcpu_init_md_blocks(chunk);
 
 	/* manage populated page bitmap */
@@ -2044,6 +2061,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	int group, unit, i;
 	int map_size;
 	unsigned long tmp_addr;
+	size_t alloc_size;
 
 #define PCPU_SETUP_BUG_ON(cond)	do {					\
 	if (unlikely(cond)) {						\
@@ -2075,14 +2093,29 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
-	group_offsets = memblock_alloc(ai->nr_groups * sizeof(group_offsets[0]),
-				       SMP_CACHE_BYTES);
-	group_sizes = memblock_alloc(ai->nr_groups * sizeof(group_sizes[0]),
-				     SMP_CACHE_BYTES);
-	unit_map = memblock_alloc(nr_cpu_ids * sizeof(unit_map[0]),
-				  SMP_CACHE_BYTES);
-	unit_off = memblock_alloc(nr_cpu_ids * sizeof(unit_off[0]),
-				  SMP_CACHE_BYTES);
+	alloc_size = ai->nr_groups * sizeof(group_offsets[0]);
+	group_offsets = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!group_offsets)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = ai->nr_groups * sizeof(group_sizes[0]);
+	group_sizes = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!group_sizes)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = nr_cpu_ids * sizeof(unit_map[0]);
+	unit_map = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!unit_map)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = nr_cpu_ids * sizeof(unit_off[0]);
+	unit_off = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!unit_off)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
 
 	for (cpu = 0; cpu < nr_cpu_ids; cpu++)
 		unit_map[cpu] = UINT_MAX;
@@ -2148,6 +2181,9 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
 	pcpu_slot = memblock_alloc(pcpu_nr_slots * sizeof(pcpu_slot[0]),
 				   SMP_CACHE_BYTES);
+	if (!pcpu_slot)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      pcpu_nr_slots * sizeof(pcpu_slot[0]));
 	for (i = 0; i < pcpu_nr_slots; i++)
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
@@ -2602,6 +2638,9 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	pages_size = PFN_ALIGN(unit_pages * num_possible_cpus() *
 			       sizeof(pages[0]));
 	pages = memblock_alloc(pages_size, SMP_CACHE_BYTES);
+	if (!pages)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      pages_size);
 
 	/* allocate pages */
 	j = 0;
-- 
2.7.4
