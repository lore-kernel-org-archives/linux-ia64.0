From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Thu, 14 Jan 2016 20:48:27 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160114204827.GE3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160112102555.GV6373@twins.programming.kicks-ass.net>
	<20160112104012.GW6373@twins.programming.kicks-ass.net>
	<20160112114111.GB15737@arm.com> <569565DA.2010903@imgtec.com>
	<20160113104516.GE25458@arm.com> <56969F4B.7070001@imgtec.com>
	<20160113204844.GV6357@twins.programming.kicks-ass.net>
	<5696BA6E.4070508@imgtec.com> <20160114120445.GB15828@arm.com>
	<56980145.5030901@imgtec.com>
In-Reply-To: <56980145.5030901@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, virtualization@lists.linux-foundation.org, "H. Peter Anvin" <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, Arnd Bergmann <arnd@arndb.de>, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, Thomas Gleixner <tglx@linutronix.de>, linux-metag@vger.kernel.orglinux-a

On Thu, Jan 14, 2016 at 12:12:53PM -0800, Leonid Yegoshin wrote:
> On 01/14/2016 04:04 AM, Will Deacon wrote:
> >Consequently, it's important that the architecture back-ends
> >implement these portable primitives (e.g. smp_mb()) in a way that
> >satisfies the kernel memory model so that core code doesn't need
> >to worry about the underlying architecture for synchronisation
> >purposes.
> 
> It seems you don't listen me. I said multiple times - MIPS
> implementation of
> SYNC_RMB/SYNC_WMB/SYNC_MB/SYNC_ACQUIRE/SYNC_RELEASE instructions
> matches the description of
> smp_rmb/smp_wmb/smp_mb/sync_acquire/sync_release from
> Documentation/memory-barriers.txt file.
> 
> What else do you want from me - RTL or microArch design for that?

I suspect that it is more likely that we are talking past each other.
This stuff is subtle and although we have better ways of talking about
it than (say) ten years ago, it is subtle.  Two ways of talking about
it are herd and ppcmem.

The overview of ppcmem (AKA armmem and cppmem) is here:
https://www.cl.cam.ac.uk/~pes20/ppcmem/help.html

The intro to herd is here: http://arxiv.org/pdf/1308.6810v5.pdf
It may be downloaded here: http://diy.inria.fr/herd/

As a very rough rule of thumb, herd is faster and easier to use
and ppcmem is more precise.

So SYNC_RMB is intended to implement smp_rmb(), correct?

You could use SYNC_ACQUIRE() to implement read_barrier_depends() and
smp_read_barrier_depends(), but SYNC_RMB probably does not suffice.
The reason for this is that smp_read_barrier_depends() must order the
pointer load against any subsequent read or write through a dereference
of that pointer.  For example:

	p = READ_ONCE(gp);
	smp_rmb();
	r1 = p->a; /* ordered by smp_rmb(). */
	p->b = 42; /* NOT ordered by smp_rmb(), BUG!!! */
	r2 = x; /* ordered by smp_rmb(), but doesn't need to be. */

In contrast:

	p = READ_ONCE(gp);
	smp_read_barrier_depends();
	r1 = p->a; /* ordered by smp_read_barrier_depends(). */
	p->b = 42; /* ordered by smp_read_barrier_depends(). */
	r2 = x; /* not ordered by smp_read_barrier_depends(), which is OK. */

Again, if your hardware maintains local ordering for address
and data dependencies, you can have read_barrier_depends() and
smp_read_barrier_depends() be no-ops like they are for most
architectures.

Does that help?

							Thanx, Paul

