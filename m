From: Linus Torvalds <torvalds@osdl.org>
Date: Mon, 12 Sep 2005 03:37:07 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.58.0509112025410.3242@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sun, 11 Sep 2005, Linus Torvalds wrote:
> 
> Everything Keith says about MCA/INIT is true on x86 about NMI's. That has 
> nothing to do with "currently runnable process". And it sure as hell 
> doesn't mean that you'd _change_ the kernel notion of what the currently 
> runnable process is.

I don't think ia64 people realize how _wrong_ it is to just switch ->curr 
around. It doesn't matter if you "set it back" when the MCA ends: it may 
look atomic wrt _that_ CPU, but you're doing things that are fundamentally 
illegal. 

For example, if one CPU starts messing around with cpu_curr() on that CPU, 
another CPU may be doing "task_rq_lock()" on a task that is currently 
running on that CPU. 

THAT CPU MUST NOT CHANGE THE "current process" WITHOUT GETTING THE 
RUNQUEUE LOCK! Other CPU's are looking at it, and the scheduler uses 
rq->curr to decide whether to wake stuff up or not etc.

In other words, anybody who changes rq->curr without getting the lock IS 
BUGGY. 

And even if it wasn't horribly buggy, it's just conceptually really really 
wrong.

Unless somebody can convince me otherwise (and quite frankly, I doubt you
can) I'm going to remove at _least_ the function that writes ->curr
(set_curr_task()) tomorrow. 

I might leave the one that reads it, although quite frankly, I don't see
the point of that one either, but at least it's not totally broken in
theory (although reading the value without having locked the rq is
unreliable unless "cpu = currentcpu").

So you'd better re-architect that ia64 bug, or have a damn good reason for 
the crap code that convinces me that you're not just doing some seriously 
damaging drugs.

And yes, I'm upset, because quite frankly, I'd have expected people to 
have better taste. Trying to pass off something like this is just 
inexcusable.

		Linus
