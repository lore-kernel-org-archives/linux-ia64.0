From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Wed, 27 Jan 2016 23:35:04 +0000
Subject: Re: [PATCH] documentation: Add disclaimer
Message-Id: <20160127233504.GP4503@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114120445.GB15828@arm.com> <56980145.5030901@imgtec.com>
	<20160114204827.GE3818@linux.vnet.ibm.com>
	<56981212.7050301@imgtec.com>
	<20160114222046.GH3818@linux.vnet.ibm.com>
	<20160126102402.GE6357@twins.programming.kicks-ass.net>
	<20160126103200.GI6375@twins.programming.kicks-ass.net>
	<20160126110053.GA21553@arm.com>
	<20160126201143.GV4503@linux.vnet.ibm.com>
	<15882.1453906627@warthog.procyon.org.uk>
In-Reply-To: <15882.1453906627@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutr>

On Wed, Jan 27, 2016 at 02:57:07PM +0000, David Howells wrote:
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > +=====
> > +DISCLAIMER
> > +=====
> > +
> > +This document is not a specification; it is intentionally (for the sake of
> > +brevity) and unintentionally (due to being human) incomplete. This document is
> > +meant as a guide to using the various memory barriers provided by Linux, but
> > +in case of any doubt (and there are many) please ask.
> > +
> > +I repeat, this document is not a specification of what Linux expects from
> > +hardware.
> 
> The purpose of this document is twofold:
> 
>  (1) to specify the minimum functionality that one can rely on for any
>      particular barrier, and
> 
>  (2) to provide a guide as to how to use the barriers that are available.
> 
> Note that an architecture can provide more than the minimum requirement for
> any particular barrier, but if the barrier provides less than that, it is
> incorrect.
> 
> Note also that it is possible that a barrier may be a no-op for an
> architecture because the way that arch works renders an explicit barrier
> unnecessary in that case.
> 
> > +
> 
> Can you bung an extra blank line in here if you have to redo this at all?
> 
> > +====
> > +CONTENTS
> > +====
> >  
> >   (*) Abstract memory access model.

Good point!  Would you be willing to add a Signed-off-by so I
can take the combined change, assuming Peter and Will are good
with it?

							Thanx, Paul

