From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 06 Jan 2005 21:29:34 +0000
Subject: Re: sn/kernel/irq.o link failure in 2.6.10
Message-Id: <200501061329.34594.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050106202618.GC6009@jale>
In-Reply-To: <20050106202618.GC6009@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, January 6, 2005 12:26 pm, dann frazier wrote:
> arch/ia64/sn/built-in.o(.text+0x1ee2): In function `sn_set_affinity_irq':
> : undefined reference to `set_irq_affinity_info'
>
> We probably need to wrap the set_irq_affinity_info in an #ifdef CONFIG_SMP
> - but should other code be ifdef'd out as well?
>
> --- kernel-source-2.6.10/arch/ia64/sn/kernel/irq.c.orig 2005-01-06
> 12:40:30.170327564 -0700 +++
> kernel-source-2.6.10/arch/ia64/sn/kernel/irq.c 2005-01-06
> 13:25:36.521856911 -0700 @@ -183,7 +183,9 @@
>
>     sn_irq_info = sn_irq_info->irq_next;
>
> +#ifdef CONFIG_SMP
>     set_irq_affinity_info((irq & 0xff), cpuphys, 0);
> +#endif
>    } else {
>     break; /* snp_affinity failed the intr_alloc */
>    }

I'd rather see a no-op version added under #else /* !CONFIG_SMP */ in 
arch/ia64/kernel/irq.c...

Jesse
