From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Mar 2007 20:33:50 +0000
Subject: Re: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <20070327203350.GA20440@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327193925.GA8615@sgi.com>
In-Reply-To: <20070327193925.GA8615@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 27, 2007 at 01:24:27PM -0700, Luck, Tony wrote:
> +smp_flush_tlb_cpumask (cpumask_t xcpumask)
> +{
> +	unsigned short counts[NR_CPUS];
> 
> Even as a "short" ... that is still a lot of stack.  Possibly
> a new place to fail when NR_CPUS gets bumped up again?

I was also somwhat concerned about that, too. At NR_CPUS24, it
uses 2k bytes whick is big but I think ok. Even at NR_CPUS 48,
I think is is still ok but I'm getting a little nervous. 

FWIW, slab.c has a "struct array_cache *new[NR_CPUS]" on the
stack.

Also, net/core/utils.c has "unsigned long seed[NR_CPUS]".

I'm only adding 1/4 as much space. Can I get away with it or
should I allocate a node-local chunk of memory & keep a pointer to
it in per-cpu data?



> 
> +#define IA64_IPI_LOCAL_TLB_FLUSH	0xfc	/* SMP reschedule */
>  #define IA64_IPI_RESCHEDULE		0xfd	/* SMP reschedule */
> 
> Cut & pasted the comment when duping this line?

Whoops :-) 
Fixed....

