From: Keith Owens <kaos@sgi.com>
Date: Sun, 06 Apr 2003 13:07:26 +0000
Subject: [Linux-ia64] Announce: kdb v4.1 is available for kernels 2.4.19, 2.4.20, i386 and ia64
Message-Id: <marc-linux-ia64-105590723705423@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=us-ascii

ftp://oss.sgi.com/projects/kdb/download/v4.1/

  kdb-v4.1-2.4.19-common-1.bz2
  kdb-v4.1-2.4.19-i386-1.bz2
  kdb-v4.1-2.4.19-ia64-020821-1.bz2
  kdb-v4.1-2.4.20-common-1.bz2
  kdb-v4.1-2.4.20-i386-1.bz2
  kdb-v4.1-2.4.20-ia64-021210-1.bz2

Changelog extracts since v4.0.

2.4.{19,20}-common-1

2003-04-04 Keith Owens  <kaos@sgi.com>

	* Remove one kallsyms pass.
	* Automatic detection of O(1) scheduler.
	* Rename cpu_online to cpu_is_online.
	* Workarounds for scheduler bugs.
	* Tweak algorithm for detecting if cpu process data is available.
	* Add 'kill' command.  Sonic Zhang, Keith Owens.

2.4.{19,20}-i386-1

2003-04-04 Keith Owens  <kaos@sgi.com>

	* Workarounds for scheduler bugs.

2.4.{19,20}-ia64-*-1

2003-04-04 Keith Owens  <kaos@sgi.com>

	* Add support for INIT slave interrupts.
	* Tell SAL to always rendezvous on MCA.
	* No lock on SAL rendezvous call.
	* Include unwind.c from 2.4.21-pre5.
	* Rename cpu_online to cpu_is_online.
	* Workarounds for scheduler bugs.


v4.1/README

Starting with kdb v2.0 there is a common patch against each kernel which
contains all the architecture independent code plus separate architecture
dependent patches.  Apply the common patch for your kernel plus at least
one architecture dependent patch, the architecture patches activate kdb.

The naming convention for kdb patches is :-

 vx.y    The version of kdb.  x.y is updated as new features are added to kdb.
 -v.p.s  The kernel version that the patch applies to.  's' may include -pre,
	 -rc or whatever numbering system the kernel keepers have thought up this
	 week.
 -common The common kdb code.  Everybody needs this.
 -i386   Architecture dependent code for i386.
 -ia64   Architecture dependent code for ia64, etc.
 -n      If there are multiple kdb patches against the same kernel version then
	 the last number is incremented.

To build kdb for your kernel, apply the common kdb patch which is less
than or equal to the kernel v.p.s, taking the highest value of '-n'
if there is more than one.  Apply the relevant arch dependent patch
with the same value of 'vx.y-v.p.s-', taking the highest value of '-n'
if there is more than one.

For example, to use kdb for i386 on kernel 2.4.20, apply
  kdb-v4.1-2.4.20-common-<n>            (use highest value of <n>)
  kdb-v4.1-2.4.20-i386-<n>              (use highest value of <n>)
in that order.  To use kdb for ia64-021210 on kernel 2.4.20, apply
  kdb-v4.1-2.4.20-common-<n>            (use highest value of <n>)
  kdb-v4.1-2.4.20-ia64-021210-<n>       (use highest value of <n>)
in that order.

Use patch -p1 for all patches.

I do not have any time to work on 2.5, so there are no patches available
for 2.5 kernels.  If somebody wants to port the latest kdb patches to
2.5 kernels and send patches to kaos@sgi.com then I will put them up in
this directory.

The kdb-smphdr* patches in the v4.0 directory are Sonic Zhang's changes
to improve hardware breakpoint handling on i386 and ia64.  They are
not official kdb patches yet, they are available for review.  They will
probably fit v4.1.

The next step is to integrate Sonic Zhang's breakpoint changes into kdb
and to change the kdb entry logic to cope with multiple cpus doing
concurrent entry into kdb.  At the moment kdb tries to serialize so it
only processes one event at a time.  The bad news is that this does not
work well with IA64 SAL interrupts so kdb has to change.  The good news
is that the change will remove the deadlock when two cpus hit a
breakpoint at the same time.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE+kCaJi4UHNye0ZOoRAvSZAKC/aXyVRPjaho5/RY+JbhUF8xNGlwCeKtUv
BBrDAhSon5J4woF3+65q+sY=VZPB
-----END PGP SIGNATURE-----


