From: Martin Hicks <mort@wildopensource.com>
Date: Thu, 28 Aug 2003 16:59:16 +0000
Subject: Re: 2.6.0 test3 does not boot on ia64 NUMA
MIME-Version: 1
Content-Type: multipart/mixed; boundary="l76fUT7nc3MelDdI"
Message-Id: <marc-linux-ia64-106209004208203@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106191285716253@msgid-missing>
In-Reply-To: <marc-linux-ia64-106191285716253@msgid-missing>
To: linux-ia64@vger.kernel.org


--l76fUT7nc3MelDdI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable



On Thu, Aug 28, 2003 at 06:38:41PM +0200, Xavier Bru wrote:
>=20
> Martin,
>=20
> Thanks for answering my mail. I applied Jesse's patch ([PATCH] latest
> discontig mail dated Fri, 8 Aug 2003) but this does'nt build with:
> 	CONFIG_NUMA=3Dy
> 	CONFIG_ACPI_NUMA=3Dy
> 	CONFIG_DISCONTIGMEM=3Dy
> 	# CONFIG_VIRTUAL_MEM_MAP is not set
> I get:
> include/linux/mm.h: In function `lowmem_page_address':
> include/linux/mm.h:349: `mem_map' undeclared (first use in this function)
>=20
> It seems that this only works on Altix, unless I missed something.

I'm pretty sure that you need CONFIG_VIRTUAL_MEM_MAP=3Dy if you have
CONFIG_DISCONTIGMEM=3Dy

mh

--=20
Wild Open Source Inc.                  mort@wildopensource.com

--l76fUT7nc3MelDdI
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/TjTk0ZUZrUx/K+4RAu35AKDVCabaM6jgc+sDVWpRnQDucUjXCwCgml+V
j2ytc0fss4nwmS6G9zy7ZKY=
=Osgg
-----END PGP SIGNATURE-----

--l76fUT7nc3MelDdI--
