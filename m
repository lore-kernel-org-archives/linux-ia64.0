From: Keith Owens <kaos@sgi.com>
Date: Sun, 06 Jun 2004 10:04:14 +0000
Subject: Announce: kdb v4.4 updates for for kernel 2.6.6
Message-Id: <12428.1086516254@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kdb@oss.sgi.com, linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

KDB (Linux Kernel Debugger) has been updated.

ftp://oss.sgi.com/projects/kdb/download/v4.4/

Current versions are :-

  kdb-v4.4-2.6.6-common-2.bz2
  kdb-v4.4-2.6.6-i386-2.bz2
  kdb-v4.4-2.6.6-ia64-040521-2.bz2
  kdb-v4.4-2.6.6-sparc64-1.bz2

Changelog extract since kdb-v4.3-2.6.6-common-2.

2004-06-06 Keith Owens  <kaos@sgi.com>

	* Avoid recursion problems in kdb_init().
	* Add standard archkdb commands.
	* Add per_cpu command.
	* Move kdb_{get,put}userarea_size definitions to linux/kdb.h.
	* kdb v4.4-2.6.6-common-2.

Changelog extract since kdb-v4.3-2.6.6-i386-1.

2004-06-06 Keith Owens  <kaos@sgi.com>

	* Correct Kconfig help text.
	* Coexist with CONFIG_REGPARM.
	* Add standard archkdb commands.
	* Move kdb_{get,put}userarea_size definitions to linux/kdb.h.
	* kdb v4.4-2.6.6-i386-2.

Changelog extract since kdb v4.3-2.6.6-rc3-ia64-1.

2004-06-06 Keith Owens  <kaos@sgi.com>

	* Add standard archkdb commands.
	* Move kdb_{get,put}userarea_size definitions to linux/kdb.h.
	* kdb v4.4-2.6.6-ia64-040521-2.

Changelog extract for sparc64.

2004-05-24 Tom Duffy <Thomas.Duffy.99@alumni.brown.edu>

	* bump up to 2.6.6 kernel
	* move to kdb 4.4 base
	* kdb v4.4-2.6.6-sparc64-1

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQFAwuwdi4UHNye0ZOoRAsJkAJ4iH0j6IaZsYZMEOabW4xMHw1wciACcCFey
ceeg7EBi97KqtgXUQe0Nw84=FvEk
-----END PGP SIGNATURE-----

