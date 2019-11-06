From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Wed, 06 Nov 2019 07:46:20 +0000
Subject: Re: [PATCH V8] mm/debug: Add tests validating architecture page table helpers
Message-Id: <0e0c2ce9-636d-1153-2451-baf7317ed45f@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1572240562-23630-1-git-send-email-anshuman.khandual@arm.com>
 <3229d68d-0b9d-0719-3370-c6e1df0ea032@arm.com>
 <42160baa-0e9d-73d0-bf72-58bdbacf10ff@c-s.fr>
In-Reply-To: <42160baa-0e9d-73d0-bf72-58bdbacf10ff@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 11/06/2019 12:11 PM, Christophe Leroy wrote:
> 
> 
> Le 06/11/2019 à 04:22, Anshuman Khandual a écrit :
>>
>>
>> On 10/28/2019 10:59 AM, Anshuman Khandual wrote:
>>> +    -----------------------
>>> +    |         arch |status|
>>> +    -----------------------
>>> +    |       alpha: | TODO |
>>> +    |         arc: | TODO |
>>> +    |         arm: | TODO |
>>> +    |       arm64: |  ok  |
>>> +    |         c6x: | TODO |
>>> +    |        csky: | TODO |
>>> +    |       h8300: | TODO |
>>> +    |     hexagon: | TODO |
>>> +    |        ia64: | TODO |
>>> +    |        m68k: | TODO |
>>> +    |  microblaze: | TODO |
>>> +    |        mips: | TODO |
>>> +    |       nds32: | TODO |
>>> +    |       nios2: | TODO |
>>> +    |    openrisc: | TODO |
>>> +    |      parisc: | TODO |
>>> +    |     powerpc: | TODO |
>>> +    |       ppc32: |  ok  |
> 
> Note that ppc32 is a part of powerpc, not a standalone arch.

Right, I understand. But we are yet to hear about how this test
came about on powerpc server platforms. Will update 'powerpc'
arch listing above once we get some confirmation. May be once
this works on all relevant powerpc platforms, we can just merge
'powerpc' and 'ppc32' entries here as just 'powerpc'.

> 
> Maybe something like the following would be more correct:
> |  powerpc/32: |  ok  |
> |  powerpc/64: | TODO |
> 
> Christophe
> 
>>> +    |       riscv: | TODO |
>>> +    |        s390: | TODO |
>>> +    |          sh: | TODO |
>>> +    |       sparc: | TODO |
>>> +    |          um: | TODO |
>>> +    |   unicore32: | TODO |
>>> +    |         x86: |  ok  |
>>> +    |      xtensa: | TODO |
>>> +    -----------------------
>>
>> While here, are there some volunteers to test this on any of the
>> 'yet to be tested and supported' platforms ?
>>
>> - Anshuman
>>
> 
