From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 29 Jul 2008 13:07:16 +0000
Subject: Re: [Patch] Allow ia64 to CONFIG_NR_CPUS up to 4096
Message-Id: <20080729220604.F195.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729122621.GE10501@sgi.com>
In-Reply-To: <20080729122621.GE10501@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Index: contention_unroll/arch/ia64/Kconfig
> =================================> --- contention_unroll.orig/arch/ia64/Kconfig	2008-07-28 18:19:56.000000000 -0500
> +++ contention_unroll/arch/ia64/Kconfig	2008-07-29 06:29:26.248066055 -0500
> @@ -322,9 +322,9 @@ config SMP
>  
>  config NR_CPUS
>  	int "Maximum number of CPUs (2-1024)"

Should we change to 'int "Maximum number of CPUs (2-4096)"' ?


> -	range 2 1024
> +	range 2 4096
>  	depends on SMP
> -	default "1024"
> +	default "4096"
>  	help
>  	  You should set this to the number of CPUs in your system, but
>  	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


