From: Zwane Mwaikambo <zwane@linuxpower.ca>
Date: Fri, 12 Mar 2004 23:26:39 +0000
Subject: Re: RE[PATCH]2.6.4-rc3 MSI Support for IA64
Message-Id: <Pine.LNX.4.58.0403121743310.29087@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403130008.i2D08SMQ011709@snoqualmie.dp.intel.com>
In-Reply-To: <200403130008.i2D08SMQ011709@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: long <tlnguyen@snoqualmie.dp.intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, davidm@napali.hpl.hp.com, grep@kroah.com, jgarzik@pobox.com, jun.nakajima@intel.com, tom.l.nguyen@intel.com, tony.luck@intel.com

On Fri, 12 Mar 2004, long wrote:

> Thanks for all inputs received from the previous patch posted a few
> weeks ago. Based on Zwane Mwaikambo's suggestion of using a
> standard name like assign_irq_vector(), we made some changes to
> the previous posted patch. Attached is an update version, based on
> kernel 2.6.4-rc3.

Thanks for doing this, i have a few comments;

> diff -urN linux-2.6.4-rc3/arch/ia64/kernel/irq_ia64.c linux-2.6.4-rc3-msi/arch/ia64/kernel/irq_ia64.c
> --- linux-2.6.4-rc3/arch/ia64/kernel/irq_ia64.c	2004-03-09 19:00:26.000000000 -0500
> +++ linux-2.6.4-rc3-msi/arch/ia64/kernel/irq_ia64.c	2004-03-11 14:52:57.000000000 -0500
> @@ -60,12 +60,18 @@
>  int
>  ia64_alloc_vector (void)
>  {
> +#ifdef CONFIG_PCI_USE_VECTOR
> +	extern int assign_irq_vector(int irq);
> +
> +	return assign_irq_vector(AUTO_ASSIGN);
> +#else
>  	static int next_vector = IA64_FIRST_DEVICE_VECTOR;
>
>  	if (next_vector > IA64_LAST_DEVICE_VECTOR)
>  		/* XXX could look for sharable vectors instead of panic'ing... */
>  		panic("ia64_alloc_vector: out of interrupt vectors!");
>  	return next_vector++;
> +#endif
>  }

This one is slightly confusing readability wise since ia64 already does
the vector based interrupt numbering. Perhaps CONFIG_PCI_USE_VECTOR should
really be CONFIG_MSI but that's up to you. I wonder if we could
consolidate these vector allocators as assign_irq_vector(AUTO_ASSIGN) has
the same semantics as ia64_alloc_vector() and the one for i386 is also
almost the same as its MSI ilk.

> +static inline int vector_resources(void)
> +{
> + 	int res;
> +#ifndef CONFIG_IA64
> + 	int i, repeat;
> + 	for (i = NR_REPEATS; i > 0; i--) {
> + 		if ((FIRST_DEVICE_VECTOR + i * 8) > FIRST_SYSTEM_VECTOR)
> + 			continue;
> + 		break;
> + 	}
> + 	i++;
> + 	repeat = (FIRST_SYSTEM_VECTOR - FIRST_DEVICE_VECTOR)/i;
> + 	res = i * repeat - NR_RESERVED_VECTORS + 1;
>  #else
> -extern void restore_ioapic_irq_handler(int irq);
> + 	res = LAST_DEVICE_VECTOR - FIRST_DEVICE_VECTOR - 1;
>  #endif
> +
> + 	return res;
> +}

Is this supposed to return number of vectors available for external
devices? Also regarding vector allocation, assign_irq_vector() in
drivers/pci/msi.c only can allocate 166 vectors before going -ENOSPC is
this intentional?

Thanks,
	Zwane
