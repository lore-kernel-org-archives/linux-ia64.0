From: Dean Nelson <dcn@sgi.com>
Date: Mon, 27 Aug 2007 16:01:32 +0000
Subject: [PATCH 2/4] export zap_page_range for XPMEM
Message-Id: <20070827160132.GC25589@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827155622.GA25589@sgi.com>
In-Reply-To: <20070827155622.GA25589@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, jes@sgi.com

This patch exports zap_page_range as it is needed by XPMEM.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

XPMEM would have used sys_madvise() except that madvise_dontneed()
madvise_dontneed() returns an -EINVAL if VM_PFNMAP is set, which is
always true for the pages XPMEM imports from other partitions and is
also true for uncached pages allocated locally via the mspec allocator.
XPMEM needs zap_page_range() functionality for these types of pages as
well as 'normal' pages.

Index: linux-2.6/mm/memory.c
=================================--- linux-2.6.orig/mm/memory.c	2007-08-09 07:07:55.762651612 -0500
+++ linux-2.6/mm/memory.c	2007-08-09 07:15:43.226389312 -0500
@@ -894,6 +894,7 @@
 		tlb_finish_mmu(tlb, address, end);
 	return end;
 }
+EXPORT_SYMBOL_GPL(zap_page_range);
 
 /*
  * Do a quick page-table lookup for a single page.
