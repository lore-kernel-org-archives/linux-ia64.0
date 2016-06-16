From: Boqun Feng <boqun.feng@gmail.com>
Date: Thu, 16 Jun 2016 02:19:51 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160616021951.GA16918@insomnia>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615080446.GA28443@insomnia>
 <5761A5FF.5070703@hpe.com>
In-Reply-To: <5761A5FF.5070703@hpe.com>
To: Waiman Long <waiman.long@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Will Deacon <will.deacon@arm.com>


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 15, 2016 at 03:01:19PM -0400, Waiman Long wrote:
> On 06/15/2016 04:04 AM, Boqun Feng wrote:
> > Hi Waiman,
> >=20
> > On Tue, Jun 14, 2016 at 06:48:04PM -0400, Waiman Long wrote:
> > > The osq_lock() and osq_unlock() function may not provide the necessary
> > > acquire and release barrier in some cases. This patch makes sure
> > > that the proper barriers are provided when osq_lock() is successful
> > > or when osq_unlock() is called.
> > >=20
> > > Signed-off-by: Waiman Long<Waiman.Long@hpe.com>
> > > ---
> > >   kernel/locking/osq_lock.c |    4 ++--
> > >   1 files changed, 2 insertions(+), 2 deletions(-)
> > >=20
> > > diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
> > > index 05a3785..7dd4ee5 100644
> > > --- a/kernel/locking/osq_lock.c
> > > +++ b/kernel/locking/osq_lock.c
> > > @@ -115,7 +115,7 @@ bool osq_lock(struct optimistic_spin_queue *lock)
> > >   	 * cmpxchg in an attempt to undo our queueing.
> > >   	 */
> > >=20
> > > -	while (!READ_ONCE(node->locked)) {
> > > +	while (!smp_load_acquire(&node->locked)) {
> > >   		/*
> > >   		 * If we need to reschedule bail... so we can block.
> > >   		 */
> > > @@ -198,7 +198,7 @@ void osq_unlock(struct optimistic_spin_queue *loc=
k)
> > >   	 * Second most likely case.
> > >   	 */
> > >   	node =3D this_cpu_ptr(&osq_node);
> > > -	next =3D xchg(&node->next, NULL);
> > > +	next =3D xchg_release(&node->next, NULL);
> > >   	if (next) {
> > >   		WRITE_ONCE(next->locked, 1);
> > So we still use WRITE_ONCE() rather than smp_store_release() here?
> >=20
> > Though, IIUC, This is fine for all the archs but ARM64, because there
> > will always be a xchg_release()/xchg() before the WRITE_ONCE(), which
> > carries a necessary barrier to upgrade WRITE_ONCE() to a RELEASE.
> >=20
> > Not sure whether it's a problem on ARM64, but I think we certainly need
> > to add some comments here, if we count on this trick.
> >=20
> > Am I missing something or misunderstanding you here?
> >=20
> > Regards,
> > Boqun
>=20
> The change on the unlock side is more for documentation purpose than is
> actually needed. As you had said, the xchg() call has provided the necess=
ary
> memory barrier. Using the _release variant, however, may have some

But I'm afraid the barrier doesn't remain if we replace xchg() with
xchg_release() on ARM64v8, IIUC, xchg_release() is just a ldxr+stlxr
loop with no barrier on ARM64v8. This means the following code:

	CPU 0					CPU 1 (next)
	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D		=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
	WRITE_ONCE(x, 1);			r1 =3D smp_load_acquire(next->locked, 1);
	xchg_release(&node->next, NULL);	r2 =3D READ_ONCE(x);
	WRITE_ONCE(next->locked, 1);

could result in (r1 =3D=3D 1 && r2 =3D=3D 0) on ARM64v8, IIUC.

I translated it into a litmus test:

	AArch64 stlxr+str
	""
	{
	0:X4=3Dx; 0:X5=3Dnode; node=3Dnext;
	1:X4=3Dx; 1:X5=3Dnext;
	}
	 P0              | P1          ;
	 MOV W0,#1       | LDAR W1,[X5];
	 STR W0,[X4]     | LDR W2,[X4] ;
	 MOV X0,#0       |             ;
	 LDXR X2,[X5]    |             ;
	 STLXR W1,X0,[X5]|             ;
	 CBNZ W1, fail   |             ;
	 MOV W0, #1      |             ;
	 STR W0,[X2]     |             ;
	 fail:           |             ;

	exists
	(0:X0 =3D 1 /\ 1:X1 =3D 1 /\ 1:X2 =3D 0)

and herd said "Sometimes".

But I may miss something here or make a mistake in the translation. So
add Will in Cc list ;-)

> performance benefit in some architectures.
>=20
> BTW, osq_lock/osq_unlock aren't general purpose locking primitives. So th=
ere
> is some leeways on how fancy we want on the lock and unlock sides.
>=20

Understood, I think it's fine if we rely on something subtle here, but
I just want to make we won't be bitten by some corner cases.

Regards,
Boqun

> Cheers,
> Longman

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXYgzBAAoJEEl56MO1B/q4Py4H/30cxqC4BO2n1w2GuuXqRu3d
VzpF/HppsSLqBNxd1bR41TFpQg2q6DETh938Dei2LC4w1ONN9DpjXY0rELoPK6ea
V9rl7eeHPeB7tOmnyYujwpnfKSflCukEv595vf9T2Ql37rwM7U96ANqedM/rZg7v
x7q9HvtyChoWQ52NCBNb/+ZaUrdb775pG9iYOqo4WIvTkUueA7xVzESWjq4D8u4g
mCZrJ2Ja7g1GRaRH96Bwv4/iZTygtEkVJtjzaOLUtZclqKUPwpP7ufKml9Dbzbss
rmjZ6Y9028NFPyP1u6w8fpH2MeEDZbyZ3ge80RsVHKkduAZEfTdWeJL18F/c1hk=
=gHkT
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
