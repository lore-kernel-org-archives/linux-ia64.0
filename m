From: Keith Owens <kaos@sgi.com>
Date: Wed, 11 Feb 2004 04:16:18 +0000
Subject: Announce: kdb v4.3 is available for kernel 2.4.25-rc1
Message-Id: <4730.1076472978@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kdb@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

ftp://oss.sgi.com/projects/kdb/download/v4.3/

Current versions are :-
  kdb-v4.3-2.4.25-rc1-common-1.bz2
  kdb-v4.3-2.4.25-rc1-i386-1.bz2
  kdb-v4.3-2.4.25-rc1-ia64-cset-1.1069.246.14-to-1.1166-1.bz2

Before applying kdb for ia64, you must apply the 2.4.25-rc1 BK patch,
the first link on
ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/testing/cset/index.html.

Changelog extracts since 2.4.23.

common

2004-02-11 Keith Owens  <kaos@sgi.com>

	* Convert longjmp buffers from static to dynamic allocation, for large
	  cpu counts.
	* Tweak kdbm_task for SMP/UP.
	* Update to 2.4.25-rc1.
	* Simplify coexistence with NPTL patches.
	* Support kill command on new scheduler.
	* Do not refetch data when printing a value as characters.
	* Document the pid command.
	* kdb v4.3-2.4.25-rc1-common-1.


i386

2004-02-11 Keith Owens  <kaos@sgi.com>

	* Adjust for LDT changes in i386 mainline.
	* kdb v4.3-2.4.25-rc1-i386-1.


ia64

2004-02-11 Keith Owens  <kaos@sgi.com>

	* Convert longjmp buffers from static to dynamic allocation, for large
	  cpu counts.
	* Update to 2.4.25-rc1 bk, including rework of mca.c patch after the
	  major clean up of mca.c.
	* Redo KDBA_MCA_TRACE to get more diagnostics for MCA/INIT events.
	* Handle recoverable MCA/INIT events, kdb traces them but does not drop
	  into kdb.
	* kdb v4.3-2.4.25-rc1-ia64-cset-1.1069.246.14-to-1.1166-1.


Porting kdb v4.3 to 2.6.[23] is now in progress.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQFAKaySi4UHNye0ZOoRAvEtAJ0fP2WvSAaT91nfbUdpFrbKQegMWwCgt1TR
8mTZeytw7+nch3FEe+wsFJc=KATc
-----END PGP SIGNATURE-----

