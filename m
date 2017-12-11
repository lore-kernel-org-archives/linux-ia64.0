From: Borislav Petkov <bp@alien8.de>
Date: Mon, 11 Dec 2017 17:45:00 +0000
Subject: Re: [PATCH 08/13] x86: do not use print_symbol()
Message-Id: <20171211174459.l2ugmyi6kcr33zxp@pd.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20171211125025.2270-9-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-9-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Mon, Dec 11, 2017 at 09:50:20PM +0900, Sergey Senozhatsky wrote:
> print_symbol() uses extra stack space to sprintf() symbol
> information and then to feed that buffer to printk()
> 
>   char buffer[KSYM_SYMBOL_LEN];
> 
>   sprint_symbol(buffer, address);
>   printk(fmt, buffer);
> 
> Replace print_symbol() with a direct printk("%pS") call.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/kernel/cpu/mcheck/mce.c | 3 +--
>  arch/x86/mm/mmio-mod.c           | 5 ++---
>  2 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
> index b1d616d08eee..8ca8f6eb32db 100644
> --- a/arch/x86/kernel/cpu/mcheck/mce.c
> +++ b/arch/x86/kernel/cpu/mcheck/mce.c
> @@ -14,7 +14,6 @@
>  #include <linux/capability.h>
>  #include <linux/miscdevice.h>
>  #include <linux/ratelimit.h>
> -#include <linux/kallsyms.h>
>  #include <linux/rcupdate.h>
>  #include <linux/kobject.h>
>  #include <linux/uaccess.h>
> @@ -235,7 +234,7 @@ static void __print_mce(struct mce *m)
>  			m->cs, m->ip);
>  
>  		if (m->cs = __KERNEL_CS)
> -			print_symbol("{%s}", m->ip);
> +			pr_cont("{%pS}", (void *)m->ip);
>  		pr_cont("\n");
>  	}
>  

For the mce.c bit above:

Acked-by: Borislav Petkov <bp@suse.de>

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
