From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 15 Nov 2001 09:08:41 +0000
Subject: [Linux-ia64] Announce: Kernel Build for 2.5, Release 1.7 is available
Message-Id: <marc-linux-ia64-105590698805518@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=3Dus-ascii

Release 1.7 of kernel build for kernel 2.5 (kbuild 2.5) has been
released.  http://sourceforge.net/projects/kbuild/, Package kbuild-2.5,
download release 1.7.

http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=99725412902968&w=3D2
contains information about the base release.

Changelog:

  Make CML1 menuconfig handle strings containing special characters
  like whitespace.

  Add vmlinuz as a target.

  New macro installable() to standardize the definition of installable
  targets.

  Adjust link order of drivers/char subdirectories to match kbuild 2.4.

  This release does not support CML2, only use it with CML1.  ESR has
  upgraded CML2 to kernel 2.4.14, I need to add it to kbuild 2.5.

  IA64 support.  That's right, you can compile ia64 using kbuild 2.5.
  There is a separate ia64 patch kbuild-2.5-2.4.14-ia64-011105-3, read
  the comments at the start.

  Upgrade the 2.4.15-pre4 patch to track the 2.4.14 changes.  Apply
  kbuild-2.5-2.4.14-3 and kbuild-2.5-2.4.15-pre4-3 to a clean
  2.4.15-pre4 kernel.

Files:
  kbuild-2.5-2.4.14-3 - core kbuild 2.5 and i386 code.
  kbuild-2.5-2.4.15-pre4-3 - track 2.4.15-pre4 makefile changes.
  kbuild-2.5-2.4.14-ia64-011105-3 - ia64 support.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE784YWi4UHNye0ZOoRAh+/AJ9iheycIQ5lqvoQ2x28FJ1TNPEKRwCfT6qc
qPVUs23Fhm+XsO7PyjEc/54=3D3g47
-----END PGP SIGNATURE-----


