From: David Hildenbrand <david@redhat.com>
Date: Fri, 02 Sep 2022 18:52:44 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <323fdb0f-c5a5-e0e5-1ff4-ab971bc295cc@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <608934d4-466d-975e-6458-34a91ccb4669@redhat.com> <Yw5AOZ/Kc5f3UP+s@monkey>
 <Yw6Bpsow+gUMlHCU@monkey> <739dc825-ece3-a59f-adc5-65861676e0ae@redhat.com>
 <YxJQfGSsbXd3W4m/@monkey>
In-Reply-To: <YxJQfGSsbXd3W4m/@monkey>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>, Christophe Leroy <christophe.leroy@csgroup.eu>

>>> Adding Christophe on Cc:
>>>
>>> Christophe do you know if is_hugepd is true for all hugetlb entries, not
>>> just hugepd?
>>>
>>> On systems without hugepd entries, I guess ptdump skips all hugetlb entries.
>>> Sigh!
>>
>> IIUC, the idea of ptdump_walk_pgd() is to dump page tables even outside
>> VMAs (for debugging purposes?).
>>
>> I cannot convince myself that that's a good idea when only holding the
>> mmap lock in read mode, because we can just see page tables getting
>> freed concurrently e.g., during concurrent munmap() ... while holding
>> the mmap lock in read we may only walk inside VMA boundaries.
>>
>> That then raises the questions if we're only calling this on special MMs
>> (e.g., init_mm) whereby we cannot really see concurrent munmap() and
>> where we shouldn't have hugetlb mappings or hugepd entries.
>>
> 
> This is going to require a little more thought.
> 
> Since Baolin's patch for stable releases is moving forward, I want to
> get the cleanup provided by this patch in ASAP.  So, I am going to rebase
> this patch on Baolin's with the other fixups.
> 
> Will come back to this cleanup later.

Sure, no need to do it all at once (I was just bringing it up while
thinking about it).

-- 
Thanks,

David / dhildenb
