From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Tue, 28 Jan 2020 06:13:04 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <a7ba6d8a-6443-5994-6a34-2824aa9b054b@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1580174873-18117-1-git-send-email-anshuman.khandual@arm.com>
 <14882A91-17DE-4ABD-ABF2-08E7CCEDF660@lca.pw>
 <214c0d53-eb34-9b0c-2e4e-1aa005146331@arm.com>
 <016A776F-EFD9-4D2B-A3A9-788008617D95@lca.pw>
In-Reply-To: <016A776F-EFD9-4D2B-A3A9-788008617D95@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Qian Cai <cai@lca.pw>, Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



Le 28/01/2020 à 04:33, Qian Cai a écrit :
> 
> 
>> On Jan 27, 2020, at 10:06 PM, Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>
>>
>>
>> On 01/28/2020 07:41 AM, Qian Cai wrote:
>>>
>>>
>>>> On Jan 27, 2020, at 8:28 PM, Anshuman Khandual <Anshuman.Khandual@arm.com> wrote:
>>>>
>>>> This adds tests which will validate architecture page table helpers and
>>>> other accessors in their compliance with expected generic MM semantics.
>>>> This will help various architectures in validating changes to existing
>>>> page table helpers or addition of new ones.
>>>>
>>>> This test covers basic page table entry transformations including but not
>>>> limited to old, young, dirty, clean, write, write protect etc at various
>>>> level along with populating intermediate entries with next page table page
>>>> and validating them.
>>>>
>>>> Test page table pages are allocated from system memory with required size
>>>> and alignments. The mapped pfns at page table levels are derived from a
>>>> real pfn representing a valid kernel text symbol. This test gets called
>>>> right after page_alloc_init_late().
>>>>
>>>> This gets build and run when CONFIG_DEBUG_VM_PGTABLE is selected along with
>>>> CONFIG_VM_DEBUG. Architectures willing to subscribe this test also need to
>>>> select CONFIG_ARCH_HAS_DEBUG_VM_PGTABLE which for now is limited to x86 and
>>>> arm64. Going forward, other architectures too can enable this after fixing
>>>> build or runtime problems (if any) with their page table helpers.
>>
>> Hello Qian,
>>
>>>
>>> What’s the value of this block of new code? It only supports x86 and arm64
>>> which are supposed to be good now.
>>
>> We have been over the usefulness of this code many times before as the patch is
>> already in it's V12. Currently it is enabled on arm64, x86 (except PAE), arc and
>> ppc32. There are build time or runtime problems with other archs which prevent
> 
> I am not sure if I care too much about arc and ppc32 which are pretty much legacy
> platforms.
> 
>> enablement of this test (for the moment) but then the goal is to integrate all
>> of them going forward. The test not only validates platform's adherence to the
>> expected semantics from generic MM but also helps in keeping it that way during
>> code changes in future as well.
> 
> Another option maybe to get some decent arches on board first before merging this
> thing, so it have more changes to catch regressions for developers who might run this.
> 

ppc32 an indecent / legacy platform ? Are you kidying ?

Powerquicc II PRO for instance is fully supported by the manufacturer 
and widely used in many small networking devices.

Christophe
