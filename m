From: Jeff Licquia <jlicquia@progeny.com>
Date: Tue, 09 Apr 2002 05:56:54 +0000
Subject: Re: [Linux-ia64] epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905425@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905403@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905403@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2002-04-09 at 00:09, Randolph Chung wrote:
> > I'm unable to reproduce this.  If I'm understanding you right, the
> > problem occurred during the configure phase of mozilla (not libffi).
> 
> that's right
> 
> > I just rebuilt Mozilla from the current CVS tree with gcc3.1
> > pre-release and the current CVS binutils.  It built just fine and the
> > resulting binary seems to work flawlessly.
> 
> I'm building from Debian sources. It's possible that it's simply out of
> date (I'm building version 0.9.9).
> 
> > >From the assembly code you provided, it looks as if conftest.c tried
> > to call FFI_STATIC_CLOSURE() from within a function, which can't
> > possibly work.
> 
> indeed, mozilla's configure.in says:
> 
>     if test "$LIBFFI_FOUND" = "yes"; then
>         AC_MSG_CHECKING("for FFI_STATIC_CLOSURE in libffi")
>         AC_TRY_COMPILE([#include "ffi.h"],
>                         [ FFI_STATIC_CLOSURE(foo, bar, baz, quux); ],
>                         [ LIBFFI_HAS_STATIC_CLOSURE=yes ])
>         AC_MSG_RESULT("$result")
>     fi
> 
> which generates (from config.log):
> 
> configure:13494: checking for FFI_STATIC_CLOSURE in libffi
> configure:13503: gcc-3.0 -c -I/home/randolph/debian/mozilla-0.9.9/build-tree/libffi-install/include  -fshort-wchar -pthread -pipe   -I/usr/X11R6/include conftest.c 1>&5
> {standard input}: Assembler messages:
> {standard input}:40: Error: Epilogue count of 4294967296 exceeds number of nested prologues (0)
> configure: failed program was:
> #line 13496 "configure"
> #include "confdefs.h"
> #include "ffi.h"
> int main() {
>  FFI_STATIC_CLOSURE(foo, bar, baz, quux);
> ; return 0; }

I claim responsibility for this code.  For some reason, it worked in
older revisions.

But yes, I can see how that's incorrect, and should be changed.  I can
whip up a patch if no one else is tomorrow.


