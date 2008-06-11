From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 11 Jun 2008 23:10:03 +0000
Subject: Re: [BUILD-FAILURE] linux-next: Tree for June 11 - on ia64
Message-Id: <20080612091003.775bc671.sfr@canb.auug.org.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Signature=_Thu__12_Jun_2008_09_10_03_+1000_qTA4nMRA2oeAkxDd"
List-Id: <linux-ia64.vger.kernel.org>
References: <20080611193840.08a35b14.sfr@canb.auug.org.au>
	<484FE1EE.9020201@linux.vnet.ibm.com>
In-Reply-To: <484FE1EE.9020201@linux.vnet.ibm.com>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>

--Signature=_Thu__12_Jun_2008_09_10_03_+1000_qTA4nMRA2oeAkxDd
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Sam,

One for you?

On Wed, 11 Jun 2008 20:02:14 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ib=
m.com> wrote:
>
> The next-20080611 kernel build fails on ia64 machine
>=20
>   AR      arch/ia64/lib/lib.a
>   LD      vmlinux.o
>   MODPOST vmlinux.o
>   GEN     .version
>   CHK     include/linux/compile.h
>   UPD     include/linux/compile.h
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux
>   LD      vmlinux
> ld: .tmp_kallsyms.o: linking constant-gp files with non-constant-gp files
> ld: failed to merge target specific data of file .tmp_kallsyms.o
> make: *** [vmlinux] Error 1
>=20
> --=20
> Thanks & Regards,
> Kamalesh Babulal,
> Linux Technology Center,
> IBM, ISTL.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__12_Jun_2008_09_10_03_+1000_qTA4nMRA2oeAkxDd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkhQW0sACgkQTgG2atn1QN8gsQCfWLhWhcbULR7y7qW850v7dMzZ
jeYAnA00FEZEMT0vMX5xFXUVrgXZwYnJ
=Tttp
-----END PGP SIGNATURE-----

--Signature=_Thu__12_Jun_2008_09_10_03_+1000_qTA4nMRA2oeAkxDd--
