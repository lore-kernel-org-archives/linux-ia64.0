From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 03 Oct 2000 01:02:02 +0000
Subject: Re: [Linux-ia64] gcc bug (2.9-ia64-000216-final)
Message-Id: <marc-linux-ia64-105590678205540@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205537@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205537@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a memory aliasing bug that causes the instruction scheduler to perform
invalid code movement.  It only occurs when both const and volatile are
present on a function argument.

When you use volatile, the compiler forces the argument to the stack.  When
you use const, the compiler marks the stack read as a const read, but does not
also similarly mark the stack write.  Thus the scheduler thinks the write and
read do not alias and can be re-ordered.  If I use -O2 -fno-schedule-insns I
get correct code.  For a more complicated example, you might also need to use
-fno-schedule-insns2.  Or you can just use -O to avoid the problem.

The new toolchain does not have this bug.

Jim

