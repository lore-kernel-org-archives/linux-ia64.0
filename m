From: Matt Domsch <Matt_Domsch@dell.com>
Date: Thu, 26 Aug 2004 20:43:12 +0000
Subject: efibootmgr 0.5.0 release
Message-Id: <20040826204312.GC20465@lists.us.dell.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="KsGdsel6WgEHnImy"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I've released efibootmgr version 0.5.0.  It is code-wise identical to
version 0.5.0-test4 released in June, I've only updated the
ChangeLog.  This is the first major release since September 2003, and
includes support for accessing EFI Variables via /proc and sysfs, the
latter necessary for recent 2.6 kernels.

http://linux.dell.com/efibootmgr/efibootmgr-0.5.0.tar.gz
http://linux.dell.com/efibootmgr/efibootmgr-0.5.0.tar.gz.sign

I encourage distributions to upgrade to this version at your earliest
convenience.


* Thu Aug 26 2004 Matt Domsch <Matt_Domsch@dell.com>
- v0.5.0-test4 released as v0.5.0 with no code changes

* Wed Jun 07 2004 Matt Domsch <Matt_Domsch@dell.com>
- Fixed bug where read_boot_order() would wrongly return EFI_NOT_FOUND
  when it needed to create a new BootOrder variable.  Reported by Micah Par=
rish.
- Added code to recursively walk the PCI bus putting parent PCI bridges
  in.  This is necessary for Dell PowerEdge 3250 and 7250 servers and
  Intel Tiger2 and Tiger4 platforms when creating PXE boot entries for
  the onboard NICs, and if creating EDD30 boot path entries.  Work by Matt
  and Joshua Giles.
  - Note, efibootmgr now requires libpci for building.
- Released v0.5.0-test4

* Sat Apr 24 2004 Matt Domsch <Matt_Domsch@dell.com>
- Fixed reversed logic of create_or_edit_variable which prevented object
  creation or editing on sysfs.
- Removed debug printfs in sysfs read/write commands.
- Released v0.5.0-test3

* Thu Feb 04 2004 Matt Domsch <Matt_Domsch@dell.com>
- removed -t short option for --test
- added -t <timeout> and -T delete timeout options
- updated man page and README about the timeout options
- Released v0.5.0-test2

* Tue Sep 09 2003 Matt Domsch <Matt_Domsch@dell.com>
- Released v0.5.0-test1

* Thu Sep 04 2003 Matt Domsch <Matt_Domsch@dell.com>
- Seperated access to variables through /proc into efivars_procfs.[ch]
- Added efivars_sysfs.h to access variables through sysfs.
- Moved around some functions, cleaned up some duplication.


Thanks,
Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBLktfIavu95Lw/AkRAir2AJ44fM1y7ehk+If+fe33N/PCU30FngCfQ14w
/OeluOdaVN21l6dpBT/CYZw=
=DiRg
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
