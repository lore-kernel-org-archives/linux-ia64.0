From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sun, 09 Feb 2003 05:19:20 +0000
Subject: [Linux-ia64] sigaltstack and RBS
Message-Id: <marc-linux-ia64-105590709805824@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm having some difficulty "demand paging" register backing store from
userspace (i.e. using SIGSEGV to map pages in on demand).

The problem is that even when using sigaltstack, the original backing
store (which caused the fault) is still touched when returning to the
signal trampoline, before it switches to the alternate RBS.  Thus I
get recursive faulting before it gets to the signal handler.

Ideally, signal handling on an alternate RBS/stack wouldn't touch the
original RBS/stack at all.

Any suggestions how to deal with this?

Matt


