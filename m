From: Jim Wilson <wilson@redhat.com>
Date: Thu, 05 Dec 2002 03:11:26 +0000
Subject: [Linux-ia64] Re: [patch] binutils support for new IA-64 instructions (as per SDM2.1)
Message-Id: <marc-linux-ia64-105590709805502@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[This also went to the binutils list, but my first attempt at replying to
David's message had a broken linux-ia64 address, apparently because of a buggy
Red Hat MTA, so I am resending this separately.]

I looked through the patch, comparing it against the new manuals, and didn't
see any problems.

I rebuilt ia64-asmtab.c, and checked in your patch along with a ChangeLog
entry for the ia64-asmtab.c change.

While testing this, I got a gas testsuite failure in opc-x.d.  This is an
objdump problem.  Objdump sees 8 consecutive zeros, prints "...", and then
starts printing bundles at the wrong address.  When we get to the end of the
file, we accidentally print two bytes past the end.  This data is garbage,
and I happened to get a non-zero value for one of the bytes.  There is already
a solution for this problem for the c4x which we should be able to adapt for
the IA-64.  That involves setting SKIP_ZEROES to 16 in binutils/configure.in.
I will try writing a patch for that tomorrow.

There are dependency tables in Intel's DVLoc library.
        http://www.intel.com/software/products/opensource/tools1/dvloc.htm
However, that hasn't been updated since August 2000.  We would need an updated
copy of that, plus permission to take files from there and use them in
binutils.

Jim

