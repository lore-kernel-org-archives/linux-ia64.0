From: Harald Welte <laforge@netfilter.org>
Date: Fri, 09 Jul 2004 18:52:37 +0000
Subject: Re: [netfilter-core] strict rejection of init -> core references causes problems
Message-Id: <20040709185237.GF5173@sunbeam2>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="zaRBsRFn0XYhEU69"
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org


--zaRBsRFn0XYhEU69
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 09, 2004 at 11:36:35AM -0700, David Mosberger wrote:

> We don't have much of a choice, but I think it would be worthwhile to
> consider whether netfilter could avoid doing this in the future.  It
> really is very easy to make a mistake when allowing core->init calls.

well, all we do is:

1) have a common init and de-init function
2) call it from a wrapper funcion declared as module_init()
3) call it from a wrapper function declared __exit as module_exit()

Since 1) is called from init and fini, we cannot declare it as __init
(this would remove it from ram).

So what really happens is: calls from init to 'core' functions and calls
=66rom 'exit' to core functions.

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

--zaRBsRFn0XYhEU69
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA7ul1XaXGVTD0i/8RAhbvAJ4r7cYfPOoxZNor2pyaRysmDDjQRgCePYyW
Hae42CsZi5Y1mjfrxbFmVnI=
=gZax
-----END PGP SIGNATURE-----

--zaRBsRFn0XYhEU69--
