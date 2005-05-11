From: Roland McGrath <roland@redhat.com>
Date: Wed, 11 May 2005 00:59:46 +0000
Subject: Re: [patch] add arch_ptrace_stop() hook and use it on ia64
Message-Id: <200505110059.j4B0xkkM003452@magilla.sf.frob.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: David Mosberger's message of  Tuesday, 10 May 2005 13:31:59 -0700 <17025.6719.837031.411067@napali.hpl.hp.com>
References: <17025.6719.837031.411067@napali.hpl.hp.com>
In-Reply-To: <17025.6719.837031.411067@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: akpm@osdl.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi David.  Sorry I wasn't able to reply to your earlier questions about
this before now.  I knew the question needed some thought and I was too
busy to consider it in detail, so it fell by the wayside.  Today I've spent
a little time thinking about it, though still not explored the subject
completely.  It definitely will not fly to change ptrace_stop in that way.
That opens up some race holes that the whole revamp that added the
ptrace_stop function was intended to close.  The scenario I can think of
off hand is a race with a SIGKILL that must resume the thread from any
tracing stop, or prevent it from entering the tracing stop, and then will
not.  (This leads to threads in TASK_TRACED with a pending SIGKILL, that
cannot be killed with repeated kill -9s, and live until the tracer uses
PTRACE_CONT, detaches, or dies.)

When I suggested this change for ia64 originally, I overlooked the need to
handle blocking in writing to user memory.  I'd like to give a little more
thought to the general case.  As long as only uninterruptible waits are
provoked by an arch hook, then I think it is reasonably solvable.  I think
that SIGKILL races are the only ones that can arise, and those can be
addressed with some signal bookkeeping changes.  I'd like to give it a
little more thought.  I expect it will wind up being some core changes that
make it safe for an arch hook to drop and reacquire the siglock if it's
doing something that won't always complete quickly, and then this will all
happen before changing state, unlocking, and deciding to block (which won't
be done if there was an intervening SIGKILL).


Thanks,
Roland

