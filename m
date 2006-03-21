From: Keith Owens <kaos@sgi.com>
Date: Tue, 21 Mar 2006 05:59:24 +0000
Subject: Announce: kdb v4.4 is available for kernel 2.6.16
Message-Id: <28258.1142920764@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <12956.1085377697@kao2.melbourne.sgi.com>
In-Reply-To: <12956.1085377697@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: kdb@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

KDB (Linux Kernel Debugger) has been updated for kernel 2.6.16.

ftp://oss.sgi.com/projects/kdb/download/v4.4/
ftp://ftp.ocs.com.au/pub/mirrors/oss.sgi.com/projects/kdb/download/v4.4/

Note:  Due to a spam attack, the kdb@oss.sgi.com mailing list is now
subscriber only.  If you reply to this mail, you may wish to trim
kdb@oss.sgi.com from the cc: list.

Thanks to Nathan Scott for updating KDB while I was on holiday.

Current versions are :-

  kdb-v4.4-2.6.16-common-1.bz2
  kdb-v4.4-2.6.16-i386-1.bz2
  kdb-v4.4-2.6.16-ia64-1.bz2

Changelog extract since kdb-v4.4-2.6.15-common-1.

2006-03-21 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.16-common-1.

2006-03-14 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc6-common-1.

2006-02-28 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc5-common-1.

2006-02-20 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc4-common-1.

2006-02-06 Keith Owens  <kaos@sgi.com>

	* Change CONFIG_CRASH_DUMP to CONFIG_LKCD.
	* Remove obsolete kdb_notifier_list.
	* kdb v4.4-2.6.16-rc2-common-2.

2006-02-06 Keith Owens  <kaos@sgi.com>

	* Add xpcusers command.  Dean Nelson, SGI.
	* kdb v4.4-2.6.16-rc2-common-1.

2006-02-02 Keith Owens  <kaos@sgi.com>

	* Check if we have a console before using it for KDB.
	* kdb v4.4-2.6.16-rc1-common-3.

2006-02-01 Keith Owens  <kaos@sgi.com>

	* Add option 'R' to the pid command to reset to the original task.
	* Include 'pid R' in archkdb* commands to reset up the original failing
	  task.  Users may have switched to other cpus and/or tasks before
	  issuing archkdb.
	* Compile fix for kdbm_pg.c on i386.
	* kdb v4.4-2.6.16-rc1-common-2.

2006-01-18 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.16-rc1-common-1.

2006-01-11 Keith Owens  <kaos@sgi.com>

	* Plug a timing race between KDB_ENTER_SLAVE and KDB_ENTER, and allow
	  the cpu command to switch to a slave cpu.
	* KDB_REASON_SILENT now waits for other cpus, to avoid spurious NMI
	  events that were seen on some Xeon systems.
	* kdb v4.4-2.6.15-common-3.

2006-01-08 Keith Owens  <kaos@sgi.com>

	* kdb mainline invokes DIE_KDEBUG_ENTER and DIE_KDEBUG_LEAVE via
	  notify_die.
	* Move xpc debug support from xpc to mainline kdb.
	* kdbm_cm.c: check if file_lock_operations or lock_manager_operations
	  are set before dereferencing them.  Felix Blyakher, SGI.
	* kdb v4.4-2.6.15-common-2.


Changelog extract since kdb-v4.4-2.6.15-i386-1.

2006-03-21 Keith Owens  <kaos@sgi.com>

        * kdb v4.4-2.6.16-i386-1.

2006-03-14 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc6-i386-1.

2006-02-28 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc5-i386-1.

2006-02-20 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc4-i386-1.

2006-02-06 Keith Owens  <kaos@sgi.com>

	* Change CONFIG_CRASH_DUMP to CONFIG_LKCD.
	* kdb v4.4-2.6.16-rc2-i386-2.

2006-02-06 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.16-rc2-i386-1.

2006-01-18 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.16-rc1-i386-1.

2006-01-08 Keith Owens  <kaos@sgi.com>

	* Add DIE_KDEBUG_ENTER and DIE_KDEBUG_LEAVE to notify_die.
	* kdb v4.4-2.6.15-i386-2.


Changelog extract since kdb v4.4-2.6.15-ia64-1.

2006-03-21 Keith Owens  <kaos@sgi.com>

        * kdb v4.4-2.6.16-ia64-1.

2006-03-14 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc6-ia64-1.

2006-02-28 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc5-ia64-1.

2006-02-20 Nathan Scott  <nathans@sgi.com>

	* kdb v4.4-2.6.16-rc4-ia64-1.

2006-02-07 Keith Owens  <kaos@sgi.com>

	* Change kdb_running_process_save from a static array to a pointer.
	  gcc 4.0 objects to forward declarations for arrays with an incomplete
	  type.
	* kdb v4.4-2.6.16-rc2-ia64-3.

2006-02-06 Keith Owens  <kaos@sgi.com>

	* Change CONFIG_CRASH_DUMP to CONFIG_LKCD.
	* kdb v4.4-2.6.16-rc2-ia64-2.

2006-02-06 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.16-rc2-ia64-1.

2006-02-01 Keith Owens  <kaos@sgi.com>

	* Handlers: check that the task is in kernel space before looking at
	  the thread_info bits.
	* Expose kdb_running_process_save[] so 'pid R' can get the original
	  process, even when the MCA/INIT handlers are being used.
	* kdb v4.4-2.6.16-rc1-ia64-3.

2006-01-19 Keith Owens  <kaos@sgi.com>

	* Add back some kdb changes to xpc_main that were lost due to a patch
	  conflict.
	* kdb v4.4-2.6.16-rc1-ia64-2.

2006-01-18 Keith Owens  <kaos@sgi.com>

	* kdb v4.4-2.6.16-rc1-ia64-1.

2006-01-10 Keith Owens  <kaos@sgi.com>

	* Build kdba_pod for generic as well as sn2 kernels and test at run
	  time if the platform is sn2.
	* kdb v4.4-2.6.15-ia64-3.

2006-01-08 Keith Owens  <kaos@sgi.com>

	* Convert xpc to use DIE_KDEBUG_ENTER and DIE_KDEBUG_LEAVE.
	* Add debug option for xpc.
	* break.b always sets a debug trap number of 0 , so pass that to kdb as
	  well as the normal kdb traaps.
	* kdb v4.4-2.6.15-ia64-2.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQFEH5Y8i4UHNye0ZOoRAgxfAKDEFyGyiC0MqpZf3g++ZcyWnkZm4QCfdGpB
vrKA3BN4aKCI/MDX6bJTme0=EDpm
-----END PGP SIGNATURE-----

