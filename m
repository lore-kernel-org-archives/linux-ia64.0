From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 04 Mar 2005 16:44:01 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <Pine.LNX.4.58.0503040842200.17556@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
 <20050302174507.7991af94.akpm@osdl.org> <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
 <20050302185508.4cd2f618.akpm@osdl.org> <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
 <20050302201425.2b994195.akpm@osdl.org> <Pine.LNX.4.58.0503022021150.3816@schroedinger.engr.sgi.com>
 <20050302205612.451d220b.akpm@osdl.org> <Pine.LNX.4.58.0503022206001.4389@schroedinger.engr.sgi.com>
 <20050302222008.4910eb7b.akpm@osdl.org> <Pine.LNX.4.58.0503030852490.8941@schroedinger.engr.sgi.com>
 <20050303132011.7c80033d.akpm@osdl.org>
In-Reply-To: <20050303132011.7c80033d.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 3 Mar 2005, Andrew Morton wrote:

> A fix would be to restore the get_page() if CONFIG_DEBUG_PAGEALLOC.  Not
> particularly glorious..

Here is the unglorious solution. It also requies that
CONFIG_ATOMIC_TABLE_OPS not be used together with CONFIG_DEBUG_PAGEALLOC
(handled in the following patch):

---------------------------------------------------------------------------

We do a page_cache_get in do_wp_page but we check the pte for changes later.

So why do a page_cache_get at all? Do the copy and maybe copy garbage and
if the pte was changed forget about it. This avoids having to keep state
on the page copied from.

However this does not work for CONFIG_DEBUG_PAGEALLOC. So leave these in
if debugging is enabled. This also means that the following patch will not
allow setting CONFIG_ATOMIC_TABLE_OPS if CONFIG_DEBUG_PAGEALLOC is
selected.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/mm/memory.c
=================================--- linux-2.6.11.orig/mm/memory.c	2005-03-04 08:25:22.000000000 -0800
+++ linux-2.6.11/mm/memory.c	2005-03-04 08:26:30.000000000 -0800
@@ -1318,8 +1318,14 @@ static int do_wp_page(struct mm_struct *
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	/* For debugging we need to get the page otherwise
+	 * the pte for this kernel page may vanish while
+	 * we copy the page.
+	 */
 	if (!PageReserved(old_page))
 		page_cache_get(old_page);
+#endif
 	spin_unlock(&mm->page_table_lock);

 	if (unlikely(anon_vma_prepare(vma)))
@@ -1358,12 +1364,16 @@ static int do_wp_page(struct mm_struct *
 	}
 	pte_unmap(page_table);
 	page_cache_release(new_page);
+#ifdef CONFIG_DEBUG_PAGEALLOC
 	page_cache_release(old_page);
+#endif
 	spin_unlock(&mm->page_table_lock);
 	return VM_FAULT_MINOR;

 no_new_page:
+#ifdef CONFIG_DEBUG_PAGEALLOC
 	page_cache_release(old_page);
+#endif
 	return VM_FAULT_OOM;
 }

