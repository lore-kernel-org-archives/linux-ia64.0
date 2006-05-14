From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 14 May 2006 19:13:05 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64-2.patch added to -mm tree
Message-Id: <1147633985.2551.14.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2006-05-14 at 11:01 -0700, akpm@osdl.org wrote:
> 
> diff -puN include/asm-ia64/page.h~git-hdrcleanup-vs-git-klibc-on-ia64-2 include/asm-ia64/page.h
> --- 25/include/asm-ia64/page.h~git-hdrcleanup-vs-git-klibc-on-ia64-2    Mon May 15 01:48:22 2006
> +++ 25-akpm/include/asm-ia64/page.h     Mon May 15 01:49:38 2006
> @@ -36,7 +36,11 @@
>  #elif defined(CONFIG_IA64_PAGE_SIZE_64KB)
>  # define PAGE_SHIFT    16
>  #else
> +#ifdef __KERNEL__
>  # error Unsupported page size!
> +#else
> +#define PAGE_SHIFT     12
> +#endif
>  #endif
>  
>  #define PAGE_SIZE              (__IA64_UL_CONST(1) << PAGE_SHIFT)

Hm, same applies here as to the last one. The __KERNEL__ ifdef applies
to the whole crap around PAGE_SHIFT _and_ PAGE_SIZE, at least. 

In the long term I think we want to drop page.h and elf.h from the list
of files which are exported to userspace altogether. Either way, it's
complicated so I was leaving them until later, after the first round of
_simple_ cleanups was in. This failure is purely due to the removal of
config.h, which is automatically included in kernel builds but evidently
not klibc...

-- 
dwmw2

