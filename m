From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 30 Mar 2006 19:11:15 +0000
Subject: Re: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603301107480.370@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <65953E8166311641A685BDF71D865826A23D40@cacexc12.americas.cpqcorp.net>
 <Pine.LNX.4.64.0603291529160.26011@schroedinger.engr.sgi.com>
 <442B9A2A.7000306@bull.net> <442B9D18.4050903@yahoo.com.au>
In-Reply-To: <442B9D18.4050903@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Nick Piggin wrote:

> Zoltan Menyhart wrote:
> 
> > However, I do not think your implementation would be efficient due to
> > selecting the ordering mode at run time:
> > 
> > > +    switch (mode) {
> > > +    case MODE_NONE :
> > > +    case MODE_ACQUIRE :
> > > +        return cmpxchg_acq(m, old, new);
> > > +    case MODE_FENCE :
> > > +        smp_mb();
> > > +        /* Fall through */
> > > +    case MODE_RELEASE :
> > > +        return cmpxchg_rel(m, old, new);
> > 
> 
> BTW. Isn't MODE_FENCE wrong? Seems like a read or write could be moved
> above cmpxchg_rel?

Hmmm.... We should call this MODE_BARRIER I guess...
 
> I think you need rel+acq rather than acq+rel (if I'm right, then the
> same goes for your earlier bitops patches, btw).

The question is what does fence imply for the order of the atomic 
operation. Will the operation be performed before or after the barrier? 
Or do we need barriers on both sides?

If so then we may simulate that with a release and then do a acquire load 
afterwards

	 cmpxchg_rel(m, old, new);
	 return *m;	/* m volatile so it has acquire semantics */

