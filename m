From: Andrew Morton <akpm@osdl.org>
Date: Wed, 20 Dec 2006 10:47:54 +0000
Subject: Re: [patch 3/3] IA64: virt_to_page() can be called with NULL arg
Message-Id: <20061220024754.38618f7e.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
In-Reply-To: <200612192104.kBJL4iBg010376@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 20 Dec 2006 11:14:53 +0100
Jes Sorensen <jes@sgi.com> wrote:

> Kirill Korotaev wrote:
> > Jes Sorensen wrote:
> >> If you hit this, yes I'd insert the BUG_ON in your test kernel and fix
> >> the code. Maybe add the BUG_ON in upstream for CONFIG_DEBUG or
> >> something.
> > I guess then all the platforms should be analyzed/patched carefully
> > or all the callers of virt_to_page().
> > Care to create debug patch?
> 
> Well you suggested a patch which just hides the problem. I suggest you
> change it to have the BUG_ON().
> 

The patch doesn't hide any problems:

--- a/include/asm-ia64/pgalloc.h~ia64-virt_to_page-can-be-called-with-null-arg
+++ a/include/asm-ia64/pgalloc.h
@@ -137,7 +137,8 @@ pmd_populate_kernel(struct mm_struct *mm
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long addr)
 {
-	return virt_to_page(pgtable_quicklist_alloc());
+	void *pg = pgtable_quicklist_alloc();
+	return pg ? virt_to_page(pg) : NULL;
 }
 


if the memory allocation function fails, we propagate that failure back to
callers.  All very good.

From a quick look it seems that the pte_alloc() callers are all nicely
handling the failures.

The patch looks good to me?
