From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 05 May 2020 02:52:21 +0000
Subject: Re: [PATCH 3/3] mm/hugetlb: Introduce HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS
Message-Id: <21460cbc-8e9a-b956-5797-57b2e1df9fb1@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1586864670-21799-1-git-send-email-anshuman.khandual@arm.com>
 <1586864670-21799-4-git-send-email-anshuman.khandual@arm.com>
 <20200425175511.7a68efb5e2f4436fe0328c1d@linux-foundation.org>
 <87d37591-caa2-b82b-392a-3a29b2c7e9a6@arm.com>
 <20200425200124.20d0c75fcaef05d062d3667c@linux-foundation.org>
In-Reply-To: <20200425200124.20d0c75fcaef05d062d3667c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, David



On 04/26/2020 08:31 AM, Andrew Morton wrote:
> On Sun, 26 Apr 2020 08:13:17 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>>
>>
>> On 04/26/2020 06:25 AM, Andrew Morton wrote:
>>> On Tue, 14 Apr 2020 17:14:30 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>>
>>>> There are multiple similar definitions for arch_clear_hugepage_flags() on
>>>> various platforms. This introduces HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS for those
>>>> platforms that need to define their own arch_clear_hugepage_flags() while
>>>> also providing a generic fallback definition for others to use. This help
>>>> reduce code duplication.
>>>>
>>>> ...
>>>>
>>>> --- a/include/linux/hugetlb.h
>>>> +++ b/include/linux/hugetlb.h
>>>> @@ -544,6 +544,10 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
>>>>  }
>>>>  #endif
>>>>  
>>>> +#ifndef HAVE_ARCH_CLEAR_HUGEPAGE_FLAGS
>>>> +static inline void arch_clear_hugepage_flags(struct page *page) { }
>>>> +#endif
>>>> +
>>>>  #ifndef arch_make_huge_pte
>>>>  static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>>>>  				       struct page *page, int writable)
>>>
>>> This is the rather old-school way of doing it.  The Linus-suggested way is
>>>
>>> #ifndef arch_clear_hugepage_flags
>>> static inline void arch_clear_hugepage_flags(struct page *page)
>>> {
>>> }
>>> #define arch_clear_hugepage_flags arch_clear_hugepage_flags
>>
>> Do we need that above line here ? Is not that implicit.
> 
> It depends if other header files want to test whether
> arch_clear_hugepage_flags is already defined.  If the header heorarchy
> is well-defined and working properly, they shouldn't need to, because
> we're reliably indluding the relevant arch header before (or early
> within) include/linux/hugetlb.h.
> 
> It would be nice if
> 
> #define arch_clear_hugepage_flags arch_clear_hugepage_flags
> #define arch_clear_hugepage_flags arch_clear_hugepage_flags
> 
> were to generate an compiler error but it doesn't.  If it did we could
> detect these incorrect inclusion orders.
> 
>>> #endif
>>>
>>> And the various arch headers do
>>>
>>> static inline void arch_clear_hugepage_flags(struct page *page)
>>> {
>>> 	<some implementation>
>>> }
>>> #define arch_clear_hugepage_flags arch_clear_hugepage_flags
>>>
>>> It's a small difference - mainly to avoid adding two variables to the
>>> overall namespace where one would do.
>>
>> Understood, will change and resend.
> 
> That's OK - I've queued up that fix.
>

Hello Andrew,

I might not have searched all the relevant trees or might have just searched
earlier than required. But I dont see these patches (or your proposed fixes)
either in mmotm (2020-04-29-23-04) or in next-20200504. Wondering if you are
waiting on a V2 for this series accommodating the changes you had proposed.

- Anshuman
