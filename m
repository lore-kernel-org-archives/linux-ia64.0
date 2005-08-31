From: Martin Hicks <mort@sgi.com>
Date: Wed, 31 Aug 2005 18:21:26 +0000
Subject: [PATCH] uncached: use generic functions
Message-Id: <20050831182126.GN13449@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony,

Here's a patch for the uncached allocator to make it use non-sn2
specific functions.

Its against a recent git tree.
thanks
mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com



Change sn2-specific calls into generic functions.  Without this change
the uncached allocator will not work on non-sn2 platforms.

Signed-off-by: Greg Edwards <edwardsg@sgi.com>
Signed-off-by: Martin Hicks <mort@sgi.com>

---
commit f69ce6dfd209052bee3d4491cd242ae6575194a9
tree dded7605c2b6aa4108384dc7c886d0dcf9ee13c7
parent 4b6fda9870f5f87068221379d935007f5ccdc61e
author Martin Hicks <mort@descartes.bork.org> Wed, 31 Aug 2005 11:49:14 -0400
committer Martin Hicks <mort@descartes.bork.org> Wed, 31 Aug 2005 11:49:14 -0400

 arch/ia64/kernel/uncached.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -184,7 +184,7 @@ uncached_free_page(unsigned long maddr)
 {
 	int node;
 
-	node = nasid_to_cnodeid(NASID_GET(maddr));
+	node = paddr_to_nid(maddr - __IA64_UNCACHED_OFFSET);
 
 	dprintk(KERN_DEBUG "uncached_free_page(%lx) on node %i\n", maddr, node);
 
@@ -217,7 +217,7 @@ uncached_build_memmap(unsigned long star
 
 	memset((char *)vstart, 0, length);
 
-	node = nasid_to_cnodeid(NASID_GET(start));
+	node = paddr_to_nid(start);
 
 	for (; vstart < vend ; vstart += PAGE_SIZE) {
 		dprintk(KERN_INFO "sticking %lx into the pool!\n", vstart);
