From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 18 Dec 2001 05:12:20 +0000
Subject: [Linux-ia64] Re: Announce: Kernel Build for 2.5, Release 1.11 is available
Message-Id: <marc-linux-ia64-105590698805711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

Patch for IA64 support using kbuild 2.5 for 2.4.16-ia64-011214.
Build the kbuild 2.5 for ia64-011214 tree in this order:

  Linus's 2.4.16 kernel.
  kbuild-2.5-2.4.16-2 (common and ix86 patches).
  linux-2.4.16-ia64-011214.diff (ia64 changes from Linus's tree).
  kbuild-2.5-2.4.16-ia64-011214-2 (ia64 specific kbuild 2.5 patches).

Then proceed with kbuild 2.5, see Documentation/kbuild/kbuild-2.5.txt.

If you are still using 2.4.16-ia64-011128 you can patch in this order:

  Linus's 2.4.16 kernel.
  kbuild-2.5-2.4.16-2 (common and ix86 patches).
  linux-2.4.16-ia64-011128.diff (older ia64 changes from Linus's tree).
  kbuild-2.5-2.4.16-ia64-011214-2 (the current ia64 kbuild patch).
  Manually edit arch/ia64/kernel/Makefile.in to remove salinfo.o from
  the select list.

NOTE: The previous kbuild 2.5 ia64 patch prevented the use of kbuild
      2.4, this patch attempts to preserve the use of kbuild 2.4 on
      ia64.  It makes the patch quite a bit uglier but is probably
      worth the effort.

This conversion to kbuild 2.5 has only been tested with CONFIG_IA64_DIG=y.  I
could not test with CONFIG_IA64_HP_SIM=y (compile and build errors),
CONFIG_IA64_SGI_SN[12]=y (no asm/mmzone.h) or CONFIG_IA64_GENERIC=y (all the
problems of each platform).

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE8HtAzi4UHNye0ZOoRAhEGAKDy9ekVxfNGbkCBdvBBeBG+IZgAUQCg5MLU
LaQF7+Dll48XejzyEXDZdTk=Ky+a
-----END PGP SIGNATURE-----


