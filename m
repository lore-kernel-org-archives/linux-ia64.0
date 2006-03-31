From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 00:45:09 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301642330.2068@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310038.k2V0crg26704@unix-os.sc.intel.com>
In-Reply-To: <200603310038.k2V0crg26704@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> >  static __inline__ void
> >  clear_bit (int nr, volatile void *addr)
> >  {
> > -	__u32 mask, old, new;
> > -	volatile __u32 *m;
> > -	CMPXCHG_BUGCHECK_DECL
> > -
> > -	m = (volatile __u32 *) addr + (nr >> 5);
> > -	mask = ~(1 << (nr & 31));
> > -	do {
> > -		CMPXCHG_BUGCHECK(m);
> > -		old = *m;
> > -		new = old & mask;
> > -	} while (cmpxchg_acq(m, old, new) != old);
> > +	clear_bit_mode(nr, addr, MODE_ATOMIC);
> >  }
> 
> I would make that MODE_RELEASE for clear_bit, simply to match the
> observation that clear_bit is usually used in unlock path and have
> potential less surprises.

clear_bit per se is defined as an atomic operation with no implications 
for release or acquire. If it is used for release then either add the 
appropriate barrier or use MODE_RELEASE explicitly.

It precise the uncleanness in ia64 that such semantics are attached to 
these bit operations which may lead people to depend on those. We need to 
either make these explicit or not depend on them.


