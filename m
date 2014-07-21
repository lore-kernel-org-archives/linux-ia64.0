From: Wang Nan <wangnan0@huawei.com>
Date: Mon, 21 Jul 2014 03:46:42 +0000
Subject: [PATCH v2 7/7] memory-hotplug: tile: suitable memory should go to ZONE_MOVABLE
Message-Id: <1405914402-66212-8-git-send-email-wangnan0@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com

This patch introduces zone_for_memory() to arch_add_memory() on tile to
ensure new, higher memory added into ZONE_MOVABLE if movable zone has
already setup.

This patch also fix a problem: on tile, new memory should be added into
ZONE_HIGHMEM by default, not MAX_NR_ZONES-1, which is ZONE_MOVABLE.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 arch/tile/mm/init.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index bfb3127..22ac6c1 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -872,7 +872,8 @@ void __init mem_init(void)
 int arch_add_memory(u64 start, u64 size)
 {
 	struct pglist_data *pgdata = &contig_page_data;
-	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
+	struct zone *zone = pgdata->node_zones +
+		zone_for_memory(nid, start, size, ZONE_HIGHMEM);
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-- 
1.8.4

