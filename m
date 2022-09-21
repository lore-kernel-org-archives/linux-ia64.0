From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Wed, 21 Sep 2022 09:30:03 +0000
Subject: Re: [PATCH v3] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <41579b3d-00a4-d3ba-ea7a-21d6d147e018@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919021348.22151-1-mike.kravetz@oracle.com>
In-Reply-To: <20220919021348.22151-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>



On 9/19/2022 10:13 AM, Mike Kravetz wrote:
> During discussions of this series [1], it was suggested that hugetlb
> handling code in follow_page_mask could be simplified.  At the beginning
> of follow_page_mask, there currently is a call to follow_huge_addr which
> 'may' handle hugetlb pages.  ia64 is the only architecture which provides
> a follow_huge_addr routine that does not return error.  Instead, at each
> level of the page table a check is made for a hugetlb entry.  If a hugetlb
> entry is found, a call to a routine associated with that entry is made.
> 
> Currently, there are two checks for hugetlb entries at each page table
> level.  The first check is of the form:
>          if (p?d_huge())
>                  page = follow_huge_p?d();
> the second check is of the form:
>          if (is_hugepd())
>                  page = follow_huge_pd().
> 
> We can replace these checks, as well as the special handling routines
> such as follow_huge_p?d() and follow_huge_pd() with a single routine to
> handle hugetlb vmas.
> 
> A new routine hugetlb_follow_page_mask is called for hugetlb vmas at the
> beginning of follow_page_mask.  hugetlb_follow_page_mask will use the
> existing routine huge_pte_offset to walk page tables looking for hugetlb
> entries.  huge_pte_offset can be overwritten by architectures, and already
> handles special cases such as hugepd entries.
> 
> [1] https://lore.kernel.org/linux-mm/cover.1661240170.git.baolin.wang@linux.alibaba.com/
> 
> Suggested-by: David Hildenbrand <david@redhat.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

LGTM, and works well on my machine. So feel free to add:
Reviewed-by: Baolin Wang <baolin.wang@linux.alibaba.com>
Tested-by: Baolin Wang <baolin.wang@linux.alibaba.com>
