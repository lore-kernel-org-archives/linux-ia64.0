From: Keith Owens <kaos@melbourne.sgi.com>
Date: Thu, 08 Feb 2001 00:45:48 +0000
Subject: [Linux-ia64] kdb-v1.7-2.4.1-ia64-010131 is available
Message-Id: <marc-linux-ia64-105590693005122@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

http://oss.sgi.com/projects/kdb/download/ia64/ contains kdb v1.7 for
IA64, using the same design as kdb for i386.  This is completely
incompatible with HP's version of kdb, use one or the other but not
both.

kdb-v1.7-2.4.1-ia64-010131 is a patch against Linus's 2.4.1 tree + HP's
linux-2.4.1-ia64-010131.diff; apply the HP IA64 kernel patch before
kdb.  The only significant change to kdb from 2.4.0 is the removal of
the struct switch_stack changes, kdb now uses a different method to get
a starting point for back trace.

You must use a compiler that supports the new unwind code, kdb relies
on unwind data.  I have been using gcc snapshot snap-001117 from
cygnus.

The kdb patch also contains code for the i386 version of kdb but do not
use this patch on i386, the i386 and IA64 patches for kdb are not
interchangable due to ia64-010109 changes to common kernel code.

There are still a lot of rough edges in kdb for IA64, treat it with
care.

Save your .config and do make mrproper after applying the kdb patch.
To cross compile kdb for ia64 from i386 from you need kallsyms_i386_ia64.c
from kdb/download/ia64.  Compile wth -malign-double and save the binary
anywhere.  Specify the location of the cross compile kallsyms on the
make command.

Point CROSS_COMPILE_INC at an include library that contains an ia64
version of bfd.h, it must contain these lines

#define BFD_ARCH_SIZE 64
#define BFD_HOST_64BIT_LONG 0

Example cross compile from i386 to ia64 with kdb.

make ARCH=ia64 \
  CROSS_COMPILE=/ia64/install/bin/ia64-unknown-linux- \
  CROSS_COMPILE_INC=/ia64/install/include/ \
  KALLSYMS=/ia64/kallsyms_i386_ia64 \
  vmlinux modules


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.3 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE6gew7i4UHNye0ZOoRAnkxAKC+D0l1Ii2iXgWRGB9f5yb2f2C+gwCfXHa+
whjdqe/lUGkvusnPr+C8rmU=I7iQ
-----END PGP SIGNATURE-----


