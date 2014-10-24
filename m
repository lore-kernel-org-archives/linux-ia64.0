From: James Hogan <james.hogan@imgtec.com>
Date: Fri, 24 Oct 2014 09:47:03 +0000
Subject: Re: [PATCH v2 08/47] kernel: Move pm_power_off to common code
Message-Id: <544A2017.7020804@imgtec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413864783-3271-1-git-send-email-linux@roeck-us.net>
 <1413864783-3271-9-git-send-email-linux@roeck-us.net>
In-Reply-To: <1413864783-3271-9-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Hi Guenter,

On 21/10/14 05:12, Guenter Roeck wrote:
> pm_power_off is defined for all architectures. Move it to common code.
> 
> Have all architectures call do_kernel_power_off instead of pm_power_off.
> Some architectures point pm_power_off to machine_power_off. For those,
> call do_kernel_power_off from machine_power_off instead.
> 
> Acked-by: David Vrabel <david.vrabel@citrix.com>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Hirokazu Takata <takata@linux-m32r.org>
> Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>
> Acked-by: Max Filippov <jcmvbkbc@gmail.com>
> Acked-by: Rafael J. Wysocki <rjw@rjwysocki.net>
> Acked-by: Richard Weinberger <richard@nod.at>
> Acked-by: Xuetao Guan <gxt@mprc.pku.edu.cn>

For metag:
Acked-by: James Hogan <james.hogan@imgtec.com>

Thanks
James

> diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
> index 483dff9..8d95773 100644
> --- a/arch/metag/kernel/process.c
> +++ b/arch/metag/kernel/process.c
> @@ -67,9 +67,6 @@ void arch_cpu_idle_dead(void)
>  }
>  #endif
>  
> -void (*pm_power_off)(void);
> -EXPORT_SYMBOL(pm_power_off);
> -
>  void (*soc_restart)(char *cmd);
>  void (*soc_halt)(void);
>  
> @@ -90,8 +87,7 @@ void machine_halt(void)
>  
>  void machine_power_off(void)
>  {
> -	if (pm_power_off)
> -		pm_power_off();
> +	do_kernel_power_off();
>  	smp_send_stop();
>  	hard_processor_halt(HALT_OK);
>  }
