From: Ulrich Drepper <drepper@redhat.com>
Date: Mon, 08 Apr 2002 17:51:06 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-XLYXSz9id3jBVh0Qrlwl"
Message-Id: <marc-linux-ia64-105590701905410@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-XLYXSz9id3jBVh0Qrlwl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2002-04-08 at 10:26, David Mosberger wrote:

> No, glibc needs to provide its own headers for this purpose.

Wrong.  If you want this kind of functionality create your own
module-dev package.  It is unfortunate that we have any such header in
glibc butnot changeable.  I certainly will not add more.

--=20
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

--=-XLYXSz9id3jBVh0Qrlwl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8sdiK2ijCOnn/RHQRAjXHAJ9ziFilTY0NEQ7oD2x3imqymLmr6ACcD3kX
lyKyORvXAR49e0z4YZUvcyw=
=cBcQ
-----END PGP SIGNATURE-----

--=-XLYXSz9id3jBVh0Qrlwl--


