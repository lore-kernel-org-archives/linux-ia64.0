From: Matt Domsch <Matt_Domsch@dell.com>
Date: Sat, 24 Apr 2004 15:26:48 +0000
Subject: efibootmgr 0.5.0-test3
Message-Id: <20040424152648.GA23444@lists.us.dell.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

This should correct the use of efibootmgr with Matt T's new sysfs
implementation of the efivars kernel module.

http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.0-test3.tar.gz
http://linux.dell.com/efibootmgr/testing/efibootmgr-0.5.0-test3.tar.gz.asc

Please note the new home for efibootmgr is now on linux.dell.com
rather than domsch.com.


There's still some wierdness I've seen which I'll investigate next
week.

1) Not all changes to variables are reflected in the output; they took
   effect, but it's possible for old values to be printed still.  If
   you run it a second time without specifying to make changes, you'll
   see the right information.

2) When deleting Boot000* values, they're not removed from BootOrder.
   You've got to do that yourself.

Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--yrj/dFKFPuw6o+aM
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAioc4Iavu95Lw/AkRAocGAKCQzfakk6YusvkQg8ABG8Gf6goELgCfa3EQ
o8wNWPmXtmbetWpQHHAS6+4=
=fgp8
-----END PGP SIGNATURE-----

--yrj/dFKFPuw6o+aM--
