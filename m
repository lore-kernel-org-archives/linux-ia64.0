From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 07 Feb 2005 02:00:08 +0000
Subject: Re: Default preempt_count setting
Message-Id: <20050207020008.GV20386@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050203151501.GC20386@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050203151501.GC20386@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 07, 2005 at 11:48:11AM +1100, Peter Chubb wrote:
> >>>>> "Matthew" = Matthew Wilcox <matthew@wil.cx> writes:
> Matthew> #define INIT_THREAD_INFO(tsk) \ [...]  .preempt_count = 1, \
> 
> It doesn't matter: new processes have preempt_count set to one in
> sched_fork() (they don't inherit the value) which then drops to zero
> when they're first run.   So init_task's preempt count will be set to one
> when the task is created.

But init_task isn't created by copy_process(), it's statically initialised
in arch/ia64/kernel/init_task.c.  Based on that, I'd say we do need it to
change ...

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
