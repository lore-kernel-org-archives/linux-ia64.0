From: Guo Ren <guoren@kernel.org>
Date: Thu, 17 Jan 2019 07:06:03 +0000
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of memblock_alloc*()
Message-Id: <20190117070602.GA31839@guoren-Inspiron-7460>
List-Id: <linux-ia64.vger.kernel.org>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

On Wed, Jan 16, 2019 at 03:44:19PM +0200, Mike Rapoport wrote:
>  arch/csky/mm/highmem.c                    |  5 +++++
...
> diff --git a/arch/csky/mm/highmem.c b/arch/csky/mm/highmem.c
> index 53b1bfa..3317b774 100644
> --- a/arch/csky/mm/highmem.c
> +++ b/arch/csky/mm/highmem.c
> @@ -141,6 +141,11 @@ static void __init fixrange_init(unsigned long start, unsigned long end,
>  			for (; (k < PTRS_PER_PMD) && (vaddr != end); pmd++, k++) {
>  				if (pmd_none(*pmd)) {
>  					pte = (pte_t *) memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
> +					if (!pte)
> +						panic("%s: Failed to allocate %lu bytes align=%lx\n",
> +						      __func__, PAGE_SIZE,
> +						      PAGE_SIZE);
> +
>  					set_pmd(pmd, __pmd(__pa(pte)));
>  					BUG_ON(pte != pte_offset_kernel(pmd, 0));
>  				}

Looks good for me and panic is ok.

Reviewed-by: Guo Ren <ren_guo@c-sky.com>
