From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 04 Nov 2019 02:27:56 +0000
Subject: Re: [PATCH V8] mm/debug: Add tests validating architecture page table helpers
Message-Id: <fdb72ac1-5f21-bcf1-ebab-411f56e67b56@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1572240562-23630-1-git-send-email-anshuman.khandual@arm.com>
 <B6AAFA3F-745D-48E2-98CC-CFB30934CE39@lca.pw>
In-Reply-To: <B6AAFA3F-745D-48E2-98CC-CFB30934CE39@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qian Cai <cai@lca.pw>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 10/29/2019 04:01 PM, Qian Cai wrote:
> 
> 
>> On Oct 28, 2019, at 1:29 AM, Anshuman Khandual <Anshuman.Khandual@arm.com> wrote:
>>
>> This adds tests which will validate architecture page table helpers and
>> other accessors in their compliance with expected generic MM semantics.
>> This will help various architectures in validating changes to existing
>> page table helpers or addition of new ones.
>>
>> This test covers basic page table entry transformations including but not
>> limited to old, young, dirty, clean, write, write protect etc at various
>> level along with populating intermediate entries with next page table page
>> and validating them.
>>
>> Test page table pages are allocated from system memory with required size
>> and alignments. The mapped pfns at page table levels are derived from a
>> real pfn representing a valid kernel text symbol. This test gets called
>> right after page_alloc_init_late().
>>
>> This gets build and run when CONFIG_DEBUG_VM_PGTABLE is selected along with
>> CONFIG_VM_DEBUG. Architectures willing to subscribe this test also need to
>> select CONFIG_ARCH_HAS_DEBUG_VM_PGTABLE which for now is limited to x86 and
>> arm64. Going forward, other architectures too can enable this after fixing
>> build or runtime problems (if any) with their page table helpers.
>>
>> Folks interested in making sure that a given platform's page table helpers
>> conform to expected generic MM semantics should enable the above config
>> which will just trigger this test during boot. Any non conformity here will
>> be reported as an warning which would need to be fixed. This test will help
>> catch any changes to the agreed upon semantics expected from generic MM and
>> enable platforms to accommodate it thereafter.
> 
> This looks like a perfect candidate to streamline with the new kunit framework, no?

I have not been following the kunit test framework. But being highly dependent on
existing MM accessors (generic or platform) and very much page table modification
centric, mm/ is the best place for this test IMHO. It is now also part of DEBUG_VM
set of tests. Probably in future all existing MM tests (mm/ or lib/) might move to
kunit framework but for now it should remain with DEBUG_VM set of tests.
