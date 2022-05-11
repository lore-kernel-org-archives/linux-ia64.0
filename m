From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Wed, 11 May 2022 03:59:57 +0000
Subject: Re: [PATCH v3 2/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when migration
Message-Id: <84209c7b-ac3e-fa3b-75fc-d76ec7c99d68@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1652147571.git.baolin.wang@linux.alibaba.com>
 <ea5abf529f0997b5430961012bfda6166c1efc8c.1652147571.git.baolin.wang@linux.alibaba.com>
 <20220510161739.fdea4d78dde8471033aab22b@linux-foundation.org>
 <20220510162847.d9cf3c767e755a54699fb121@linux-foundation.org>
In-Reply-To: <20220510162847.d9cf3c767e755a54699fb121@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org, songmuchun@bytedance.com, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.osdn.me, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



On 5/11/2022 7:28 AM, Andrew Morton wrote:
> On Tue, 10 May 2022 16:17:39 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>>> +
>>> +static inline pte_t huge_ptep_clear_flush(struct vm_area_struct *vma,
>>> +					  unsigned long addr, pte_t *ptep)
>>> +{
>>> +	return ptep_get(ptep);
>>> +}
>>> +
>>> +static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>>> +				   pte_t *ptep, pte_t pte)
>>> +{
>>> +}
>>>   #endif	/* CONFIG_HUGETLB_PAGE */
>>>   
>>
>> This blows up nommu (arm allnoconfig):
>>
>> In file included from fs/io_uring.c:71:
>> ./include/linux/hugetlb.h: In function 'huge_ptep_clear_flush':
>> ./include/linux/hugetlb.h:1100:16: error: implicit declaration of function 'ptep_get' [-Werror=implicit-function-declaration]
>>   1100 |         return ptep_get(ptep);
>>        |                ^~~~~~~~
>>
>>
>> huge_ptep_clear_flush() is only used in CONFIG_NOMMU=n files, so I simply
>> zapped this change.
>>
> 
> Well that wasn't a great success.  Doing this instead.  It's pretty
> nasty - something nicer would be nicer please.

Thanks for fixing the building issue. I'll look at this to simplify the 
dummy function. Myabe just remove the ptep_get().

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -1097,7 +1097,7 @@ static inline void set_huge_swap_pte_at(struct 
mm_struct *mm, unsigned long addr
  static inline pte_t huge_ptep_clear_flush(struct vm_area_struct *vma,
                                           unsigned long addr, pte_t *ptep)
  {
-       return ptep_get(ptep);
+       return *ptep;
  }

> 
> --- a/include/linux/hugetlb.h~mm-rmap-fix-cont-pte-pmd-size-hugetlb-issue-when-migration-fix
> +++ a/include/linux/hugetlb.h
> @@ -1094,6 +1094,7 @@ static inline void set_huge_swap_pte_at(
>   {
>   }
>   
> +#ifdef CONFIG_MMU
>   static inline pte_t huge_ptep_clear_flush(struct vm_area_struct *vma,
>   					  unsigned long addr, pte_t *ptep)
>   {
> @@ -1104,6 +1105,7 @@ static inline void set_huge_pte_at(struc
>   				   pte_t *ptep, pte_t pte)
>   {
>   }
> +#endif
>   #endif	/* CONFIG_HUGETLB_PAGE */
>   
>   static inline spinlock_t *huge_pte_lock(struct hstate *h,
> _
