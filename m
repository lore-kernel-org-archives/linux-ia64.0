From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 20 Dec 2003 10:50:31 +0000
Subject: Re: [RFC][PATCH] 2.6.0-test11 sched_clock() broken for "drifty ITC"
Message-Id: <marc-linux-ia64-107191774714628@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107178053026093@msgid-missing>
In-Reply-To: <marc-linux-ia64-107178053026093@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* John Hawkes <hawkes@babylon.engr.sgi.com> wrote:

> Some amount of code would need to be added to sched.c to deal with
> unsynchronized values: scheduler_tick() remembers a local jiffies-
> granularity sched_clock() in the runqueue struct, and load_balance's
> can_migrate_task() uses that saved timestamp to compare against the
> tested task->timestamp to determine cache-hot-or-not, rather than
> using the local CPU's sched_clock() value.  Also, task->timestamp
> needs to be readjusted when the task migrates:

this is a tough problem that wont go away.

Even platforms where the per-CPU clock is supposed to be synchronized,
sometimes it isnt. (this is a recurring problem on x86 SMP - so x86 will
benefit from it too.)

the relaxation means the effective granularity reduction of the
migration decisions - but this is not a problem, migration latencies are
always a high multiple of the timer irq frequency. The cycle accuracy of
sched_clock() is otherwise very important for correct interactivity
decisions - but this is only used locally and is thus preserved by the
patch. The only area where this change can reduce the quality of
interactivity estimatio is when a task oscillates very quickly between
multiple CPUs and is also somehow relevant to interactivity.

So i believe the generic relaxing of sched_clock() synchronization is
the right thing to do. I like your patch. It adds minimal overhead and
solves a hard problem - nice work! Andrew, please apply it.

	Ingo
