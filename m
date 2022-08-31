From: David Hildenbrand <david@redhat.com>
Date: Wed, 31 Aug 2022 08:07:24 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <739dc825-ece3-a59f-adc5-65861676e0ae@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <608934d4-466d-975e-6458-34a91ccb4669@redhat.com> <Yw5AOZ/Kc5f3UP+s@monkey>
 <Yw6Bpsow+gUMlHCU@monkey>
In-Reply-To: <Yw6Bpsow+gUMlHCU@monkey>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>, Christophe Leroy <christophe.leroy@csgroup.eu>

On 30.08.22 23:31, Mike Kravetz wrote:
> On 08/30/22 09:52, Mike Kravetz wrote:
>> On 08/30/22 10:11, David Hildenbrand wrote:
>>> On 30.08.22 01:40, Mike Kravetz wrote:
>>>> During discussions of this series [1], it was suggested that hugetlb
>>>> handling code in follow_page_mask could be simplified.  At the beginning
>>>
>>> Feel free to use a Suggested-by if you consider it appropriate.
>>>
>>>> of follow_page_mask, there currently is a call to follow_huge_addr which
>>>> 'may' handle hugetlb pages.  ia64 is the only architecture which provides
>>>> a follow_huge_addr routine that does not return error.  Instead, at each
>>>> level of the page table a check is made for a hugetlb entry.  If a hugetlb
>>>> entry is found, a call to a routine associated with that entry is made.
>>>>
>>>> Currently, there are two checks for hugetlb entries at each page table
>>>> level.  The first check is of the form:
>>>> 	if (p?d_huge())
>>>> 		page = follow_huge_p?d();
>>>> the second check is of the form:
>>>> 	if (is_hugepd())
>>>> 		page = follow_huge_pd().
>>>
>>> BTW, what about all this hugepd stuff in mm/pagewalk.c?
>>>
>>> Isn't this all dead code as we're essentially routing all hugetlb VMAs
>>> via walk_hugetlb_range? [yes, all that hugepd stuff in generic code that
>>> overcomplicates stuff has been annoying me for a long time]
>>
>> I am 'happy' to look at cleaning up that code next.  Perhaps I will just
>> create a cleanup series.
>>
> 
> Technically, that code is not dead IIUC.  The call to walk_hugetlb_range in
> __walk_page_range is as follows:
> 
> 	if (vma && is_vm_hugetlb_page(vma)) {
> 		if (ops->hugetlb_entry)
> 			err = walk_hugetlb_range(start, end, walk);
> 	} else
> 		err = walk_pgd_range(start, end, walk);
> 
> We also have the interface walk_page_range_novma() that will call
> __walk_page_range without a value for vma.  So, in that case we would
> end up calling walk_pgd_range, etc.  walk_pgd_range and related routines
> do have those checks such as:
> 
> 		if (is_hugepd(__hugepd(pmd_val(*pmd))))
> 			err = walk_hugepd_range((hugepd_t *)pmd, addr, next, walk, PMD_SHIFT);
> 
> So, it looks like in this case we would process 'hugepd' entries but not
> 'normal' hugetlb entries.  That does not seem right.

:/ walking a hugetlb range without knowing whether it's a hugetlb range
is certainly questionable.


> 
> Christophe Leroy added this code with commit e17eae2b8399 "mm: pagewalk: fix
> walk for hugepage tables".  This was part of the series "Convert powerpc to
> GENERIC_PTDUMP".  And, the ptdump code uses the walk_page_range_novma
> interface.  So, this code is certainly not dead.

Hm, that commit doesn't actually mention how it can happen, what exactly
will happen ("crazy result") and if it ever happened.

> 
> Adding Christophe on Cc:
> 
> Christophe do you know if is_hugepd is true for all hugetlb entries, not
> just hugepd?
> 
> On systems without hugepd entries, I guess ptdump skips all hugetlb entries.
> Sigh!

IIUC, the idea of ptdump_walk_pgd() is to dump page tables even outside
VMAs (for debugging purposes?).

I cannot convince myself that that's a good idea when only holding the
mmap lock in read mode, because we can just see page tables getting
freed concurrently e.g., during concurrent munmap() ... while holding
the mmap lock in read we may only walk inside VMA boundaries.

That then raises the questions if we're only calling this on special MMs
(e.g., init_mm) whereby we cannot really see concurrent munmap() and
where we shouldn't have hugetlb mappings or hugepd entries.

-- 
Thanks,

David / dhildenb
