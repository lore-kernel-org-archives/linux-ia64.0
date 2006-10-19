From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 19 Oct 2006 22:11:40 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061019221140.GF22389@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On Thu, Oct 19, 2006 at 02:22:41PM -0700, Luck, Tony wrote:
> > I don't think this is going to work for the simple reason that perfmon supports per-thread
> > monitoring. As a thread migrates from one CPU to another, its PMU state migrates with it.
> > So you cannot reload a full Montecito state onto a Madison PMU. You will not crash, because
> > write to unimplemented PMD are ignored but you will get false results. Even in system-wide
> > tools are not prepare to cope with mixed configurations.
> 
> Well you could do some ugly things forcing a sched_setaffinity-like call to prevent
> the task migrating to an incompatible cpu (but you'd also have to somehow make sure
> that the process didn't call sched_setaffinity() itself to undo this).
> 
Exactly. And that's a problem!

> System wide sounds like an even bigger problem.
> 
Well not quite. Keep in mind that perfmon does system-wide as a union of
CPU-wide sessions. You have to create a perfmon context on each CPUs you
want to monitor. That context does not migrate. The controlling  thread MUST
run on the CPU it monitors to gets access to the PMU state. So there I see less
problems at the kernel level. But the tools, such as pfmon or Caliper, would not
be ready to deal with this. Take pfmon, it uses cpuid once to determine the
PMU type. I am not sure for Caliper.

> Forcing perfmon into "generic" mode sounds like a saner option.
> 
Yes. But again, tools may have to change to forget about CPUID and use
the information returned by perfmon in /proc/perfmon (v2.0). Note
that this is not as bad as it seems. I said in generic (architected)
mode you only get 4 counters. But those counters are completely generic,
they can count any events. So they can count the architected events
(cpu_cycles, ia64_inst_retired), but they could also count Montecito specific
events. 

I think we could solve this by importing one of the features of perfmon v2.2
and by using pfmon-3.2.

In perfmon v2.2, there is a call you can make to return a bitmask of available PMC
registers. Typically available_pmcs = implemented_pmcs, but because the PMU resource
may be shared by multiple subsystems (e.g. on Opteron one counter may be used for
the NMI watchdog), we do export the list of available pmcs. Pfmon 3.2 queries the
list of available pmcs and passes the bitmask to libpfm which then tries to solve
the event -> pmc assignment problem using the available PMC resources.

Unfortunately, the existing v2.0 does not export this information. But we could hack
something in that would expose that in /proc. The key point is that we would want the
tools to think they are running on Montecito, so they can use more than 2 events, but
simply restrict them to using only the 4 architected counters.

-- 
-Stephane
