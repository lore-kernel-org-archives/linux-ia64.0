From: Jim Wilson <wilson@redhat.com>
Date: Thu, 21 Mar 2002 21:01:18 +0000
Subject: Re: [Linux-ia64] Trouble building cross compilers
Message-Id: <marc-linux-ia64-105590701905316@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905309@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905309@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>1) is it possible to build an x86 hosted gcc 3.0 ia64 cross compiler
>   without nue?  Or, which packages do I need to build a gcc cross
>   compiler?

Yes.

Andreas Schwab mentioned --with-headers=.  There is also a --with-libs= option.
You need to set up IA-64 .../usr/include and .../use/lib trees on the x86
host, and use these configure options to point at the IA-64 headers and libs
respectively.

There is also the matter that gcc 3.0 out of the box does not support cross
compiling from a 32-bit host to a 64-bit target.  This was fixed for gcc 3.1,
but could not be fixed in gcc 3.0 because of latent problems with the powerpc
(rs6000) port.  I've already pointed at the recommended solution:
http://gcc.gnu.org/ml/gcc/2002-02/msg00643.html

With these two changes, it should work, however, because gcc is big and
complicated and there are lots of things that can go wrong in a build.  Cross
compilers are much harder to get right than native compilers.  Personally, I
stopped building cross compilers once the ia64-linux systems were stable enough
such that I never had to worry about my native builds failing.

>2) does an x86 hosted gcc 3.0 ia64 cross compiler generate different
>   code than a native ia64 compiler?  If so, how different is the
>   generated code?

If you use the solution suggested by Steve Christiansen, then your cross
compiled code will be very different, mainly bigger and slower.  If you
use the solution I suggested, the code should be the same in theory, but
I don't know of anyone who has tried to verify this.

Jim

