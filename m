From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 22 Jul 2004 17:54:59 +0000
Subject: Re: [RFC] Patch for isolated scheduler domains
Message-Id: <20040722175459.GA30059@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040722164126.GB13189@sgi.com>
In-Reply-To: <20040722164126.GB13189@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


* Dimitri Sivanich <sivanich@sgi.com> wrote:

> I'm interested in implementing something I'll call isolated sched
> domains for single cpus (to minimize the latencies involved when doing
> things like load balancing on certain select cpus) on IA64.
> 
> Below I've included an initial patch to illustrate what I'd like to
> do.  I know there's been mention of 'platform specific work' in the
> area of sched domains. This patch only addresses IA64, but could be
> made generic as well.  The code is derived directly from the current
> default arch_init_sched_domains code.

it looks good to me - and i'd suggest to put it into sched.c. Every
architecture benefits from the ability to define isolated CPUs.

One minor nit wrt. this line:

+               cpu_sd->flags &= ~(SD_BALANCE_NEWIDLE | SD_BALANCE_EXEC |
+ SD_BALANCE_CLONE);  /* Probably redundant */

i'd suggest to set it to 0. You dont want WAKE_AFFINE nor WAKE_BALANCE
to move your tasks out of the isolated domain.

> - Assuming boot time configuration is appropriate ('isolcpus=' in my example),
>   is allowing boot time configuration of only completely isolated cpus
>   focusing too narrowly on this one concept, or should a boot time
>   configuration allow for a broader array of configurations, or would other
>   types of sched domain configurations be addressed separately?

i'd prefer to go with this simple solution and wait for actual usage
patterns to materialize. If it becomes popular we can define a syscall
to configure the domain hierarchy (maybe even the parameters) runtime.

	Ingo
