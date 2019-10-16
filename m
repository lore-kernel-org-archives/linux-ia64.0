From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Wed, 16 Oct 2019 09:54:31 +0000
Subject: Re: [PATCH V6 2/2] mm/debug: Add tests validating architecture page table helpers
Message-Id: <7cd03155-6713-3116-1e88-f81f84dd794f@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1571131302-32290-1-git-send-email-anshuman.khandual@arm.com>
 <1571131302-32290-3-git-send-email-anshuman.khandual@arm.com>
 <1571162982.5937.42.camel@lca.pw>
In-Reply-To: <1571162982.5937.42.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Qian Cai <cai@lca.pw>, linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, James Hogan <jhogan@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Paul Mackerras <paulus@samba.org>, sparclinux@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, Russell King - ARM Linux <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>, Steven Price <Steven.Price@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Mark Brown <broonie@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christophe Leroy <christophe.leroy@c-s.fr>, Sri Krishna chowdary <schowdary@nvidia.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mips@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>



On 10/15/2019 11:39 PM, Qian Cai wrote:
> On Tue, 2019-10-15 at 14:51 +0530, Anshuman Khandual wrote:
>> +static unsigned long __init get_random_vaddr(void)
>> +{
>> +	unsigned long random_vaddr, random_pages, total_user_pages;
>> +
>> +	total_user_pages = (TASK_SIZE - FIRST_USER_ADDRESS) / PAGE_SIZE;
>> +
>> +	random_pages = get_random_long() % total_user_pages;
>> +	random_vaddr = FIRST_USER_ADDRESS + random_pages * PAGE_SIZE;
>> +
>> +	WARN_ON(random_vaddr > TASK_SIZE);
>> +	WARN_ON(random_vaddr < FIRST_USER_ADDRESS);
> 
> It would be nice if this patch does not introduce a new W=1 GCC warning here on
> x86 because FIRST_USER_ADDRESS is 0, and GCC think the code is dumb because
> "random_vaddr" is unsigned,
> 
> In file included from ./arch/x86/include/asm/bug.h:83,
>                  from ./include/linux/bug.h:5,
>                  from ./include/linux/mmdebug.h:5,
>                  from ./include/linux/gfp.h:5,
>                  from mm/debug_vm_pgtable.c:13:
> mm/debug_vm_pgtable.c: In function ‘get_random_vaddr’:
> mm/debug_vm_pgtable.c:359:23: warning: comparison of unsigned expression < 0 is
> always false [-Wtype-limits]
>   WARN_ON(random_vaddr < FIRST_USER_ADDRESS);
>                        ^
> ./include/asm-generic/bug.h:113:25: note: in definition of macro ‘WARN_ON’
>   int __ret_warn_on = !!(condition);    \
>                          ^~~~~~~~~

The test checks against an erroneous unsigned long overflow when
FIRST_USER_ADDRESS is not 0 but a positive number. Wondering if
the compiler will still complain if we merge both the WARN_ON()
checks as || on a single statement.
