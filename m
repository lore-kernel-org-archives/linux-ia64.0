From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sat, 29 Apr 2017 18:14:32 +0000
Subject: Re: [PATCH v3] ia64: fix module loading for gcc-5.4
Message-Id: <20170429191432.5ebe2129@sf>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/OZ5I.vO1_G3QQCjMgsQsPc3"
List-Id: <linux-ia64.vger.kernel.org>
References: <to=<20170408081449.4872-1-slyfox@gentoo.org>
        <20170408195318.18080-1-slyfox@gentoo.org>
In-Reply-To: <20170408195318.18080-1-slyfox@gentoo.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/OZ5I.vO1_G3QQCjMgsQsPc3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sat,  8 Apr 2017 20:53:18 +0100
Sergei Trofimovich <slyfox@gentoo.org> wrote:

> Starting from gcc-5.4+ gcc generates MLX
> instructions in more cases to refer local
> symbols:
>     https://gcc.gnu.org/PR60465
>=20
> That caused ia64 module loader to choke
> on such instructions:
>     fuse: invalid slot number 1 for IMM64
>=20
> Linux kernel used to handle only case where
> relocation pointed to slot=3D2 instruction in
> the bundle. That limitation was fixed in linux by
> commit 9c184a073bfd ("[IA64] Fix 2.6 kernel for the new ia64 assembler")
> See http://sources.redhat.com/bugzilla/show_bug.cgi?id=3D1433
>=20
> This change lifts the slot=3D2 restriction from
> linux kernel module loader.
>=20
> Tested on 'fuse' and 'btrfs' kernel modules.
>=20
> Cc: Markus Elfring <elfring@users.sourceforge.net>
> Cc: H. J. Lu <hjl.tools@gmail.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Bug: https://bugs.gentoo.org/601014
> Tested-by: =C3=89meric MASCHINO <emeric.maschino@gmail.com>
> Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
> ---
> Change since v1: added 'Tested-by'
> Change since v2: checkpatched, fixed typos by found by Markus Elfring

Ping :)

--=20

  Sergei

--Sig_/OZ5I.vO1_G3QQCjMgsQsPc3
Content-Type: application/pgp-signature
Content-Description: =?unknown-8bit?b?0KbQuNGE0YDQvtCy0LDRjyDQv9C+0LTQv9C40YHRjA==?= OpenPGP

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQSZKa0VG5avZRlY01hxoe52YR/zqgUCWQTYCQAKCRBxoe52YR/z
qvviAJ9vvOptrhATiYO5/vRmPegGfwtOUgCfSeoTYhaTD0ZqAtVyzqkPCD7G24s=
=wvtz
-----END PGP SIGNATURE-----

--Sig_/OZ5I.vO1_G3QQCjMgsQsPc3--
