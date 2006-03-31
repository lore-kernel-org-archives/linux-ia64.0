From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 01:04:23 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310103.k2V13cg27083@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301653200.2068@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 4:55 PM
> > We are talking about arch specific implementation of clear_bit and smp_mb_*.
> > Yes, for generic code, clear_bit has no implication of memory ordering, but
> > for arch specific code, one should optimize those three functions with the
> > architecture knowledge of exactly what's happening under the hood.
> 
> Arch specific code should make this explicit too and not rely on implied 
> semantics. Otherwise one has to memorize that functions have to work with 
> different semantics in arch code and core code which makes the source 
> code difficult to maintain.

I don't know whether we are talking about the same thing: I propose for ia64:
clear_bit to have release semantic, smp_mb__before_clear_bit will be a noop, smp_mb_after_clear_bit will be a smp_mb().

Caller are still required to use smp_mb__before_clear_bit if it requires, on
ia64, that function will simply be a noop.

- Ken
