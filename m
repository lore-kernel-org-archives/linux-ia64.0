From: Arun Sharma <arun.sharma@intel.com>
Date: Fri, 26 Sep 2003 22:24:13 +0000
Subject: Re: [PATCH] long format VHPT
Message-Id: <marc-linux-ia64-106461515127683@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106453902218848@msgid-missing>
In-Reply-To: <marc-linux-ia64-106453902218848@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Darren Williams wrote:
> +#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
> +	int cpu = smp_processor_id();
> +	int i;
> +	
> +	if (cpu = 0)
> +	{
> +		/* We allocate all VHPTs here as we may not have enough contiguous memory later */
> +		/* Also, we cannot use __get_free_pages on the target processor (until after init_cpu) */
> +		for (i = 0; i < NR_CPUS; i++){
> +			vhpt_base[i] = (unsigned long)__alloc_bootmem(LONG_VHPT_SIZE, LONG_VHPT_SIZE, __pa(MAX_DMA_ADDRESS));
> +			printk(KERN_INFO "CPU %d: Long format VHPT initialised at base address: 0x%lx\n", i, vhpt_base[i]);
> +		}
> +	}
> +#endif

- Can we avoid allocating VHPTs for non-existent CPUs ?
- How about calling alloc_bootmem on cpu0 and __get_free_pages on secondary cpus ?
- Does the VHPT size have to be a config option ? Can we not size it based on the size of the physical memory and some user supplied multiplier ?

I noticed that when we hit ia64_mmu_init() on a secondary processor, cpu0 has already made successful calls to __get_free_pages(). But calls from the secondary cpus fail. Does anyone know why ?

	-Arun

PS: patches for some of the above available, but they're based on Matt's earlier patch and need cleaning up.

