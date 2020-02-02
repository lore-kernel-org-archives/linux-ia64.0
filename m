From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Sun, 02 Feb 2020 08:38:04 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <eecaf6d6-66d2-1c17-ce02-74ed399fc58e@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1580174873-18117-1-git-send-email-anshuman.khandual@arm.com>
 <68ed6488-aa25-ab41-8da6-f0ddeb15d52b@c-s.fr>
 <49754f74-53a7-0e4a-bb16-53617f8c902c@arm.com>
In-Reply-To: <49754f74-53a7-0e4a-bb16-53617f8c902c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 01/30/2020 06:34 PM, Anshuman Khandual wrote:
> On 01/28/2020 10:35 PM, Christophe Leroy wrote:
>>
>> Le 28/01/2020 à 02:27, Anshuman Khandual a écrit :
>>> This adds tests which will validate architecture page table helpers and
>>> other accessors in their compliance with expected generic MM semantics.
>>> This will help various architectures in validating changes to existing
>>> page table helpers or addition of new ones.
>>>
>>> This test covers basic page table entry transformations including but not
>>> limited to old, young, dirty, clean, write, write protect etc at various
>>> level along with populating intermediate entries with next page table page
>>> and validating them.
>>>
>>> Test page table pages are allocated from system memory with required size
>>> and alignments. The mapped pfns at page table levels are derived from a
>>> real pfn representing a valid kernel text symbol. This test gets called
>>> right after page_alloc_init_late().
>>>
>>> This gets build and run when CONFIG_DEBUG_VM_PGTABLE is selected along with
>>> CONFIG_VM_DEBUG. Architectures willing to subscribe this test also need to
>>> select CONFIG_ARCH_HAS_DEBUG_VM_PGTABLE which for now is limited to x86 and
>>> arm64. Going forward, other architectures too can enable this after fixing
>>> build or runtime problems (if any) with their page table helpers.
>>>
>>> Folks interested in making sure that a given platform's page table helpers
>>> conform to expected generic MM semantics should enable the above config
>>> which will just trigger this test during boot. Any non conformity here will
>>> be reported as an warning which would need to be fixed. This test will help
>>> catch any changes to the agreed upon semantics expected from generic MM and
>>> enable platforms to accommodate it thereafter.
>>>
>> [...]
>>
>>> Tested-by: Christophe Leroy <christophe.leroy@c-s.fr>        #PPC32
>> Also tested on PPC64 (under QEMU): book3s/64 64k pages, book3s/64 4k pages and book3e/64
> Hmm but earlier Michael Ellerman had reported some problems while
> running these tests on PPC64, a soft lock up in hash__pte_update()
> and a kernel BUG (radix MMU). Are those problems gone away now ?
> 
> Details in this thread - https://patchwork.kernel.org/patch/11214603/
> 

It is always better to have more platforms enabled than not. But lets keep
this test disabled on PPC64 for now, if there is any inconsistency between
results while running this under QEMU and on actual systems.
