From: Ulrich Drepper <drepper@redhat.com>
Date: Fri, 05 Apr 2002 16:44:40 +0000
Subject: Re: [Linux-ia64] pipe() not setting errno.
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-rVp2ubm5t6QdcnaxrU2t"
Message-Id: <marc-linux-ia64-105590701905392@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905376@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905376@msgid-missing>
To: linux-ia64@vger.kernel.org

--=-rVp2ubm5t6QdcnaxrU2t
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2002-04-04 at 05:36, Andreas Schwab wrote:

> 2002-04-04  Andreas Schwab  <schwab@suse.de>
>=20
> 	* sysdeps/unix/sysv/linux/ia64/pipe.S: Don't overwrite r8 on
> 	error.

I've applied the patch now.  Thanks,

--=20
---------------.                          ,-.   1325 Chesapeake Terrace
Ulrich Drepper  \    ,-------------------'   \  Sunnyvale, CA 94089 USA
Red Hat          `--' drepper at redhat.com   `------------------------

--=-rVp2ubm5t6QdcnaxrU2t
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8rdR42ijCOnn/RHQRAiwkAKC9kQrhew3fuh9rLpTL3bMwQ4ONyQCePMus
WPbMXttnxRJB5MmLI+yINTA=
=8syi
-----END PGP SIGNATURE-----

--=-rVp2ubm5t6QdcnaxrU2t--


