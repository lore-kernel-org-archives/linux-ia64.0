From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 03 May 2007 20:42:48 +0000
Subject: Re: [PATCH] - SN: validate smp_affinity mask on intr redirect
Message-Id: <20070503134248.e9b58a32.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070503125602.12552.4152.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20070503125602.12552.4152.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-ia64@vger.kernel.org, steiner@sgi.com, linux-kernel@vger.kernel.org

On Thu, 03 May 2007 07:56:02 -0500
John Keller <jpk@sgi.com> wrote:

> On SN, only allow one bit to be set in the smp_affinty mask
> when redirecting an interrupt. Currently setting multiple
> bits is allowed, but only the first bit is used in
> determining the CPU to redirect to. This has caused confusion
> among some customers.
> 
> ...
>
> +
> +int is_affinity_mask_valid(cpumask_t cpumask)
> +{
> +	if (ia64_platform_is("sn2")) {
> +		/* Only allow one CPU to be specified in the smp_affinity mask */
> +		if (cpus_weight(cpumask) != 1)
> +			return 0;
> +	}
> +	return 1;
> +}

A bool returning true or false would be appropriate, given this function's
clearly-boolean name.

> +#ifndef ARCH_HAS_IRQ_AFFINITY_VALIDATION
> +#define is_irq_affinity_mask_valid(cpumask)         1
> +#endif

The ARCH_HAS_FOO things have never been popular.  There are a couple of
alternatives going around:

a) use __attribute__((weak)) and provide a one-line default
   implementation in kernel/irq/proc.c.  This has a small runtime cost.

b) In include/asm-ia64/irq.h, do

   #define is_affinity_mask_valid is_affinity_mask_valid

   and in kernel/irq/proc.c do

   #ifndef is_affinity_mask_valid
   #define is_affinity_mask_valid() 1
   #endif

   This has minimal runtime cost, but is a bit tricksy.

   It has the advantage that it doesn't introduce some new identifier
   which needs to be maintained.

>  extern int irq_set_affinity(unsigned int irq, cpumask_t cpumask);
>  extern int irq_can_set_affinity(unsigned int irq);
>  
> Index: linux-2.6/include/asm-ia64/irq.h
> =================================> --- linux-2.6.orig/include/asm-ia64/irq.h	2007-05-01 15:47:01.660643076 -0500
> +++ linux-2.6/include/asm-ia64/irq.h	2007-05-01 15:48:42.729254805 -0500
> @@ -11,6 +11,8 @@
>   * 02/29/00     D.Mosberger	moved most things into hw_irq.h
>   */
>  
> +#include <linux/cpumask.h>
> +

This is the sort of inclusion which tends to make things blow up.  I trust
this was carefully compile-tested.

With a) above, the is_affinity_mask_valid() declaration would be in a
different header.  With b), no additional include will be needed.

>  #define NR_IRQS		256
>  #define NR_IRQ_VECTORS	NR_IRQS
>  
> @@ -30,4 +32,7 @@ extern void disable_irq_nosync (unsigned
>  extern void enable_irq (unsigned int);
>  extern void set_irq_affinity_info (unsigned int irq, int dest, int redir);
>  
> +#define ARCH_HAS_IRQ_AFFINITY_VALIDATION
> +extern int is_affinity_mask_valid(cpumask_t cpumask);
> +

