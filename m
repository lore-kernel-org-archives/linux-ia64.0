From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 15 Mar 2004 16:59:39 +0000
Subject: Re: Compilation problem in arch/ia64/sn/kernel/setup.c
Message-Id: <20040315165939.GA1363@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <002b01c40a55$d5b392f0$39624c0f@india.hp.com>
In-Reply-To: <002b01c40a55$d5b392f0$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch looks fine, but I wonder if we really need CONFIG_IA64_MCA
anymore, does anyone really want to run without it?

Jesse

On Mon, Mar 15, 2004 at 11:52:03AM +0530, Sourav Sen wrote:
> Hello,
> 
> In arch/ia64/sn/kernel/setup.c in 2.6.4 + IA64 patch,
> the array, platform_intr_list[] is declared
> as:
> 
> #ifdef CONFIG_IA64_MCA
> extern int platform_intr_list[];
> #endif
> 
> but is used without that (CONFIG_IA64_MCA) guard.
> So, I have done the following to get around the
> compilation problem. Somebody knowledgeable on
> this will be able to validate if this is the
> right way.
> 
> regards
> Sourav
> 
> --- arch/ia64/sn/kernel/setup.c.orig    Mon Mar 15 05:58:30 2004
> +++ arch/ia64/sn/kernel/setup.c Mon Mar 15 05:59:14 2004
> @@ -311,7 +311,9 @@
>         else
>                 sn_rtc_cycles_per_second = ticks_per_sec;
>  
> +#ifdef CONFIG_IA64_MCA
>         platform_intr_list[ACPI_INTERRUPT_CPEI] = IA64_CPE_VECTOR;
> +#endif
>  
>  
>         if ( IS_RUNNING_ON_SIMULATOR() )
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
