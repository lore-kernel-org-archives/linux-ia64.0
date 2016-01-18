From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Mon, 18 Jan 2016 15:46:29 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160118154629.GB3818@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114204827.GE3818@linux.vnet.ibm.com>
	<20160118081929.GA30420@gondor.apana.org.au>
In-Reply-To: <20160118081929.GA30420@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, mst@redhat.com, peterz@infradead.org, will.deacon@arm.com, virtualization@lists.linux-foundation.org, hpa@zytor.com, sparclinux@vger.kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux@arm.linux.org.uk, arnd@arndb.de, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, xen-devel@lists.xenproject.org, mingo@elte.hu, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, user-mode-linux-devel@lists.sourceforge.net, stefano.stabellini@eu.citrix.com, adi-buildroot-devel@lists.sourceforge.net, Leonid.Yegoshin@imgtec.com, ddaney.cavm@gmail.com, tglx@linutronix.de, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, andrew.cooper3@citrix.com, linux-kernel@vger.kernel.org, ralf@linux-mips.org, joe@perches.com

On Mon, Jan 18, 2016 at 04:19:29PM +0800, Herbert Xu wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> >
> > You could use SYNC_ACQUIRE() to implement read_barrier_depends() and
> > smp_read_barrier_depends(), but SYNC_RMB probably does not suffice.
> > The reason for this is that smp_read_barrier_depends() must order the
> > pointer load against any subsequent read or write through a dereference
> > of that pointer.  For example:
> > 
> >        p = READ_ONCE(gp);
> >        smp_rmb();
> >        r1 = p->a; /* ordered by smp_rmb(). */
> >        p->b = 42; /* NOT ordered by smp_rmb(), BUG!!! */
> >        r2 = x; /* ordered by smp_rmb(), but doesn't need to be. */
> > 
> > In contrast:
> > 
> >        p = READ_ONCE(gp);
> >        smp_read_barrier_depends();
> >        r1 = p->a; /* ordered by smp_read_barrier_depends(). */
> >        p->b = 42; /* ordered by smp_read_barrier_depends(). */
> >        r2 = x; /* not ordered by smp_read_barrier_depends(), which is OK. */
> > 
> > Again, if your hardware maintains local ordering for address
> > and data dependencies, you can have read_barrier_depends() and
> > smp_read_barrier_depends() be no-ops like they are for most
> > architectures.
> > 
> > Does that help?
> 
> This is crazy! smp_rmb started out being strictly stronger than
> smp_read_barrier_depends, when did this stop being the case?

Hello, Herbert!

It is true that most Linux kernel code relies only on the read-read
properties of dependencies, but the read-write properties are useful.
Admittedly relatively rarely, but useful.

The better comparison for smp_read_barrier_depends(), especially in
its rcu_dereference*() form, is smp_load_acquire().

							Thanx, Paul

