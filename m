From: David Hildenbrand <david@redhat.com>
Date: Mon, 05 Sep 2022 09:46:10 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <e54a4004-3de9-7ddf-9368-e98e0dc45425@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <608934d4-466d-975e-6458-34a91ccb4669@redhat.com> <Yw5AOZ/Kc5f3UP+s@monkey>
 <Yw6Bpsow+gUMlHCU@monkey> <739dc825-ece3-a59f-adc5-65861676e0ae@redhat.com>
 <YxJQfGSsbXd3W4m/@monkey> <323fdb0f-c5a5-e0e5-1ff4-ab971bc295cc@redhat.com>
 <c6f3d408-e050-c1dc-9864-c1b2c92369ed@csgroup.eu>
 <5f6a7c6b-5073-f050-8dae-6ee279a8bb0b@redhat.com>
 <ac9ef726-c465-ccec-363e-9cfb60c170e7@csgroup.eu>
In-Reply-To: <ac9ef726-c465-ccec-363e-9cfb60c170e7@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Baolin Wang <baolin.wang@linux.alibaba.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On 05.09.22 11:33, Christophe Leroy wrote:
> 
> 
> Le 05/09/2022 à 10:37, David Hildenbrand a écrit :
>> On 03.09.22 09:07, Christophe Leroy wrote:
>>> +Resending with valid powerpc list address
>>>
>>> Le 02/09/2022 à 20:52, David Hildenbrand a écrit :
>>>>>>> Adding Christophe on Cc:
>>>>>>>
>>>>>>> Christophe do you know if is_hugepd is true for all hugetlb
>>>>>>> entries, not
>>>>>>> just hugepd?
>>>
>>> is_hugepd() is true if and only if the directory entry points to a huge
>>> page directory and not to the normal lower level directory.
>>>
>>> As far as I understand if the directory entry is not pointing to any
>>> lower directory but is a huge page entry, pXd_leaf() is true.
>>>
>>>
>>>>>>>
>>>>>>> On systems without hugepd entries, I guess ptdump skips all
>>>>>>> hugetlb entries.
>>>>>>> Sigh!
>>>
>>> As far as I can see, ptdump_pXd_entry() handles the pXd_leaf() case.
>>>
>>>>>>
>>>>>> IIUC, the idea of ptdump_walk_pgd() is to dump page tables even
>>>>>> outside
>>>>>> VMAs (for debugging purposes?).
>>>>>>
>>>>>> I cannot convince myself that that's a good idea when only holding the
>>>>>> mmap lock in read mode, because we can just see page tables getting
>>>>>> freed concurrently e.g., during concurrent munmap() ... while holding
>>>>>> the mmap lock in read we may only walk inside VMA boundaries.
>>>>>>
>>>>>> That then raises the questions if we're only calling this on
>>>>>> special MMs
>>>>>> (e.g., init_mm) whereby we cannot really see concurrent munmap() and
>>>>>> where we shouldn't have hugetlb mappings or hugepd entries.
>>>
>>> At least on powerpc, PTDUMP handles only init_mm.
>>>
>>> Hugepage are used at least on powerpc 8xx for linear memory mapping, see
>>>
>>> commit 34536d780683 ("powerpc/8xx: Add a function to early map kernel
>>> via huge pages")
>>> commit cf209951fa7f ("powerpc/8xx: Map linear memory with huge pages")
>>>
>>> hugepds may also be used in the future to use huge pages for vmap and
>>> vmalloc, see commit a6a8f7c4aa7e ("powerpc/8xx: add support for huge
>>> pages on VMAP and VMALLOC")
>>>
>>> As far as I know, ppc64 also use huge pages for VMAP and VMALLOC, see
>>>
>>> commit d909f9109c30 ("powerpc/64s/radix: Enable HAVE_ARCH_HUGE_VMAP")
>>> commit 8abddd968a30 ("powerpc/64s/radix: Enable huge vmalloc mappings")
>>
>> There is a difference between an ordinary huge mapping (e.g., as used
>> for THP) and a a hugetlb mapping.
>>
>> Our current understanding is that hugepd only applies to hugetlb.
>> Wouldn't vmap/vmalloc user ordinary huge pmd entries instead of hugepd?
>>
> 
> 'hugepd' stands for huge page directory. It is independant of whether a
> huge page is used for hugetlb or for anything else, it represents the
> way pages are described in the page tables.

This patch here makes the assumption that hugepd only applies to 
hugetlb, because it removes any such handling from the !hugetlb path in 
GUP. Is that incorrect or are there valid cases where that could happen? 
(init_mm is special in that regard, i don't think it interacts with GUP 
at all).

> 
> I don't know what you mean by _ordinary_ huge pmd entry.
> 

Essentially, what we use for THP. Let me try to understand how hugepd 
interact with the rest of the system.

Do systems that support hugepd currently implement THP? Reading above 
32bit systems below, I assume not?

> Let's take the exemple of powerpc 8xx which is the one I know best. This
> is a powerpc32, so it has two levels : PGD and PTE. PGD has 1024 entries
> and each entry covers a 4Mbytes area. Normal PTE has 1024 entries and
> each entry is a 4k page. When you use 8Mbytes pages, you don't use PTEs
> as it would be a waste of memory. You use a huge page directory that has
> a single entry, and you have two PGD entries pointing to the huge page
> directory.

Thanks, I assume there are no 8MB THP, correct?

The 8MB example with 4MB PGD entries makes it sound a bit like the 
cont-PTE/cont-PMD handling on aarch64: they don't use a hugepd but 
would simply let two consecutive PGD entries point at the the relevant 
(sub) parts of the hugetlb page. No hugepd involved.

> 
> Some time ago, hupgepd was also used for 512kbytes pages and 16kbytes
> pages:
> - there was huge page directories with 8x 512kbytes pages,
> - there was huge page directories with 256x 16kbytes pages,
> 
> And the PGD/PMD entry points to a huge page directory (HUGEPD) instead
> of pointing to a page table directory (PTE).

Thanks for the example.

> 
> Since commit b250c8c08c79 ("powerpc/8xx: Manage 512k huge pages as
> standard pages."), the 8xx doesn't use anymore hugepd for 512k huge
> page, but other platforms like powerpc book3e extensively use huge page
> directories.
> 
> I hope this clarifies the subject, otherwise I'm happy to provide
> further details.

Thanks, it would be valuable to know if the assumption in this patch is 
correct: hugepd will only be found in hugetlb areas in ordinary MMs (not 
init_mm).

-- 
Thanks,

David / dhildenb
