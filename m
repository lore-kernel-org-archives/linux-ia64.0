From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 12 May 2000 02:50:58 +0000
Subject: Re: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205082@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I wrote a simple program that generates a very large program with out of range
calls, compiled it with -Wl,-relax, and looked at the code.  It looks fine.
The out-of-range call gets redirected to a stub at the end of the function
that does a brl with absolute address to the target function.  I don't see
how this can corrupt the gp.

Maybe it is a kernel problem with the emulation?  Have you tried debugging the
code to see where the gp gets corrupted?  Try stepping over the brl instruction
to see if the kernel is clobbering gp.  I don't have a kernel with brl
emulation support yet, so I can not try this myself.

Alternatively, there could be something different about your testcase that
causes the linker relaxation to fail.  I might be obvious if you look at the
code you are getting.

Jim


