From: Jun Nakajima <jun@sco.com>
Date: Thu, 19 Oct 2000 23:00:12 +0000
Subject: Re: [Linux-ia64] HZ and PROC_CHANGE_PENALTY
Message-Id: <marc-linux-ia64-105590678205601@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205599@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205599@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think I may have oversimplied the explanation, but p->counter is set
and updated on several occasions. For example, a child inherites
p->counter from the parent, in do_fork():
    p->counter = (current->counter + 1) >> 1;
    current->counter >>= 1;

Or in schedule():
...
recalculate:
    {
        struct task_struct *p;
        spin_unlock_irq(&runqueue_lock);
        read_lock(&tasklist_lock);
        for_each_task(p)
            p->counter = (p->counter >> 1) + NICE_TO_TICKS(p->nice);
        read_unlock(&tasklist_lock);
        spin_lock_irq(&runqueue_lock);
    }

Here NICE_TO_TICKS is
#if HZ < 200
#define TICK_SCALE(x)   ((x) >> 2)
#elif HZ < 400
#define TICK_SCALE(x)   ((x) >> 1)
#elif HZ < 800
#define TICK_SCALE(x)   (x)
#elif HZ < 1600
#define TICK_SCALE(x)   ((x) << 1)
#else
#define TICK_SCALE(x)   ((x) << 2)
#endif

#define NICE_TO_TICKS(nice) (TICK_SCALE(20-(nice))+1)

So when all of the counters expire and recaluculation is required for
them, the quantum/counter for IA-64 processes is about 8 times larger,
compared to the one for IA-32, regardless of p->nice.



Stephan.Zeisset@intel.com wrote:
> 
> Interesting observation.
> 
> I have seen threads jumping cpus without need on a 2.4.0-test8 kernel and this might explain.
> 
> Stephan.
> 
> -----Original Message-----
> From: Jun Nakajima [mailto:jun@sco.com]
> Sent: Thursday, October 19, 2000 1:56 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] HZ and PROC_CHANGE_PENALTY
> 
> I think we have may CPU affinity issues.
> 
> At this point we are using
> #define HZ 1024
> #define PROC_CHANGE_PENALTY 20
> IA-32 uses:
> #define HZ 100
> #define PROC_CHANGE_PENALTY 15
> 
> When a process is created, p->counter is set to
> #define DEF_COUNTER (10*HZ/100) /* 100 ms time slice */
> 
> And basically p->counter is decremented by update_process_times(), to
> implement the time-sharing scheduling (i.e. SCHED_OTHER). Now schedule()
> calls goodness() to compute goodness for every process on the runqueue,
> to pick up a process with the max goodness.
> 
> The function goodness() computes goodness using p->counter (for
> SCHED_OTHER):
>     if (p->policy = SCHED_OTHER) {
>         /*
>          * Give the process a first-approximation goodness value
>          * according to the number of clock-ticks it has left.
>          *
>          * Don't do any other calculations if the time slice is
>          * over..
>          */
>         weight = p->counter;
>         if (!weight)
>             goto out;
> 
> #ifdef CONFIG_SMP
>         /* Give a largish advantage to the same processor...   */
>         /* (this is equivalent to penalizing other processors) */
>         if (p->processor = this_cpu)
>             weight += PROC_CHANGE_PENALTY;
> #endif
> 
>         /* .. and a slight advantage to the current MM */
>         if (p->mm = this_mm || !p->mm)
>             weight += 1;
>         weight += 20 - p->nice;
>         goto out;
>     }
> 
> The bottom line is that in general processes on IA-64 Linux would have
> much larger p->counter (10 times larger, compared to IA-32 or other
> architectures), PROC_CHANGE_PENALTY should be large enough to provide
> that kind of soft CPU affinity (I'm not sure the difference '5' was
> intended for that). In addition the contributions from other factors
> (p->nice and p->mm) are much less effective at this point.
> Am I missing something?
> 
> Thanks,
> --
> Jun U Nakajima
> Core OS Development
> SCO/Murray Hill, NJ
> Email: jun@sco.com, Phone: 908-790-2352 Fax: 908-790-2426
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

-- 
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ
Email: jun@sco.com, Phone: 908-790-2352 Fax: 908-790-2426

