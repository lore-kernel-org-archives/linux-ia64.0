From: Randy Dunlap <rdunlap@infradead.org>
Date: Wed, 28 Jul 2021 19:53:29 +0000
Subject: Re: [PATCH] arch: Kconfig: clean up obsolete use of HAVE_IDE
Message-Id: <0dcbd285-0fab-cc58-7f1a-013263f9cb45@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210728182115.4401-1-lukas.bulwahn@gmail.com>
In-Reply-To: <20210728182115.4401-1-lukas.bulwahn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lukas Bulwahn <lukas.bulwahn@gmail.com>, Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>
Cc: x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, uclinux-h8-devel@lists.sourceforge.jp, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 7/28/21 11:21 AM, Lukas Bulwahn wrote:
> The arch-specific Kconfig files use HAVE_IDE to indicate if IDE is
> supported.
> 
> As IDE support and the HAVE_IDE config vanishes with commit b7fb14d3ac63
> ("ide: remove the legacy ide driver"), there is no need to mention
> HAVE_IDE in all those arch-specific Kconfig files.
> 
> The issue was identified with ./scripts/checkkconfigsymbols.py.
> 
> Fixes: b7fb14d3ac63 ("ide: remove the legacy ide driver")
> Suggested-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
>  arch/alpha/Kconfig            | 1 -
>  arch/arm/Kconfig              | 6 ------
>  arch/arm/mach-davinci/Kconfig | 1 -
>  arch/h8300/Kconfig.cpu        | 1 -
>  arch/ia64/Kconfig             | 1 -
>  arch/m68k/Kconfig             | 1 -
>  arch/mips/Kconfig             | 1 -
>  arch/parisc/Kconfig           | 1 -
>  arch/powerpc/Kconfig          | 1 -
>  arch/sh/Kconfig               | 1 -
>  arch/sparc/Kconfig            | 1 -
>  arch/x86/Kconfig              | 1 -
>  arch/xtensa/Kconfig           | 1 -
>  13 files changed, 18 deletions(-)
> 


-- 
~Randy
