From: Keith Owens <kaos@sgi.com>
Date: Sat, 06 Dec 2003 06:26:40 +0000
Subject: Re: Announce: kdb v4.3 is available for kernel 2.4.23
Message-Id: <marc-linux-ia64-107069202810924@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105609297910151@msgid-missing>
In-Reply-To: <marc-linux-ia64-105609297910151@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Content-Type: text/plain; charset=3Dus-ascii

The latest version of the Linux Kernel Debugger (kdb) is in

ftp://oss.sgi.com/projects/kdb/download/v4.3/

Current versions are
  kdb-v4.3-2.4.23-common-2.bz2
  kdb-v4.3-2.4.23-i386-1.bz2
  kdb-v4.3-2.4.23-ia64-031205-1.bz2

ia64 has just been added.  Changelog extracts for ia64 since 2.4.22.

2003-12-06 Keith Owens  <kaos@sgi.com>

	* Coexist with the new salinfo interface.
	* Redo the workaround for backtrace through spinlock contention called
	  from leaf functions.
	* kdb v4.3-2.4.23-ia64-031205-1.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)
Comment: Exmh version 2.1.1 10/15/1999

iD8DBQE/0Xagi4UHNye0ZOoRAiBZAJsFkZE9YNG7C8K8K9HJsl/7X4u3EQCfa2GK
2Nj2Ou21kJEEiiI5dCNYXj4=CFJG
-----END PGP SIGNATURE-----

