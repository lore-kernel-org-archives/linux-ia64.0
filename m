From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 23 Aug 2005 08:10:35 +0000
Subject: Re: [PATCH 2.6.13-rc6] cpu_exclusive sched domains on partial nodes temp fix
Message-Id: <20050823081035.GA1346@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050823080427.14740.20177.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20050823080427.14740.20177.sendpatchset@jackhammer.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Jackson <pj@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, hawkes@sgi.com, dino@in.ibm.com


* Paul Jackson <pj@sgi.com> wrote:

>  	/*
> +	 * Hack to avoid 2.6.13 partial node dynamic sched domain bug.
> +	 * Require the 'cpu_exclusive' cpuset to include all (or none)
> +	 * of the CPUs on each node, or return w/o changing sched domains.
> +	 * Remove this hack when dynamic sched domains fixed.
> +	 */
> +	{
> +		int i, j;
> +
> +		for_each_cpu_mask(i, cur->cpus_allowed) {
> +			for_each_cpu_mask(j, node_to_cpumask(cpu_to_node(i))) {
> +				if (!cpu_isset(j, cur->cpus_allowed))
> +					return;
> +			}
> +		}
> +	}
> +

certainly looks acceptable from a scheduler POV.

Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
