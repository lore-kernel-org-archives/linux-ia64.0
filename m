From: Michael Ellerman <mpe@ellerman.id.au>
Date: Sun, 04 Sep 2022 11:49:34 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <87ilm3tl4h.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <608934d4-466d-975e-6458-34a91ccb4669@redhat.com>
 <Yw5AOZ/Kc5f3UP+s@monkey> <Yw6Bpsow+gUMlHCU@monkey>
 <739dc825-ece3-a59f-adc5-65861676e0ae@redhat.com>
 <YxJQfGSsbXd3W4m/@monkey>
 <323fdb0f-c5a5-e0e5-1ff4-ab971bc295cc@redhat.com>
 <c6f3d408-e050-c1dc-9864-c1b2c92369ed@csgroup.eu>
In-Reply-To: <c6f3d408-e050-c1dc-9864-c1b2c92369ed@csgroup.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@csgroup.eu>, David Hildenbrand <david@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Baolin Wang <baolin.wang@linux.alibaba.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

Christophe Leroy <christophe.leroy@csgroup.eu> writes:
> +Resending with valid powerpc list address
>
> Le 02/09/2022 à 20:52, David Hildenbrand a écrit :
>>>>> Adding Christophe on Cc:
>>>>>
>>>>> Christophe do you know if is_hugepd is true for all hugetlb entries, not
>>>>> just hugepd?
>
> is_hugepd() is true if and only if the directory entry points to a huge 
> page directory and not to the normal lower level directory.
>
> As far as I understand if the directory entry is not pointing to any 
> lower directory but is a huge page entry, pXd_leaf() is true.

Yes.

Though historically it's pXd_huge() which is used to test that, which is
gated by CONFIG_HUGETLB_PAGE.

The leaf versions are newer and test whether the entry is a PTE
regardless of whether CONFIG_HUGETLB_PAGE is enabled. Which is needed
for PTDUMP if the kernel mapping uses huge pages independently of
CONFIG_HUGETLB_PAGE, which is true on at least powerpc.

>>>>>
>>>>> On systems without hugepd entries, I guess ptdump skips all hugetlb entries.
>>>>> Sigh!
>
> As far as I can see, ptdump_pXd_entry() handles the pXd_leaf() case.
>
>>>>
>>>> IIUC, the idea of ptdump_walk_pgd() is to dump page tables even outside
>>>> VMAs (for debugging purposes?).
>>>>
>>>> I cannot convince myself that that's a good idea when only holding the
>>>> mmap lock in read mode, because we can just see page tables getting
>>>> freed concurrently e.g., during concurrent munmap() ... while holding
>>>> the mmap lock in read we may only walk inside VMA boundaries.
>>>>
>>>> That then raises the questions if we're only calling this on special MMs
>>>> (e.g., init_mm) whereby we cannot really see concurrent munmap() and
>>>> where we shouldn't have hugetlb mappings or hugepd entries.
>
> At least on powerpc, PTDUMP handles only init_mm.
>
> Hugepage are used at least on powerpc 8xx for linear memory mapping, see
>
> commit 34536d780683 ("powerpc/8xx: Add a function to early map kernel 
> via huge pages")
> commit cf209951fa7f ("powerpc/8xx: Map linear memory with huge pages")
>
> hugepds may also be used in the future to use huge pages for vmap and 
> vmalloc, see commit a6a8f7c4aa7e ("powerpc/8xx: add support for huge 
> pages on VMAP and VMALLOC")
>
> As far as I know, ppc64 also use huge pages for VMAP and VMALLOC, see
>
> commit d909f9109c30 ("powerpc/64s/radix: Enable HAVE_ARCH_HUGE_VMAP")
> commit 8abddd968a30 ("powerpc/64s/radix: Enable huge vmalloc mappings")

64-bit also uses huge pages for the kernel linear mapping (aka. direct
mapping), and on newer systems (>= Power9) those also appear in the
kernel page tables.

cheers
