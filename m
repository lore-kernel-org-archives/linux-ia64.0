From: Sebastian Henschel <linux@kodeaffe.de>
Date: Tue, 10 Feb 2004 12:13:51 +0000
Subject: [PATCH] URL addition tuxmobil.org
Message-Id: <20040210121351.GA19769@fuchi>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="NMuMz9nt05w80d4+"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--NMuMz9nt05w80d4+
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Content-Disposition: inline


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

hi there...

attached is a cosmetic patch for arch/ia64/Kconfig which introduces the
URL of tuxmobil.org as an alternative to linux-on-laptops.com.

thanks and bye,
 sebastian
--=20
::: .O.
::: ..O
::: OOO
::: lynx -source http://www.kodeaffe.de/shensche.pub | gpg --import

--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="lol-tuxmobil.ia64.diff"
Content-Transfer-Encoding: quoted-printable

diff -Naur linux-2.6.2-ben1-stir4200.orig/arch/ia64/Kconfig linux-2.6.2-ben=
1-stir4200/arch/ia64/Kconfig
--- linux-2.6.2-ben1-stir4200.orig/arch/ia64/Kconfig	2004-02-10 11:51:40.70=
6972960 +0100
+++ linux-2.6.2-ben1-stir4200/arch/ia64/Kconfig	2004-02-10 12:37:09.0002093=
44 +0100
@@ -258,8 +258,9 @@
=20
 	  Power Management is most important for battery powered laptop
 	  computers; if you have a laptop, check out the Linux Laptop home
-	  page on the WWW at <http://www.linux-on-laptops.com/> and the
-	  Battery Powered Linux mini-HOWTO, available from
+	  page on the WWW at <http://www.linux-on-laptops.com/> or
+	  Tuxmobil - Linux on Mobile Computers at <http://www.tuxmobil.org/>
+	  and the Battery Powered Linux mini-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
=20
 	  Note that, even if you say N here, Linux on the x86 architecture

--XsQoSWH+UP9D9v3l--

--NMuMz9nt05w80d4+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAKMr/reHfL3pi+bQRAq7PAJ0Van4pcg+eiN3MMPEYqqosjumP1QCggc30
acLIc5oitbwt6uVZDzDD/BI=
=/SAj
-----END PGP SIGNATURE-----

--NMuMz9nt05w80d4+--
