From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 06:15:28 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310614.k2V6Ehg30012@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <442C99A1.6060901@yahoo.com.au>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: 'Christoph Lameter' <clameter@sgi.com>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Nick Piggin wrote on Thursday, March 30, 2006 6:53 PM
> >>smp_mb__before_clear_bit()
> >>clear_bit(...)(
> > 
> > Sorry, you totally lost me.  It could me I'm extremely slow today.  For
> > option (1), on ia64, clear_bit has release semantic already.  The comb
> > of __before_clear_bit + clear_bit provides the required ordering.  Did
> > I miss something?  By the way, we are talking about detail implementation
> > on one specific architecture.  Not some generic concept that clear_bit
> > has no ordering stuff in there.
> > 
> 
> The memory ordering that above combination should produce is a
> Linux style smp_mb before the clear_bit. Not a release.

Whoever designed the smp_mb_before/after_* clearly understand the
difference between a bidirectional smp_mb() and a one-way memory
ordering.  If smp_mb_before/after are equivalent to smp_mb, what's
the point of introducing another interface?

- Ken
