From: Paul Jackson <pj@sgi.com>
Date: Thu, 22 Jul 2004 19:34:37 +0000
Subject: Re: [RFC] Patch for isolated scheduler domains
Message-Id: <20040722123437.1f0398db.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040722164126.GB13189@sgi.com>
In-Reply-To: <20040722164126.GB13189@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu

You should double check my logic, but I think a couple of the cpumask
calculations can be tightened up, as follows.

Dimitri Sivanich <sivanich@sgi.com> wrote:
> 
> +	cpumask_t cpu_nonisolated;
> +
> +	cpus_and(cpu_nonisolated, cpu_possible_map, isol_cpumask);
> +	cpus_complement(cpu_nonisolated, cpu_nonisolated);
> +	cpus_and(cpu_nonisolated, cpu_nonisolated, cpu_possible_map);

	cpumask_t cpu_nonisolated;
	cpus_andnot(cpu_nonisolated, cpu_possible_map, isol_cpumas);



> +		cpumask_t tmp = node_to_cpumask(i);
> +		cpumask_t nodemask;
> +		...
> +		cpus_and(nodemask, tmp, cpu_nonisolated);

		cpumask_t nodemask;
		...
		cpus_and(nodemask, node_to_cpumask(i), cpu_nonisolated);

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
