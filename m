From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 31 Jul 2000 18:56:48 +0000
Subject: [Linux-ia64] Re: ia64 toolchain problem
Message-Id: <marc-linux-ia64-105590678205249@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I still don't know what bug you are trying to report.  If indeed there is a
bug here, I would very much like to know what it is.

I agree that there is a discrepancy between glibc and gcc.  Obviously, we need
to fix glibc to match gcc.  Your proposal to change gcc to avoid future
problems has some merit, but it is very controversial and unlikely to be
adopted anytime soon.  If you can wait a year for a fix, then fine, we can go
with the gcc change.  Otherwise, if you want the problem fixed now, then we
need to fix glibc.  Like I said last time, you need to report this bug to the
glibc maintainers so that they can fix glibc.

	My point is gcc should define a stable ABI

There is no stable ABI yet, because we are still writing the compiler.
When the compiler is done, the ABI will be stable, and we won't have this
problem anymore.

These are the kinds of problems you have to live with when the hardware, OS,
and compilers are all developed in parallel.

	Is collect2 used on ia64?  If yes, it has the same problem as glibc

Yes and no.  collect2 does multiple things, and is used for all targets.
But the important bit here, creating the init sections, is not used for most
elf targets including ia64, and hence this isn't a problem.

Jim


