From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 23 Sep 2000 03:37:31 +0000
Subject: [Linux-ia64] Announce: modutils 2.3.17 is available
Message-Id: <marc-linux-ia64-105590678205516@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fastest download from kernel.org.
Mirror at ftp://ftp.<country>.kernel.org/pub/linux/utils/kernel/modutils/v2.3
Master at ftp://ftp.ocs.com.au/pub/modutils/v2.3.  (slow)

patch-modutils-2.3.17.bz2       Patch from modutils 2.3.16 to 2.3.17
modutils-2.3.17.tar.bz2         Source tarball, includes RPM spec file
modutils-2.3.17-1.src.rpm       As above, in SRPM format
modutils-2.3.17-1.i386.rpm      Compiled with egcs-2.91.66, glibc 2.1.2

Changelog extract

	* config.{guess,sub}, configure.in updates by Pavel Roskin.
	* Fix a NULL base_dir in modinfo.  Reported by John Summerfield.
	* obj_ia64 patch for module unwind.  Mike Stephens.
	* Add vmlinux, vmlinuz, bzImage, zImage to prune list.
	* depmod -F System.map only looks at exported symbols.
	* Convert to bzip2.

IA64 users with patch 2.4.0-test8-000908 or later need this version of
modutils for correct unwind support in modules.  Otherwise IA64 modules
may not load.


