From: Peter Xu <peterx@redhat.com>
Date: Fri, 28 Oct 2022 23:24:18 +0000
Subject: Re: [PATCH v4] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Y1xkonJ2DkQQbAaT@x1n>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221028181108.119432-1-mike.kravetz@oracle.com>
In-Reply-To: <20221028181108.119432-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 28, 2022 at 11:11:08AM -0700, Mike Kravetz wrote:
> v4 -    Remove vma (pmd sharing) locking as this can be called with
> 	FOLL_NOWAIT. Peter

Thanks, Mike.  For the gup safety on pmd unshare, I'll prepare a few small
patches and post hopefully early next week (will be off-work on Mon & Tue,
but maybe I'll still try).

-- 
Peter Xu
