From: Volker Birk <vb@ebios.de>
Date: Thu, 20 Feb 2003 19:59:47 +0000
Subject: Re: [Linux-ia64] strange performance behaviour with floats
MIME-Version: 1
Content-Type: multipart/mixed; boundary="GdbWtwDHkcXqP16f"
Message-Id: <marc-linux-ia64-105590709805893@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805852@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805852@msgid-missing>
To: linux-ia64@vger.kernel.org

--GdbWtwDHkcXqP16f
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 20, 2003 at 09:52:43AM -0800, David Mosberger wrote:
> Hmmh, that's really strange.  I assume you realize that your
> test-program doesn't really do what the source code suggests (the
> loop-body gets optimized away), but regardless the high variation
> you're seeing seems wrong.

I think, optimazation does not matter on that point.

> Are you re-directing the kernel console to
> a serial line?

No.

VB.
--=20
*** ebios Informationssysteme, Germany      ***
*** Gut-Betha-Platz 1, 88339 Bad Waldsee    ***
*** Phone +49-7524-93421 Fax +49-7524-93423 ***
*** mailto:vb@ebios.de                      ***

--GdbWtwDHkcXqP16f
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE+VTOzq2Wx34LtkcYRAkGOAKC4yHYnMCXQzEM+n9TELkqrbbeZPQCfRUAm
b4s1iyCJRKWy0UQ5/smc2X4=
=KWpj
-----END PGP SIGNATURE-----

--GdbWtwDHkcXqP16f--

