From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 26 Jan 2005 18:11:10 +0000
Subject: Re: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <200501261011.10889.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16887.1203.470842.161249@napali.hpl.hp.com>
In-Reply-To: <16887.1203.470842.161249@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, January 26, 2005 10:05 am, David Mosberger wrote:
> Hmmh, I probably misread the patch.  I was looking at this hunk:
>
> +#ifdef CONFIG_SMP
>  /**
>   * per_cpu_init - setup per-cpu variables
>   *
> @@ -558,6 +586,7 @@
>
>   return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
>  }
> +#endif /* CONFIG_SMP */

Oh, you're right.  My patch just defaults to using __phys_per_cpu_start.  
That's probably why the MCA stuff didn't work.

Jesse
