From: Tejun Heo <tj@kernel.org>
Date: Mon, 28 Nov 2011 19:31:20 +0000
Subject: [PATCH 18/23] ia64: Use HAVE_MEMBLOCK_NODE_MAP
Message-Id: <1322508685-32532-19-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1322508685-32532-1-git-send-email-tj@kernel.org>
In-Reply-To: <1322508685-32532-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: benh@kernel.crashing.org, yinghai@kernel.org, hpa@zytor.com, tony.luck@intel.com, ralf@linux-mips.org, schwidefsky@de.ibm.com, liqin.chen@sunplusct.com, lethal@linux-sh.org, davem@davemloft.net, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, jonas@southpole.se, lennox.wu@gmail.com
Cc: Tejun Heo <tj@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

ia64 used early_node_map[] just to prime free_area_init_nodes().  Now
memblock can be used for the same purpose and early_node_map[] is
scheduled to be dropped.  Use memblock instead.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig     |    3 +++
 arch/ia64/mm/contig.c |    3 ++-
 arch/ia64/mm/init.c   |    4 ++--
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 27489b6..e2c7de0 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -23,6 +23,9 @@ config IA64
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_DMA_API_DEBUG
 	select HAVE_GENERIC_HARDIRQS
+	select HAVE_MEMBLOCK
+	select HAVE_MEMBLOCK_NODE_MAP
+	select ARCH_DISCARD_MEMBLOCK
 	select GENERIC_IRQ_PROBE
 	select GENERIC_PENDING_IRQ if SMP
 	select IRQ_PER_CPU
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index f114a3b..1516d1d 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -16,6 +16,7 @@
  */
 #include <linux/bootmem.h>
 #include <linux/efi.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/nmi.h>
 #include <linux/swap.h>
@@ -348,7 +349,7 @@ paging_init (void)
 		printk("Virtual mem_map starts at 0x%p\n", mem_map);
 	}
 #else /* !CONFIG_VIRTUAL_MEM_MAP */
-	add_active_range(0, 0, max_low_pfn);
+	memblock_add_node(0, PFN_PHYS(max_low_pfn), 0);
 	free_area_init_nodes(max_zone_pfns);
 #endif /* !CONFIG_VIRTUAL_MEM_MAP */
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 00cb0e2..13df239d 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -10,6 +10,7 @@
 #include <linux/bootmem.h>
 #include <linux/efi.h>
 #include <linux/elf.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/module.h>
@@ -557,8 +558,7 @@ int __init register_active_ranges(u64 start, u64 len, int nid)
 #endif
 
 	if (start < end)
-		add_active_range(nid, __pa(start) >> PAGE_SHIFT,
-			__pa(end) >> PAGE_SHIFT);
+		memblock_add_node(__pa(start), end - start, nid);
 	return 0;
 }
 
-- 
1.7.3.1

