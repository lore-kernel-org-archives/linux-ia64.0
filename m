From: Matt Domsch <Matt_Domsch@dell.com>
Date: Fri, 20 May 2005 16:06:18 +0000
Subject: efibootmgr 0.5.2
Message-Id: <20050520160618.GA10014@lists.us.dell.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Q68bSM7Ycu6FN28Q"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I've released efibootmgr-0.5.2, with the following minor changes:

* Fri May 20 2005 Matt Domsch <Matt_Domsch@dell.com>
- applied patch from Andreas Schwab to properly parse PCI
  domain:bus:device.fn info in netboot entries.  Fixed up return value
  when creating network boot entries for nonexistant devices, so the
  creation now fails, rather than succeeding with incorrect data.
- v0.5.2 released

http://linux.dell.com/efibootmgr/permalink/efibootmgr-0.5.2.tar.gz
http://linux.dell.com/efibootmgr/permalink/efibootmgr-0.5.2.tar.gz.sign

Thanks,
Matt

--=20
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--Q68bSM7Ycu6FN28Q
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFCjgr5Iavu95Lw/AkRApKCAJ9ycYV7lLrGMAcieNOVtyAEVM4DLwCfVbj2
8i7iUGvKA/SIBbiKf9cMT4w=
=zqdh
-----END PGP SIGNATURE-----

--Q68bSM7Ycu6FN28Q--
