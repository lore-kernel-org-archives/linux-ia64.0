From: Aron Griffis <aron@hp.com>
Date: Tue, 06 Mar 2007 17:08:17 +0000
Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
Message-Id: <20070306170817.GC28832@fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simon Horman wrote:  [Tue Mar 06 2007, 02:28:52AM EST]
> +/* find a block of memory aligned to 64M exclude reserved regions
> +   rsvd_regions are sorted
> + */
> +static int __init
> +kdump_region_verify_rsvd_region (unsigned long base, unsigned long size,
> +	       			 struct rsvd_region *rsvd_regions, int n)
> +{
> +	int i;
> +
> +	for (i = 0; i < n; i++) {
> +		if (__pa(rsvd_regions[i].start) < base ||
> +		    __pa(rsvd_regions[i].end) >= base + size - 1)
> +			continue;
> +		printk(KERN_WARNING "Kdump: crashkernel region 0x%lx-0x%lx "
> +		       "clashes with reserved region 0x%lx-0x%lx\n", base,
> +		       base + size - 1, __pa(rsvd_regions[i].start),
> +		       __pa(rsvd_regions[i].end));
> +		return 0;
> +	}
> +	return 0;
> +}

You're returning 0 in both cases here, is that what you really want?

> +/* find a block of memory aligned to 64M exclude reserved regions
> +   rsvd_regions are sorted
> + */
> +int __init
> +kdump_region_verify (unsigned long base, unsigned long size,
> +		     struct rsvd_region *rsvd_regions, int n)
> +{
> +	/* This isn't considered to be a failure condition,
> +	 * but it isn't desireable either, so log it */
> +	if (ALIGN(base, CRASHDUMP_ALIGNMENT) != base)
> +		printk(KERN_WARNING "Kdump: warning: crashkernel region "
> +		       "0x%lx-0x%lx is not aligned to 0x%x\n",
> +		       base, base + size - 1, CRASHDUMP_ALIGNMENT);
> +
> +	if (!kdump_region_verify_efi(base, size))
> +		return 0;
> +
> +	if (!kdump_region_verify_rsvd_region(base, size, rsvd_regions, n))
> +		return 0;
> +
> +	printk(KERN_INFO "Kdump: crashkernel region verified\n");
> +		return 1;
> +	return 1;

and here it appears you have an extra return.

Aron
