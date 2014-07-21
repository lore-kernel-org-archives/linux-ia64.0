From: Wang Nan <wangnan0@huawei.com>
Date: Mon, 21 Jul 2014 03:46:40 +0000
Subject: [PATCH v2 5/7] memory-hotplug: ppc: suitable memory should go to ZONE_MOVABLE
Message-Id: <1405914402-66212-6-git-send-email-wangnan0@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
In-Reply-To: <1405914402-66212-1-git-send-email-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: peifeiyue@huawei.com, linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, wangnan0@huawei.com

This patch introduces zone_for_memory() to arch_add_memory() on powerpc
to ensure new, higher memory added into ZONE_MOVABLE if movable zone has
already setup.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 arch/powerpc/mm/mem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 2c8e90f..e0f7a18 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -128,7 +128,8 @@ int arch_add_memory(int nid, u64 start, u64 size)
 		return -EINVAL;
 
 	/* this should work for most non-highmem platforms */
-	zone = pgdata->node_zones;
+	zone = pgdata->node_zones +
+		zone_for_memory(nid, start, size, 0);
 
 	return __add_pages(nid, zone, start_pfn, nr_pages);
 }
-- 
1.8.4

