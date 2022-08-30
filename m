From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Tue, 30 Aug 2022 16:44:18 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Yw4+YvdS9kJUnx1s@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <57c8f032-e48a-bacb-7922-3e2cc10dc0d2@linux.alibaba.com>
In-Reply-To: <57c8f032-e48a-bacb-7922-3e2cc10dc0d2@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baolin Wang <baolin.wang@linux.alibaba.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/30/22 09:06, Baolin Wang wrote:
> Hi Mike,
> 
> On 8/30/2022 7:40 AM, Mike Kravetz wrote:
> > During discussions of this series [1], it was suggested that hugetlb
> > handling code in follow_page_mask could be simplified.  At the beginning
> > of follow_page_mask, there currently is a call to follow_huge_addr which
> > 'may' handle hugetlb pages.  ia64 is the only architecture which provides
> > a follow_huge_addr routine that does not return error.  Instead, at each
> > level of the page table a check is made for a hugetlb entry.  If a hugetlb
> > entry is found, a call to a routine associated with that entry is made.
> > 
> > Currently, there are two checks for hugetlb entries at each page table
> > level.  The first check is of the form:
> > 	if (p?d_huge())
> > 		page = follow_huge_p?d();
> > the second check is of the form:
> > 	if (is_hugepd())
> > 		page = follow_huge_pd().
> > 
> > We can replace these checks, as well as the special handling routines
> > such as follow_huge_p?d() and follow_huge_pd() with a single routine to
> > handle hugetlb vmas.
> > 
> > A new routine hugetlb_follow_page_mask is called for hugetlb vmas at the
> > beginning of follow_page_mask.  hugetlb_follow_page_mask will use the
> > existing routine huge_pte_offset to walk page tables looking for hugetlb
> > entries.  huge_pte_offset can be overwritten by architectures, and already
> > handles special cases such as hugepd entries.
> 
> Could you also mention that this patch will fix the lock issue for
> CONT-PTE/PMD hugetlb by changing to use huge_pte_lock()? which will help
> people to understand the issue.

Will update message in v2.  Thanks for taking a look!

> 
> Otherwise the changes look good to me.
> Reviewed-by: Baolin Wang <baolin.wang@linux.alibaba.com>
-- 
Mike Kravetz
