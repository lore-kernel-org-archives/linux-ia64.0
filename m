From: Erich Focht <efocht@hpce.nec.com>
Date: Thu, 17 Jul 2003 08:23:37 +0000
Subject: Re: [Discontig-devel] [PATCH] another discontig patch
Message-Id: <marc-linux-ia64-105843017700413@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105618641519753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105618641519753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Same comment as above. NEC TX7 is an IA64_DIG platform.
>
> Oops, sorry.  Here's another one.  How does it look?
...

> --- a/arch/ia64/Kconfig	Wed Jul 16 15:36:33 2003
> +++ b/arch/ia64/Kconfig	Wed Jul 16 15:36:33 2003
> @@ -211,7 +211,7 @@
>
>  config NUMA
>  	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
> -	default y if IA64_SGI_SN2
> +	default y if IA64_SGI_SN2 || IA64_GENERIC
>  	help
>  	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
>  	  Access).  This option is for configuring high-end multiprocessor
> @@ -234,9 +234,8 @@
>  endchoice

OK. Thanks.

>
>  config DISCONTIGMEM
> -	bool
> -	depends on IA64_SGI_SN2 || (IA64_GENERIC || IA64_DIG || IA64_HP_ZX1) &&
> NUMA -	default y
> +	bool "Discontiguous memory support" if IA64_DIG
> +	default y if IA64_SGI_SN2 || IA64_GENERIC
>  	help
>  	  Say Y to support efficient handling of discontiguous physical memory,
>  	  for architectures which are either NUMA (Non-Uniform Memory Access)
> @@ -245,8 +244,7 @@

Maybe that should better be 
     bool "Discontiguous memory support" if (IA64_DIG && NUMA)

Discontigmem alone doesn't make sense, yet, I think...

Regards,
Erich


