From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 00:42:31 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301639530.2068@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603310038.k2V0crg26704@unix-os.sc.intel.com>
In-Reply-To: <200603310038.k2V0crg26704@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 30 Mar 2006, Chen, Kenneth W wrote:

> Christoph Lameter wrote on Thursday, March 30, 2006 4:18 PM
> > Note that the current semantics for bitops IA64 are broken. Both
> > smp_mb__after/before_clear_bit are now set to full memory barriers
> > to compensate
> 
> Why you say that?  clear_bit has built-in acq or rel semantic depends
> on how you define it. I think only one of smp_mb__after/before need to
> be smp_mb?

clear_bit has no barrier semantics just acquire. Therefore both smp_mb_* 
need to be barriers or they need to add some form of "release".


> > +static __inline__ void
> > +set_bit_mode (int nr, volatile void *addr, int mode)
> > +{
> > +	__u32 bit, old, new;
> > +	volatile __u32 *m;
> > +	CMPXCHG_BUGCHECK_DECL
> > +
> > +	m = (volatile __u32 *) addr + (nr >> 5);
> > +	bit = 1 << (nr & 31);
> > +
> > +	if (mode = MODE_NON_ATOMIC) {
> > +		*m |= bit;
> > +		return;
> > +	}
> 
> Please kill all volatile declaration, because for non-atomic version,
> you don't need to do any memory ordering, but compiler automatically
> adds memory order because of volatile.  It's safe to kill them because
> cmpxchg later has explicit mode in there.

Ok. V3 will have that.
