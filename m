From: alex_williamson@hp.com (Alex Williamson)
Date: Wed, 14 May 2003 15:32:53 +0000
Subject: Re: [Linux-ia64] runtime platform detection in GENERIC kernels
Message-Id: <marc-linux-ia64-105590723705792@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   Why not just make a runtime strcmp to platform_name?  Then
you could make a generic is_platform("sn2") type function/macro
that everyone could use and you'd get rid of that nasty init
function.  If you realy need to make such a check in a perfmance
path, it should probably be a machvec.  Thanks,

	Alex

> 
> Hello,
> 
> In the process of trying to get a GENERIC kernel running on SGI SN2
> hardware we've run into a few instances where knowing what type of
> machine we are running on is useful.  Would it be acceptable to make a
> macro such as is_sgi_sn2() to check this?
> 
> One of the specific situations is in console_init()
> (drivers/char/tty_io.c) where SN2 machines must use the sgi-l1_protocol
> driver and the rest of the IA64 machines just use the normal serial
> driver.  A small check was added:
> 
>         mac_scc_console_init();
>  #elif defined(CONFIG_PARISC)
>         pdc_console_init();
> +#elif defined(CONFIG_IA64_GENERIC)
> +       if (is_sgi_sn2())
> +               sgi_l1_serial_console_init();
> +       else
> +               serial_console_init();
>  #elif defined(CONFIG_SERIAL)
>         serial_console_init();
>  #endif /* CONFIG_8xx */
> 
> 
> The current patch is attached.  It's a first draft.  I'm looking
> comments on whether this (or something like it) has any chance
> of being accepted, and if so, any comments on the design of
> the facility.
> 
> mh
> 
> 
> -- 
> Wild Open Source Inc.                  mort@wildopensource.com
> 
> 
> 
> ====================================
> => Index: linux/arch/ia64/kernel/setup.c
> ====================================
> => 
> --- /usr/tmp/TmpDir.30939-0/linux/arch/ia64/kernel/setup.c_1.33	Tue May
> 13 14:41:50 2003
> +++ linux/arch/ia64/kernel/setup.c	Tue May 13 14:38:08 2003
> @@ -63,6 +63,8 @@
>   struct cpuinfo_ia64 _cpu_data[NR_CPUS] __attribute__ ((section
> ("__special_page_section")));
>  #endif
>  
> +int machine_is_sgi_sn2;
> +
>  unsigned long ia64_cycles_per_usec;
>  struct ia64_boot_param *ia64_boot_param;
>  struct screen_info screen_info;
> @@ -446,7 +448,11 @@
>  	ia64_sal_init(efi.sal_systab);
>  
>  #ifdef CONFIG_IA64_GENERIC
> -	machvec_init(acpi_get_sysname());
> +	{
> +		char *str = acpi_get_sysname();
> +		machvec_init(str);
> +		init_is_sgi_sn2(str);
> +	}
>  #endif
>  
>  	/*
> 
> ====================================
> => Index: linux/include/asm-ia64/system.h
> ====================================
> => 
> --- /usr/tmp/TmpDir.30939-0/linux/include/asm-ia64/system.h_1.25
> Tue May 13 14:41:50 2003
> +++ linux/include/asm-ia64/system.h	Tue May 13 14:40:26 2003
> @@ -445,6 +445,20 @@
>  #define task_running(rq, p)    (((rq)->curr = (p)) ||
> spin_is_locked(&(p)->switch_lock))
>  #define idle_needs_wakeup	0
>  
> +#ifdef CONFIG_IA64_GENERIC
> +extern int machine_is_sgi_sn2;
> +#define init_is_sgi_sn2(str) do { 		\
> +	if (!strcmp(str,"sn2"))			\
> +		machine_is_sgi_sn2=1;		\
> +  } while (0)
> +
> +#define is_sgi_sn2() 	(machine_is_sgi_sn2)
> +#elif CONFIG_IA64_SGI_SN
> +#define is_sgi_sn2()	1
> +#else
> +#define is_sgi_sn2()	0
> +#endif /* CONFIG_IA64_GENERIC */
> +
>  #endif /* __KERNEL__ */
>  
>  #endif /* __ASSEMBLY__ */
> 


