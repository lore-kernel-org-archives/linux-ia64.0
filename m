From: Linus Torvalds <torvalds@osdl.org>
Date: Mon, 12 Sep 2005 04:05:27 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.58.0509112051530.3242@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sun, 11 Sep 2005, Linus Torvalds wrote:
>
> In other words, anybody who changes rq->curr without getting the lock IS 
> BUGGY. 

Just a few minutes of looking around in kernel/sched.c should have made 
this clear.

For example, look at 

	wait_task_inactive(task_t *p)

which is used by ptrace to make sure that the task we're going to ptrace 
is quiescent.

So walk through it. Let's say that CPU#0 is the ptracer, and is waiting 
for its child to become inactive on CPU#1. It gets the rq spinlock, and 
because your MCA "stole away" the thing momentarily and did its own magic 
task switch, we do _not_ see it as being "task_running()" on CPU#1 any 
more. So we go on and start doing ptrace operations.

But oops - it came back. It _was_ still running on CPU#1, and it hasn't 
actually had time to save all the register state away on the stack yet. So 
ptrace gets the wrong values altogether, because the rq->curr hacking made 
the value that we _depended_ on being stable not be stable at all.

Or, if that felt a bit too esoteric, I suspect that every _single_ use of 
"task_rq_lock()" is a potential for bugs. IOW, by doing a "task switch" 
the wrong way, you've basically invalidated pretty much all of the real 
scheduler.

		Linus
