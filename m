From: Jun Nakajima <jun@sco.com>
Date: Thu, 19 Oct 2000 20:56:14 +0000
Subject: [Linux-ia64] HZ and PROC_CHANGE_PENALTY
Message-Id: <marc-linux-ia64-105590678205599@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think we have may CPU affinity issues. 

At this point we are using 
#define HZ 1024
#define PROC_CHANGE_PENALTY 20
IA-32 uses:
#define HZ 100
#define PROC_CHANGE_PENALTY 15

When a process is created, p->counter is set to 
#define DEF_COUNTER (10*HZ/100) /* 100 ms time slice */

And basically p->counter is decremented by update_process_times(), to
implement the time-sharing scheduling (i.e. SCHED_OTHER). Now schedule()
calls goodness() to compute goodness for every process on the runqueue,
to pick up a process with the max goodness.

The function goodness() computes goodness using p->counter (for
SCHED_OTHER):
    if (p->policy = SCHED_OTHER) {
        /*
         * Give the process a first-approximation goodness value
         * according to the number of clock-ticks it has left.
         *
         * Don't do any other calculations if the time slice is
         * over..
         */
        weight = p->counter;
        if (!weight)
            goto out;

#ifdef CONFIG_SMP
        /* Give a largish advantage to the same processor...   */
        /* (this is equivalent to penalizing other processors) */
        if (p->processor = this_cpu)
            weight += PROC_CHANGE_PENALTY;
#endif

        /* .. and a slight advantage to the current MM */
        if (p->mm = this_mm || !p->mm)
            weight += 1;
        weight += 20 - p->nice;
        goto out;
    }

The bottom line is that in general processes on IA-64 Linux would have
much larger p->counter (10 times larger, compared to IA-32 or other
architectures), PROC_CHANGE_PENALTY should be large enough to provide
that kind of soft CPU affinity (I'm not sure the difference '5' was
intended for that). In addition the contributions from other factors
(p->nice and p->mm) are much less effective at this point.
Am I missing something?

Thanks,
-- 
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ
Email: jun@sco.com, Phone: 908-790-2352 Fax: 908-790-2426

