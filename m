From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 19 May 2004 01:23:26 +0000
Subject: Disable CONFIG_SMP for IA64_HP_SIM
Message-Id: <20040519012326.GA27655@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ZoaI/ZTpAVc4A5k6"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--ZoaI/ZTpAVc4A5k6
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Content-Disposition: inline


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

CONFIG_SMP depends on CONFIG_IOSAPIC to build (maybe this is the real
problem, I don't know). =20

CONFIG_IOSAPIC excludes IA64_HP_SIM.  Some sample configs [1] have SMP
enabled for the simulator, and it broke my autobuild, so maybe making
it explicit would be good?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

[1] http://www.hpl.hp.com/research/linux/ski/get.php?file=3D2.6.5-config&na=
me=3Dconfig.2.5.5



--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="Kconfig-nosimsmp.patch"
Content-Transfer-Encoding: quoted-printable

=3D=3D=3D=3D=3D arch/ia64/Kconfig 1.73 vs edited =3D=3D=3D=3D=3D
--- 1.73/arch/ia64/Kconfig	Sat May 15 12:00:12 2004
+++ edited/arch/ia64/Kconfig	Wed May 19 10:52:57 2004
@@ -225,6 +225,7 @@
=20
 config SMP
 	bool "Symmetric multi-processing support"
+	depends on !IA64_HP_SIM
 	help
 	  This enables support for systems with more than one CPU. If you have
 	  a system with only one CPU, say N.  If you have a system with more

--jI8keyz6grp/JLjh--

--ZoaI/ZTpAVc4A5k6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAqrcOWDlSU/gp6ecRAgtzAKDOhHMecxfpnyBVtHK4xp2x8lskaACgt0VM
AcNZPgR7YIoY5ISn65/UMiA=
=7bKt
-----END PGP SIGNATURE-----

--ZoaI/ZTpAVc4A5k6--
