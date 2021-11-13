From: Jason Wang <wangborong@cdjrlc.com>
Date: Sat, 13 Nov 2021 03:03:16 +0000
Subject: [PATCH] ia64: Fix typo in a comment
Message-Id: <20211113030316.22650-1-wangborong@cdjrlc.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ardb@kernel.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jason Wang <wangborong@cdjrlc.com>

The double `the' in a comment is repeated, thus it should be removed.

Signed-off-by: Jason Wang <wangborong@cdjrlc.com>
---
 arch/ia64/kernel/uncached.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index 51883a66aeb5..816803636a75 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -171,7 +171,7 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
  * @n_pages: number of contiguous pages to allocate
  *
  * Allocate the specified number of contiguous uncached pages on the
- * the requested node. If not enough contiguous uncached pages are available
+ * requested node. If not enough contiguous uncached pages are available
  * on the requested node, roundrobin starting with the next higher node.
  */
 unsigned long uncached_alloc_page(int starting_nid, int n_pages)
-- 
2.33.0
