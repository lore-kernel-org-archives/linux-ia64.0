From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Fri, 18 Jan 2019 08:43:02 +0000
Subject: Re: [PATCH 19/21] treewide: add checks for the return value of memblock_alloc*()
Message-Id: <20190118084302.GA4160@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
 <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1547646261-32535-20-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, devicetree@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org, linux-mips@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Richard Weinberger <richard@nod.at>, linux-sh@vger.kernel.org, Russell King <linux@armlinux.org.uk>, kasan-dev@googlegroups.com, Geert Uytterhoeven <geert@linux-m68k.org>, Mark Salter <msalter@redhat.com>, Dennis Zhou <dennis@kernel.org>, Matt Turner <mattst88@gmail.com>, linux-snps-arc@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, Petr Mladek <pmladek@suse.com>, linux-xtensa@linux-xtensa.org, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, Rob Herring <robh+dt@kernel.org>, Greentime Hu <green.hu@gmail.com>, xen-devel@lists.xenproject.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Burton <paul.burton@mips.com>, Vineet Gupta <vgupta@synopsys.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, openrisc@lists.librecores.org

On Wed, Jan 16, 2019 at 03:44:19PM +0200, Mike Rapoport wrote:
> Add check for the return value of memblock_alloc*() functions and call
> panic() in case of error.
> The panic message repeats the one used by panicing memblock allocators with
> adjustment of parameters to include only relevant ones.
> 
> The replacement was mostly automated with semantic patches like the one
> below with manual massaging of format strings.
> 
> @@
> expression ptr, size, align;
> @@
> ptr = memblock_alloc(size, align);
> + if (!ptr)
> + 	panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
> size, align);
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
...
> diff --git a/arch/s390/numa/toptree.c b/arch/s390/numa/toptree.c
> index 71a608c..0118c77 100644
> --- a/arch/s390/numa/toptree.c
> +++ b/arch/s390/numa/toptree.c
> @@ -31,10 +31,14 @@ struct toptree __ref *toptree_alloc(int level, int id)
>  {
>  	struct toptree *res;
> 
> -	if (slab_is_available())
> +	if (slab_is_available()) {
>  		res = kzalloc(sizeof(*res), GFP_KERNEL);
> -	else
> +	} else {
>  		res = memblock_alloc(sizeof(*res), 8);
> +		if (!res)
> +			panic("%s: Failed to allocate %zu bytes align=0x%x\n",
> +			      __func__, sizeof(*res), 8);
> +	}
>  	if (!res)
>  		return res;

Please remove this hunk, since the code _should_ be able to handle
allocation failures anyway (see end of quoted code).

Otherwise for the s390 bits:
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
