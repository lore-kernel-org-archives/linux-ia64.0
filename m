From: "John Hawkes" <hawkes@sgi.com>
Date: Thu, 20 Nov 2003 20:58:20 +0000
Subject: Re: [PATCH] - sched_clock() broken for ia64 SN platform
Message-Id: <marc-linux-ia64-106936209405237@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106928980122896@msgid-missing>
In-Reply-To: <marc-linux-ia64-106928980122896@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "David Mosberger" <davidm@napali.hpl.hp.com>
>   Jack Steiner> However, reading the ITC is faster & preferred if intercpu
>   Jack Steiner> drift is not an issue.
>
> Yes.  Plus we could solve the problem once and for all, not once for
> each drifty platform.
>
> As I remember it, sched_clock() was originally invented to measure
> fine-grained "how long have I run" times.  This can be done with ITC
> without synchronization, since the start and stop "times" will be
> measured on the same CPU.  Howver, as John points out, at the moment
> sched_clock() is also used for migration-decisions.  My guess is that
> this part is just due to someone trying to be overly clever.  At least
> on drifty platforms, you can just as easily make this decision based
> on jiffies.  All it would do is add one word to the task_struct and
> reading both sched_clock() and jiffies when updating the timestamp(s).

I doubt this double-count would ever be accepted by the wider Linux Community,
as it bloats mainline arch-independent code, just to fix a problem with a
handful of drifty platforms.

The i386 code is uglier than my patch, as it makes NUMA platforms use the
gross-granularity "jiffies" as the time base.  So much for any of the benefits
in the scheduler to a high-precision task->timestamp.  At least with my ia64
patch, it allows for a platform-specific sched_clock() that returns a
high-precision value and doesn't appreciably add bloat.

John Hawkes


