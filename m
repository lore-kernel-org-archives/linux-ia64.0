From: aip@turbolinux.com
Date: Fri, 01 Sep 2000 19:08:11 +0000
Subject: [Linux-ia64] [PATCH] fix casting problem in megaraid driver
MIME-Version: 1
Content-Type: multipart/mixed; boundary="9zSXsLTf0vkW971A"
Message-Id: <marc-linux-ia64-105590678205441@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--9zSXsLTf0vkW971A
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch fixes bug where mbox's pointer was cast to integer, caused
segfault.

-Andrew


--oyUTqETQ0mS9luUI
Content-Type: application/x-patch
Content-Disposition: attachment; filename="linux-2.4.0test7-ia64-megaraid.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nur linux-2.4.0test7/drivers/scsi/megaraid.c linux-2.4.0test7.megarai=
d/drivers/scsi/megaraid.c=0A--- linux-2.4.0test7/drivers/scsi/megaraid.c	Mo=
n Jun 19 13:42:40 2000=0A+++ linux-2.4.0test7.megaraid/drivers/scsi/megarai=
d.c	Thu Aug 31 16:14:09 2000=0A@@ -129,6 +129,11 @@=0A  *    occasionally h=
ang. We check such cards and report them. You can=0A  *    get firmware upg=
rades to flash the board to 3.10 for free.=0A  *=0A+ * Version 1.08=0A+ *  =
  Fixed bug where pointer of mbox was cast to integer in=0A+ *    mega_regi=
ster_mailbox causing segfault. =0A+ *    Aug 31 2000 Andrew Ip <aip@turboli=
nux.com>   =0A+ *=0A  * BUGS:=0A  *     Some older 2.1 kernels (eg. 2.1.90)=
 have a bug in pci.c that=0A  *     fails to detect the controller as a pci=
 device on the system.=0A@@ -1282,13 +1287,13 @@=0A  *   10 01 numstatus by=
te=0A  *   11 01 status byte=0A  *-----------------------------------------=
---------------------------*/=0A-static int mega_register_mailbox (mega_hos=
t_config * megaCfg, u32 paddr)=0A+static int mega_register_mailbox (mega_ho=
st_config * megaCfg, u64 paddr)=0A {=0A   /* align on 16-byte boundry */=0A=
   megaCfg->mbox =3D &megaCfg->mailbox64.mailbox;=0A-  megaCfg->mbox =3D (m=
ega_mailbox *) ((((u32) megaCfg->mbox) + 16) & 0xfffffff0);=0A+  megaCfg->m=
box =3D (mega_mailbox *) ((((u64) megaCfg->mbox) + 16) & 0xfffffffffffffff0=
);=0A   megaCfg->mbox64 =3D (mega_mailbox64 *) (megaCfg->mbox - 4);=0A-  pa=
ddr =3D (paddr + 4 + 16) & 0xfffffff0;=0A+  paddr =3D (paddr + 4 + 16) & 0x=
fffffffffffffff0;=0A =0A   /* Register mailbox area with the firmware */=0A=
   if (!(megaCfg->flag & BOARD_QUARTZ)) {=0A
--oyUTqETQ0mS9luUI--

--9zSXsLTf0vkW971A
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.2 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE5r/6bSclQecCvPM8RAppSAKCfnQfLsmcscISqoRqe5tj3Bed/QgCg1nIt
1GY/ozG5v5zcRntMo8GupzA=
=xFDJ
-----END PGP SIGNATURE-----

--9zSXsLTf0vkW971A--

