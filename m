From: Robin Holt <holt@sgi.com>
Date: Thu, 09 Sep 2004 17:59:37 +0000
Subject: Re: [RFC 0/4] Add SN2 Special Memory driver.
Message-Id: <20040909175937.GC23863@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909163638.GA23178@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 09, 2004 at 06:21:56PM +0100, Christoph Hellwig wrote:
> On Thu, Sep 09, 2004 at 11:36:38AM -0500, Robin Holt wrote:
> > 
> > This driver provides three different devices for mmap'ing pages which
> > are not visible to the kernel.
> > 
> > sgi_fetchops) atomic operations performed by the SN2 memory controller.
> > 	These operations are performed using uncached memory
> > 	references with an offset of the address specifying the
> > 	operation (add, sub) to perform.
> > 
> > sgi_uncached) Provides a device which supports mapping pages which
> > 	will only be referenced uncached.  These use the Intel ia64
> > 	write combining feature.  These need to be in a separate
> > 	granule from regular memory to prevent the FSB from having
> > 	both a cached and an uncached reference to a memory location.
> > 
> > sgi_cached) Provides a device which support cached operations from the
> > 	processor and uncached from processors outside the coherence
> > 	domain.  This provides rapid read access to the 16 words in the
> > 	cache line to data that was written uncached by remote processors.
> 
From your description only the first two actually use special SGI hardware
> features, or did I misread the descruption?  If so they should probably
> have a separate driver that works on all ia64 hardware.

I am not sure how to read this.  The fetchop function is a feature specifically
in the SN2 memory controller.  Are you saying we should have a driver that
provides fetchops for all ia64?  That seems wrong since it is a hardware feature.

If, on the other hand, you are saying that the uncached and cached drivers
should be available for all ia64 and the fetchop only if you are on sn2, I
can understand that.  That actually seems rather reasonable.

Would anybody else on ia64 be interested in either the uncached or cached
features?  The cached is really there to support MPI communications across
the coherence domain.  Does anybody else have a NUMA architecture which
mixes cache coherent and non-coherent NUMA?  If not, I don't think that
the cached functionality would ever be preferrable over regular cached
references.

Robin
