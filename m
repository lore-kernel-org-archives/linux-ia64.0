From: Ulrich Drepper <drepper@redhat.com>
Date: Mon, 08 Apr 2002 19:23:14 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-ByJq9s8Wboj6LwADsW25"
Message-Id: <marc-linux-ia64-105590701905412@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-ByJq9s8Wboj6LwADsW25
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2002-04-08 at 12:00, David Mosberger wrote:

> So you're OK with glibc providing the syscall stubs for module*(), but
> not the header files required to use them?

Yes.  There is no fundamental problems with this.

--=20
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

--=-ByJq9s8Wboj6LwADsW25
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8se4i2ijCOnn/RHQRAiEuAKDJ23wmwQ/ua4sPu5/Lj2lOAJFLYACeNEeP
1UOhy+saUeaWVYd2GsqRYhU=
=6QUC
-----END PGP SIGNATURE-----

--=-ByJq9s8Wboj6LwADsW25--


