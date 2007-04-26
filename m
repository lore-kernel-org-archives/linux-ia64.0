From: Mike Stroyan <mike.stroyan@hp.com>
Date: Thu, 26 Apr 2007 00:16:15 +0000
Subject: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <20070426001615.GA8908@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

  This is a very similar problem to a copy-on-write cache flushing problem
that Tony Luck fixed in July 2006.  In this case the do_no_page function
handles a fault in an executable or library that is mmapped from an
NFS file system.  The code is copied into a newly reallocated page.
The lazy_mmu_prot_update() function should be used to flush old entries
from the icache for that page on ia64 processors.  But that call is made
after a set_pte_at call that makes the page accessible to other threads
executing the same code.  This was seen to cause application crashes
when an OpenMP application ran many threads calling same functions at
the same time.  The first thread to reach a page starts to fault in the
new code.  One of the other threads overtakes the first and executes old
data from the icache.  That could result in bad instructions.  It is more
obvious when an old cache line contains prefetched non-instruction bits
that result in an illegal instruction trap.

  The problem has only been seen on montecito processors which have
separate level 2 icache and dcache.  This dcache to icache coherency
problem is more likely to occur there because of the much larger level
2 icache.  I suspect that the non-NFS case is working because direct
DMA into the new page is making the instruction cache coherent.  Any
file system that uses a non-DMA copy into the text page could show the
same problem.

Signed-off-by: Mike Stroyan <mike.stroyan@hp.com>

diff --git a/mm/memory.c b/mm/memory.c
index e7066e7..50c8848 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2291,6 +2291,7 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		lazy_mmu_prot_update(entry);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
@@ -2312,7 +2313,6 @@ retry:
 
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	update_mmu_cache(vma, address, entry);
-	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {

-- 
Mike Stroyan, mike.stroyan@hp.com
