From: Jack Steiner <steiner@SGI.com>
Date: Wed, 28 Jan 2004 22:36:01 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040128223601.GA5021@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 28, 2004 at 09:17:59PM +0000, Christoph Hellwig wrote:
> On Wed, Jan 28, 2004 at 02:59:12PM -0600, Jack Steiner wrote:
> > +#ifdef CONFIG_NUMA
> > +			cpus_clear(mm->cpu_vm_mask);
> > +#endif
> 
> I really hate this ifdefs all over the place.  Does this really hurt that
> much on non-NUMA systems?  Also SN2 seems to use this code always so
> CONFIG_NUMA looks like the wrong ifdef to me.  

Are you suggesting that we remove the #ifdef OR hide the code
in a function that, depending on config options, may or may not do anything?

The code is needed on kernels built for SN2. That includes both
CONFIG_IA64_GENERIC & CONFIG_IA64_SGI_SN2. I agree that CONFIG_NUMA
is not a great choice but nothing else seemed appropriate. 

I could either delete the #ifdef, or switch it to 
"#if defined(CONFIG_IA64_GENERIC) || defined(CONFIG_IA64_SGI_SN2)".
The latter could be hidden in an inline function. I cant think of any
other options.

Which looks best or is there a better approach.


> 
> > +#ifdef CONFIG_NUMA
> > +		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
> > +			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
> 
> cpu_test_and_set()?

On IA64 (not sure about other architectures), cpu_test_and_set will always 
set the bit regardless of it's previous state. That causes the cacheline containing
the bitmask to be bounced between cpus - possibly unnecessarily. For most
applications this may not matter. However, for large OpenMP apps, this may add additional
overhead. I was trying to avoid this extra overhead.

In addition, the code in include/asm-sparc64/mmu_context.h is similar (activate_mm).
I assume (just a guess) that they were trying to avoid the same problem.



> 
> > +/* When nodemask_t is available, delete the following definitions */
> > +#define NODEMASK_WORDCOUNT       ((NR_NODES+(BITS_PER_LONG-1))/BITS_PER_LONG)
> > +#define NODE_MASK_ALL    { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = ~0UL }
> > +#define NODE_MASK_NONE   { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = 0 }
> > +typedef unsigned long   nodemask_t[NODEMASK_WORDCOUNT];
> 
> Don't we have the generic bitmask code merged now?

Agree. Will change.


> >
> > +	for (i=0, cpu=find_first_bit(&mm->cpu_vm_mask, NR_CPUS); cpu < NR_CPUS;
> > +			i++, cpu=find_next_bit(&mm->cpu_vm_mask, NR_CPUS, ++cpu)) {
> 
> This assumes a specific cpumask_t implementation.  You should just use
> for_each_cpu_mask()

Agree. Will change.


> 
> > @@ -218,3 +265,4 @@
> >  
> >  	sn_send_IPI_phys(physid, vector, delivery_mode);
> >  }
> > +EXPORT_SYMBOL(sn2_send_IPI);
> 
> What's this?

Whoops - different patch. I'll delete it.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


