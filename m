From: Arjan van de Ven <arjanv@redhat.com>
Date: Wed, 21 May 2003 09:01:33 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-jdn4kkStXG9zAFTHIY0R"
Message-Id: <marc-linux-ia64-105590723705966@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--=-jdn4kkStXG9zAFTHIY0R
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2003-05-21 at 08:49, David Mosberger wrote:

>=20
> I think the web pages should be most relevant to the HPTC (high
> performance technical computing) community, since this is the
> community that is most likely affected by some of the performance
> oddities of the O(1) scheduler.  Certainly anyone using OpenMP on
> Intel platforms (x86 and ia64) may want to take a look.

oh you mean the OpenMP broken behavior of calling sched_yield() in a
tight loop to implement spinlocks ?

I'd guess that instead of second guessing the runtime, they should use
the pthreads primitives which are the fastest for the platform one would
hope.. (eg futexes nowadays)

--=-jdn4kkStXG9zAFTHIY0R
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA+y0BsxULwo51rQBIRArOMAJ9yAk3Z9IroEHYebopZJURFBSCi6ACgny4i
qyZcXObrE3j3F9UpJ3B1uEo=
=l5W7
-----END PGP SIGNATURE-----

--=-jdn4kkStXG9zAFTHIY0R--

