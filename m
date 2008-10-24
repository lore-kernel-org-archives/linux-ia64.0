From: Len Brown <lenb@kernel.org>
Date: Fri, 24 Oct 2008 19:25:20 +0000
Subject: Re: [PATCH] ACPI: cpufreq,
Message-Id: <alpine.LFD.1.10.0810241524590.3056@localhost.localdomain>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary_(ID_c2v0sdjgLm3jZ9/jR7fKOg)"
List-Id: <linux-ia64.vger.kernel.org>
References: <490193BC.70108@cn.fujitsu.com>
In-Reply-To: <490193BC.70108@cn.fujitsu.com>
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: linux-acpi@vger.kernel.org, trenn@suse.de, linux-ia64@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--Boundary_(ID_c2v0sdjgLm3jZ9/jR7fKOg)
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit

applied.
thanks,
-len

On Fri, 24 Oct 2008, Miao Xie wrote:

> When trying to build 2.6.28-rc1 on ia64, make aborts with:
> 
>   CC      drivers/acpi/processor_perflib.o
>   drivers/acpi/processor_perflib.c:41:28: error: asm/cpufeature.h: No such file or directory
>   drivers/acpi/processor_perflib.c: In function ‘acpi_processor_get_performance_info’:
>   drivers/acpi/processor_perflib.c:364: error: implicit declaration of function ‘boot_cpu_has’
>   drivers/acpi/processor_perflib.c:364: error: ‘X86_FEATURE_EST’ undeclared (first use in this function)
>   drivers/acpi/processor_perflib.c:364: error: (Each undeclared identifier is reported only once
>   drivers/acpi/processor_perflib.c:364: error: for each function it appears in.)
>   make[2]: *** [drivers/acpi/processor_perflib.o] Error 1
>   make[1]: *** [drivers/acpi] Error 2
>   make: *** [drivers] Error 2
> 
> this patch fix it.
> 
> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
> Cc: Thomas Renninger <trenn@suse.de>
> 
> ---
>  drivers/acpi/processor_perflib.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/acpi/processor_perflib.c b/drivers/acpi/processor_perflib.c
> index dc98f7a..dbcf260 100644
> --- a/drivers/acpi/processor_perflib.c
> +++ b/drivers/acpi/processor_perflib.c
> @@ -38,7 +38,10 @@
>  
>  #include <asm/uaccess.h>
>  #endif
> +
> +#ifdef CONFIG_X86
>  #include <asm/cpufeature.h>
> +#endif
>  
>  #include <acpi/acpi_bus.h>
>  #include <acpi/processor.h>
> @@ -360,11 +363,13 @@ static int acpi_processor_get_performance_info(struct acpi_processor *pr)
>  	 * the BIOS is older than the CPU and does not know its frequencies
>  	 */
>   update_bios:
> +#ifdef CONFIG_X86
>  	if (ACPI_SUCCESS(acpi_get_handle(pr->handle, "_PPC", &handle))){
>  		if(boot_cpu_has(X86_FEATURE_EST))
>  			printk(KERN_WARNING FW_BUG "BIOS needs update for CPU "
>  			       "frequency support\n");
>  	}
> +#endif
>  	return result;
>  }
>  
> -- 
> 1.5.4.rc3
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--Boundary_(ID_c2v0sdjgLm3jZ9/jR7fKOg)--
