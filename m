From: Keith Owens <kaos@sgi.com>
Date: Thu, 21 Oct 2004 03:52:28 +0000
Subject: Announce: kdb v4.4 is available for kernel 2.6.9
Message-Id: <6628.1098330748@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12956.1085377697@kao2.melbourne.sgi.com>
In-Reply-To: <12956.1085377697@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kdb@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

KDB (Linux Kernel Debugger) has been updated.

ftp://oss.sgi.com/projects/kdb/download/v4.4/
ftp://ftp.ocs.com.au/pub/mirrors/oss.sgi.com/projects/kdb/download/v4.4/

Current versions are :-

  kdb-v4.4-2.6.9-common-1.bz2
  kdb-v4.4-2.6.9-i386-1.bz2
  kdb-v4.4-2.6.9-ia64-1.bz2
  kdb-v4.4-2.6.9-rc2-x86-64-1.bz2 (may or may not work with 2.6.9).


Changelog extract since kdb-v4.4-2.6.7-common-1.


2004-10-19 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-common-1.

2004-10-12 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-rc4-common-1.

2004-10-01 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-rc3-common-1.

2004-09-30 Keith Owens  <kaos@sgi.com>

	* Add stackdepth command to Documentation/kdb/kdb.mm.  stackdepth is
	  only supported on i386 and ia64 at the moment.
	* Skip kdbm_pg memmap build on x86_64.  Scott Lurndal, 3leafnetworks.
	* Export kdb_serial_str for modular I/O.  Bryan Cardillo, UPenn.
	* Reinstate tab completion for symbols.
	* kdb v4.4-2.6.9-rc2-common-2.

2004-09-14 Keith Owens  <kaos@sgi.com>

	* Add task states C (traCed) and E (dEad).
	* kdb v4.4-2.6.9-rc2-common-1.

2004-08-27 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-rc1-common-1.

2004-08-14 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.8-common-1.

2004-08-12 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.8-rc4-common-1.

2004-08-05 Keith Owens  <kaos@sgi.com>

	* Mark kdb_initcall as __attribute_used__ for newer gcc.
	* kdb v4.4-2.6.8-rc3-common-2.

2004-08-04 Keith Owens  <kaos@sgi.com>

	* Add mdp (memory display physical) comnmand.
	  Ananth N Mavinakayanahalli, IBM.
	* kdb v4.4-2.6.8-rc3-common-1.

2004-07-18 Keith Owens  <kaos@sgi.com>

	* Patch for new sn_console.  Erik Jacobson. SGI.
	* kdb v4.4-2.6.8-rc2-common-1.

2004-07-12 Keith Owens  <kaos@sgi.com>

	* Convert kdbm_task to standard cpumask_t.
	* Document '*' (all breakpoints) option on bd/be/bc commands.
	* kdb v4.4-2.6.8-rc1-common-1.

2004-06-30 Keith Owens  <kaos@sgi.com>

	* Common changes to help the x86-64 port.
	* kdb v4.4-2.6.7-common-3.

2004-06-20 Keith Owens  <kaos@sgi.com>

	* Move kdb includes in mm/swapfile.c to reduce conflicts with other
	  SGI patches.
	* kdb v4.4-2.6.7-common-2.


Changelog extract since kdb-v4.4-2.6.7-i386-1.


2004-10-19 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-i386-1.

2004-10-12 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-rc4-i386-1.

2004-10-01 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-rc3-i386-1.

2004-09-30 Keith Owens  <kaos@sgi.com>

	* Add stackdepth command.
	* Handle backtrace with separate soft and hard irq stacks
          (CONFIG_4KSTACKS).
	* Work around RESTORE_ALL macro, which can only be used once.
	* Export kdba_dumpregs.  Bryan Cardillo, UPenn.
	* kdb v4.4-2.6.9-rc2-i386-2.

2004-09-14 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-rc2-i386-1.

2004-08-27 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.9-rc1-i386-1.

2004-08-14 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.8-i386-1.

2004-08-12 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.8-rc4-i386-1.

2004-08-04 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.8-rc3-i386-1.

2004-07-18 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.8-rc2-i386-1.

2004-07-12 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.8-rc1-i386-1.

2004-06-16 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.7-i386-1.


Changelog extract since kdb v4.4-2.6.7-ia64-040629-1.


2004-10-19 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.9-ia64-1.

2004-10-12 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.9-rc4-ia64-1.

2004-10-01 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.9-rc3-ia64-1.

2004-09-30 Keith Owens  <kaos@sgi.com>

	* Add stackdepth command.
	* kdb-v4.4-2.6.9-rc2-ia64-3.

2004-09-16 Keith Owens  <kaos@sgi.com>

	* Fixes for current in region 5 instead of 7 (idle task on cpu 0).
	* kdb-v4.4-2.6.9-rc2-ia64-2.

2004-09-14 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.9-rc2-ia64-1.

2004-08-27 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.9-rc1-ia64-1.

2004-08-14 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.8-ia64-1.

2004-08-12 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.8-rc4-ia64-1.

2004-08-04 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.8-rc3-ia64-1.

2004-07-18 Keith Owens  <kaos@sgi.com>

	* New config name for SN serial console.
	* kdb-v4.4-2.6.8-rc2-ia64-1.

2004-07-12 Keith Owens  <kaos@sgi.com>

	* kdb-v4.4-2.6.8-rc1-ia64-1.


Changelog extract for kdb v4.4-2.6.9-rc2-x86-64-1.


2004-09-30 Keith Owens <kaos@sgi.com>

	* Port to 2.6.9-rc2
	* Fix line editting characters.  Jim Houston, Comcast.
	* kdb v4.4-2.6.9-rc2-x86-64-1.

2004-08-15 Jack F. Vogel <jfv@bluesong.net>
	* Port to 2.6.8
	* tighten up the code, using the built-in
	  die_chain notify interface, thanks to
	  Andi Kleen for pointing this out.

2004-05-15 Jack F. Vogel <jfv@bluesong.net>
	* port to 2.6.6 for x86_64

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQFBdzJ8i4UHNye0ZOoRAmL7AKDuGQLB94/yos2DoSSC5X7AubniVgCguA26
FQLeGkj6GWY7PjnCgLqdYno=y0AP
-----END PGP SIGNATURE-----

