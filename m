From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 30 Aug 2000 23:54:29 +0000
Subject: [Linux-ia64] new toolchain snapshots
Message-Id: <marc-linux-ia64-105590678205422@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am making available new toolchain snapshots, based on July FSF gcc sources.
These snapshots are available from ftp.cygnus.com in pub/ia64-linux.  The
current snapshot is in the snap-000828 directory.

The new toolchain is intended to support glibc 2.2.  Because of ABI changes,
the new toolchain will not work as is on any existing glibc 2.1.3 based
system.  There is a README.glibc213 file that will revert some of the ABI
changes allowing the toolchain to mostly work on existing systems.  This is
just a temporary workaround until glibc 2.2 based systems are available
though, and I don't expect to support this use of the toolchain.

The new toolchain is not as robust as the February-based toolchains yet.
There are a number of reported bugs against cpp that need to be investigated
and fixed.  There are some DV related problems that should be fixed.  Etc.
I won't consider this a production quality toolchain until someone has managed
to build a complete working linux system from it.  That hasn't happened yet.

If you want to build kernels from this toolchain, then you must use 2.4.0-test7
or later.  This toolchain will not build earlier kernels because of optimizer
changes that exposed problems with some of the extended asms in the kernel.

Jim

