From: Boqun Feng <boqun.feng@gmail.com>
Date: Sat, 18 Jun 2016 08:46:20 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160618084620.GA24424@insomnia>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615080446.GA28443@insomnia>
 <5761A5FF.5070703@hpe.com>
 <20160616021951.GA16918@insomnia>
 <57631BBA.9070505@hpe.com>
 <20160617004837.GB16918@insomnia>
 <576416B1.6020006@hpe.com>
 <20160617154536.GB1284@arm.com>
 <57643EB7.6030600@hpe.com>
In-Reply-To: <57643EB7.6030600@hpe.com>
To: Waiman Long <waiman.long@hpe.com>
Cc: Will Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 17, 2016 at 02:17:27PM -0400, Waiman Long wrote:
> On 06/17/2016 11:45 AM, Will Deacon wrote:
> > On Fri, Jun 17, 2016 at 11:26:41AM -0400, Waiman Long wrote:
> > > On 06/16/2016 08:48 PM, Boqun Feng wrote:
> > > > On Thu, Jun 16, 2016 at 05:35:54PM -0400, Waiman Long wrote:
> > > > > If you look into the actual code:
> > > > >=20
> > > > >          next =3D xchg_release(&node->next, NULL);
> > > > >          if (next) {
> > > > >                  WRITE_ONCE(next->locked, 1);
> > > > >                  return;
> > > > >          }
> > > > >=20
> > > > > There is a control dependency that WRITE_ONCE() won't happen until
> > > > But a control dependency only orders LOAD->STORE pairs, right? And =
here
> > > > the control dependency orders the LOAD part of xchg_release() and t=
he
> > > > WRITE_ONCE().
> > > >=20
> > > > Along with the fact that RELEASE only orders the STORE part of xchg=
 with
> > > > the memory operations preceding the STORE part, so for the following
> > > > code:
> > > >=20
> > > > 	WRTIE_ONCE(x,1);
> > > > 	next =3D xchg_release(&node->next, NULL);
> > > > 	if (next)
> > > > 		WRITE_ONCE(next->locked, 1);
> > > >=20
> > > > such a reordering is allowed to happen on ARM64v8
> > > >=20
> > > > 	next =3D ldxr [&node->next] // LOAD part of xchg_release()
> > > >=20
> > > > 	if (next)
> > > > 		WRITE_ONCE(next->locked, 1);
> > > >=20
> > > > 	WRITE_ONCE(x,1);
> > > > 	stlxr NULL [&node->next]  // STORE part of xchg_releae()
> > > >=20
> > > > Am I missing your point here?
> > > My understanding of the release barrier is that both prior LOADs and =
STOREs
> > > can't move after the barrier. If WRITE_ONCE(x, 1) can move to below a=
s shown
> > > above, it is not a real release barrier and we may need to change the
> > > barrier code.
> > You seem to be missing the point.
> >=20
> > {READ,WRITE}_ONCE accesses appearing in program order after a release
> > are not externally ordered with respect to the release unless they
> > access the same location.
> >=20
> > This is illustrated by Boqun's example, which shows two WRITE_ONCE
> > accesses being reordered before a store-release forming the write
> > component of an xchg_release. In both cases, WRITE_ONCE(x, 1) remains
> > ordered before the store-release.
> >=20
> > Will
>=20
> I am sorry that I misread the mail. I am not used to treating xchg as two
> separate instructions. Yes, it is a problem. In that case, we have to eit=
her

And sorry for the Red Pill ;-)

> keep the xchg() function as it is or use smp_store_release(&next->locked,
> 1). So which one is a better alternative for ARM or PPC?
>=20

For PPC, I think xchg_release() + smp_store_release() is better than the=20
current code, because the former has two lwsync while the latter has two
sync, and sync is quite expensive than lwsync on PPC.

I need to leave the ARM part to Will ;-)

Regards,
Boqun

> Cheers,
> Longman

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXZQpWAAoJEEl56MO1B/q4EvcIAJaKsjeT+0WpdzKQmZFFiCkl
WM7yCDfa/eYz4qVkxMIaKluoR1SX/cMXUlRSSmJWqjrTczvDSugMPNYEVXCHJsdv
qkWKdONYuz5fhzUBFqBK+B3usUUpRM4v/vUOE2BG7YE+yzZSpI5Sq5Y+KpI5xuUk
UFq/4bV6jM5ufhMOARFdctIdHx3UUzZpAsQPwBx79cN3kSH2BUUx4PhHd3XQYw+Q
HOLQB4jqd0TyKe2r6LJb+/FAsyl28nnLPo/pF7H8H+cGgCJaBKjouvA5TFV3yTD/
FfiTf6fCpTJ7OIT9aLZnlZhfznYoHQ6pKHm6AdT5bCYmyJqv16gtPHvhZu43+0U=
=FP4F
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--
