From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 01 Nov 2001 00:27:17 +0000
Subject: Re: [Linux-ia64] gcc won't inline function returning struct?
Message-Id: <marc-linux-ia64-105590698805430@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805421@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805421@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	typedef struct {
		float re, im;
		int dummy;
	} complex;

I tried this, and it works.

>Since this is no longer an HFA would this kick the compiler into
>a mode where the code would at least work, all be it not in the most
>efficient manner?

Just to clarify, the code that gcc emits is correct.  The testcase can fail
only if the "extern inline" feature is misused.  I assumed that was the
case without explicitly mentioning it.  Thus my recommended solution would be
to stop using extern inline, or else use it correctly.  I can understand that
this might be inconvenient, and that you might want to keep the current
unsafe uses of extern inline.

extern inline means emit this function inline if you can, otherwise emit
nothing.  Since gcc makes no promise that it will inline any function, it
is inherently unsafe to put extern inline in a C file.  There is no guarantee
that it will work.

There are some programs that do this for functions that the IA-32 compiler
happens to inline, but which the IA-64 compiler does not happen to inline.
This always gets reported as an IA-64 gcc "bug", but really it isn't.  It
is programmer error; extern inline has been used incorrectly.

A correct use of extern inline is how glibc uses it.  It puts extern inline
in header files, and static functions in C files linked into libc/libm.
If gcc can inline the function, then you get the fast inline version from
the header file.  If gcc cannot inline the function, then you get the slow
static version from libc/libm.

Jim

