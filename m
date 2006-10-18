From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 18 Oct 2006 22:57:39 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061018225739.GF20590@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ,

On Wed, Oct 18, 2006 at 05:38:43PM -0500, Russ Anderson wrote:
> > With the existing perfmon v2.0, All the PMU description tables are compiled in.
> > 
> > I think what we could do is to detect we have a mixed (family) configuration
> > and drop to the generic (architected) PMU with only 4 counters and 2 events. That
> > is, I am afraid, the best we could do.
> 
> Tony's test kernel (plus Jack's patch and my patch) boots on a mixed Montecito
> and Madison system.  Perfmon runs, though I'm not sure what to look for
> to tell if it is not functioning properly.
> 
> 
Yes, it could work for very simple measurements. The CPU_CYCLES is a good example, though
the event on Montecito as a different name (by same encoding). But it gets more tricky as soon
as you try accessing PMU registers outside the range of architected registers, i.e., outside
PMC4-7/PMD4-7. There there are big differences. Montecito has 12 counters, Madison has 4.
All the extended features, such as opcode matching, range restrictions use differnet registers
between the 2 models.

Perfmon detects the cpu type using cpuid only once during initialization. So it depends
on which CPU executes the initialization. The only common set guaranteed to work the same
way is PMC4-7/PMD4-7 and events CPU_CYCLES and INSTRUCTION_RETIRED.

> ---------------------
> saturn2-7:~ # profile.pl --kernel-only -T 10
> profile.pl: found pfmon version 3.0.
> profile.pl: run profile for 10 seconds.
> profile.pl: no_dplace=1....c_opt=.
> profile.pl: Samples/tick defaults to: 13940008 for event CPU_CYCLES.
> profile.pl: pfmon command: /usr/bin/pfmon --system-wide --smpl-outfile=/tmp/sample.out.4022 --smpl-entries0000  -k --short-smpl-periods940008 --smpl-module=compact-ia64 --events=CPU_CYCLES --relative  -t 10
> profile.pl: Running a timed profile for 10 seconds:
> <session to end in 10 seconds>
> profile.pl: Profile complete.
> profile.pl: Checking the profile results.
> profile.pl: Merging sample files into a single file.
> profile.pl: my_partition_id=0 makemap_partition_id=0.
> profile.pl: Running the profile analyzer.
> profile.pl: analyze.pl kernel_only /tmp/sample.out.4022 profile.out  --system-map /proc/kallsyms
> analyze,pl: Using /proc/kallsyms as the kernel map file.
> analyze.pl: Read 13679 symbols from /proc/kallsyms.
> analyze.pl: total observations: 1017
> profile.pl: Profile results are in file: profile.out.
> profile.pl: Removing the sample files.
> profile.pl: Normal exit.
> saturn2-7:~ # cat profile.out
> user ticks:             0               0 %
> kernel ticks:           1017            100 %
> idle ticks:             1015            99.8 %
> 
> Using /proc/kallsyms as the kernel map file.
> ==================================
>                            Kernel
> 
>       Ticks     Percent  Cumulative   Routine
>                           Percent
> --------------------------------------------------------------------
>        1015       99.80    99.80      default_idle
>           1        0.10    99.90      get_page_from_freelist
>           1        0.10   100.00      hrtimer_run_queues
> ==================================
> 
> 
> 
> -- 
> Russ Anderson, OS RAS/Partitioning Project Lead  
> SGI - Silicon Graphics Inc          rja@sgi.com

-- 

-Stephane
