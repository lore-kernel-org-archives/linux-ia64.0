From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Aug 2004 17:31:56 +0000
Subject: sigaltstack() + siglongjmp() breakage
Message-Id: <16682.10764.487722.503967@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Back in Feb 2002, we changed the kernel to spill the dirty partition
of the register stack onto the alternate signal stack rather than
spilling it onto the old stack.  This inadvertently broke
siglongjmp().  As a result, if you do a siglongjmp() out of a signal
handler which uses the alternate signal stack, it's possible (and
often likely) that the contents of register-backing store will be
trashed.

Apparently, this isn't something that tons of programs do as nobody
seems to have complained so far.  I only discovered it when tracking
down a test-case failure in libc which only showed with libunwind;
GCC's built-in unwinder masks the bug for unrelated reasons.

Fixing this problem is of course very important but since it's rather
fundamental stuff, I'll need to test it carefully before posting a
patch.  For now, I just wanted to give a heads up in case somebody is
seeing failures in programs that use alternate signal stacks and
siglongjmp().

If you need a quick workaround, you could consider using the
setjmp/longjmp implementation that comes with libunwind [1] (it's in
library libunwind-setjmp).  This implementation doesn't suffer from
the problem described above, but, on the flip-side, you need fairly
current libraries and compilers to be sure that the unwind-info is
correct.  Without correct unwind-info, the libunwind implementation of
setjmp/longjmp would fail, of course.  Also, another thing to consider
is that with the libunwind-based implementation, setjmp() will be
extremely fast (just needs to store 3 words), but longjmp() will be
much slower (since the stack needs to be unwound).

	--david

[1] http://www.hpl.hp.com/research/linux/
