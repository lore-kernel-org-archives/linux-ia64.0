From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Apr 2002 05:00:02 +0000
Subject: Re: [Linux-ia64] epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905423@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905403@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905403@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Apr 2002 22:09:53 -0700, Randolph Chung <tausq@debian.org> said:

  Randolph> indeed, mozilla's configure.in says:

  Randolph> if test "$LIBFFI_FOUND" = "yes"; then
  Randolph> AC_MSG_CHECKING("for FFI_STATIC_CLOSURE in libffi")
  Randolph> AC_TRY_COMPILE([#include "ffi.h"],
  Randolph> [ FFI_STATIC_CLOSURE(foo, bar, baz, quux); ],
  Randolph> [ LIBFFI_HAS_STATIC_CLOSURE=yes ])
  Randolph> AC_MSG_RESULT("$result")
  Randolph> fi

  Randolph> which generates (from config.log):

  Randolph> configure:13494: checking for FFI_STATIC_CLOSURE in libffi
  Randolph> configure:13503: gcc-3.0 -c -I/home/randolph/debian/mozilla-0.9.9/build-tree/libffi-install/include  -fshort-wchar -pthread -pipe   -I/usr/X11R6/include conftest.c 1>&5
  Randolph> {standard input}: Assembler messages:
  Randolph> {standard input}:40: Error: Epilogue count of 4294967296 exceeds number of nested prologues (0)
  Randolph> configure: failed program was:
  Randolph> #line 13496 "configure"
  Randolph> #include "confdefs.h"
  Randolph> #include "ffi.h"
  Randolph> int main() {
  Randolph> FFI_STATIC_CLOSURE(foo, bar, baz, quux);
  Randolph> ; return 0; }

For some reason, I don't see this in my configure.in.  Was this added
by the Debian patch?  In principle, it's a good idea to check for this
macro, but I the check needs to be different.  To get it to compile,
FFI_STATIC_CLOSURE() would have to be declared at the outermost level.
Alternatively, perhaps you can just grep for this macro in ffi.h (I
think autoconf has support for doing this).

	--david

PS: I dropped binutils from the cc list, as it's clearly not a binutils
    issue.

