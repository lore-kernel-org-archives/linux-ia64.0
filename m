From: Roland McGrath <roland@redhat.com>
Date: Tue, 13 Nov 2007 00:30:38 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <20071113003038.66BF14D04C9@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> the trouble is I used the current ia64 patch and even inserted an
> msleep(10) into ptrace_stop() to make sure it does sleep but I don't see
> any problems. I added the following code between arch_ptrace_stop(1) and
> set_current_state(TASK_TRACED):
> 
> 	msleep(10);
> 	if (unlikely(sigismember(&current->pending.signal, SIGKILL)))
> 		printk(KERN_INFO "%d (%s): Got SIGKILL in ptrace_stop\n",
> 			current->pid, current->comm);
> 
> I ran strace on a simple program (calling gettimeofday() in an endless
> loop) and killed it with SIGKILL. The program exited correctly and I got
> the message in syslog. I'm puzzled. :/  Is this not the correct place
> where the race condition should happen?

I'm not entirely clear on what code you are using.  

If you are using my patch, then the sigkill_pending check fixes this.  

If you are using code that does not drop the siglock before calling the
arch_ptrace_stop code, then you won't see the SIGKILL race either.  In that
case, you are just breaking rules for how long to hold locks and what you
can hold while you block and so forth.  This will have other bad effects
and would never be allowed to go into the kernel, but I don't have a
straightforward test case for such problems.

What I suggested testing was my code without the sigkill_pending check,
i.e. dropping the siglock around arch_ptrace_stop but no other fix-up.
If that is what you are trying and it does not produce a problem, then
I am surprised.

> Ah, Roland, you're right, strace ends with:
> 
> +++ killed by SIGKILL +++
> Process 2946 detached
> 
> I've just realized that it's exactly what SHOULDN'T happen. Sorry for
> the fuss.

No, this is correct behavior.  The bug symptom would be that noone
ever saw the SIGKILL because the traced process didn't wake up and
remains in TASK_TRACED with SIGKILL pending.

The test scenario I gave using strace is the wrong one.  In that case,
strace is always about to continue the process anyway, so you wouldn't
notice the problem even if it happened.  The problem case is when the
tracer doesn't do a PTRACE_CONT soon, so there is nothing other than
SIGKILL that would wake it up right away.  The race is between the
traced process going into ptrace_stop and the SIGKILL being sent.  It
probably does happen in this test, but once it does, strace sees the
process stop and immediately resumes it after printing its syscall
details.  

If you do the artificial test using a long sleep in arch_ptrace_stop,
then you can probably produce this by hand with gdb.  Have the process
doing raise(SIGCHLD) or some other harmless signal.  The traced
process will stop to report the signal to gdb, and then gdb will sit
at the prompt before resuming it (given "handle SIGFOO stop" if not default).  
If your sleep is long enough, it won't be hard to get your SIGKILL in there.
Then when gdb is sitting, the traced process may still be sitting too.
But it should have gone away instantly from SIGKILL.


Thanks,
Roland
