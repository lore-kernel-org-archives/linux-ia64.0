From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Sun, 30 Oct 2022 22:54:04 +0000
Subject: Re: [PATCH v4] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Y18B9yYTAqrQ9Zvu@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221028181108.119432-1-mike.kravetz@oracle.com>
 <Y17UPk9CBjPumcz6@x1n>
In-Reply-To: <Y17UPk9CBjPumcz6@x1n>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 10/30/22 15:45, Peter Xu wrote:
> On Fri, Oct 28, 2022 at 11:11:08AM -0700, Mike Kravetz wrote:
> > +	} else {
> > +		if (is_hugetlb_entry_migration(entry)) {
> > +			spin_unlock(ptl);
> > +			hugetlb_vma_unlock_read(vma);
> 
> Just noticed it when pulled the last mm-unstable: this line seems to be a
> left-over of v3, while not needed now?
> 
> > +			__migration_entry_wait_huge(pte, ptl);
> > +			goto retry;
> > +		}

Thanks Peter!

Sent v5 with the that line removed.

-- 
Mike Kravetz
