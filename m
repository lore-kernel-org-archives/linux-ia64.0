From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 00:59:52 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310059.k2V0x7g26953@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301650220.2068@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 4:51 PM
> > > It precise the uncleanness in ia64 that such semantics are attached to 
> > > these bit operations which may lead people to depend on those. We need to 
> > > either make these explicit or not depend on them.
> > 
> > I know, I'm saying since it doesn't make any difference from API point of
> > view whether it is acq, rel, or no ordering, then just make them rel as a
> > "preferred" Operation on ia64.
> 
> That would make the behavior of clear_bit different from other bitops and 
> references to volatile pointers. I'd like to have this as consistent as 
> possible.

Yeah, but we just agreed that caller shouldn't be thinking clear_bit has
memory ordering at all.

- Ken
