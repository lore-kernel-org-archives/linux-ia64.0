From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 00:53:11 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310052.k2V0qQg26856@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301639530.2068@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 4:43 PM
> > > Note that the current semantics for bitops IA64 are broken. Both
> > > smp_mb__after/before_clear_bit are now set to full memory barriers
> > > to compensate
> > 
> > Why you say that?  clear_bit has built-in acq or rel semantic depends
> > on how you define it. I think only one of smp_mb__after/before need to
> > be smp_mb?
> 
> clear_bit has no barrier semantics just acquire. Therefore both smp_mb_* 
> need to be barriers or they need to add some form of "release".

We are talking about arch specific implementation of clear_bit and smp_mb_*.
Yes, for generic code, clear_bit has no implication of memory ordering, but
for arch specific code, one should optimize those three functions with the
architecture knowledge of exactly what's happening under the hood.

- Ken
