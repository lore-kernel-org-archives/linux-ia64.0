From: Roland McGrath <roland@redhat.com>
Date: Mon, 28 Apr 2008 02:30:19 +0000
Subject: Re: ptrace problem with 2.6.25 on Itanium
Message-Id: <20080428023019.7BD7726F8F0@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
In-Reply-To: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry to complicate your life, but this one is officially Your Problem.
There is no kernel bug here.  The semantics have not changed, only the
timing.  (You are not the first to assume some ordering constraint was
provided in the ptrace interface that in fact has never been guaranteed
at all.)

It's not surprising that the TIF_RESTORE_RSE/arch_ptrace_stop() changes
precipitated your first experience seeing this.  It may very well be that
this order of the reports never ever happened before even once in real
life.  But, it really truly has never been guaranteed (on any arch).
There is not going to be any new guarantee.  You'll just have to adapt to
what the actual rules have always been.  Sorry.

The new child is started running (so as to immediately deliver its
SIGSTOP) before the parent's ptrace_notify.  This has always been so.
It's probably true that for the child to get far enough to stop before
the parent did, in the past, could only have happened through an
extraordinary preemption situation.  Now that both parent and child do
the arch_ptrace_stop() logic before they complete their stops, there
are many more factors of nondeterminism involved in the common case.

On every arch, in every older kernel, if you have enough SMP, enough
preemption load (and preemption enabled), HZ high enough to drive up
frequency of preemption, relative to how long the particular CPU takes
to complete the ptrace_notify work, you will eventually manage to see
intermittent nondeterminism in the order of these two ptrace reports.
A robust userland application just has to cope with it.

This is not so hard to deal with.  If you get a report for a new pid you
have never heard of, then you know it must be a new child whose parent's
fork/clone event you have yet to see.  (Note it won't always be a SIGSTOP
that you see.  It could be a death by SIGKILL, or it could be a stop for
a different signal that was dequeued before SIGSTOP, having just been
posted in a quick race right after the birth of the child.)  In that
event, you can be sure that the parent will be very quickly reporting
too.  So you can do synchronous waits until you see the parent clone
report whose eventmsg matches the spontaneous child pid.  (Or you can
just keep track of the partial child in your data structures and go back
to your normal wait loop, which is probably a better way to write your
application.)


Thanks,
Roland
