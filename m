From: Muchun Song <songmuchun@bytedance.com>
Date: Fri, 17 Jun 2022 08:13:28 +0000
Subject: Re: [PATCH 1/4] hugetlb: skip to end of PT page mapping when pte not present
Message-Id: <Yqw3qHZIwM35rcLh@FVFYT0MHHV2J.usts.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220616210518.125287-1-mike.kravetz@oracle.com>
 <20220616210518.125287-2-mike.kravetz@oracle.com>
In-Reply-To: <20220616210518.125287-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Peter Xu <peterx@redhat.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jun 16, 2022 at 02:05:15PM -0700, Mike Kravetz wrote:
> HugeTLB address ranges are linearly scanned during fork, unmap and
> remap operations.  If a non-present entry is encountered, the code
> currently continues to the next huge page aligned address.  However,
> a non-present entry implies that the page table page for that entry
> is not present.  Therefore, the linear scan can skip to the end of
> range mapped by the page table page.  This can speed operations on
> large sparsely populated hugetlb mappings.
> 
> Create a new routine hugetlb_mask_last_page() that will return an
> address mask.  When the mask is ORed with an address, the result
> will be the address of the last huge page mapped by the associated
> page table page.  Use this mask to update addresses in routines which
> linearly scan hugetlb address ranges when a non-present pte is
> encountered.
> 
> hugetlb_mask_last_page is related to the implementation of
> huge_pte_offset as hugetlb_mask_last_page is called when huge_pte_offset
> returns NULL.  This patch only provides a complete hugetlb_mask_last_page
> implementation when CONFIG_ARCH_WANT_GENERAL_HUGETLB is defined.
> Architectures which provide their own versions of huge_pte_offset can also
> provide their own version of hugetlb_mask_last_page.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Tested-by: Baolin Wang <baolin.wang@linux.alibaba.com>
> Reviewed-by: Baolin Wang <baolin.wang@linux.alibaba.com>

It'll be more efficient, Thanks.

Acked-by: Muchun Song <songmuchun@bytedance.com>
