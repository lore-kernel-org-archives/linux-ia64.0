From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Sat, 07 May 2022 02:33:20 +0000
Subject: Re: [PATCH 2/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when migration
Message-Id: <e8b56f7d-ad95-7938-21a5-55caedbbb354@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1651216964.git.baolin.wang@linux.alibaba.com>
 <11b92502b3df0e0bba6a1dc71476d79cab6c79ba.1651216964.git.baolin.wang@linux.alibaba.com>
 <5cab0eca-9630-a7c6-4f5d-5cb45ff82c83@oracle.com>
 <21b11024-e893-8c11-9b98-ab1d13413b61@linux.alibaba.com>
 <85bd80b4-b4fd-0d3f-a2e5-149559f2f387@oracle.com>
In-Reply-To: <85bd80b4-b4fd-0d3f-a2e5-149559f2f387@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Mike Kravetz <mike.kravetz@oracle.com>, akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org
Cc: tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



On 5/7/2022 1:56 AM, Mike Kravetz wrote:
> On 5/5/22 20:39, Baolin Wang wrote:
>>
>> On 5/6/2022 7:53 AM, Mike Kravetz wrote:
>>> On 4/29/22 01:14, Baolin Wang wrote:
>>>> On some architectures (like ARM64), it can support CONT-PTE/PMD size
>>>> hugetlb, which means it can support not only PMD/PUD size hugetlb:
>>>> 2M and 1G, but also CONT-PTE/PMD size: 64K and 32M if a 4K page
>>>> size specified.
>>> <snip>
>>>> diff --git a/mm/rmap.c b/mm/rmap.c
>>>> index 6fdd198..7cf2408 100644
>>>> --- a/mm/rmap.c
>>>> +++ b/mm/rmap.c
>>>> @@ -1924,13 +1924,15 @@ static bool try_to_migrate_one(struct folio *folio, struct vm_area_struct *vma,
>>>>                        break;
>>>>                    }
>>>>                }
>>>> +
>>>> +            /* Nuke the hugetlb page table entry */
>>>> +            pteval = huge_ptep_clear_flush(vma, address, pvmw.pte);
>>>>            } else {
>>>>                flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
>>>> +            /* Nuke the page table entry. */
>>>> +            pteval = ptep_clear_flush(vma, address, pvmw.pte);
>>>>            }
>>>>    
>>>
>>> On arm64 with CONT-PTE/PMD the returned pteval will have dirty or young set
>>> if ANY of the PTE/PMDs had dirty or young set.
>>
>> Right.
>>
>>>
>>>> -        /* Nuke the page table entry. */
>>>> -        pteval = ptep_clear_flush(vma, address, pvmw.pte);
>>>> -
>>>>            /* Set the dirty flag on the folio now the pte is gone. */
>>>>            if (pte_dirty(pteval))
>>>>                folio_mark_dirty(folio);
>>>> @@ -2015,7 +2017,10 @@ static bool try_to_migrate_one(struct folio *folio, struct vm_area_struct *vma,
>>>>                pte_t swp_pte;
>>>>                  if (arch_unmap_one(mm, vma, address, pteval) < 0) {
>>>> -                set_pte_at(mm, address, pvmw.pte, pteval);
>>>> +                if (folio_test_hugetlb(folio))
>>>> +                    set_huge_pte_at(mm, address, pvmw.pte, pteval);
>>>
>>> And, we will use that pteval for ALL the PTE/PMDs here.  So, we would set
>>> the dirty or young bit in ALL PTE/PMDs.
>>>
>>> Could that cause any issues?  May be more of a question for the arm64 people.
>>
>> I don't think this will cause any issues. Since the hugetlb can not be split, and we should not lose the the dirty or young state if any subpages were set. Meanwhile we already did like this in hugetlb.c:
>>
>> pte = huge_ptep_get_and_clear(mm, address, ptep);
>> tlb_remove_huge_tlb_entry(h, tlb, ptep, address);
>> if (huge_pte_dirty(pte))
>>      set_page_dirty(page);
>>
> 
> Agree that it 'should not' cause issues.  It just seems inconsistent.
> This is not a problem specifically with your patch, just the handling of
> CONT-PTE/PMD entries.
> 
> There does not appear to be an arm64 specific version of huge_ptep_get()
> that takes CONT-PTE/PMD into account.  So, huge_ptep_get() would only
> return the one specific value.  It would not take into account the dirty
> or young bits of CONT-PTE/PMDs like your new version of
> huge_ptep_get_and_clear.  Is that correct?  Or, am I missing something.

Yes, you are right.

> 
> If I am correct, then code like the following may not work:
> 
> static int gather_hugetlb_stats(pte_t *pte, unsigned long hmask,
>                  unsigned long addr, unsigned long end, struct mm_walk *walk)
> {
>          pte_t huge_pte = huge_ptep_get(pte);
>          struct numa_maps *md;
>          struct page *page;
> 
>          if (!pte_present(huge_pte))
>                  return 0;
> 
>          page = pte_page(huge_pte);
> 
>          md = walk->private;
>          gather_stats(page, md, pte_dirty(huge_pte), 1);
>          return 0;
> }

Right, this is inconsistent with current huge_ptep_get() interface like 
you said. So I think we can define an ARCH-specific huge_ptep_get() 
interface for arm64, and some sample code like below. How do you think?

+pte_t huge_ptep_get(pte_t *ptep, unsigned long size)
+{
+       int ncontig;
+       pte_t orig_pte = ptep_get(ptep);
+
+       if (!pte_cont(orig_pte))
+               return orig_pte;
+
+       switch (size) {
+       case CONT_PMD_SIZE:
+               ncontig = CONT_PMDS;
+               break;
+       case CONT_PTE_SIZE:
+               ncontig = CONT_PTES;
+               break;
+       default:
+               WARN_ON_ONCE(1);
+               return orig_pte;
+       }
+
+       for (i = 0; i < ncontig; i++, ptep++) {
+               pte_t pte = ptep_get(ptep);
+
+               if (pte_dirty(pte))
+                       orig_pte = pte_mkdirty(orig_pte);
+
+               if (pte_young(pte))
+                       orig_pte = pte_mkyong(orig_pte);
+       }
+
+       return orig_pte;
+}
