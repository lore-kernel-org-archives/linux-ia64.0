From: Roland McGrath <roland@redhat.com>
Date: Fri, 03 Aug 2007 13:08:20 +0000
Subject: Re: revising [patch] add arch_ptrace_stop() hook and use it on ia64
Message-Id: <20070803130820.648B04D04BC@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070720191246.GA19523@lst.de>
In-Reply-To: <20070720191246.GA19523@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> * Christoph Hellwig <hch@lst.de> [2007-07-20 21:12]:
> > Is anyone ia64-savy interested in revising the patch posted by David in
> > http://marc.info/?l=linux-kernel&m1575781225495&w=2 ?
> > 
> > This would allow for converting ia64 to the generic ptrace code,
> > something I would love to see.
> 
> Looking into the archive, there were some concerns about SIGKILL
> handling. See http://marc.info/?l=linux-ia64&m1577337511750&w=2.
> 
> Roland, did you look into that issue?

The issues with SIGKILL haven't changed, but I do understand them
better now, and they are not too hard to finesse.  However, more
fundamental, ia64-specific issues with the approach have come to
light, which now need to be resolved first.

I had this discussion with David in mind, and so the Intel folks
who worked on the ia64 port of utrace implemented this scheme
there.  The context where the code gets inserted is different, and
SIGKILL is not an issue for this code in that framework.  But the
plan is the same: a thread stopping with the expectation of being
examined flushes all its register data to the user memory backing
store addresses debuggers know about.

But, it became clear that we had only covered half the problem.
Calling ia64_sync_user_rbs copies register data to the user memory
so that a debugger can read it.  The debugger also expects to
change the user memory and have that affect registers seen both by
user mode, and by system call # and argument decoding when changed
at the syscall-entry tracing stop.  This requires either some
copying back the other way just before the thread resumes, or some
kind of rbs magic fiddling that forces it to fill its register
file from user memory when it resumes (including syscall entry).
That needs to be hashed out by experts on the ia64 rbs machinery
and its use in the kernel.

Bibo Mao has been working on this problem recently, and has a patch that
involves copying back from user rbs to kernel rbs after resuming from a
stop.  We discuss the utrace code on utrace-devel@redhat.com.  The ideal
solution, whatever it is, should fit in about the same with the vanilla
ptrace as with utrace.  Bibo's patch uses a TIF flag to mark that the
synchronization needs to be done on any return to user-mode (and the
restart of traced syscalls).  Something like that is the only way to go
for utrace.  Even in vanilla ptrace, it's necessary (rather than just
doing it directly after wakeup in ptrace_stop) because a thread can be
ptrace'd (and its user rbs poked) when it was originally in TASK_STOPPED,
and not in ptrace_stop at all.


Thanks,
Roland
