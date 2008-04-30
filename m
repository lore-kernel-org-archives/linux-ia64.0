From: "stephane eranian" <eranian@googlemail.com>
Date: Wed, 30 Apr 2008 19:32:11 +0000
Subject: Re: ptrace problem with 2.6.25 on Itanium
Message-Id: <7c86c4470804301232u79550db8g1792544bd2812c38@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
In-Reply-To: <7c86c4470804240339p77639b4ejee73baec305d74c5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Roland,

On Mon, Apr 28, 2008 at 4:30 AM, Roland McGrath <roland@redhat.com> wrote:
> Sorry to complicate your life, but this one is officially Your Problem.
>  There is no kernel bug here.  The semantics have not changed, only the
>  timing.  (You are not the first to assume some ordering constraint was
>  provided in the ptrace interface that in fact has never been guaranteed
>  at all.)
>
I suspected you were going to say that. I have now fixed pfmon. I have
released the new version yesterday. The trick I use is that if I get SIGSTOP
notification first, I keep the child stopped until I get the FORK notification
from the parent. This way, the child cannot exit before pfmon gets the
FORK notification (I have seen this happen).

Thanks for checking on this.
So far, never seen the inversion on X86.



>  It's not surprising that the TIF_RESTORE_RSE/arch_ptrace_stop() changes
>  precipitated your first experience seeing this.  It may very well be that
>  this order of the reports never ever happened before even once in real
>  life.  But, it really truly has never been guaranteed (on any arch).
>  There is not going to be any new guarantee.  You'll just have to adapt to
>  what the actual rules have always been.  Sorry.
>
>  The new child is started running (so as to immediately deliver its
>  SIGSTOP) before the parent's ptrace_notify.  This has always been so.
>  It's probably true that for the child to get far enough to stop before
>  the parent did, in the past, could only have happened through an
>  extraordinary preemption situation.  Now that both parent and child do
>  the arch_ptrace_stop() logic before they complete their stops, there
>  are many more factors of nondeterminism involved in the common case.
>
>  On every arch, in every older kernel, if you have enough SMP, enough
>  preemption load (and preemption enabled), HZ high enough to drive up
>  frequency of preemption, relative to how long the particular CPU takes
>  to complete the ptrace_notify work, you will eventually manage to see
>  intermittent nondeterminism in the order of these two ptrace reports.
>  A robust userland application just has to cope with it.
>
>  This is not so hard to deal with.  If you get a report for a new pid you
>  have never heard of, then you know it must be a new child whose parent's
>  fork/clone event you have yet to see.  (Note it won't always be a SIGSTOP
>  that you see.  It could be a death by SIGKILL, or it could be a stop for
>  a different signal that was dequeued before SIGSTOP, having just been
>  posted in a quick race right after the birth of the child.)  In that
>  event, you can be sure that the parent will be very quickly reporting
>  too.  So you can do synchronous waits until you see the parent clone
>  report whose eventmsg matches the spontaneous child pid.  (Or you can
>  just keep track of the partial child in your data structures and go back
>  to your normal wait loop, which is probably a better way to write your
>  application.)
>
>
>  Thanks,
>  Roland
>
