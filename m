From: "John Hawkes" <hawkes@sgi.com>
Date: Fri, 06 Jan 2006 17:06:18 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <000701c612e3$8324eff0$6f00a8c0@comcast.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601052233.k05MX4g15045@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
> What type of heavy workloads have you measured? Including db transaction
> processing and decision making workloads?

I haven't used a db transaction processing benchmark, but I have used other
workloads with large process counts and high context-switch rates.

> > The potential
> > extra cachemiss seems to be lost in the noise.  The for_each_*cpu()
> > macros are relatively efficient in skipping past zeroed cpumask bits.
> > Workloads that impose higher loads on the CPU Scheduler tend to
> > bottleneck on non-Scheduler parts of the kernel, and it's the Scheduler
> > which makes the principal use of the cpumask_t, so these extra
> > cachemiss inefficiencies and extra CPU cycles to scan zero mask words
> > just get lost in the general system overhead.
>
> I found above claims are generally false for workload that puts tons
> of pressure on CPU cache, especially with db workload.  Typically
> for db workload, the working set in user space is so large that making
> a trip into the kernel has far large secondary effect then the primary
> cache miss occurred in the kernel.  In other word, cache lines evicted
> by the kernel code have far larger impact to the overall application
> performance and leads to lower overall lower system performance.  So
> when you say "get lost in the general system overhead", did you consider
> the secondary effect it does to the application performance?

The current default is 512p, which is 8 words -- a cacheline.  Increasing to
1024p adds an additional 8 words -- one cacheline -- to the cpumask_t.  I
doubt you're going to see a performance regression on your db transaction
processing benchmark because of an additional cachemiss during active or
passive load-balancing.

I agree that throughout the kernel we ought to be aware of increasing
cachemisses and the lengthening code paths, but I don't believe this
particular one is some evil that needs to be suppressed.  We have far more
micro-performance-impacting algorithms and data structures in the kernel right
now that we ought to consider -- e.g., cache coloring conflicts with the
struct runqueue -- as well as the obvious algorithm tweaks that greatly affect
processor assignments -- e.g., whether or not to call wake_idle().

> What we found is going from NR_CPU = 64 to 128, it has small performance
> impact to db transaction processing workload.  Though I have not measured
> difference between 128 to 1024.

Going from 64 (one word) to >64 (an array of words) produces a qualitative
change to the emitted code in how the cpumask_t is passed in calling sequences
and how it is manipulated.  I completely understand that you can detect a
small performance regression between 64 and 128.  I just don't believe you can
conclude that going from 512 to 1024 will exhibit a similar measurable
regression.

John Hawkes

