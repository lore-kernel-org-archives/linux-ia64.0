From: Harald Welte <laforge@netfilter.org>
Date: Fri, 09 Jul 2004 08:01:27 +0000
Subject: Re: [netfilter-core] strict rejection of init -> core references causes problems
Message-Id: <20040709080127.GA3168@sunbeam2>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 09, 2004 at 12:02:26AM -0700, David Mosberger wrote:
> Tony,
>=20
> To recap, with that patch applied, calls from the core section of a
> module to an init section are rejected because that's in general a
> dangerous thing to do (the called code may be gone by the time the
> call gets executed).

This breaks almost all netfilter modules, indeed.

> I'm not terribly familiar with the netfilter code, but I think the
> problem there comes from the fact that some code is shared between
> init and exit handlers and that shared code ends up in the module
> core.

that's exactly the case.  Since we have fairly long initialization
functions (allocating/initializing dozens of ressources, where each one
can fail), we share the code for partial and full de-initialization
between the failing module_init() routine and the module_exit() routine.

Initially Rusty wrote the modules like this, and I very much agree with
this decision to not replicate the same code in module_init() and
_exit() functions. (which would have to be kept in sync every time some
item is added to the initialization chain).

> it's common practice, I suppose we don't have much choice but to allow
> calls from core to init sections again.  Perhaps someone from the
> netfilter team could comment?

I wuold very much appreciate if this was still possible in the future.

> 	--david

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA7lDXXaXGVTD0i/8RAo8FAJ4mk5vLTnLmqXCD/NgRjPKTKrSjEwCgnVUJ
Nz+Wi+2ps9IdJ4g0WkdoSJE=
=1l8b
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
