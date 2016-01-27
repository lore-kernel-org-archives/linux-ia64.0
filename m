From: Boqun Feng <boqun.feng@gmail.com>
Date: Wed, 27 Jan 2016 02:04:47 +0000
Subject: Re: [v3,11/41] mips: reuse asm-generic/barrier.h
Message-Id: <20160127020447.GA1293@fixme-laptop.cn.ibm.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
List-Id: <linux-ia64.vger.kernel.org>
References: <20160114204827.GE3818@linux.vnet.ibm.com>
 <20160118081929.GA30420@gondor.apana.org.au>
 <20160118154629.GB3818@linux.vnet.ibm.com>
 <20160126165207.GB6029@fixme-laptop.cn.ibm.com>
 <20160126172227.GG6357@twins.programming.kicks-ass.net>
 <CA+55aFzcC6C8imPs5vk4yH1Y2YHjnAdFM9HCkVs04COxuDQH6w@mail.gmail.com>
 <20160126201037.GU4503@linux.vnet.ibm.com>
 <CA+55aFxjb+2rs2wVHtiSCcOzgMrE8H=yDeNcjyujPQudDCtLgw@mail.gmail.com>
 <CA+55aFwxTJd+uibcxtZD3tGnj_n=LMwyAa0s8qyx_OF0OMWQkA@mail.gmail.com>
 <20160126232921.GY4503@linux.vnet.ibm.com>
In-Reply-To: <20160126232921.GY4503@linux.vnet.ibm.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Herbert Xu <herbert@gondor.apana.org.au>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, linux-mips <linux-mips@linux-mips.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, Will Deacon <will.deacon@arm.com>, virtualization <virtualization@lists.linux-foundation.org>, Peter Anvin <hpa@zytor.com>, sparclinux@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, uml-devel <user-mode-linux-devel@lists.sourceforge.net>, linux-sh@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, the arch/x86 maintainers <x86@kernel.org>, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@elte.hu>


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 26, 2016 at 03:29:21PM -0800, Paul E. McKenney wrote:
> On Tue, Jan 26, 2016 at 02:33:40PM -0800, Linus Torvalds wrote:
> > On Tue, Jan 26, 2016 at 2:15 PM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> > >
> > > You might as well just write it as
> > >
> > >     struct foo x =3D READ_ONCE(*ptr);
> > >     x->bar =3D 5;
> > >
> > > because that "smp_read_barrier_depends()" does NOTHING wrt the second=
 write.
> >=20
> > Just to clarify: on alpha it adds a memory barrier, but that memory
> > barrier is useless.
>=20
> No trailing data-dependent read, so agreed, no smp_read_barrier_depends()
> needed.  That said, I believe that we should encourage rcu_dereference*()
> or lockless_dereference() instead of READ_ONCE() for documentation
> reasons, though.
>=20
> > On non-alpha, it is a no-op, and obviously does nothing simply because
> > it generates no code.
> >=20
> > So if anybody believes that the "smp_read_barrier_depends()" does
> > something, they are *wrong*.
>=20
> The other problem with smp_read_barrier_depends() is that it is often
> a pain figuring out which prior load it is supposed to apply to.
> Hence my preference for rcu_dereference*() and lockless_dereference().
>=20

Because semantically speaking, rcu_derefence*() and
lockless_dereference() are CONSUME(i.e. data/address dependent
read->read and read->write pairs are ordered), whereas
smp_read_barrier_depends() only guarantees read->read pairs with data
dependency are ordered, right?

If so, maybe we need to call it out in memory-barriers.txt, for example:

diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barri=
ers.txt
index 904ee42..6b262c2 100644
--- a/Documentation/memory-barriers.txt
+++ b/Documentation/memory-barriers.txt
@@ -1703,8 +1703,8 @@ There are some more advanced barrier functions:
=20
=20
  (*) lockless_dereference();
-     This can be thought of as a pointer-fetch wrapper around the
-     smp_read_barrier_depends() data-dependency barrier.
+     This is a load, and any load or store that has a data dependency on t=
he
+     value returned by this load won't be reordered before this load.
=20
      This is also similar to rcu_dereference(), but in cases where
      object lifetime is handled by some mechanism other than RCU, for


Regards,
Boqun

> > And if anybody sends out an email with that smp_read_barrier_depends()
> > in an example, they are actively just confusing other people, which is
> > even worse than just being wrong. Which is why I jumped in.
> >=20
> > So stop perpetuating the myth that smp_read_barrier_depends() does
> > something here. It does not. It's a bug, and it has become this "mind
> > virus" for some people that seem to believe that it does something.
>=20
> It looks like I should add words to memory-barriers.txt de-emphasizing
> smp_read_barrier_depends().  I will take a look at that.
>=20
> > I had to remove this crap once from the kernel already, see commit
> > 105ff3cbf225 ("atomic: remove all traces of READ_ONCE_CTRL() and
> > atomic*_read_ctrl()").
> >=20
> > I don't want to ever see that broken construct again. And I want to
> > make sure that everybody is educated about how broken it was. I'm
> > extremely unhappy that it came up again.
>=20
> Well, if it makes you feel better, that was control dependencies and this
> was data dependencies.  So it was not -exactly- the same.  ;-)
>=20
> (Sorry, couldn't resist...)
>=20
> > If it turns out that some architecture does actually need a barrier
> > between a read and a dependent write, then that will mean that
> >=20
> >  (a) we'll have to make up a _new_ barrier, because
> > "smp_read_barrier_depends()" is not that barrier. We'll presumably
> > then have to make that new barrier part of "rcu_derefence()" and
> > friends.
>=20
> Agreed.  We can worry about whether or not we replace the current
> smp_read_barrier_depends() with that new barrier when and if such
> hardware appears.
>=20
> >  (b) we will have found an architecture with even worse memory
> > ordering semantics than alpha, and we'll have to stop castigating
> > alpha for being the worst memory ordering ever.
>=20
> ;-) ;-) ;-)
>=20
> > but I sincerely hope that we'll never find that kind of broken architec=
ture.
>=20
> Apparently at least some hardware vendors are reading memory-barriers.txt,
> so perhaps the odds of that kind of breakage have reduced.
>=20
> 								Thanx, Paul
>=20

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWqCW7AAoJEEl56MO1B/q4s1oH/iHzdn5KSPbNB42xfz6tFsll
f9Zrh2E67bvEmxIbrj8LQ3Mohfu/kKidJ+kB/JFNSTcpDo0TenA4pkcedwVN5VPX
uGlhN2gPpbU4FLIAtefu4htGyXgeeGN/8v3w78nyKh57N1/ZcgFycu16pDIpri/h
JY4KnRfSbK3iakJGdQRjQdb/iSPsJtoFrFUnc9HddUet28CbUF4MHV8si0sUV/LW
M+hCR5X+h+2fjiAtZQvA9NzuQ4TWz3oorL+nKZ86KrWUZc196fJzIK2Gfix23bOk
ABplTs7dOOjtuDkzlxwVnXgP97++iC0poCYqeTW7dm1mpWG361x8yH2rqlXz2wA=
=21MT
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
