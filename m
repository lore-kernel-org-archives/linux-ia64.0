From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Wed, 28 Mar 2007 03:03:50 +0000
Subject: RE: [PATCH] - Optional method to purge the TLB on SN systems
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086C55@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327193925.GA8615@sgi.com>
In-Reply-To: <20070327193925.GA8615@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Jack Steiner [mailto:steiner@sgi.com]
> Sent: 2007=C4=EA3=D4=C228=C8=D5 9:53
> To: Zou, Nanhai
> Cc: Luck, Tony; Linux-IA64
> Subject: Re: [PATCH] - Optional method to purge the TLB on SN systems
>=20
> On Wed, Mar 28, 2007 at 08:46:44AM +0800, Zou Nan hai wrote:
> > On Wed, 2007-03-28 at 03:39, Jack Steiner wrote:
> >
> > > This patch adds an optional method for purging the TLB on SN IA64 sys=
tems.
> > > The change should not affect any non-SN system.
> > >
> > > 	Signed-off-by: Jack Steiner <steiner@sgi.com>
> > >
> > > ---
> > >
> > > +void
> > > +smp_flush_tlb_cpumask (cpumask_t xcpumask)
> > > +{
> > > +	unsigned short counts[NR_CPUS];
> > > +	cpumask_t cpumask =3D xcpumask;
> > > +	int count, mycpu, cpu, flush_mycpu =3D 0;
> > > +
> > > +	preempt_disable();
> > > +	mycpu =3D smp_processor_id();
> > > +
> > > +	for_each_cpu_mask(cpu, cpumask) {
> > > +		counts[cpu] =3D per_cpu(local_flush_count, cpu);
> > > +		mb();
> > > +		if (cpu =3D mycpu)
> > > +			flush_mycpu =3D 1;
> > > +		else
> > > +			smp_send_local_flush_tlb(cpu);
> > > +	}
> > > +
> > > +	if (flush_mycpu)
> > > +		smp_local_flush_tlb();
> > > +
> > > +	for_each_cpu_mask(cpu, cpumask) {
> > > +		count =3D 0;
> > > +		while(counts[cpu] =3D per_cpu(local_flush_count, cpu)) {
> >
> > Due to 64k offset of percpu data, the same percpu variable on different
> > CPUs are very likely to be on the same cacheline of some levels of
> > cache.
> >
> > So I think the operation on local_flush_count may be very cache
> > unfriendly...
>=20
> I was concerned about that, too, but testing finally convinced me that
> it was not an issue. I think the reason is that is takes a few hundred
> nanoseconds per cpu to send an IPI.  So rather than a contended cache
> line, we have a line that is serially read by multiple cpus. Although
> contention can occur, typically multiple cpus are not trying to read
> the same line at the same time.
>=20
> For example (oversimplified), IPI sent to cpu 0 at time 0, to cpu 1 at
> time ~100, cpu 2 at time ~200, etc. The IPI requires a chipset access
> that takes order-of-memory-access time. Assume it take N usec for a
> cpu to recognize the IPI & call the TLB flushing code. Cpu 0 reads
> local_flush_count at time N, cpu reads local_flush_count at time
> 100+N, etc. Very little contention, just serial access.
>=20
> --
>=20
> I tried a second algorithm where the local_flush_count was kept in
> node-local percpu data. That scheme was significantly slower. Most
> likely because the cpu that initiates the flush will take N (# of
> cpus) cache misses to get an initial snapshot of the counts, then
> another N cache misses to check for completion. This assumes that
> a cpu doing a flush is not the most-recent cpu to do a flush.
> I believe this is typical.
>=20
> Keeping the counts in a single array (64cpus/cache line)
> significantly reduces the number of cache misses.

>=20
> Another disadvantage of keeping counts in per-cpu data is that
> scanning the counts trashes the TLB for large NR_CPUS. The counts will
> be located in different 16MB granules. Each reference to cpu's percpu
> data will require a different TLB entry to map the address used to
> reference the count. To scan N cpus, there will be ~2*N TLB misses
> plus at the end of the flush, the contents of the TLB are useless
> for most kernel or user use.
>=20
> --
>=20
> I tried a third algorithm where the counts were kept in a single array
> but each count was cacheline aligned to eliminate any possibility
> of contention. This was better that the second method that trashed
> the TLB. 1 TLB entry will cover the entire array. Unfortunately,
> this algorithm still encurs 2*N cache misses & is slower than
> the current algorithm.
>=20
>=20
> Does this explanation make sense...... If anyone has an alternate
> algorithm, I be glad to try it.

  Yes, put count in a tight array could be better.
  But your original patch is using the second algorithm?

  Zou Nan hai
>=20
>=20
> -- jack
