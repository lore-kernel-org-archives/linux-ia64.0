From: Boqun Feng <boqun.feng@gmail.com>
Date: Tue, 26 Jan 2016 16:52:07 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160126165207.GB6029@fixme-laptop.cn.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="LyciRD1jyfeSSjG0"
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114204827.GE3818@linux.vnet.ibm.com>
 <20160118081929.GA30420@gondor.apana.org.au>
 <20160118154629.GB3818@linux.vnet.ibm.com>
In-Reply-To: <20160118154629.GB3818@linux.vnet.ibm.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Leonid.Yegoshin@imgtec.com, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, mst@redhat.com, peterz@infradead.org, will.deacon@arm.com, virtualization@lists.linux-foundation.org, hpa@zytor.com, sparclinux@vger.kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux@arm.linux.org.uk, user-mode-linux-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, mpe@ellerman.id.au, x86@kernel.org, xen-devel@lists.xenproject.org, mingo@elte.hu, linux-xtensa@linux-xtensa.org, james.hogan@imgtec.com, arnd@arndb.de, stefano.stabellini@eu.citrix.com, adi-buildroot-devel@lists.sourceforge.net, ddaney.cavm@gmail.com, tglx@linutronix.de, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, andrew.cooper3@citrix.com, linux-kernel@vger.kernel.org, ralf@linux-mips.org, joe@perches.com, linuxp


--LyciRD1jyfeSSjG0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Paul,

On Mon, Jan 18, 2016 at 07:46:29AM -0800, Paul E. McKenney wrote:
> On Mon, Jan 18, 2016 at 04:19:29PM +0800, Herbert Xu wrote:
> > Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > >
> > > You could use SYNC_ACQUIRE() to implement read_barrier_depends() and
> > > smp_read_barrier_depends(), but SYNC_RMB probably does not suffice.
> > > The reason for this is that smp_read_barrier_depends() must order the
> > > pointer load against any subsequent read or write through a dereferen=
ce
> > > of that pointer.  For example:
> > >=20
> > >        p =3D READ_ONCE(gp);
> > >        smp_rmb();
> > >        r1 =3D p->a; /* ordered by smp_rmb(). */
> > >        p->b =3D 42; /* NOT ordered by smp_rmb(), BUG!!! */
> > >        r2 =3D x; /* ordered by smp_rmb(), but doesn't need to be. */
> > >=20
> > > In contrast:
> > >=20
> > >        p =3D READ_ONCE(gp);
> > >        smp_read_barrier_depends();
> > >        r1 =3D p->a; /* ordered by smp_read_barrier_depends(). */
> > >        p->b =3D 42; /* ordered by smp_read_barrier_depends(). */
> > >        r2 =3D x; /* not ordered by smp_read_barrier_depends(), which =
is OK. */
> > >=20
> > > Again, if your hardware maintains local ordering for address
> > > and data dependencies, you can have read_barrier_depends() and
> > > smp_read_barrier_depends() be no-ops like they are for most
> > > architectures.
> > >=20
> > > Does that help?
> >=20
> > This is crazy! smp_rmb started out being strictly stronger than
> > smp_read_barrier_depends, when did this stop being the case?
>=20
> Hello, Herbert!
>=20
> It is true that most Linux kernel code relies only on the read-read
> properties of dependencies, but the read-write properties are useful.
> Admittedly relatively rarely, but useful.
>=20
> The better comparison for smp_read_barrier_depends(), especially in
> its rcu_dereference*() form, is smp_load_acquire().
>=20

Confused..

I recall that last time you and Linus came into a conclusion that even
on Alpha, a barrier for read->write with data dependency is unnecessary:

http://article.gmane.org/gmane.linux.kernel/2077661

And in an earlier mail of that thread, Linus made his point that
smp_read_barrier_depends() should only be used to order read->read.

So right now, are we going to extend the semantics of
smp_read_barrier_depends()? Can we just make smp_read_barrier_depends()
still only work for read->read, and assume all the architectures won't
reorder read->write with data dependency, so that the code above having
a smp_rmb() also works?

Regards,
Boqun

--LyciRD1jyfeSSjG0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWp6QvAAoJEEl56MO1B/q4pKoIAJPOsJ2T06GUg0wVhH82BU2R
ZlkpggDwyKR/oUt7FdAj9Kzxq1ZMBfqOdIzwH81kpg0h4Z5fBOvAx3FXdBUb0rqS
jkpd0eqRH0Ur1dPo3Mp9TvD3yPS51obs5HnpOE/E9WAMQcx7nDgjuqNHxSIJj1yG
9qc/WDqt7WgQZaNoD9/3Y+JAtM0YfukMVfxTI7OoJdnZCKDa0jO3YExgC2SJVAEF
0iB28yCN9OM2VSBNGdAnaQErCEL/GEi1Dzh6eI2UYPYfxBOL1EMMi9z97/00f7aS
ZRJFahwgFqy/hJNbT7v3VWcBoYdj5vJxwjHZmR6seJsmo24GfJV9huS9tS8606w=
=xJxv
-----END PGP SIGNATURE-----

--LyciRD1jyfeSSjG0--
