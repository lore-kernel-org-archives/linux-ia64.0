From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 14 Jul 2004 04:59:34 +0000
Subject: RE: Next Revison of timer patches with split into nanosecond, time_interpolator and debug patch
Message-Id: <200407140456.i6E4ugY06018@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Tuesday, July 13, 2004 7:06 PM
> > > +	ld4 r20 = [r31]		//  xtime_lock.sequence
> > > +	mf
> >
> > convert to ld4.acq??
>
> Doesnt that run a risk because some of the timer values may be already
> in the cache?

No, this is memory ordering semantics. Cache coherency is a different thing.
MESI protocol on MP ensures cache coherency here.


> > > + 	ld8 r21 = [r21]		// xtime.tv_sec
> > > +	ld8 r22 = [r22]		// xtime_tv_nsec
> >
> > Probably not going to help much, but it should be scheduled way above,
> > right after seqread to hide some part of memory latency.
>
> I thought the itanium would coalesce these accesses since they are most
> likely in the same cache line.

For me, xtime is not on the same cache line with other time_interpolator_*
variables.  So still buys a few cycles if these instructions get scheduled
as early as possible.  By the way, there is a typo in the comment.


