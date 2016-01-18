From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Jan 2016 08:19:29 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160118081929.GA30420@gondor.apana.org.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114204827.GE3818@linux.vnet.ibm.com>
In-Reply-To: <20160114204827.GE3818@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: paulmck@linux.vnet.ibm.com
Cc: Leonid.Yegoshin@imgtec.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, mst@redhat.com, peterz@infradead.org, will.deacon@arm.com, virtualization@lists.linux-foundation.org, hpa@zytor.com, sparclinux@vger.kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux@arm.linux.org.uk, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, xen-devel@lists.xenproject.org, mingo@elte.hu, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, arnd@arndb.de, stefano.stabellini@eu.citrix.com, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, tglx@linutronix.de, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, andrew.cooper3@citrix.com, linux-kernel@vger.kernel.org, ralf@linux-mips.org, joe@perches.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.ne

Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
>
> You could use SYNC_ACQUIRE() to implement read_barrier_depends() and
> smp_read_barrier_depends(), but SYNC_RMB probably does not suffice.
> The reason for this is that smp_read_barrier_depends() must order the
> pointer load against any subsequent read or write through a dereference
> of that pointer.  For example:
> 
>        p = READ_ONCE(gp);
>        smp_rmb();
>        r1 = p->a; /* ordered by smp_rmb(). */
>        p->b = 42; /* NOT ordered by smp_rmb(), BUG!!! */
>        r2 = x; /* ordered by smp_rmb(), but doesn't need to be. */
> 
> In contrast:
> 
>        p = READ_ONCE(gp);
>        smp_read_barrier_depends();
>        r1 = p->a; /* ordered by smp_read_barrier_depends(). */
>        p->b = 42; /* ordered by smp_read_barrier_depends(). */
>        r2 = x; /* not ordered by smp_read_barrier_depends(), which is OK. */
> 
> Again, if your hardware maintains local ordering for address
> and data dependencies, you can have read_barrier_depends() and
> smp_read_barrier_depends() be no-ops like they are for most
> architectures.
> 
> Does that help?

This is crazy! smp_rmb started out being strictly stronger than
smp_read_barrier_depends, when did this stop being the case?
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
