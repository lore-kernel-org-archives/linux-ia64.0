From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 06 Feb 2008 00:30:17 +0000
Subject: Re: [patch] Fix large MCA bootmem allocation
Message-Id: <47A8FF99.2040700@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205193232.GA8834@sgi.com>
In-Reply-To: <20080205193232.GA8834@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ Anderson wrote:
> The MCA code allocates bootmem memory for NR_CPUS, regardless
> of how many cpus the system actually has.

So... how about using num_possible_cpus() instead?

> @@ -1762,11 +1762,8 @@ format_mca_init_stack(void *mca_data, un
>  /* Caller prevents this from being called after init */
>  static void * __init_refok mca_bootmem(void)
>  {
> -	void *p;
> -
> -	p = alloc_bootmem(sizeof(struct ia64_mca_cpu) * NR_CPUS +
> -	                  KERNEL_STACK_SIZE);
> -	return (void *)ALIGN((unsigned long)p, KERNEL_STACK_SIZE);
> +	return __alloc_bootmem(sizeof(struct ia64_mca_cpu),
> +	                    KERNEL_STACK_SIZE, 0);
>  }
>  
>  /* Do per-CPU MCA-related initialization.  */

i.e.
p = alloc_bootmem(sizeof(struct ia64_mca_cpu) * num_possible_cpus() +
	                  KERNEL_STACK_SIZE);

Thanks,
H.Seto
