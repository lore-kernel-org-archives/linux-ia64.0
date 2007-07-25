From: Horms <horms@verge.net.au>
Date: Wed, 25 Jul 2007 07:17:19 +0000
Subject: Re: Regression in serial console on ia64 after 2.6.22
Message-Id: <20070725071718.GB18068@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070719074147.GA23879@verge.net.au> <46A0191E.3000100@sun.com> <200707241657.33095.yinghai.lu@sun.com>
In-Reply-To: <200707241657.33095.yinghai.lu@sun.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Bjorn Helgaas <bjorn.helgaas@hp.com>, Russell King <rmk@arm.linux.org.uk>, Gerd Hoffmann <kraxel@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

On Tue, Jul 24, 2007 at 04:57:32PM -0700, Yinghai Lu wrote:
> 
> IA64
> 
> Subject         : Regression in serial console on ia64 after 2.6.22
> References      : http://marc.info/?l=linux-ia64&m8483645914066&w=2
> Last known good : ?
> Submitter       : Horms <horms@verge.net.au>
> Caused-By       : Yinghai Lu <Yinghai.Lu@Sun.COM>
>                   commit 18a8bd949d6adb311ea816125ff65050df1f3f6e
> Handled-By      : ?
> Status          : unknown
> 
> 
> please test this patch.
> 
> YH

I just posted a similar patch (sorry, I didn't see your post until
afterwards). I guess that we both have the same ideas :)

> 
> 
> [PATCH] ia64: move machvec_init before parse_early_param
> 
> So ia64_mv is initialized before early console
> 
> Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
> 
> diff --git a/arch/ia64/kernel/machvec.c b/arch/ia64/kernel/machvec.c
> index 13df337..a94feaa 100644
> --- a/arch/ia64/kernel/machvec.c
> +++ b/arch/ia64/kernel/machvec.c
> @@ -14,12 +14,6 @@ struct ia64_machine_vector ia64_mv;
>  EXPORT_SYMBOL(ia64_mv);
>  
>  static __initdata const char *mvec_name;
> -static __init int setup_mvec(char *s)
> -{
> -	mvec_name = s;
> -	return 0;
> -}
> -early_param("machvec", setup_mvec);
>  
>  static struct ia64_machine_vector * __init
>  lookup_machvec (const char *name)
> @@ -42,6 +36,10 @@ machvec_init (const char *name)
>  
>  	if (!name)
>  		name = mvec_name ? mvec_name : acpi_get_sysname();

I think that mvec_name can be disposed of all together as
its only used by the line above and setup_mvec(), which in
turn is only used by early_param. I got rid of mvec_name in
my incantation of this patch, and it seemed to work quite well.

> +
> +	if (!mvec_name)
> +		mvec_name = name;
> +
>  	mv = lookup_machvec(name);
>  	if (!mv)
>  		panic("generic kernel failed to find machine vector for"
> diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> index cf06fe7..b06d7b7 100644
> --- a/arch/ia64/kernel/setup.c
> +++ b/arch/ia64/kernel/setup.c
> @@ -481,6 +481,9 @@ int __init reserve_elfcorehdr(unsigned long *start, unsigned long *end)
>  void __init
>  setup_arch (char **cmdline_p)
>  {
> +#ifdef CONFIG_IA64_GENERIC
> +	char *mvstr;
> +#endif
>  	unw_init();
>  
>  	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
> @@ -491,12 +494,15 @@ setup_arch (char **cmdline_p)
>  	efi_init();
>  	io_port_init();
>  
> -	parse_early_param();
> -
>  #ifdef CONFIG_IA64_GENERIC
> -	machvec_init(NULL);
> +	mvstr = strstr(*cmd_line_p, "machvec=")
> +	if (mvstr)
> +		mvstr = strchr(mvstr, '=') + 1;
> +	machvec_init(mvstr);
>  #endif

Do you need to copy and truncate mvstr on ' ' in the case
that machvec= isn't the last argument on the command line?
I did this in my patch, though I didn't test to see if
it was uneccessary.


>  
> +	parse_early_param();
> +
>  	if (early_console_setup(*cmdline_p) = 0)
>  		mark_bsp_online();
>  
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

