From: Jack Steiner <steiner@sgi.com>
Date: Wed, 28 Mar 2007 03:26:05 +0000
Subject: Re: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <20070328032605.GA9496@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327193925.GA8615@sgi.com>
In-Reply-To: <20070327193925.GA8615@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 28, 2007 at 11:03:50AM +0800, Zou, Nanhai wrote:
> > -----Original Message-----
> > From: Jack Steiner [mailto:steiner@sgi.com]
> > Sent: 2007??3??28?? 9:53
> > To: Zou, Nanhai
> > Cc: Luck, Tony; Linux-IA64
> > Subject: Re: [PATCH] - Optional method to purge the TLB on SN systems
> > 
> > On Wed, Mar 28, 2007 at 08:46:44AM +0800, Zou Nan hai wrote:
> > > On Wed, 2007-03-28 at 03:39, Jack Steiner wrote:
> > >
> > > > This patch adds an optional method for purging the TLB on SN IA64 systems.
> > > > The change should not affect any non-SN system.
> > > >
> > > > 	Signed-off-by: Jack Steiner <steiner@sgi.com>
> > > >
> > > > ---
> > > >
> > > > +void
> > > > +smp_flush_tlb_cpumask (cpumask_t xcpumask)
> > > > +{
> > > > +	unsigned short counts[NR_CPUS];
> > > > +	cpumask_t cpumask = xcpumask;
> > > > +	int count, mycpu, cpu, flush_mycpu = 0;
> > > > +
> > > > +	preempt_disable();
> > > > +	mycpu = smp_processor_id();
> > > > +
> > > > +	for_each_cpu_mask(cpu, cpumask) {
> > > > +		counts[cpu] = per_cpu(local_flush_count, cpu);
> > > > +		mb();
> > > > +		if (cpu = mycpu)
> > > > +			flush_mycpu = 1;
> > > > +		else
> > > > +			smp_send_local_flush_tlb(cpu);
> > > > +	}
> > > > +
> > > > +	if (flush_mycpu)
> > > > +		smp_local_flush_tlb();
> > > > +
> > > > +	for_each_cpu_mask(cpu, cpumask) {
> > > > +		count = 0;
> > > > +		while(counts[cpu] = per_cpu(local_flush_count, cpu)) {
> > >
> > > Due to 64k offset of percpu data, the same percpu variable on different
> > > CPUs are very likely to be on the same cacheline of some levels of
> > > cache.
> > >
> > > So I think the operation on local_flush_count may be very cache
> > > unfriendly...
> > 
> > I was concerned about that, too, but testing finally convinced me that
> > it was not an issue. I think the reason is that is takes a few hundred
> > nanoseconds per cpu to send an IPI.  So rather than a contended cache
> > line, we have a line that is serially read by multiple cpus. Although
> > contention can occur, typically multiple cpus are not trying to read
> > the same line at the same time.
> > 
> > For example (oversimplified), IPI sent to cpu 0 at time 0, to cpu 1 at
> > time ~100, cpu 2 at time ~200, etc. The IPI requires a chipset access
> > that takes order-of-memory-access time. Assume it take N usec for a
> > cpu to recognize the IPI & call the TLB flushing code. Cpu 0 reads
> > local_flush_count at time N, cpu reads local_flush_count at time
> > 100+N, etc. Very little contention, just serial access.
> > 
> > --
> > 
> > I tried a second algorithm where the local_flush_count was kept in
> > node-local percpu data. That scheme was significantly slower. Most
> > likely because the cpu that initiates the flush will take N (# of
> > cpus) cache misses to get an initial snapshot of the counts, then
> > another N cache misses to check for completion. This assumes that
> > a cpu doing a flush is not the most-recent cpu to do a flush.
> > I believe this is typical.
> > 
> > Keeping the counts in a single array (64cpus/cache line)
> > significantly reduces the number of cache misses.
> 
> > 
> > Another disadvantage of keeping counts in per-cpu data is that
> > scanning the counts trashes the TLB for large NR_CPUS. The counts will
> > be located in different 16MB granules. Each reference to cpu's percpu
> > data will require a different TLB entry to map the address used to
> > reference the count. To scan N cpus, there will be ~2*N TLB misses
> > plus at the end of the flush, the contents of the TLB are useless
> > for most kernel or user use.
> > 
> > --
> > 
> > I tried a third algorithm where the counts were kept in a single array
> > but each count was cacheline aligned to eliminate any possibility
> > of contention. This was better that the second method that trashed
> > the TLB. 1 TLB entry will cover the entire array. Unfortunately,
> > this algorithm still encurs 2*N cache misses & is slower than
> > the current algorithm.
> > 
> > 
> > Does this explanation make sense...... If anyone has an alternate
> > algorithm, I be glad to try it.
> 
>   Yes, put count in a tight array could be better.
>   But your original patch is using the second algorithm?

That's embarasing.

I had several variants of the patch & did a lot of testing with each.
The only difference was in the "counts". Arrays, sizes, alignment,
percpu, etc. It looks like I grabbed the wrong patch.

I want to review my notes & possibly retest to make sure that what I
said was correct about the differences between the patches & the
performance of each.

Stay tuned & thanks for the careful review.

-- jack


