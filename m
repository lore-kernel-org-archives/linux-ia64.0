From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Fri, 06 May 2022 18:55:13 +0000
Subject: Re: [PATCH 3/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when unmapping
Message-Id: <f64f0d4f-f0fc-f07c-3c17-96f124da21e4@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1651216964.git.baolin.wang@linux.alibaba.com>
 <c91e04ebb792ef7b72966edea8bd6fa2dfa5bfa7.1651216964.git.baolin.wang@linux.alibaba.com>
In-Reply-To: <c91e04ebb792ef7b72966edea8bd6fa2dfa5bfa7.1651216964.git.baolin.wang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baolin Wang <baolin.wang@linux.alibaba.com>, akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org
Cc: tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On 4/29/22 01:14, Baolin Wang wrote:
> On some architectures (like ARM64), it can support CONT-PTE/PMD size
> hugetlb, which means it can support not only PMD/PUD size hugetlb:
> 2M and 1G, but also CONT-PTE/PMD size: 64K and 32M if a 4K page
> size specified.
> 
> When unmapping a hugetlb page, we will get the relevant page table
> entry by huge_pte_offset() only once to nuke it. This is correct
> for PMD or PUD size hugetlb, since they always contain only one
> pmd entry or pud entry in the page table.
> 
> However this is incorrect for CONT-PTE and CONT-PMD size hugetlb,
> since they can contain several continuous pte or pmd entry with
> same page table attributes, so we will nuke only one pte or pmd
> entry for this CONT-PTE/PMD size hugetlb page.
> 
> And now we only use try_to_unmap() to unmap a poisoned hugetlb page,

Since try_to_unmap can be called for non-hugetlb pages, perhaps the following
is more accurate?

try_to_unmap is only passed a hugetlb page in the case where the
hugetlb page is poisoned.

It does concern me that this assumption is built into the code as
pointed out in your discussion with Gerald.  Should we perhaps add
a VM_BUG_ON() to make sure the passed huge page is poisoned?  This
would be in the same 'if block' where we call
adjust_range_if_pmd_sharing_possible.

-- 
Mike Kravetz

> which means now we will unmap only one pte entry for a CONT-PTE or
> CONT-PMD size poisoned hugetlb page, and we can still access other
> subpages of a CONT-PTE or CONT-PMD size poisoned hugetlb page,
> which will cause serious issues possibly.
> 
> So we should change to use huge_ptep_clear_flush() to nuke the
> hugetlb page table to fix this issue, which already considered
> CONT-PTE and CONT-PMD size hugetlb.
> 
> Note we've already used set_huge_swap_pte_at() to set a poisoned
> swap entry for a poisoned hugetlb page.
> 
> Signed-off-by: Baolin Wang <baolin.wang@linux.alibaba.com>
> ---
>  mm/rmap.c | 34 +++++++++++++++++-----------------
>  1 file changed, 17 insertions(+), 17 deletions(-)
