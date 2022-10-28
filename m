From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Fri, 28 Oct 2022 15:27:57 +0000
Subject: Re: [PATCH v3] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Y1v0/Y4Xiut2FWx4@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220919021348.22151-1-mike.kravetz@oracle.com>
 <Y1mtz7dFAlhGRsAd@x1n>
 <Y1nR/KToV44GKZ5G@monkey>
 <Y1rdVLMDD4PMt3s3@x1n>
In-Reply-To: <Y1rdVLMDD4PMt3s3@x1n>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, Baolin Wang <baolin.wang@linux.alibaba.com>, David Hildenbrand <david@redhat.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 10/27/22 15:34, Peter Xu wrote:
> On Wed, Oct 26, 2022 at 05:34:04PM -0700, Mike Kravetz wrote:
> > On 10/26/22 17:59, Peter Xu wrote:
> 
> If we want to use the vma read lock to protect here as the slow gup path,
> then please check again with below [1] - I think we'll also need to protect
> it with fast-gup (probably with trylock only, because fast-gup cannot
> sleep) or it'll encounter the same race, iiuc.
> 
> Actually, instead of using vma lock, I really think this is another problem
> and needs standalone fixing.  The problem is we allows huge_pte_offset() to
> walk the process pgtable without any protection, while pmd unsharing can
> drop a page anytime.  huge_pte_offset() is always facing use-after-free
> when walking the PUD page.
> 
> We may want RCU lock to protect the pgtable pages from getting away when
> huge_pte_offset() is walking it, it'll be safe then because pgtable pages
> are released in RCU fashion only (e.g. in above example, process [2] will
> munmap() and release the last ref to the "used to be shared" pmd and the
> PUD that maps the shared pmds will be released only after a RCU grace
> period), and afaict that's also what's protecting fast-gup from accessing
> freed pgtable pages.
> 
> If with all huge_pte_offset() callers becoming RCU-safe, then IIUC we can
> drop the vma lock in all GUP code, aka, in hugetlb_follow_page_mask() here,
> because both slow and fast gup should be safe too in the same manner.
> 
> Thanks,
> 
> > > IIUC it's also the same as fast-gup - afaiu we don't take the read vma lock
> > > in fast-gup too but I also think it's safe.  But I hope I didn't miss
> > > something.
> 
> [1]

Thanks Peter!  I think the best thing would be to eliminate the vma_lock
calls in this patch.  The code it is replacing/simplifying does not do any
locking, so no real regression.

I think a scheme like you describe above is going to require some more
thought/work.  It might be better as a follow on patch.
-- 
Mike Kravetz
