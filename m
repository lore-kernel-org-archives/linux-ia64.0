From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 26 Jan 2016 19:51:04 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160126195104.GR4503@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114204827.GE3818@linux.vnet.ibm.com>
	<20160118081929.GA30420@gondor.apana.org.au>
	<20160118154629.GB3818@linux.vnet.ibm.com>
	<20160126165207.GB6029@fixme-laptop.cn.ibm.com>
In-Reply-To: <20160126165207.GB6029@fixme-laptop.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Boqun Feng <boqun.feng@gmail.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, mst@redhat.com, peterz@infradead.org, will.deacon@arm.com, virtualization@lists.linux-foundation.org, hpa@zytor.com, sparclinux@vger.kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux@arm.linux.org.uk, Herbert Xu <herbert@gondor.apana.org.au>, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, xen-devel@lists.xenproject.org, mingo@elte.hu, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, user-mode-linux-devel@lists.sourceforge.net, stefano.stabellini@eu.citrix.com, adi-buildroot-devel@lists.sourceforge.net, Leonid.Yegoshin@imgtec.com, ddaney.cavm@gmail.com, tglx@linutronix.de, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, andrew.cooper3@citrix.com, linux-kernel@vger.kernel.org, ralf@linux-

On Wed, Jan 27, 2016 at 12:52:07AM +0800, Boqun Feng wrote:
> Hi Paul,
> 
> On Mon, Jan 18, 2016 at 07:46:29AM -0800, Paul E. McKenney wrote:
> > On Mon, Jan 18, 2016 at 04:19:29PM +0800, Herbert Xu wrote:
> > > Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > >
> > > > You could use SYNC_ACQUIRE() to implement read_barrier_depends() and
> > > > smp_read_barrier_depends(), but SYNC_RMB probably does not suffice.
> > > > The reason for this is that smp_read_barrier_depends() must order the
> > > > pointer load against any subsequent read or write through a dereference
> > > > of that pointer.  For example:
> > > > 
> > > >        p = READ_ONCE(gp);
> > > >        smp_rmb();
> > > >        r1 = p->a; /* ordered by smp_rmb(). */
> > > >        p->b = 42; /* NOT ordered by smp_rmb(), BUG!!! */
> > > >        r2 = x; /* ordered by smp_rmb(), but doesn't need to be. */
> > > > 
> > > > In contrast:
> > > > 
> > > >        p = READ_ONCE(gp);
> > > >        smp_read_barrier_depends();
> > > >        r1 = p->a; /* ordered by smp_read_barrier_depends(). */
> > > >        p->b = 42; /* ordered by smp_read_barrier_depends(). */
> > > >        r2 = x; /* not ordered by smp_read_barrier_depends(), which is OK. */
> > > > 
> > > > Again, if your hardware maintains local ordering for address
> > > > and data dependencies, you can have read_barrier_depends() and
> > > > smp_read_barrier_depends() be no-ops like they are for most
> > > > architectures.
> > > > 
> > > > Does that help?
> > > 
> > > This is crazy! smp_rmb started out being strictly stronger than
> > > smp_read_barrier_depends, when did this stop being the case?
> > 
> > Hello, Herbert!
> > 
> > It is true that most Linux kernel code relies only on the read-read
> > properties of dependencies, but the read-write properties are useful.
> > Admittedly relatively rarely, but useful.
> > 
> > The better comparison for smp_read_barrier_depends(), especially in
> > its rcu_dereference*() form, is smp_load_acquire().
> 
> Confused..
> 
> I recall that last time you and Linus came into a conclusion that even
> on Alpha, a barrier for read->write with data dependency is unnecessary:
> 
> http://article.gmane.org/gmane.linux.kernel/2077661
> 
> And in an earlier mail of that thread, Linus made his point that
> smp_read_barrier_depends() should only be used to order read->read.

Those examples involved read-to-write with conditionals, as in:

	if (READ_ONCE(a))
		WRITE_ONCE(b, 1);

Without the "if", no ordering is guaranteed on weakly ordered CPUs.
(The volatile accesses keep ordering within the compiler for once...

> So right now, are we going to extend the semantics of
> smp_read_barrier_depends()? Can we just make smp_read_barrier_depends()
> still only work for read->read, and assume all the architectures won't
> reorder read->write with data dependency, so that the code above having
> a smp_rmb() also works?

The semantics of smp_read_barrier_depends() has been both read-to-write
and read-to-read for some time now, this patch just catches the
documentation up with reality.

							Thanx, Paul

