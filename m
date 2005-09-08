From: Martin Hicks <mort@sgi.com>
Date: Thu, 08 Sep 2005 17:46:19 +0000
Subject: [PATCH] uncached allocator: Update for new efi_memmap_walk
Message-Id: <20050908174619.GF13449@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi Tony and Jes,

Here is an update to the uncached allocator to handle the new address
format from efi_memmap_walk_uc().

Boot tested on sn2 and zx1.

This depends on the efi_memmap_init() fixes that I posted to the Linux
IA64 list a couple of hours ago.

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com




Clean up the uncached allocator to use the new efi_memmap_walk().

Signed-off-by: Martin Hicks <mort@sgi.com>

---

 arch/ia64/kernel/uncached.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

Index: linux-2.6.13/arch/ia64/kernel/uncached.c
=================================--- linux-2.6.13.orig/arch/ia64/kernel/uncached.c	2005-09-08 08:33:31.000000000 -0700
+++ linux-2.6.13/arch/ia64/kernel/uncached.c	2005-09-08 10:08:24.000000000 -0700
@@ -205,23 +205,18 @@ EXPORT_SYMBOL(uncached_free_page);
 static int __init
 uncached_build_memmap(unsigned long start, unsigned long end, void *arg)
 {
-	long length;
-	unsigned long vstart, vend;
+	long length = end - start;
 	int node;
 
-	length = end - start;
-	vstart = start + __IA64_UNCACHED_OFFSET;
-	vend = end + __IA64_UNCACHED_OFFSET;
-
 	dprintk(KERN_ERR "uncached_build_memmap(%lx %lx)\n", start, end);
 
-	memset((char *)vstart, 0, length);
+	memset((char *)start, 0, length);
 
-	node = paddr_to_nid(start);
+	node = paddr_to_nid(start - __IA64_UNCACHED_OFFSET);
 
-	for (; vstart < vend ; vstart += PAGE_SIZE) {
-		dprintk(KERN_INFO "sticking %lx into the pool!\n", vstart);
-		gen_pool_free(uncached_pool[node], vstart, PAGE_SIZE);
+	for (; start < end ; start += PAGE_SIZE) {
+		dprintk(KERN_INFO "sticking %lx into the pool!\n", start);
+		gen_pool_free(uncached_pool[node], start, PAGE_SIZE);
 	}
 
 	return 0;
