From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 10 Jul 2002 18:08:59 +0000
Subject: [Linux-ia64] libunwind-based gdb available for testing
Message-Id: <marc-linux-ia64-105590701905760@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

For a while now, I had a version of gdb that is based on libunwind.
The main-advantage of using libunwind is that it can reliably do
backtraces.  Things have become stable enough that I think it might be
worthwhile to give it some more exposure, so others can try it out and
report their experiences.

A pre-compiled binary and the corresponding patch can be found at
ftp://ftp.hpl.hp.com/pub/linux-ia64:

					md5sum:
  112456 ugdb-020531.diff.gz		ccd363430b73157832a64895dcd60357
 1693480 ugdb-ia64-020531.tar.gz	a617f7870f2cde0963f5cd8610591bd6

Brief installation/usage instructions are in the README contained in
the tar ball.

My plan is to update the gdb patch for the current gdb CVS tree and
then get the libunwind support merged into the official sources.

Note that the libunwind API is not ia64 specific.  I'm hoping to have
a DWARF2-unwinder based libunwind implementation at some point, so
that gdb libunwind support can be extended to other architectures
(e.g., Alpha).  Of course, any and all help would be welcome in this
effort.

Enjoy,

	--david

