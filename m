From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 23:58:45 +0000
Subject: important fsyscall bug fix (affects McKinley only)
Message-Id: <marc-linux-ia64-106626252723372@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While working on a lightweight version of sigprocmask(), I discovered
that the McKinley E9 workaround had exactly the opposite effect from
what was intended: it was supposed to ensure that we always return at
priv level 3, and instead it caused us to always return at priv level
0!  Fortunately, the fix is pretty simple and the whole patch can be
found here:

  http://lia64.bkbits.net:8080/linux-ia64-2.5/cset@1.1512.1.22

Since the fsyscall stubs aren't in wide-spread use yet, I doubt this
bug will affect many people, but clearly it would have been a problem
going forward.  Also, remember that the workaround is needed only for
McKinley.  Merced and Madison are both OK in this regard.

The above patch also includes the sigprocmask() light-weight handler
because it's easiest to observe the bug with this handler (since it's
invoked via an inlined syscall; non-inlined syscalls mask the problem,
because they'll return immediately with br.ret again, which drops the
privilege level back to 3).

	--david
