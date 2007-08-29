From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 29 Aug 2007 18:53:53 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070829125651.L13320@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823042038.GI18788@wotan.suse.de>
	<alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
	<1187886462.5972.17.camel@localhost.localdomain>
	<20070824030904.GC6989@wotan.suse.de>
	<20070828151737.P5403@pkunk.americas.sgi.com>
	<20070829005904.GB25335@wotan.suse.de>
In-Reply-To: <20070829005904.GB25335@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org

On Wed, 29 Aug 2007, Nick Piggin wrote:

> On Tue, Aug 28, 2007 at 03:56:28PM -0500, Brent Casavant wrote:

> > The simplistic method to solve this is a lock around the section
> > issuing IOs, thereby ensuring serialization of access to the IO
> > device.  However, as SN2 does not enforce an ordering between normal
> > memory transactions and memory-mapped IO transactions, you cannot
> > be sure that an IO transaction will arrive at the IO fabric "on the
> > correct side" of the unlock memory transaction using this scheme.
> 
> Hmm. So what if you had the following code executed by a single CPU:
> 
> writel(data, ioaddr);
> wmb(); 
> *mem = 10;
> 
> Will the device see the io write before the store to mem?

Not necessarily.  There is no guaranteed ordering between the IO write
arriving at the device and the order of the normal memory reference,
regardless of the intervening wmb(), at least on SN2.  I believe the
missing component in the mental model is the effect of the platform
chipset.

Perhaps this will help.  Uncached writes (i.e. IO writes) are posted
to the SN2 SHub ASIC and placed in their own queue which the SHub chip
then routes to the appropriate target.  This uncached write queue is
independent of the NUMA cache-coherency maintained by the SHub ASIC
for system memory; the relative order in which the uncached writes
and the system memory traffic appear at their respective targets is
undefined with respect to eachother.

wmb() does not address this situation as it only guarantees that
the writes issued from the CPU have been posted to the chipset,
not that the chipset itself has posted the write to the final
destination.  mmiowb() guarantees that all outstanding IO writes
have been issued to the IO fabric before proceeding.

I like to think of it this way (probably not 100% accurate, but it
helps me wrap my brain around this particular point):

	wmb(): Ensures preceding writes have issued from the CPU.
	mmiowb(): Ensures preceding IO writes have issued from the
		  system chipset.

mmiowb() on SN2 polls a register in SHub that reports the length
of the outstanding uncached write queue.  When the queue has emptied,
it is known that all subsequent normal memory writes will therefore
arrive at their destination after all preceding IO writes have arrived
at the IO fabric.

Thus, typical mmiowb() usage, for SN2's purpose, is to ensure that
all IO traffic from a CPU has made it out to the IO fabric before
issuing the normal memory transactions which release a RAM-based
lock.  The lock in this case is the one used to serialize access
to a particular IO device.

> > mmiowb() causes SN2 to drain the pending IOs from the current CPU's
> > node.  Once the IOs are drained the CPU can safely unlock a normal
> > memory based lock without fear of the unlock's memory write passing
> > any outstanding IOs from that CPU.
> 
> mmiowb needs to have the disclaimer that it's probably wrong if called
> outside a lock, and it's probably wrong if called between two io writes
> (need a regular wmb() in that case). I think some drivers are getting
> this wrong.

There are situations where mmiowb() can be pressed into service to
some other end, but those are rather rare.  The only instance I am
personally familiar with is synchronizing a free-running counter on
a PCI device as closely as possible to the execution of a particular
line of driver code.  A write of the new counter value to the device
and subsequent mmiowb() synchronizes that execution point as closely
as practical to the IO write arriving at the device.  Not perfect, but
good enough for my purposes.  (This was a hack, by the way, pressing
a bit of hardware into a purpose for which it wasn't really designed,
ideally the hardware would have had a better mechanism to accomplish
this goal.)

But in the normal case, I believe you are 100% correct -- wmb() would
ensure that the memory-mapped IO writes arrive at the chipset in a
particular order, and thus should arrive at the IO hardware in a particular
order.  mmiowb() would not necessarily accomplish this goal, and is
incorrectly used wherever that is the intention.  At least for SN2.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
