From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon, 03 Feb 2020 15:14:24 +0000
Subject: Re: [PATCH V12] mm/debug: Add tests validating architecture page table helpers
Message-Id: <8e94a073-4045-89aa-6a3b-24847ad7c858@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <473d8198-3ac4-af3b-e2ec-c0698a3565d3@c-s.fr>
 <2C4ADFAE-7BB4-42B7-8F54-F036EA7A4316@lca.pw>
In-Reply-To: <2C4ADFAE-7BB4-42B7-8F54-F036EA7A4316@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Qian Cai <cai@lca.pw>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, kasan-dev <kasan-dev@googlegroups.com>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Jason Gunthorpe <jgg@ziepe.ca>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Anshuman Khandual <Anshuman.Khandual@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-arm-kernel@lists.infradead.org, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave.hansen@intel.com>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



Le 02/02/2020 à 12:26, Qian Cai a écrit :
> 
> 
>> On Jan 30, 2020, at 9:13 AM, Christophe Leroy <christophe.leroy@c-s.fr> wrote:
>>
>> config DEBUG_VM_PGTABLE
>>     bool "Debug arch page table for semantics compliance" if ARCH_HAS_DEBUG_VM_PGTABLE || EXPERT
>>     depends on MMU
>>     default 'n' if !ARCH_HAS_DEBUG_VM_PGTABLE
>>     default 'y' if DEBUG_VM
> 
> Does it really necessary to potentially force all bots to run this? Syzbot, kernel test robot etc? Does it ever pay off for all their machine times there?
> 

Machine time ?

On a 32 bits powerpc running at 132 MHz, the tests takes less than 10ms. 
Is it worth taking the risk of not detecting faults by not selecting it 
by default ?

[    5.656916] debug_vm_pgtable: debug_vm_pgtable: Validating 
architecture page table helpers
[    5.665661] debug_vm_pgtable: debug_vm_pgtable: Validated 
architecture page table helpers

Christophe
