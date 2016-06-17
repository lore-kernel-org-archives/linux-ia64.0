From: Boqun Feng <boqun.feng@gmail.com>
Date: Fri, 17 Jun 2016 00:48:37 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160617004837.GB16918@insomnia>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="s/l3CgOIzMHHjg/5"
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615080446.GA28443@insomnia>
 <5761A5FF.5070703@hpe.com>
 <20160616021951.GA16918@insomnia>
 <57631BBA.9070505@hpe.com>
In-Reply-To: <57631BBA.9070505@hpe.com>
To: Waiman Long <waiman.long@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Will Deacon <will.deacon@arm.com>


--s/l3CgOIzMHHjg/5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 16, 2016 at 05:35:54PM -0400, Waiman Long wrote:
> On 06/15/2016 10:19 PM, Boqun Feng wrote:
> > On Wed, Jun 15, 2016 at 03:01:19PM -0400, Waiman Long wrote:
> > > On 06/15/2016 04:04 AM, Boqun Feng wrote:
> > > > Hi Waiman,
> > > >=20
> > > > On Tue, Jun 14, 2016 at 06:48:04PM -0400, Waiman Long wrote:
> > > > > The osq_lock() and osq_unlock() function may not provide the nece=
ssary
> > > > > acquire and release barrier in some cases. This patch makes sure
> > > > > that the proper barriers are provided when osq_lock() is successf=
ul
> > > > > or when osq_unlock() is called.
> > > > >=20
> > > > > Signed-off-by: Waiman Long<Waiman.Long@hpe.com>
> > > > > ---
> > > > >    kernel/locking/osq_lock.c |    4 ++--
> > > > >    1 files changed, 2 insertions(+), 2 deletions(-)
> > > > >=20
> > > > > diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
> > > > > index 05a3785..7dd4ee5 100644
> > > > > --- a/kernel/locking/osq_lock.c
> > > > > +++ b/kernel/locking/osq_lock.c
> > > > > @@ -115,7 +115,7 @@ bool osq_lock(struct optimistic_spin_queue *l=
ock)
> > > > >    	 * cmpxchg in an attempt to undo our queueing.
> > > > >    	 */
> > > > >=20
> > > > > -	while (!READ_ONCE(node->locked)) {
> > > > > +	while (!smp_load_acquire(&node->locked)) {
> > > > >    		/*
> > > > >    		 * If we need to reschedule bail... so we can block.
> > > > >    		 */
> > > > > @@ -198,7 +198,7 @@ void osq_unlock(struct optimistic_spin_queue =
*lock)
> > > > >    	 * Second most likely case.
> > > > >    	 */
> > > > >    	node =3D this_cpu_ptr(&osq_node);
> > > > > -	next =3D xchg(&node->next, NULL);
> > > > > +	next =3D xchg_release(&node->next, NULL);
> > > > >    	if (next) {
> > > > >    		WRITE_ONCE(next->locked, 1);
> > > > So we still use WRITE_ONCE() rather than smp_store_release() here?
> > > >=20
> > > > Though, IIUC, This is fine for all the archs but ARM64, because the=
re
> > > > will always be a xchg_release()/xchg() before the WRITE_ONCE(), whi=
ch
> > > > carries a necessary barrier to upgrade WRITE_ONCE() to a RELEASE.
> > > >=20
> > > > Not sure whether it's a problem on ARM64, but I think we certainly =
need
> > > > to add some comments here, if we count on this trick.
> > > >=20
> > > > Am I missing something or misunderstanding you here?
> > > >=20
> > > > Regards,
> > > > Boqun
> > > The change on the unlock side is more for documentation purpose than =
is
> > > actually needed. As you had said, the xchg() call has provided the ne=
cessary
> > > memory barrier. Using the _release variant, however, may have some
> > But I'm afraid the barrier doesn't remain if we replace xchg() with
> > xchg_release() on ARM64v8, IIUC, xchg_release() is just a ldxr+stlxr
> > loop with no barrier on ARM64v8. This means the following code:
> >=20
> > 	CPU 0					CPU 1 (next)
> > 	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D		=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > 	WRITE_ONCE(x, 1);			r1 =3D smp_load_acquire(next->locked, 1);
> > 	xchg_release(&node->next, NULL);	r2 =3D READ_ONCE(x);
> > 	WRITE_ONCE(next->locked, 1);
> >=20
> > could result in (r1 =3D=3D 1&&  r2 =3D=3D 0) on ARM64v8, IIUC.
>=20
> If you look into the actual code:
>=20
>         next =3D xchg_release(&node->next, NULL);
>         if (next) {
>                 WRITE_ONCE(next->locked, 1);
>                 return;
>         }
>=20
> There is a control dependency that WRITE_ONCE() won't happen until

But a control dependency only orders LOAD->STORE pairs, right? And here
the control dependency orders the LOAD part of xchg_release() and the
WRITE_ONCE().

Along with the fact that RELEASE only orders the STORE part of xchg with
the memory operations preceding the STORE part, so for the following
code:

	WRTIE_ONCE(x,1);
	next =3D xchg_release(&node->next, NULL);
	if (next)
		WRITE_ONCE(next->locked, 1);

such a reordering is allowed to happen on ARM64v8

	next =3D ldxr [&node->next] // LOAD part of xchg_release()

	if (next)
		WRITE_ONCE(next->locked, 1);

	WRITE_ONCE(x,1);
	stlxr NULL [&node->next]  // STORE part of xchg_releae()

Am I missing your point here?

Regards,
Boqun

> xchg_release() returns. For your particular example, I will change it to
>=20
>     CPU 0
>     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>     WRITE_ONCE(x, 1);
>     xchg_relaxed(&node->next, NULL);
>     smp_store_release(next->locked, 1);
>=20
> I don't change WRITE_ONCE to a smp_store_release() because it may not alw=
ays
> execute.
>=20
> Cheers,
> Longman
>=20

--s/l3CgOIzMHHjg/5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXY0jfAAoJEEl56MO1B/q4CioH/32kU7U5OsJVIyKF2cxqxw46
FNYuryFBOXPgNc03h+aqeWVdZor0e7EOeB7b0S6DNqVp10spQkDOUGACZ5CanYL5
InZL+LIFMOif3JMLJ5fcNbAPdPCtGh2kDoWVj47J2J8xmaNN6y/zbh1whB1oXYkE
qLwI4iDGX3E/4z9+PdCAJhtdhA+vbL+5QgSS2PWCc6gnbSH90pvlowFKhYnwzt1M
M/dbBAMj1aVR3CyaSHFaEekHzKUHd7O0e4Ry0RYgn1wjjlsE563DItWVxUzGboJ8
0wuDCKV1SuwdStIrhyAxM2NeVYZ2LJHKLPcPpAI3yTswAdwxbaS3RizDTIlDaZA=
=waUZ
-----END PGP SIGNATURE-----

--s/l3CgOIzMHHjg/5--
