From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 27 Sep 2021 03:22:34 +0000
Subject: Re: [PATCH v2] ia64: don't do IA64_CMPXCHG_DEBUG without CONFIG_PRINTK
Message-Id: <20210927032234.GA20607@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210926171224.27019-1-rdunlap@infradead.org>
In-Reply-To: <20210926171224.27019-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[[PATCH v2] ia64: don't do IA64_CMPXCHG_DEBUG without CONFIG_PRINTK] On 26/09/2021 (Sun 10:12) Randy Dunlap wrote:

> When CONFIG_PRINTK is not set, the CMPXCHG_BUGCHECK() macro calls
> _printk(), but _printk() is a static inline function, not available
> as an extern.
> Since the purpose of the macro is to print the BUGCHECK info,
> make this config option depend on PRINTK.
> 
> Fixes multiple occurrences of this build error:
> 
> ../include/linux/printk.h:208:5: error: static declaration of '_printk' follows non-static declaration
>   208 | int _printk(const char *s, ...)
>       |     ^~~~~~~
> In file included from ../arch/ia64/include/asm/cmpxchg.h:5,
> ../arch/ia64/include/uapi/asm/cmpxchg.h:146:28: note: previous declaration of '_printk' with type 'int(const char *, ...)'
>   146 |                 extern int _printk(const char *fmt, ...);
> 
> Fixes: 85f8f7759e41 ("ia64: populate the cmpxchg header with appropriate code")

I don't think this fixes tag makes sense either as it was just a
straightforward code relocation.  As pointed out elsewhere, it will
probably be back even further where CONFIG_PRINTK was introduced, which
would be d59745ce3e7a (2005 vintage).  The ia64 debug option predates
git, so it isn't at fault (and you can't blame it anyway).

Honestly, realize this is just for a randconfig for ia64 where PRINTK is
disabled - something that will never be done in any of the remaining
ia64 deployments out there (if there is any).  So I'd just recommend
dropping the Fixes tag and move on.  It isn't like there is a lot of
people out there doing randconfig builds on linux-stable releases.

Paul.
--

> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: linux-ia64@vger.kernel.org
> Cc: Petr Mladek <pmladek@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Chris Down <chris@chrisdown.name>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
> ---
> v2: correct the Fixes: commit info
> 
>  arch/ia64/Kconfig.debug |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next-20210917.orig/arch/ia64/Kconfig.debug
> +++ linux-next-20210917/arch/ia64/Kconfig.debug
> @@ -39,7 +39,7 @@ config DISABLE_VHPT
>  
>  config IA64_DEBUG_CMPXCHG
>  	bool "Turn on compare-and-exchange bug checking (slow!)"
> -	depends on DEBUG_KERNEL
> +	depends on DEBUG_KERNEL && PRINTK
>  	help
>  	  Selecting this option turns on bug checking for the IA-64
>  	  compare-and-exchange instructions.  This is slow!  Itaniums
