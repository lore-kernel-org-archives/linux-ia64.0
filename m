From: Robin Holt <holt@sgi.com>
Date: Tue, 10 Feb 2009 12:51:57 +0000
Subject: Re: [PATCH 2/2] don't compile SGI XP/GRU on ia64_generic
Message-Id: <20090210125157.GT8577@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090210162821.6FC1.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210210110.7001.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20090210210110.7001.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jack Steiner <steiner@sgi.com>, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Dean Nelson <dcn@sgi.com>

Dean Nelson submitted a patch yesterday to make this work.

Robin


On Tue, Feb 10, 2009 at 09:03:40PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] ia64: don't compile SGI-XP on ia64 generic.
> Impact: fix build error
> 
> Currently sgi-xp driver depend on "uv.h" header file.
> but only x86 have "uv.h" header.
> 
> Then, ia64 hit following build error.
> 
>   In file included from drivers/misc/sgi-xp/xp_main.c:19:
>   drivers/misc/sgi-xp/xp.h:18:23: error: asm/uv/uv.h: No such file or directory
>   make[3]: *** [drivers/misc/sgi-xp/xp_main.o] Error 1
>   make[2]: *** [drivers/misc/sgi-xp] Error 2
> 
> Cc: Jack Steiner <steiner@sgi.com>
> Cc: Dean Nelson <dcn@sgi.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  drivers/misc/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: b/drivers/misc/Kconfig
> =================================> --- a/drivers/misc/Kconfig
> +++ b/drivers/misc/Kconfig
> @@ -162,7 +162,7 @@ config ENCLOSURE_SERVICES
>  config SGI_XP
>  	tristate "Support communication between SGI SSIs"
>  	depends on NET
> -	depends on (IA64_GENERIC || IA64_SGI_SN2 || IA64_SGI_UV || X86_UV) && SMP
> +	depends on (IA64_SGI_SN2 || IA64_SGI_UV || X86_UV) && SMP
>  	select IA64_UNCACHED_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
>  	select GENERIC_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
>  	select SGI_GRU if (IA64_SGI_UV || X86_UV) && SMP
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
