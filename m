From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Apr 2005 01:48:34 +0000
Subject: RE: write_unlock: replace clear_bit with byte store
Message-Id: <200504290148.j3T1mZg12459@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Thursday, April 28, 2005 6:04 PM
> Christoph Lameter wrote on Thursday, April 28, 2005 5:51 PM
> 
> > +static inline void _raw_write_unlock(rwlock_t *x) {
> > +	barrier();
> > +	x->write_lock = 0;
> > +}
> > +
> >  #endif /* !ASM_SUPPORTED */
> 
> This portion is broken, where is the release semantics for updating
> the lock variable?  Or where is the smp_mb() if you decide to use an
> unordered store for the lock variable?

Oops, never mind.  Missed the portion that write_lock is declared as
volatile.  My bad.  This code is OK.

