From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 30 Jul 2003 17:17:13 +0000
Subject: Re: [PATCH] more discontig fun
Message-Id: <marc-linux-ia64-105958545513688@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942849830042@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942849830042@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 03:43:58PM -0700, David Mosberger wrote:
> Hi Jesse,
> 
> Two quick comments:
> 
> +
> +	/* for discontig machines, we do this in discontig.c */
>  	if (smp_processor_id() = 0) {
>  		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS, PERCPU_PAGE_SIZE,
> 
> This comment seems out of place.  Isn't it trying to say that all of
> per_cpu_init() is done in discontig.c for NUMA?  If so the comment
> should be in front of the #ifdef around CONFIG_DISCONTIGMEM.  Also,
> I'm wondering whether we shouldn't split off the contig-mem case into
> a separate file.  I don't like those #ifdef CONFIG_DISCONTIGMEM.  It
> would be better to control that via the Makefile.

A quick grep shows quite a few #ifndef CONFIG_DISCONTIGMEMs, I'll see if
I can clean some stuff up and put it into contig.c.

> On to this one:
> 
> +struct memmap_count_callback_data {
> +	int node;
> +	unsigned long num_physpages;
> +	unsigned long num_dma_physpages;
> +	unsigned long min_pfn;
> +	unsigned long max_pfn;
> +} cdata;
> 
> I don't like non-reentrant code.  Can't you allocate the variable on
> the stack and pass a pointer to it via the callback interface?  Yes,
> we may not be needing re-entrancy right now, but I just think it's bad
> design to have non-reentrant code (unless there are good reasons for
> it).

Ok, I'll fix this too.  Thanks for looking at it.

Jesse
