From: Xavier Bru  <Xavier.Bru@bull.net>
Date: Thu, 10 Jan 2002 18:48:26 +0000
Subject: [Linux-ia64] Re: Announce: kdb v2.0 is available for kernel 2.4.17
Message-Id: <marc-linux-ia64-105590698805789@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

We must take care that the common KDB patch (kdb-v2.0-2.4.17-common-3)
conflicts with the IA64 patch on 2.4.17(linux-2.4.17-ia64-011226.diff). (ne=
eds to merge both patches).
I did not notice that first time and got a strange KDB behavior ( kdb_init()
was not called, and no way to quit kdb after breaking into it ).

--=20

 Sinceres salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


Keith Owens writes:
 > -----BEGIN PGP SIGNED MESSAGE-----
 > Hash: SHA1
 >=20
 > Content-Type: text/plain; charset=3Dus-ascii
 >=20
 > ftp://oss.sgi.com/projects/kdb/download/v2.0/
 >=20
 >   kdb-v2.0-2.4.17-common-1.bz2
 >   kdb-v2.0-2.4.17-i386-1.bz2
 >=20
 > Starting with kdb v2.0 there is a common patch against each kernel which
 > contains all the architecture independent code plus separate architecture
 > dependent patches.  Apply the common patch for your kernel plus at least
 > one architecture dependent patch, the architecture patches activate kdb.
 >=20
 > The naming convention for kdb patches is :-
 >=20
 > vx.y    The version of kdb.  x.y is updated as new features are added to=
 kdb.
 > - -v.p.s  The kernel version that the patch applies to.  's' may include=
 -pre,
 >         -rc or whatever numbering system the kernel keepers have thought=
 up this
 >         week.
 > - -common The common kdb code.  Everybody needs this.
 > - -i386   Architecture dependent code for i386.
 > - -ia64   Architecture dependent code for ia64, etc.
 > - -n      If there are multiple kdb patches against the same kernel vers=
ion then
 >         the last number is incremented.
 >=20
 > To build kdb for your kernel, apply the common kdb patch which is less
 > than or equal to the kernel v.p.s, taking the highest value of '-n'
 > if there is more than one.  Apply the relevant arch dependent patch
 > with the same value of 'vx.y-v.p.s-', taking the highest value of '-n'
 > if there is more than one.
 >=20
 > For example, to use kdb v2.0 for i386 on kernel 2.4.17, apply
 >   kdb-v2.0-2.4.17-common-1
 >   kdb-v2.0-2.4.17-i386-1
 > in that order.
 >=20
 >=20
 > This release is functionally equivalent to kdb v1.9-2.4.16, the only
 > change is the reorganisation.  I have a backlog of kdb changes which
 > were on hold until the patches had been split, it was getting too messy
 > trying to maintain at least six versions of the common kdb code and
 > keep them in sync.  I hope to clear the backlog soon.
 >=20
 > Ethan Solomita (ethan@cs.columbia.edu) has done a port of kdb to
 > sparc64 against 2.4.13.  I will upgrade that to 2.4.17 and issue
 > kdb-v2.0-2.4.17-sparc64-1.bz2 "soon".  kdb for ia64 has to wait until
 > the 2.4.17-ia64 kernel patch is issued.
 >=20
 > Changelog extract.
 >=20
 > 2001-12-22 Keith Owens  <kaos@sgi.com>
 >=20
 >         * Upgrade to 2.4.17.
 >         * Clean up ifdef CONFIG_KDB.
 >         * Add ifdef CONFIG_KDB around include kdb.h.
 >         * Delete dummy kdb.h files for unsupported architectures.
 >         * Delete arch i386 and ia64 specific files.  This changelog now
 >           applies to kdb common code only.
 >         * Release as kdb v2.0-2.4.17-common-1.
 >=20
 > -----BEGIN PGP SIGNATURE-----
 > Version: GnuPG v1.0.4 (GNU/Linux)
 > Comment: Exmh version 2.1.1 10/15/1999
 >=20
 > iD8DBQE8JElbi4UHNye0ZOoRArPiAKCYlVUzS3EYrE5XC8sn3Xz8L9mBeQCeLHGn
 > Wdx2YfBSiLgCmg6nlUPr+8A > =BFtm
 > -----END PGP SIGNATURE-----
 >=20

