From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 19 Oct 2006 21:05:19 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061019210519.GC22389@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Russ,

On Thu, Oct 19, 2006 at 03:57:20PM -0500, Russ Anderson wrote:
> Stephane Eranian wrote:
> > 
> > Yes, it could work for very simple measurements. The CPU_CYCLES is a good example, though
> > the event on Montecito as a different name (by same encoding). But it gets more tricky as soon
> > as you try accessing PMU registers outside the range of architected registers, i.e., outside
> > PMC4-7/PMD4-7. There there are big differences. Montecito has 12 counters, Madison has 4.
> > All the extended features, such as opcode matching, range restrictions use differnet registers
> > between the 2 models.
> > 
> > Perfmon detects the cpu type using cpuid only once during initialization. So it depends
> > on which CPU executes the initialization. The only common set guaranteed to work the same
> > way is PMC4-7/PMD4-7 and events CPU_CYCLES and INSTRUCTION_RETIRED.
> 
> Stephane,
> 
> Attached is a test patch for supporting mixed CPUs.  It changes pmu_conf to
> an array, to keep track of the different CPU characteristics.  At initialization
> information is saved for each of the CPUs.
> 

I don't think this is going to work for the simple reason that perfmon supports per-thread
monitoring. As a thread migrates from one CPU to another, its PMU state migrates with it.
So you cannot reload a full Montecito state onto a Madison PMU. You will not crash, because
write to unimplemented PMD are ignored but you will get false results. Even in system-wide
tools are not prepare to cope with mixed configurations.

As I said earlier, in the initialization, you need to detect mixed configuration and if so
use the generic IA-64 PMU description on ALL CPUs. This is the one implemented by pmu_conf_gen
coming from perfmon_generic.h.

--
-Stephane
