From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 19 Feb 2003 18:44:59 +0000
Subject: [Linux-ia64] problem with ia64_fetch_and_add
Message-Id: <marc-linux-ia64-105590709805876@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm having problem compiling code with macro function ia64_fetch_and_add.

What happens is if I use atomic_add_return() in one of the inline function, I'm getting unresolved symbol error at link time for __bad_increment_for_ia64_fetch_and_add().  But the input argument to ia64_fetch_and_add() is of constant 1 or -1.  I'm using gcc-3.2.2.

Is this a toolchain problem?  Just for the sake of compile, the same code compiled without error with gcc-2.96, which kind of give me a fuzzy feeling that gcc-3.2 is not working for this case.  Has anyone seen this before?

- Ken


