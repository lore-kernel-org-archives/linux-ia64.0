From: Matt Domsch <Matt_Domsch@dell.com>
Date: Mon, 26 Apr 2004 19:03:24 +0000
Subject: [PATCH] efibootmgr location change
Message-Id: <20040426190324.GB32755@lists.us.dell.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="24zk1gE8NUlDmwG9"
List-Id: <linux-ia64.vger.kernel.org>
To: akpm@osdl.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


--24zk1gE8NUlDmwG9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I moved the home of the efibootmgr utility from domsch.com to
linux.dell.com.  Note the move in drivers/firmware/Kconfig, also note
version 0.5.0-test3 or above is necessary.=20

Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--- linux-2.6.5.orig/drivers/firmware/Kconfig	2004-04-24 06:58:08.000000000=
 -0400
+++ linux-2.6.5/drivers/firmware/Kconfig	2004-04-27 03:57:17.723835477 -0400
@@ -27,11 +27,11 @@ config EFI_VARS
 	  write, create, and destroy EFI variables through this interface.
=20
 	  Note that using this driver in concert with efibootmgr requires=20
-	  at least test release version 0.5.0-test1 or later, which is=20
+	  at least test release version 0.5.0-test3 or later, which is=20
 	  available from Matt Domsch's website located at:
-	  http://domsch.com/linux/ia64/efibootmgr/testing/efibootmgr-0.5.0-test1.=
tar.gz
+	  http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.0-test3.tar.gz
=20
 	  Subsequent efibootmgr releases may be found at:
-	  http://domsch.com/linux/ia64/efibootmgr
+	  http://linux.dell.com/efibootmgr
=20
 endmenu

--24zk1gE8NUlDmwG9
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAjVz8Iavu95Lw/AkRAmpNAJ9Qq8sG7rrvgZbPhDjczqktApy35gCgh/eB
yY4PnuVw5wvBmFhVjV+ppyo=
=bWPJ
-----END PGP SIGNATURE-----

--24zk1gE8NUlDmwG9--
