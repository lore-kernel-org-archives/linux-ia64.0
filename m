From: jbarnes@sgi.com (Jesse Barnes)
Date: Thu, 19 Jun 2003 00:14:28 +0000
Subject: Re: [RFC/PATCH] discontig update for linux-ia64-2.5 bk tree
Message-Id: <marc-linux-ia64-105598178814109@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105595347015732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105595347015732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2003 at 05:11:10PM -0700, David Mosberger wrote:
> I missed this on first reading:
> 
>  		for (cpu = 0; cpu < NR_CPUS; cpu++) {
> -			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
>  			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
>  			cpu_data += PERCPU_PAGE_SIZE;
>  		}
> +		for (cpu = 0; cpu < NR_CPUS; cpu++) {
> +			cpu_data = __per_cpu_offset[cpu] + __per_cpu_start;
> +			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
> +		}
> 
> What's the point of this?

Arg, I saw that when I got my copy back (along with a couple of other
things).  I'll fix them up.

> The patch still removes CONFIG_VIRTUAL_MEM_MAP.

...

> Also, please note that I don't want to add any ia64 patches that
> create additional dependencies on core code (I'm trying to sync things
> such that ia64 builds out of the box).  So before submitting
> ia64-specific changes, please make sure the core-code is ready for it.

Ok.  I'll try to get the bootmem changes in first.

Thanks,
Jesse
