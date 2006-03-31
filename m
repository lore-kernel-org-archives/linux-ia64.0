From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 18:57:08 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603311856.k2VIuPg04814@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <442CDB98.80803@yahoo.com.au>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: 'Christoph Lameter' <clameter@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Thursday, March 30, 2006 11:35 PM
> > >The memory ordering that above combination should produce is a
> > >Linux style smp_mb before the clear_bit. Not a release.
> > 
> > Whoever designed the smp_mb_before/after_* clearly understand the
> > difference between a bidirectional smp_mb() and a one-way memory
> > ordering.  If smp_mb_before/after are equivalent to smp_mb, what's
> > the point of introducing another interface?
> > 
> They are not. They provide equivalent barrier when performed
> before/after a clear_bit, there is a big difference.

The usage so far that I can see for

  smp_mb__before_clear_bit()
  clear_bit

is to close a critical section with clear_bit.  I will be hard impressed
to see a usage that allows stuff follows clear_bit to pass clear_bit, but
not to pass the smp_mb_before_xxx.

<end of critical section>
  smp_mb_before_clear_bit
  clear_bit
<begin other code>

But if you stand on the ground of smp_mb_before_xxx protects clear_bit
from occurring before the "end of critical section", then smp_mb_before
is such a brain dead interface and it is another good reason for having
an explicit ordering mode built into the clear_bit. 
