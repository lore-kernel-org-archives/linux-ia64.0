From: Boqun Feng <boqun.feng@gmail.com>
Date: Wed, 15 Jun 2016 08:04:46 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160615080446.GA28443@insomnia>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
To: Waiman Long <Waiman.Long@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Waiman,

On Tue, Jun 14, 2016 at 06:48:04PM -0400, Waiman Long wrote:
> The osq_lock() and osq_unlock() function may not provide the necessary
> acquire and release barrier in some cases. This patch makes sure
> that the proper barriers are provided when osq_lock() is successful
> or when osq_unlock() is called.
>=20
> Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
> ---
>  kernel/locking/osq_lock.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
> index 05a3785..7dd4ee5 100644
> --- a/kernel/locking/osq_lock.c
> +++ b/kernel/locking/osq_lock.c
> @@ -115,7 +115,7 @@ bool osq_lock(struct optimistic_spin_queue *lock)
>  	 * cmpxchg in an attempt to undo our queueing.
>  	 */
> =20
> -	while (!READ_ONCE(node->locked)) {
> +	while (!smp_load_acquire(&node->locked)) {
>  		/*
>  		 * If we need to reschedule bail... so we can block.
>  		 */
> @@ -198,7 +198,7 @@ void osq_unlock(struct optimistic_spin_queue *lock)
>  	 * Second most likely case.
>  	 */
>  	node =3D this_cpu_ptr(&osq_node);
> -	next =3D xchg(&node->next, NULL);
> +	next =3D xchg_release(&node->next, NULL);
>  	if (next) {
>  		WRITE_ONCE(next->locked, 1);

So we still use WRITE_ONCE() rather than smp_store_release() here?

Though, IIUC, This is fine for all the archs but ARM64, because there
will always be a xchg_release()/xchg() before the WRITE_ONCE(), which
carries a necessary barrier to upgrade WRITE_ONCE() to a RELEASE.

Not sure whether it's a problem on ARM64, but I think we certainly need
to add some comments here, if we count on this trick.

Am I missing something or misunderstanding you here?

Regards,
Boqun

>  		return;
> --=20
> 1.7.1
>=20

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXYQwZAAoJEEl56MO1B/q4BTEIAJfTXZU/LW00kU5SZGECAbIb
k/lhU4XFRPM4wCMZNsAgs3aO6V/VE7+F3TMfDdVik0w9zm0wvMGl3ELRTCcDNhgv
JVguF3wnwfkOIWIG/pPvGaKOGMc/1g6Pi21cxAOceTF5H5roeB7hqcJfZ3fr32gd
DYko8LgQ8xhqDV0HwIuekIgc7GP+D1sdesOcesntHOEi3xYjdDAPzZHGh0iMGzpv
cFZVTa1+dTSpJYO3LoF/zcab6yb0q2WBAYZPuLRka9Wq/yJQ230Scq3Lwy+PoJPx
eN++9Y5oXMaMAUB1PqsNPp4MOucrnakBo8dal7qA2z7k+fEFbWDxU0f5NmQDkeY=
=mWBt
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--
