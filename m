From: Volker Birk <vb@ebios.de>
Date: Sat, 15 Feb 2003 11:29:16 +0000
Subject: Re: [Linux-ia64] strange performance behaviour with floats
MIME-Version: 1
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Message-Id: <marc-linux-ia64-105590709805860@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805852@msgid-missing>
To: linux-ia64@vger.kernel.org

--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 14, 2003 at 07:50:19PM +0900, Hideki Yamamoto wrote:
>  This is really strange as you said.
>  Firstly, I suspected the ldd. I mean this is caused by
>  the dinamic library(glibc) is on the cache when the ldd running.
>  When your attached program compiled with -static
>  switch is running, it seems the strange behaviour is disappered.

It does not disappear.

Also with linking with -static, that strange behaviour is still there.
Does anybody else has that problem? Does anyone know what's up?

VB.
--=20
*** ebios Informationssysteme, Germany      ***
*** Gut-Betha-Platz 1, 88339 Bad Waldsee    ***
*** Phone +49-7524-93421 Fax +49-7524-93423 ***
*** mailto:vb@ebios.de                      ***

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE+TiSLq2Wx34LtkcYRAtKUAKC/T6zcDPgqa63mMPPiny/+7tIr1ACeLt6e
8zefkrnjQoEkICESGL5NAMY=
=IGOb
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--

