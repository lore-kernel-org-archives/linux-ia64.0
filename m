From: Michael Ellerman <michael@ellerman.id.au>
Date: Wed, 09 Feb 2005 09:58:07 +0000
Subject: [Patch] Fix oops in alloc_zeroed_user_highpage() when page is NULL
Message-Id: <20050209205807.221d4591.michael@ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
	<20050108135636.6796419a.davem@davemloft.net>
	<Pine.LNX.4.58.0501211206380.25925@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501211206380.25925@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: davem@davemloft.net, hugh@veritas.com, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi All,

The generic and IA-64 versions of alloc_zeroed_user_highpage() don't check the return value from alloc_page_vma(). This can lead to an oops if we're OOM.

This fixes my oops on PPC64, but I haven't got an IA-64 machine/compiler handy.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>

diff -rN -p -u oombreakage-old/include/asm-ia64/page.h oombreakage-new/include/asm-ia64/page.h
--- oombreakage-old/include/asm-ia64/page.h	2005-02-04 04:10:37.000000000 +1100
+++ oombreakage-new/include/asm-ia64/page.h	2005-02-09 20:53:37.000000000 +1100
@@ -79,7 +79,8 @@ do {						\
 #define alloc_zeroed_user_highpage(vma, vaddr) \
 ({						\
 	struct page *page = alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr); \
-	flush_dcache_page(page);		\
+	if (page)				\
+ 		flush_dcache_page(page);	\
 	page;					\
 })
 
diff -rN -p -u oombreakage-old/include/linux/highmem.h oombreakage-new/include/linux/highmem.h
--- oombreakage-old/include/linux/highmem.h	2005-02-09 20:22:41.000000000 +1100
+++ oombreakage-new/include/linux/highmem.h	2005-02-09 20:47:01.000000000 +1100
@@ -48,7 +48,9 @@ alloc_zeroed_user_highpage(struct vm_are
 {
 	struct page *page = alloc_page_vma(GFP_HIGHUSER, vma, vaddr);
 
-	clear_user_highpage(page, vaddr);
+	if (page)
+		clear_user_highpage(page, vaddr);
+
 	return page;
 }
 #endif



