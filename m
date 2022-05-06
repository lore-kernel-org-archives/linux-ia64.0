From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Fri, 06 May 2022 03:02:12 +0000
Subject: Re: [PATCH 1/3] mm: change huge_ptep_clear_flush() to return the original pte
Message-Id: <6c8a5b23-e470-63ca-cc82-f8b5ff1bafaf@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1651216964.git.baolin.wang@linux.alibaba.com>
 <a9038435d408cd7b9defe143537de668dfdf03be.1651216964.git.baolin.wang@linux.alibaba.com>
 <495c4ebe-a5b4-afb6-4cb0-956c1b18d0cc@oracle.com>
In-Reply-To: <495c4ebe-a5b4-afb6-4cb0-956c1b18d0cc@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>, akpm@linux-foundation.org, catalin.marinas@arm.com, will@kernel.org
Cc: tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



On 5/6/2022 7:15 AM, Mike Kravetz wrote:
> On 4/29/22 01:14, Baolin Wang wrote:
>> It is incorrect to use ptep_clear_flush() to nuke a hugetlb page
>> table when unmapping or migrating a hugetlb page, and will change
>> to use huge_ptep_clear_flush() instead in the following patches.
>>
>> So this is a preparation patch, which changes the huge_ptep_clear_flush()
>> to return the original pte to help to nuke a hugetlb page table.
>>
>> Signed-off-by: Baolin Wang <baolin.wang@linux.alibaba.com>
>> ---
>>   arch/arm64/include/asm/hugetlb.h   |  4 ++--
>>   arch/arm64/mm/hugetlbpage.c        | 12 +++++-------
>>   arch/ia64/include/asm/hugetlb.h    |  4 ++--
>>   arch/mips/include/asm/hugetlb.h    |  9 ++++++---
>>   arch/parisc/include/asm/hugetlb.h  |  4 ++--
>>   arch/powerpc/include/asm/hugetlb.h |  9 ++++++---
>>   arch/s390/include/asm/hugetlb.h    |  6 +++---
>>   arch/sh/include/asm/hugetlb.h      |  4 ++--
>>   arch/sparc/include/asm/hugetlb.h   |  4 ++--
>>   include/asm-generic/hugetlb.h      |  4 ++--
>>   10 files changed, 32 insertions(+), 28 deletions(-)
> 
> The above changes look straight forward.
> Happy that you Cc'ed impacted arch maintainers so they can at least
> have a look.
> 
> The only user of huge_ptep_clear_flush() today is hugetlb_cow/wp() in
> mm/hugetlb.c.  Any reason why you did not change that code?  At least

Cause we did not use the return value of huge_ptep_clear_flush() in 
mm/hugetlb.c.

> cast the return of huge_ptep_clear_flush() to void with a comment?

Sure. Will add an explicit casting in next version.

> Not absolutely necessary.
> 
> Acked-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks.
