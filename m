From: Ulrich Drepper <drepper@redhat.com>
Date: Mon, 08 Apr 2002 20:23:50 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-/zrP5oDO1vClD7rgASeZ"
Message-Id: <marc-linux-ia64-105590701905414@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-/zrP5oDO1vClD7rgASeZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2002-04-08 at 13:13, David Mosberger wrote:

> I guess I don't really see the harm in having glibc provide a header
> for these system call, but as long as the syscall stubs are there,
> it's probably not a huge issue in practice.

David, you are around long enough to see the dangers.  I don't want to
have any dependencies on the kernel.  Any change in the kernel interface
would force me to make a new release which isn't going to happen.

--=20
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

--=-/zrP5oDO1vClD7rgASeZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8sfxW2ijCOnn/RHQRAv+eAJ4gs89icT9ahw8AtZOXm8qeip5jAACgo31j
ecNTqm8OUDsqESGefkZBMSg=
=S40G
-----END PGP SIGNATURE-----

--=-/zrP5oDO1vClD7rgASeZ--


