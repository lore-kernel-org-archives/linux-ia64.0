From: Shailabh Nagar <nagar@watson.ibm.com>
Date: Thu, 25 Sep 2003 18:07:45 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106451388724141@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Gerrit Huizenga wrote:

>This might be worth comparing notes on with the CKRM folks (cc:'d above).
>  
>
I went through the cpusets proposal trying to see the commonalities and differences
with what CKRM is trying to achieve.

Speaking of CPUs alone:

The way I see it (corrections welcome), CPUSETS has two objectives
- performance isolation for arbitrary groups of processes by constraining them to run on 
arbitrary sets of CPUs 
- gaining performance benefits for a CPUSET by specifying *which* CPUs it can use. This could
be helpful in NUMA and Hyperthreaded CPU cases as well as for regular CPUs simply by increasing 
the chance of cache warmth etc. i.e. the same benefits as seen in sched_affinity, but generalized for
groups of processes.

CKRM shares some aspects of the first objective i.e. it also seeks performance isolation for 
arbitrary groups of processes (classes) too but differs in that it
- uses scheduler modifications to achieve isolation
- has a quantitative measures for how much resource is used
CKRM does not share the second objective i.e. it does not try to control which CPUs
are allocated by the kernel schedulers. If such constraints are placed on allocation, whether by 
sched_affinity, NUMA sched changes or CPUSETs, CKRM will cooperate and operate within that constraint.

For this second objective, CKRM is orthogonal to CPUSETs. For the first one, it is another way of
achieving isolation, one that broadly sacrifices stricter guarantees (which are possible by physically
isolating CPUs as in CPUSETS) for better load balancing and utilization.

Coming to memory, it wasn't very clear what CPUSETs future plans/objectives are. Does it intend to 
control which address ranges a CPUSET can allocate from (for NUMA reasons) AND limit how much memory it
can consume ? The latter intersects with CKRM objectives, the former doesn't.

Finally, CKRM is dealing with I/O and planning to incorporate inbound and possibly outbound networking
into its framework which would appear to be outside the scope of something like CPUSETs. 


The user interfaces used by CPUSETs like pexec are quite good. We'd been wanting to develop something
similar for CKRM usage as well - allow a user to use a single commandline to specify a job/program and 
the constraints under which it should operate. The command will then create a class with the specified
cpu/mem/io/net constraints, run the job/program within that class and autoclean it when done.


-- Shailabh





On Wed, 24 Sep 2003 17:59:01 +0200, Simon Derr wrote:

>>Hi,
>>
>>We have developped a new feature in the Linux kernel, controlling CPU
>>placements, which are useful on large SMP machines, especially NUMA ones.
>>We call it CPUSETS, and we would highly appreciate to know about anyone
>>who would be interested in such a feature. This has been somewhat inspired
>>by the pset or cpumemset patches existing for Linux 2.4.........
>>    
>>
<snip>

>>You can find the associated manpages and a slightly more detailed
>>explanation here: http://www.bullopensource.org/cpuset/
>>
>>Any feedback, comment or opinion is welcome:
>>	Simon.Derr@Bull.net,
>>	Sylvain.Jaugey@bull.net
>>
>>Thanks,
>>
>>	Simon and Sylvain.
>>    
>>

