From: Robin Holt <holt@sgi.com>
Date: Mon, 10 Oct 2005 11:37:19 +0000
Subject: Re: [PATCH] 2.6.14-rc3: wider use of for_each_cpu_mask() in arch/ia64
Message-Id: <20051010113719.GA27579@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051008174331.27208.6062.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20051008174331.27208.6062.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Oct 08, 2005 at 10:43:31AM -0700, hawkes@sgi.com wrote:
> In arch/ia64 change the explicit use of for-loops and NR_CPUS into the
> general for_each_cpu_mask() construct.  This widens the scope of
> potential future optimizations of for_each_cpu_mask().
> 
> Signed-off-by: John Hawkes <hawkes@sgi.com>
> 
> Index: linux/arch/ia64/mm/tlb.c
> =================================> --- linux.orig/arch/ia64/mm/tlb.c	2005-08-28 16:41:01.000000000 -0700
> +++ linux/arch/ia64/mm/tlb.c	2005-10-07 14:30:11.000000000 -0700
> @@ -77,9 +77,10 @@
>  	/* can't call flush_tlb_all() here because of race condition with O(1) scheduler [EF] */
>  	{
>  		int cpu = get_cpu(); /* prevent preemption/migration */
> -		for (i = 0; i < NR_CPUS; ++i)
> -			if (cpu_online(i) && (i != cpu))
> +		for_each_cpu_mask(i, cpu_online_map) {

What about for_each_online_cpu?  Reads a little more cleanly.  Accomplishes
the same thing.

Robin
