From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 14 Jun 2001 06:22:25 +0000
Subject: Re: [Linux-ia64] Stack unwind functions
Message-Id: <marc-linux-ia64-105590693005731@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005729@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005729@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stack unwinding is supported for C++ exception handling.

If you are asking about user level routines, then it varies, depending on
which version of gcc you have, but there is nothing really convenient as yet.

The "Nov snapshot" doesn't provide any user level API for unwinding.  However,
the java runtime wanted a function that worked like the Glibc backtrace
function, so they added a function to libgcc.c called __ia64_backtrace.

The gcc-3 prerelease provides the Unwind API documented in the IA-64 ABI.
However, this alone probably doesn't give you what you want.  Plus, you
may not be able to use this compiler until there is an OS distribution built
from it.  And unfortunately the __ia64_backtrace function had to go away,
since it didn't fit into the new EH implementation that uses the Unwind API.

Jim

