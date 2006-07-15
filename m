From: Rob Browning <rlb@defaultvalue.org>
Date: Sat, 15 Jul 2006 22:24:31 +0000
Subject: Problem with Guile on ia64 (possibly "getcontext" related)
Message-Id: <87ac7ajylc.fsf@raven.defaultvalue.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Guile 1.6.8 is crashing on ia64 with an illegal instruction whenever
it tries to execute call-with-current-continuation.  For those who
don't know, call-with-current-continuation captures the current state
of the computation; it's a language feature somewhat similar to
setjmp.

The crash seems to be right around an asm "getcontext" call, and after
looking around, I found these two links:

  http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/144939
  http://lists.freebsd.org/pipermail/freebsd-sparc64/2006-January/003739.html

They appear claim that adding a dummy (non-executed) setjmp just after
the getcontext call will fix the problem because gcc recognizes
setjmp, but not getcontext, and makes appropriate arrangements.

So I tried adding a dummy setjmp just after the getcontext call, and
that does fix the problem.

However, even though this worked, I'd still prefer to have a better
idea that this is the right fix before adopting it.  Is that likely?

The relevant function is scm_make_continuation which you can find
here:

  http://cvs.savannah.gnu.org/viewcvs/guile/guile-core/libguile/continuations.c?rev=1.38.2.7&root=guile&only_with_tag=branch_release-1-6&view=markup

Versions:

  Debian libc6.1 2.3.6-15
  Debian gcc (GCC) 4.1.2 20060708 (prerelease) (Debian 4.1.1-8)

Thanks

-- 
Rob Browning
rlb @defaultvalue.org and @debian.org; previously @cs.utexas.edu
GPG starting 2002-11-03 = 14DD 432F AE39 534D B592  F9A0 25C8 D377 8C7E 73A4
