From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 22 Oct 2004 09:27:30 +0000
Subject: Re: [patch 2.6.9] Avoid a rare deadlock during unwind
Message-Id: <16760.53890.446557.79770@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9718.1098174005@kao2.melbourne.sgi.com>
In-Reply-To: <9718.1098174005@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Oct 2004 00:44:35 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Emprically it works.  The patched code has been hammered
  Keith> several million times, using modifying oprofile code that
  Keith> generates gprof backtraces whenever the profile interrupt
  Keith> pops.  That was the code that found the original deadlock in
  Keith> unwind.

Yes, that's certainly a good way to test.

  Keith> o if both the unw.lock spinlock and a script's read-write lock must be
  Keith> acquired using a method that might sleep, then the read-write lock
  Keith> must be acquired first.

  Keith> adding "using a method that might sleep".  The only read-write lock
  Keith> code under spinlock(unw.lock) is write_trylock(), which never sleeps.
  Keith> If you agree with this analysis, then I am happy to update the comment.

No, the comment was intending to establish the lock hierarchy.  If there
are no other paths where the locks are acquire in the other order, then
it's OK.  I'd just reverse the comment to match the (new) reality.

	--david
