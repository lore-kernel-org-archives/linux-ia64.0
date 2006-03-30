From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Thu, 30 Mar 2006 22:26:46 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <65953E8166311641A685BDF71D865826A23E97@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Grundler, Grant G" <grant.grundler@hp.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> From: Christoph Lameter 
> On Thu, 30 Mar 2006, Nick Piggin wrote:
> 
> > Zoltan Menyhart wrote:
> > 
> > > However, I do not think your implementation would be 
> efficient due 
> > > to selecting the ordering mode at run time:
> > > 
> > > > +    switch (mode) {
> > > > +    case MODE_NONE :
> > > > +    case MODE_ACQUIRE :
> > > > +        return cmpxchg_acq(m, old, new);
> > > > +    case MODE_FENCE :
> > > > +        smp_mb();
> > > > +        /* Fall through */
> > > > +    case MODE_RELEASE :
> > > > +        return cmpxchg_rel(m, old, new);
> > > 
> > 
> > BTW. Isn't MODE_FENCE wrong? Seems like a read or write 
> could be moved 
> > above cmpxchg_rel?
> 
> Hmmm.... We should call this MODE_BARRIER I guess...
>  
I arrived at the conclusion that "fence" is a better term, at least in
user-level code.  "Barrier" seems to generate confusion with
"pthread_barrier_wait" and similar constructs, which are a different
kind of beast.

Hans
