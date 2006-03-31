From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 31 Mar 2006 03:23:10 +0000
Subject: RE: Synchronizing Bit operations V2
Message-Id: <200603310322.k2V3MPg28583@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603301909590.3145@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@bull.net>, "Boehm, Hans" <hans.boehm@hp.com>, "Grundler, Grant G" <grant.grundler@hp.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 30, 2006 7:12 PM
> > > We are talking about IA64 and IA64 only generates an single instruction 
> > > with either release or acquire semantics for the case in which either 
> > > smb_mb__before/after_clear_bit does nothing.
> > > 
> > > Neither acquire nor release is a memory barrier on IA64.
> > 
> > 
> > The use of
> >         smp_mb__before_clear_bit();
> >         clear_bit( ... );
> > 
> > is: all memory operations before this call will be visible before
> > the clear_bit().  To me, that's release semantics.
> 
> What of it? Release semantics are not a full fence or memory barrier.
> 
> > On ia64, we map the following:
> > #define Smp_mb__before_clear_bit      do { } while (0)
> > #define clear_bit                     clear_bit_mode(..., RELEASE)
> > 
> > Which looked perfect fine to me.  I don't understand why you say it does
> > not provide memory ordering.
> 
> It does not provide a memory barrier / fence. Later memory references can 
> still be moved by the processor above the instruction with release semantics.


This is probably a classic example of a sucky name leads to confusion.
There are smp_mb_ in the name, however, the semantics is really defined
as a one-way memory barrier and probably is the main reason of contention
in this discussion :-(

Another good reason to get rid of this silly smp_mb_before/after_clear_bit.

- Ken



wrong confusing implementation
