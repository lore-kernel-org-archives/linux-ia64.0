From: Roland McGrath <roland@redhat.com>
Date: Wed, 14 Nov 2007 11:09:14 +0000
Subject: Re: [PATCH] ptrace RSE bug
Message-Id: <20071114110914.446A126F8B6@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Roland McGrath wrote:
> > What's arch_ptrace_resume about?  
> > I thought we were agreed on the plan using TIF_RESTORE_RSE.
> 
> No, after further discussion we came to the conclusion that introducing
> the bit actually saves us only a couple of user-to-kernel/kernel-to-user
> copies in do_exit(), but it complicates the kernel exit path, so it's
> not really worth it. Shaohua didn't call it arch_ptrace_resume(), but he
> added an argument to arch_ptrace_stop(). I was already testing a
> different variant of that patch and I'm sorry if it caused confusion. :(

I think I missed that part of the discussion, but I may have overlooked it.
I'd thought Shaohua (or his predecessors) were already clear from my end on
why to argue for TIF_RESTORE_RSE.  Not being an actual ia64 user myself,
the plan was to outsource the arguing with ia64 people to the Intel folks.
So much for that.

It's not just do_exit, where I presume you mean for the ptrace EXIT stop,
after which user mode will never run again.  It's also any time ptrace_stop
runs more than once before going back to user mode.  This includes a signal
stop that is followed by more signal stops, a syscall-exit stop followed by
signal stops, a ptrace_notify (clone et al) followed by another (vfork-done
follows clone) or by signal or syscall-exit stops, etc.

But optimizing those cases is not really what motivates me.  What you've
implemented is pretty much exactly what David and I settled on when we
first discussed this a few years ago.  The recent action on the subject
was spurred by a slightly more recent set of interests on my part.

> Is there any other advantage in introducing TIF_RESTORE_RSE than saving
> some unneeded data copying?

No, unless "other" includes "saving a lot of very unneeded data copying".
Given ptrace, I can see the argument for simplicity over optimization.
The TIF_RESTORE_RSE plan looks forward to future debugging facilities,
where this issue could be a large performance impediment that other
machines won't have.

I became aware of this issue a long time ago because of gdb's inability
to use /proc/pid/mem reliably as it can do on all other machines.  But
when I started pressing to resolve it was while working on utrace.
Regardless of the fate of utrace per se, I think something will arise
that has the same requirements on arch code that I've set down and that
motivated the TIF_RESTORE_RSE approach to ia64's register backing store.

Consider a flexible facility for tracing actions at the kinds of event
points that ptrace monitors today.  Where now ptrace_notify or
ptrace_stop is called, a hook into some moderate intelligence can run to
decide whether to stop and what to communicate to the debugger and so forth.

It might monitor all syscalls and usually decide to do nothing at all,
or send a very cheap asynchronous notification somewhere.  The hoped-for
promise of fancy new facilities is that they can do this unobtrusively
across many, many threads in the system.  So in this case, it should be
no more expensive than TIF_SYSCALL_AUDIT.

It might stop and wait with a clunky amount of overhead like ptrace.
In this case, the additional overhead of extra copies probably doesn't rate.

It might not stop at all, but instead do some self-examination before
going on.  This might include reading (or writing) memory via
access_process_vm or get_user, including accessing register values in
the register backing store memory.  In this case, correctness demands
that the writeback to user memory be done before that memory is
examined, and that changed user memory will be reloaded into the RSE
before the user registers are used next (in user mode or at syscall entry).

But it's a flexible facility.  So it's not easy to know ahead of time
which of these scenarios it will be.  (In utrace, there's a function
pointer provided by some kernel module that can do what it likes.)
For the filtered event case (first of the three), you want to skip the
whole overhead.  For the ptrace-like case (second), you want to flush
before you stop and reload afterward.  For the non-stop introspection
case (third), you need flush and reload but here won't be any stop.

So the natural interface for these to all fall out optimal is that there
is no automagic copying at the low level, but an explicit arch
"writeback" function to call.  This gets called before something reads
user memory and expects it to be harmonized with the thread's state.  It
should be cheap to call when it's already been done, so multiple
uncoordinated things can request it when they need to ensure it, but
don't pay lots of extra overhead when several of those come before
actually going to user mode (or syscall entry).  To keep the bookkeeping
and interactions simple even among multiple uncoordinated things, that
one call should make it so that reloading from user memory is automatic
on the next return to user mode (or syscall entry).  ptrace calls this
at every stop (and attach, cf my earlier mail).  Other future facilities
would call it only selectively when they've decided they need register
values from memory at this particular stop.

The bookkeeping to prevent repeated flushes and to ensure reloads before
resuming could be done by higher layers that call ia64_ptrace_stop and
ia64_ptrace_resume.  But, this whole issue really only exists on ia64.
So it makes sense to keep the generic interface semantics that has to
consider it as simple as possible and push this work into the ia64 code,
and TIF_* is a perfect fit for this.  The main "complexity" introduced
is the overloading of TIF_NOTIFY_RESUME because there isn't another free
bit in TIF_ALLWORK_MASK.  The need to reload from memory after
syscall_trace_enter and before using the register values as syscall args
is subtle, too.  But still, it's not so much.  And frankly, ia64
deserves it for deciding to have the godforsaken RSE semantics.


Thanks,
Roland

