From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 21 Mar 2001 19:58:54 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005325@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Mar 2001 11:40:55 -0800, Jim Wilson <wilson@cygnus.com> said:

  Jim> Consider this case

  Jim>      mutex p6, p7
  Jim>   { .mib 
  Jim>      (p6) instruction that changes the unwind state
  Jim>      (p7) call that does not return
  Jim>   }
  Jim>      unwind directives to declare new unwind state

This wouldn't be correct: the unwind directives would have to go in
front of the instruction predicated by (p6).  Otherwise, you might get
interrupted (e.g., by a signal), after executing that instruction, and
then the unwind info would be wrong.

Now, to fix this, you'd have to use the general unwind directives and
that would imply that instead of p6/p7, you'd have to use a "preserved"
predicate.  Given those restrictions, I think you could just as easily
do:

	mutex p8, p9
{ .mib
	unwind directive describing effect of next insn
	(p8) instruction that changes the unwind state
	(p9) call that does not return
}
	(p9) break 0

This is slightly worse than the optimal code, but not by much.  The
biggest potential impact comes from the fact that now you need to
preserve the contents of "pr".

	--david

