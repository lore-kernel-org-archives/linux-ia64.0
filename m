From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu, 19 Sep 2019 05:41:45 +0000
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating architecture page table helpers
Message-Id: <cd22b0c3-d999-e23a-7265-1814b3312974@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <ab0ca38b-1e4f-b636-f8b4-007a15903984@c-s.fr>
 <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
 <95ed9d92-dd43-4c45-2e52-738aed7f2fb5@c-s.fr>
 <f872e6f4-a5cb-069d-2034-78961930cb9f@arm.com>
 <64504101-d9dd-f273-02f9-e9a8b178eecc@c-s.fr>
 <955491d9-d8aa-0a93-4fb9-3d15acfbcbf8@arm.com>
In-Reply-To: <955491d9-d8aa-0a93-4fb9-3d15acfbcbf8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



Le 19/09/2019 à 06:56, Anshuman Khandual a écrit :
> 
> 
> On 09/18/2019 09:56 PM, Christophe Leroy wrote:
>>
>>
>> Le 18/09/2019 à 07:04, Anshuman Khandual a écrit :
>>>
>>>
>>> On 09/13/2019 03:31 PM, Christophe Leroy wrote:
>>>>
>>>>
>>>> Le 13/09/2019 à 11:02, Anshuman Khandual a écrit :
>>>>>
>>>>>>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
>>>>>>
>>>>>> #ifdefs have to be avoided as much as possible, see below
>>>>>
>>>>> Yeah but it has been bit difficult to avoid all these $ifdef because of the
>>>>> availability (or lack of it) for all these pgtable helpers in various config
>>>>> combinations on all platforms.
>>>>
>>>> As far as I can see these pgtable helpers should exist everywhere at least via asm-generic/ files.
>>>
>>> But they might not actually do the right thing.
>>>
>>>>
>>>> Can you spot a particular config which fails ?
>>>
>>> Lets consider the following example (after removing the $ifdefs around it)
>>> which though builds successfully but fails to pass the intended test. This
>>> is with arm64 config 4K pages sizes with 39 bits VA space which ends up
>>> with a 3 level page table arrangement.
>>>
>>> static void __init p4d_clear_tests(p4d_t *p4dp)
>>> {
>>>           p4d_t p4d = READ_ONCE(*p4dp);
>>
>> My suggestion was not to completely drop the #ifdef but to do like you did in pgd_clear_tests() for instance, ie to add the following test on top of the function:
>>
>>      if (mm_pud_folded(mm) || is_defined(__ARCH_HAS_5LEVEL_HACK))
>>          return;
>>
> 
> Sometimes this does not really work. On some platforms, combination of
> __PAGETABLE_PUD_FOLDED and __ARCH_HAS_5LEVEL_HACK decide whether the
> helpers such as __pud() or __pgd() is even available for that platform.
> Ideally it should have been through generic falls backs in include/*/
> but I guess there might be bugs on the platform or it has not been
> changed to adopt 5 level page table framework with required folding
> macros etc.

Yes. As I suggested below, most likely that's better to retain the 
#ifdef __ARCH_HAS_5LEVEL_HACK but change the #ifdef 
__PAGETABLE_PUD_FOLDED by a runtime test of mm_pud_folded(mm)

As pointed by Gerald, some arches don't have __PAGETABLE_PUD_FOLDED 
because they are deciding dynamically if they fold the level on not, but 
have mm_pud_folded(mm)

> 
>>>
>>>           p4d = __p4d(p4d_val(p4d) | RANDOM_ORVALUE);
>>>           WRITE_ONCE(*p4dp, p4d);
>>>           p4d_clear(p4dp);
>>>           p4d = READ_ONCE(*p4dp);
>>>           WARN_ON(!p4d_none(p4d));
>>> }
>>>
>>> The following test hits an error at WARN_ON(!p4d_none(p4d))
>>>
>>> [   16.757333] ------------[ cut here ]------------
>>> [   16.758019] WARNING: CPU: 11 PID: 1 at mm/arch_pgtable_test.c:187 arch_pgtable_tests_init+0x24c/0x474

[...]

>>> [   16.781282] ---[ end trace 042e6c40c0a3b038 ]---
>>>
>>> On arm64 (4K page size|39 bits VA|3 level page table)
>>>
>>> #elif CONFIG_PGTABLE_LEVELS = 3    /* Applicable here */
>>> #define __ARCH_USE_5LEVEL_HACK
>>> #include <asm-generic/pgtable-nopud.h>
>>>
>>> Which pulls in
>>>
>>> #include <asm-generic/pgtable-nop4d-hack.h>
>>>
>>> which pulls in
>>>
>>> #include <asm-generic/5level-fixup.h>
>>>
>>> which defines
>>>
>>> static inline int p4d_none(p4d_t p4d)
>>> {
>>>           return 0;
>>> }
>>>
>>> which will invariably trigger WARN_ON(!p4d_none(p4d)).
>>>
>>> Similarly for next test p4d_populate_tests() which will always be
>>> successful because p4d_bad() invariably returns negative.
>>>
>>> static inline int p4d_bad(p4d_t p4d)
>>> {
>>>           return 0;
>>> }
>>>
>>> static void __init p4d_populate_tests(struct mm_struct *mm, p4d_t *p4dp,
>>>                                         pud_t *pudp)
>>> {
>>>           p4d_t p4d;
>>>
>>>           /*
>>>            * This entry points to next level page table page.
>>>            * Hence this must not qualify as p4d_bad().
>>>            */
>>>           pud_clear(pudp);
>>>           p4d_clear(p4dp);
>>>           p4d_populate(mm, p4dp, pudp);
>>>           p4d = READ_ONCE(*p4dp);
>>>           WARN_ON(p4d_bad(p4d));
>>> }
>>>
>>> We should not run these tests for the above config because they are
>>> not applicable and will invariably produce same result.
>>>

[...]

>>>>
>>>> So it shouldn't be an issue. Maybe if a couple of arches miss them, the best would be to fix the arches, since that's the purpose of your testsuite isn't it ?
>>>
>>> The run time failures as explained previously is because of the folding which
>>> needs to be protected as they are not even applicable. The compile time
>>> failures are because pxx_populate() signatures are platform specific depending
>>> on how many page table levels they really support.
>>>
>>
>> So IIUC, the compiletime problem is around __ARCH_HAS_5LEVEL_HACK. For all #if !defined(__PAGETABLE_PXX_FOLDED), something equivalent to the following should make the trick.
>>
>>      if (mm_pxx_folded())
>>          return;
>>
>>
>> For the __ARCH_HAS_5LEVEL_HACK stuff, I think we should be able to regroup all impacted functions inside a single #ifdef __ARCH_HAS_5LEVEL_HACK
> 
> I was wondering if it will be better to
> 
> 1) Minimize all #ifdefs in the code which might fail on some platforms
> 2) Restrict proposed test module to platforms where it builds and runs
> 3) Enable other platforms afterwards after fixing their build problems or other requirements

I understand that __ARCH_HAS_5LEVEL_HACK is an HACK as its name 
suggests, so you can't expect all platforms to go for an HACK. I think 
you can keep a single #ifdef __ARCH_HAS_5LEVEL_HACK / #else / #endif and 
put all relevant tests inside it.

For things like __PAGETABLE_PXX_FOLDED dependancies, I still think that 
they can all be replaced by a runtime test of mm_pxx_folded().

Can you try that and see what problem remains ?

> 
> Would that be a better approach instead ?
> 

Based on the above, that might be the approach to take, yes.

Christophe
