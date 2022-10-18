From: WANG Xuerui <kernel@xen0n.name>
Date: Tue, 18 Oct 2022 09:20:19 +0000
Subject: Re: [PATCH] mm: remove kern_addr_valid() completely
Message-Id: <27ffa400-b947-7c83-0e79-c8eb9f96e12e@xen0n.name>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221018074014.185687-1-wangkefeng.wang@huawei.com>
In-Reply-To: <20221018074014.185687-1-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kefeng Wang <wangkefeng.wang@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-fsdevel@vger.kernel.org
Cc: Richard Henderson <richard.henderson@linaro.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Guo Ren <guoren@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Dinh Nguyen <dinguyen@kernel.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E . J . Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, Sven Schnelle <svens@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H . Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>

On 2022/10/18 15:40, Kefeng Wang wrote:
> Most architectures(except arm64/x86/sparc) simply return 1 for

one space before the opening parens

> kern_addr_valid(), which is only used in read_kcore(), and it
> calls copy_from_kernel_nofault() which could check whether the
> address is a valid kernel address, so no need kern_addr_valid(),

minor grammatical nit:

"... which already checks whether the address is a valid kernel address. 
So kern_addr_valid is unnecessary, let's remove it."

> let's remove unneeded kern_addr_valid() completely.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> ---
>   arch/alpha/include/asm/pgtable.h          |  2 -
>   arch/arc/include/asm/pgtable-bits-arcv2.h |  2 -
>   arch/arm/include/asm/pgtable-nommu.h      |  2 -
>   arch/arm/include/asm/pgtable.h            |  4 --
>   arch/arm64/include/asm/pgtable.h          |  2 -
>   arch/arm64/mm/mmu.c                       | 47 -----------------------
>   arch/arm64/mm/pageattr.c                  |  3 +-
>   arch/csky/include/asm/pgtable.h           |  3 --
>   arch/hexagon/include/asm/page.h           |  7 ----
>   arch/ia64/include/asm/pgtable.h           | 16 --------
>   arch/loongarch/include/asm/pgtable.h      |  2 -
>   arch/m68k/include/asm/pgtable_mm.h        |  2 -
>   arch/m68k/include/asm/pgtable_no.h        |  1 -
>   arch/microblaze/include/asm/pgtable.h     |  3 --
>   arch/mips/include/asm/pgtable.h           |  2 -
>   arch/nios2/include/asm/pgtable.h          |  2 -
>   arch/openrisc/include/asm/pgtable.h       |  2 -
>   arch/parisc/include/asm/pgtable.h         | 15 --------
>   arch/powerpc/include/asm/pgtable.h        |  7 ----
>   arch/riscv/include/asm/pgtable.h          |  2 -
>   arch/s390/include/asm/pgtable.h           |  2 -
>   arch/sh/include/asm/pgtable.h             |  2 -
>   arch/sparc/include/asm/pgtable_32.h       |  6 ---
>   arch/sparc/mm/init_32.c                   |  3 +-
>   arch/sparc/mm/init_64.c                   |  1 -
>   arch/um/include/asm/pgtable.h             |  2 -
>   arch/x86/include/asm/pgtable_32.h         |  9 -----
>   arch/x86/include/asm/pgtable_64.h         |  1 -
>   arch/x86/mm/init_64.c                     | 41 --------------------
>   arch/xtensa/include/asm/pgtable.h         |  2 -
>   fs/proc/kcore.c                           | 26 +++++--------
>   31 files changed, 11 insertions(+), 210 deletions(-)
> 
> diff --git a/arch/loongarch/include/asm/pgtable.h b/arch/loongarch/include/asm/pgtable.h
> index 946704bee599..fc70b7041b76 100644
> --- a/arch/loongarch/include/asm/pgtable.h
> +++ b/arch/loongarch/include/asm/pgtable.h
> @@ -421,8 +421,6 @@ static inline void update_mmu_cache_pmd(struct vm_area_struct *vma,
>   	__update_tlb(vma, address, (pte_t *)pmdp);
>   }
>   
> -#define kern_addr_valid(addr)	(1)
> -
>   static inline unsigned long pmd_pfn(pmd_t pmd)
>   {
>   	return (pmd_val(pmd) & _PFN_MASK) >> _PFN_SHIFT;

Acked-by: WANG Xuerui <git@xen0n.name> # loongarch

Thanks!

-- 
WANG "xen0n" Xuerui

Linux/LoongArch mailing list: https://lore.kernel.org/loongarch/
