From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 19:41:11 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603311940.k2VJeRg05420@unix-os.sc.intel.com>
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
> > Whoever designed the smp_mb_before/after_* clearly understand the
> > difference between a bidirectional smp_mb() and a one-way memory
> > ordering.  If smp_mb_before/after are equivalent to smp_mb, what's
> > the point of introducing another interface?
> > 
> 
> They are not. They provide equivalent barrier when performed
> before/after a clear_bit, there is a big difference.

Just to give another blunt brutal example, what is said here is equivalent
to say kernel requires:

   <end of critical section>
   smp_mb_before_spin_unlock
   spin_unlock

Because it is undesirable to have spin_unlock to leak into the critical
Section and allow critical section to leak after spin_unlock.  This is
just plain brain dead.
