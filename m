From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Sun, 08 May 2022 13:09:55 +0000
Subject: Re: [PATCH v2 1/3] mm: change huge_ptep_clear_flush() to return the original pte
Message-Id: <bf627d1a-42f8-77f3-6ac2-67edde2feb8a@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1652002221.git.baolin.wang@linux.alibaba.com>
 <012a484019e7ad77c39deab0af52a6755d8438c8.1652002221.git.baolin.wang@linux.alibaba.com>
 <Ynek+b3k6PVN3x7J@FVFYT0MHHV2J.usts.net>
In-Reply-To: <Ynek+b3k6PVN3x7J@FVFYT0MHHV2J.usts.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Muchun Song <songmuchun@bytedance.com>
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



On 5/8/2022 7:09 PM, Muchun Song wrote:
> On Sun, May 08, 2022 at 05:36:39PM +0800, Baolin Wang wrote:
>> It is incorrect to use ptep_clear_flush() to nuke a hugetlb page
>> table when unmapping or migrating a hugetlb page, and will change
>> to use huge_ptep_clear_flush() instead in the following patches.
>>
>> So this is a preparation patch, which changes the huge_ptep_clear_flush()
>> to return the original pte to help to nuke a hugetlb page table.
>>
>> Signed-off-by: Baolin Wang <baolin.wang@linux.alibaba.com>
>> Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Reviewed-by: Muchun Song <songmuchun@bytedance.com>

Thanks for reviewing.

> 
> But one nit below:
> 
> [...]
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 8605d7e..61a21af 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -5342,7 +5342,7 @@ static vm_fault_t hugetlb_wp(struct mm_struct *mm, struct vm_area_struct *vma,
>>   		ClearHPageRestoreReserve(new_page);
>>   
>>   		/* Break COW or unshare */
>> -		huge_ptep_clear_flush(vma, haddr, ptep);
>> +		(void)huge_ptep_clear_flush(vma, haddr, ptep);
> 
> Why add a "(void)" here? Is there any warning if no "(void)"?
> IIUC, I think we can remove this, right?

I did not meet any warning without the casting, but this is per Mike's 
comment[1] to make the code consistent with other functions casting to 
void type explicitly in hugetlb.c file.

[1] 
https://lore.kernel.org/all/495c4ebe-a5b4-afb6-4cb0-956c1b18d0cc@oracle.com/
