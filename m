From: Jesse Barnes <jbarnes@sgi.com>
Date: Sat, 08 Jan 2005 17:59:46 +0000
Subject: Re: [PATCH] sn/kernel/irq.o link failure in 2.6.10
Message-Id: <200501080959.47222.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050108023949.GA7366@jale>
In-Reply-To: <20050108023949.GA7366@jale>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, January 07, 2005 6:39 pm, dann frazier wrote:
> This patch defines a no-op set_irq_affinity_info() when CONFIG_SMP is not
> set, fixing a linking error in sn_set_affinity_irq().
>
> Signed-off-by: dann frazier <dannf@hp.com>
>
> --- linux-2.6.10.orig/arch/ia64/kernel/irq.c 2004-12-24 14:35:27.000000000
> -0700 +++ linux-2.6.10/arch/ia64/kernel/irq.c 2005-01-07 18:56:16.819383593
> -0700 @@ -1040,6 +1040,11 @@
>   }
>  }
>
> +#else /* !CONFIG_SMP */
> +
> +void set_irq_affinity_info (unsigned int irq, int hwid, int redir)
> +{
> +}
>
>  #endif /* CONFIG_SMP */

This one looks good, Dann.  Thanks.

Jesse
