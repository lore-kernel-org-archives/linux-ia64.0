From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 18 Jun 2001 21:26:15 +0000
Subject: [Linux-ia64] gcc3.0 tarball available
Message-Id: <marc-linux-ia64-105590693005739@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

As you may have heard, gcc3.0 has been released.  A tar ball
containing the binaries for ia64 linux can be found at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/

Everything is built with debug info, so the tar ball is quite big
(71MB). It extracts into /opt/gcc3/ and the "bin" directory contains
the C, C++, Java, and Fortran compiler (the latter two haven't been
tested much).  The tar ball also includes a recent version of binutils
and gdb.  This makes it possible to the Linux kernel with:

	make CROSS_COMPILE=/opt/gcc3/bin/

There are some known issues with gcc3.0.  For example, glibc doesn't
build out of the box (though there are easy workarounds for this) and
there is a remaining C++ ABI incompatibility with respect to the
layout of the vtables (they should contain function descriptors, but
currently contain function pointers) but other than that, gcc3.0 seems
to work quite well and is definitely worth playing with.  For example,
I have been building Linux kernels with it for some time now and would
generally recommend to use it.

Many thanks in particular to Jim Wilson and Richard Henderson on
working so hard to make gcc3.0 useful for ia64 linux!

Enjoy,

	--david

PS: Of course, the tar ball is provided "as is", without warrant,
    support, etc.

