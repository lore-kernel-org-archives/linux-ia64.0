From: Peng Liu <liupeng256@huawei.com>
Date: Fri, 29 Apr 2022 02:43:47 +0000
Subject: [PATCH v4] mm: Using for_each_online_node and node_online instead of open coding
Message-Id: <20220429030218.644635-1-liupeng256@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220413032915.251254-4-liupeng256@huawei.com>
In-Reply-To: <20220413032915.251254-4-liupeng256@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mike.kravetz@oracle.com, david@redhat.com, akpm@linux-foundation.org, yaozhenguo1@gmail.com, baolin.wang@linux.alibaba.com, songmuchun@bytedance.com, liuyuntao10@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangkefeng.wang@huawei.com, dave@stgolabs.net, liupeng256@huawei.com, wangborong@cdjrlc.com, linux-ia64@vger.kernel.org, adobriyan@gmail.com

Use more generic functions to deal with issues related to online
nodes. The changes will make the code simplified.

Signed-off-by: Peng Liu <liupeng256@huawei.com>
Suggested-by: Davidlohr Bueso <dave@stgolabs.net>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
---
v4:
 Clean up all the related issues in one patch as suggested by Andrew.

 arch/ia64/kernel/uncached.c | 2 +-
 mm/hugetlb.c                | 4 ++--
 mm/page_ext.c               | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index 816803636a75..a0fec82c56b8 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -261,7 +261,7 @@ static int __init uncached_init(void)
 {
 	int nid;
 
-	for_each_node_state(nid, N_ONLINE) {
+	for_each_online_node(nid) {
 		uncached_pools[nid].pool = gen_pool_create(PAGE_SHIFT, nid);
 		mutex_init(&uncached_pools[nid].add_chunk_mutex);
 	}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 30e1099fd99a..0e5a7764efaa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -6951,7 +6951,7 @@ void __init hugetlb_cma_reserve(int order)
 		if (hugetlb_cma_size_in_node[nid] = 0)
 			continue;
 
-		if (!node_state(nid, N_ONLINE)) {
+		if (!node_online(nid)) {
 			pr_warn("hugetlb_cma: invalid node %d specified\n", nid);
 			hugetlb_cma_size -= hugetlb_cma_size_in_node[nid];
 			hugetlb_cma_size_in_node[nid] = 0;
@@ -6990,7 +6990,7 @@ void __init hugetlb_cma_reserve(int order)
 	}
 
 	reserved = 0;
-	for_each_node_state(nid, N_ONLINE) {
+	for_each_online_node(nid) {
 		int res;
 		char name[CMA_MAX_NAME];
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 2e66d934d63f..3dc715d7ac29 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -320,7 +320,7 @@ static int __meminit online_page_ext(unsigned long start_pfn,
 		 * online__pages(), and start_pfn should exist.
 		 */
 		nid = pfn_to_nid(start_pfn);
-		VM_BUG_ON(!node_state(nid, N_ONLINE));
+		VM_BUG_ON(!node_online(nid));
 	}
 
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION)
-- 
2.25.1
