From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 08 Mar 2006 22:04:25 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <Pine.LNX.4.64.0603081359290.9816@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Mar 2006, Chen, Kenneth W wrote:

> What happens to a scenario where you zap the pte right after dirty bit
> handler just finished.  Won't you lost that "dirty" information?

Well zapping is not really what happens. We do an atomic exchange with 
zero. The  dirty bit information is moved to the page_struct (and then
finally the page has a chance to be updated on disk!).
 
See in asm-ia64/pgtable.h

static inline pte_t
ptep_get_and_clear(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
{
#ifdef CONFIG_SMP
        return __pte(xchg((long *) ptep, 0));
#else
        pte_t pte = *ptep;
        pte_clear(mm, addr, ptep);
        return pte;
#endif
}


and from asm-generic/pgtable.h:

#ifndef __HAVE_ARCH_PTEP_CLEAR_FLUSH
#define ptep_clear_flush(__vma, __address, __ptep)                      \
({                                                                      \
        pte_t __pte;                                                    \
        __pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);  \
        flush_tlb_page(__vma, __address);                               \
        __pte;                                                          \
})
#endif


then in mm/rmap.c

/*
 * Subfunctions of try_to_unmap: try_to_unmap_one called
 * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
 */
static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
                                int ignore_refs)

....


       /* Nuke the page table entry. */
        flush_cache_page(vma, address, page_to_pfn(page));
        pteval = ptep_clear_flush(vma, address, pte);

        /* Move the dirty bit to the physical page now the pte is gone. */
        if (pte_dirty(pteval))
                set_page_dirty(page);


