From: Keith Owens <kaos@sgi.com>
Date: Mon, 03 Dec 2001 06:11:31 +0000
Subject: [Linux-ia64] Announce: kdb v1.9 is available for kernel 2.4.16
Message-Id: <marc-linux-ia64-105590698805576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

ftp://oss.sgi.com/projects/kdb/download/ix86/kdb-v1.9-2.4.16.bz2
ftp://oss.sgi.com/projects/kdb/download/ia64/kdb-v1.9-2.4.16-ia64-011128.bz2

Ethan Solomita (ethan@cs.columbia.edu) has done a port of kdb to
sparc64 against 2.4.13.  I will upgrade that to 2.4.16, integrate it
with the other kdb changes since 2.4.13 and release it in a few days.

This will probably be the last release of kdb using this patch format.
I plan to split kdb into a core patch and smaller arch dependent
patches, instead of one big patch for each arch.

Changelog extract.

2001-12-03 Keith Owens  <kaos@sgi.com>

	* Upgrade to 2.4.16.
	* Add include/asm-um/kdb.h stub to allow XFS to be tested under UML.
	* Check if an interrupt frame on i386 came from user space.
	* Out of scope bug fix in kdb_id.c.  Ethan Solomita.
	* Changes to common code to support sparc64.  Ethan Solomita.
	* Change GFP_KERNEL to GFP_ATOMIC in disasm.  Ethan Solomita.

2001-11-16 Keith Owens  <kaos@sgi.com>

	* Upgrade to 2.4.15-pre5.
	* Wrap () around #define expressions with unary operators.

2001-11-13 Keith Owens  <kaos@sgi.com>

	* Upgrade to 2.4.15-pre4.
	* kbdm_pg.c patch from Hugh Dickins.

2001-11-07 Keith Owens  <kaos@sgi.com>

	* Upgrade to 2.4.14-ia64-011105.
	* Change name of l1 serial I/O routine, add ia64 init command.  SGI.
	* Sync kdbm_pg with XFS.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE8CxeSi4UHNye0ZOoRAg5XAJ0X38pwRAQn626kA52x3blkPqJEZQCfYFZf
uEs8b9QtISbATIBWtO44H/Ms4
-----END PGP SIGNATURE-----


