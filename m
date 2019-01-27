From: Stafford Horne <shorne@gmail.com>
Date: Sun, 27 Jan 2019 03:07:08 +0000
Subject: Re: [PATCH v2 01/21] openrisc: prefer memblock APIs returning virtual address
Message-Id: <20190127030708.GU3235@lianli.shorne-pla.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-2-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1548057848-15136-2-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

On Mon, Jan 21, 2019 at 10:03:48AM +0200, Mike Rapoport wrote:
> The allocation of the page tables memory in openrics uses
> memblock_phys_alloc() and then converts the returned physical address to
> virtual one. Use memblock_alloc_raw() and add a panic() if the allocation
> fails.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/openrisc/mm/init.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
> index d157310..caeb418 100644
> --- a/arch/openrisc/mm/init.c
> +++ b/arch/openrisc/mm/init.c
> @@ -105,7 +105,10 @@ static void __init map_ram(void)
>  			}
>  
>  			/* Alloc one page for holding PTE's... */
> -			pte = (pte_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
> +			pte = memblock_alloc_raw(PAGE_SIZE, PAGE_SIZE);
> +			if (!pte)
> +				panic("%s: Failed to allocate page for PTEs\n",
> +				      __func__);
>  			set_pmd(pme, __pmd(_KERNPG_TABLE + __pa(pte)));
>  
>  			/* Fill the newly allocated page with PTE'S */

This seems reasonable to me.

Acked-by: Stafford Horne <shorne@gmail.com>
