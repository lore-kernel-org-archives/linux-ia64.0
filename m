From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 14 May 2003 15:47:42 +0000
Subject: Re: [Linux-ia64] runtime platform detection in GENERIC kernels
MIME-Version: 1
Content-Type: multipart/mixed; boundary="X3gaHHMYHkYqP6yf"
Message-Id: <marc-linux-ia64-105590723705794@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705791@msgid-missing>
To: linux-ia64@vger.kernel.org

--X3gaHHMYHkYqP6yf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable



On Wed, May 14, 2003 at 09:32:53AM -0600, Alex Williamson wrote:
>=20
>    Why not just make a runtime strcmp to platform_name?  Then
> you could make a generic is_platform("sn2") type function/macro
> that everyone could use and you'd get rid of that nasty init
> function.  If you realy need to make such a check in a perfmance
> path, it should probably be a machvec.  Thanks,

That sounds fine to me.  I was certainly aiming to keep this
in non-performance critical regions.  I'd actually like to
restrict its use to init decisions, such as which serial
console driver to use.

mh

--=20
Wild Open Source Inc.                  mort@wildopensource.com

--X3gaHHMYHkYqP6yf
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE+wmUe0ZUZrUx/K+4RAh0WAJ9FV2LLYRwWXVl0ndincDsm8pufZACfVHNo
xHSuaR4aokP7itzCcplmTSM=
=CxAK
-----END PGP SIGNATURE-----

--X3gaHHMYHkYqP6yf--

