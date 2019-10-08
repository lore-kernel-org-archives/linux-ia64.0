From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 08 Oct 2019 08:25:22 +0000
Subject: Re: [PATCH V4 2/2] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <881796fc-c35e-3790-a1ee-7031c6cdb38d@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1570427124-21887-1-git-send-email-anshuman.khandual@arm.com>
 <1570427124-21887-3-git-send-email-anshuman.khandual@arm.com>
 <20191007130617.GB56546@gmail.com> <20191007132607.4q537nauwfn5thol@box>
 <20191007135158.GA36360@gmail.com> <20191007140058.um5g44rvxyzyiref@box>
In-Reply-To: <20191007140058.um5g44rvxyzyiref@box>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 10/07/2019 07:30 PM, Kirill A. Shutemov wrote:
> On Mon, Oct 07, 2019 at 03:51:58PM +0200, Ingo Molnar wrote:
>>
>> * Kirill A. Shutemov <kirill@shutemov.name> wrote:
>>
>>> On Mon, Oct 07, 2019 at 03:06:17PM +0200, Ingo Molnar wrote:
>>>>
>>>> * Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>>>
>>>>> This adds a test module which will validate architecture page table helpers
>>>>> and accessors regarding compliance with generic MM semantics expectations.
>>>>> This will help various architectures in validating changes to the existing
>>>>> page table helpers or addition of new ones.
>>>>>
>>>>> Test page table and memory pages creating it's entries at various level are
>>>>> all allocated from system memory with required alignments. If memory pages
>>>>> with required size and alignment could not be allocated, then all depending
>>>>> individual tests are skipped.
>>>>
>>>>> diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
>>>>> index 52e5f5f2240d..b882792a3999 100644
>>>>> --- a/arch/x86/include/asm/pgtable_64_types.h
>>>>> +++ b/arch/x86/include/asm/pgtable_64_types.h
>>>>> @@ -40,6 +40,8 @@ static inline bool pgtable_l5_enabled(void)
>>>>>  #define pgtable_l5_enabled() 0
>>>>>  #endif /* CONFIG_X86_5LEVEL */
>>>>>  
>>>>> +#define mm_p4d_folded(mm) (!pgtable_l5_enabled())
>>>>> +
>>>>>  extern unsigned int pgdir_shift;
>>>>>  extern unsigned int ptrs_per_p4d;
>>>>
>>>> Any deep reason this has to be a macro instead of proper C?
>>>
>>> It's a way to override the generic mm_p4d_folded(). It can be rewritten
>>> as inline function + define. Something like:
>>>
>>> #define mm_p4d_folded mm_p4d_folded
>>> static inline bool mm_p4d_folded(struct mm_struct *mm)
>>> {
>>> 	return !pgtable_l5_enabled();
>>> }
>>>
>>> But I don't see much reason to be more verbose here than needed.
>>
>> C type checking? Documentation? Yeah, I know it's just a one-liner, but 
>> the principle of the death by a thousand cuts applies here.
> 
> Okay, if you think it worth it. Anshuman, could you fix it up for the next
> submission?

Sure, will do.

> 
> 
>> BTW., any reason this must be in the low level pgtable_64_types.h type 
>> header, instead of one of the API level header files?
> 
> I defined it next pgtable_l5_enabled(). What is more appropriate place to
> you? pgtable_64.h? Yeah, it makes sense.


Needs to be moved to arch/x86/include/asm/pgtable_64.h as well ?
