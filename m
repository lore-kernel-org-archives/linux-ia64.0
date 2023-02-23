From: Randy Dunlap <rdunlap@infradead.org>
Date: Thu, 23 Feb 2023 03:42:58 +0000
Subject: [PATCH] ia64: mm/contig: fix section mismatch warning/error
Message-Id: <20230223034258.12917-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

alloc_per_cpu_data() is called by find_memory(), which is marked
as __init. Therefore alloc_per_cpu_data() can also be marked as
__init to remedy this modpost problem.

WARNING: modpost: vmlinux.o: section mismatch in reference: alloc_per_cpu_data (section: .text) -> memblock_alloc_try_nid (section: .init.text)

Fixes: 4b9ddc7cf272 ("[IA64] Fix section mismatch in contig.c version of per_cpu_init()")
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/mm/contig.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -- a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -77,7 +77,7 @@ skip:
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
 
-static inline void
+static inline __init void
 alloc_per_cpu_data(void)
 {
 	size_t size = PERCPU_PAGE_SIZE * num_possible_cpus();
