From: Jim Wilson <wilson@cygnus.com>
Date: Sat, 18 Nov 2000 05:34:58 +0000
Subject: [Linux-ia64] 001117 toolchain release
Message-Id: <marc-linux-ia64-105590678205748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have put a new toolchain on ftp.cygnus.com in pub/ia64-linux/snap-001117.

This fixes all significant known toolchain problems.  I don't expect to be
adding more patches to the toolchain unless another serious toolchain bug is
found.

There is one more significant ABI change since the last release.  There was
a corresponding glibc change, so this requires an up-to-date glibc (Nov 16 or
later).  If you already have glibc 2.2, you need to recompile from scratch.
If you are trying to use this toolchain with glibc 2.1.3, then you need a
new copy of the README.glibc213 file, since this file now needs to revert 3 ABI
changes instead of 2.  Since there are no public OS distributions using glibc
2.2 yet, the glibc and toolchain maintainers decided it was better to fix ABI
bugs now than later.

I expect that the next toolchain release will be something based off of the
FSF gcc 3.0 tree sometime early next year.  This depends on when gcc 3.0 will
be available, and that is anybody's guess, but the general idea here is to get
all of us migrated to an official FSF release instead of the development
releases that we have been using.

Jim

