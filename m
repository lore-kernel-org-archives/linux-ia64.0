From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 18 Nov 2021 10:43:02 +0000
Subject: Re: [PATCH] ia64: module: use swap() to make code cleaner
Message-Id: <da752ffc-1694-d76b-cd65-ebbbec11b8ea@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20211118062002.164121-1-yao.jing2@zte.com.cn>
In-Reply-To: <20211118062002.164121-1-yao.jing2@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: cgel.zte@gmail.com, akpm@linux-foundation.org
Cc: slyfox@gentoo.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Yao Jing <yao.jing2@zte.com.cn>, Zeal Robot <zealci@zte.com.cn>

Hi!

On 11/18/21 07:20, cgel.zte@gmail.com wrote:
> From: Yao Jing <yao.jing2@zte.com.cn>
> 
> Use the macro 'swap()' defined in 'include/linux/minmax.h' to avoid
> opencoding it.
> 
> Reported-by: Zeal Robot <zealci@zte.com.cn>
> Signed-off-by: Yao Jing <yao.jing2@zte.com.cn>
> ---
>  arch/ia64/kernel/module.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/ia64/kernel/module.c b/arch/ia64/kernel/module.c
> index 2cba53c1da82..360f36b0eb3f 100644
> --- a/arch/ia64/kernel/module.c
> +++ b/arch/ia64/kernel/module.c
> @@ -848,7 +848,7 @@ register_unwind_table (struct module *mod)
>  {
>  	struct unw_table_entry *start = (void *) mod->arch.unwind->sh_addr;
>  	struct unw_table_entry *end = start + mod->arch.unwind->sh_size / sizeof (*start);
> -	struct unw_table_entry tmp, *e1, *e2, *core, *init;
> +	struct unw_table_entry *e1, *e2, *core, *init;
>  	unsigned long num_init = 0, num_core = 0;
>  
>  	/* First, count how many init and core unwind-table entries there are.  */
> @@ -865,9 +865,7 @@ register_unwind_table (struct module *mod)
>  	for (e1 = start; e1 < end; ++e1) {
>  		for (e2 = e1 + 1; e2 < end; ++e2) {
>  			if (e2->start_offset < e1->start_offset) {
> -				tmp = *e1;
> -				*e1 = *e2;
> -				*e2 = tmp;
> +				swap(*e1, *e2);
>  			}
>  		}
>  	}

I will test this patch later this week.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
