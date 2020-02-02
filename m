From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Sun, 02 Feb 2020 08:31:18 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <e1e046d7-bf1d-eaec-1d0b-fe056b83b84c@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1580174873-18117-1-git-send-email-anshuman.khandual@arm.com>
 <68ed6488-aa25-ab41-8da6-f0ddeb15d52b@c-s.fr>
 <49754f74-53a7-0e4a-bb16-53617f8c902c@arm.com>
 <473d8198-3ac4-af3b-e2ec-c0698a3565d3@c-s.fr>
 <ad5ad414-3524-2efa-df16-1ee357e6e2e4@arm.com>
In-Reply-To: <ad5ad414-3524-2efa-df16-1ee357e6e2e4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



Le 02/02/2020 à 08:18, Anshuman Khandual a écrit :
> On 01/30/2020 07:43 PM, Christophe Leroy wrote:
>>
>>
>> Le 30/01/2020 à 14:04, Anshuman Khandual a écrit :
>>>
>>> On 01/28/2020 10:35 PM, Christophe Leroy wrote:
>>
>>>
>>>> I think we could make it standalone and 'default y if DEBUG_VM' instead.
>>>
>>> Which will yield the same result like before but in a different way. But
>>> yes, this test could go about either way but unless there is a good enough
>>> reason why change the current one.
>>
>> I think if we want people to really use it on other architectures it must be possible to activate it without having to modify Kconfig. Otherwise people won't even know the test exists and the architecture fails the test.
>>
>> The purpose of a test suite is to detect bugs. If you can't run the test until you have fixed the bugs, I guess nobody will ever detect the bugs and they will never be fixed.
>>
>> So I think:
>> - the test should be 'default y' when ARCH_HAS_DEBUG_VM_PGTABLE is selected
>> - the test should be 'default n' when ARCH_HAS_DEBUG_VM_PGTABLE is not selected, and it should be user selectable if EXPERT is selected.
>>
>> Something like:
>>
>> config DEBUG_VM_PGTABLE
>>      bool "Debug arch page table for semantics compliance" if ARCH_HAS_DEBUG_VM_PGTABLE || EXPERT
>>      depends on MMU
> 
> (ARCH_HAS_DEBUG_VM_PGTABLE || EXPERT) be moved along side MMU on the same line ?

Yes could also go along side MMU, or could be a depend by itself:
	depends on ARCH_HAS_DEBUG_VM_PGTABLE || EXPERT

> 
>>      default 'n' if !ARCH_HAS_DEBUG_VM_PGTABLE
>>      default 'y' if DEBUG_VM
> 
> This looks good, at least until we get all platforms enabled. Will do all these
> changes along with s390 enablement and re-spin.

Christophe
