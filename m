From: "John Hawkes" <hawkes@sgi.com>
Date: Wed, 24 Aug 2005 16:09:40 +0000
Subject: Re: [PATCH 2.6.13-rc6] cpu_exclusive sched domains build fix
Message-Id: <006a01c5a8c6$3c2006d0$6600a8c0@PCJohn>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050824111510.11478.49764.sendpatchset@jackhammer.engr.sgi.com> <20050824112640.GB5197@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dino@in.ibm.com, Paul Jackson <pj@sgi.com>
Cc: paulus@samba.org, Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org, mingo@elte.hu

From: "Dinakar Guniguntala" <dino@in.ibm.com>
> Can we hold on to this patch for a while, as I reported yesterday,
> this hangs up my ppc64 box on doing rmdir on a exclusive cpuset.
> Still debugging the problem, hope to have a fix soon, Thanks

Paul's patch simply constrains the scope of cpuset configurations that will 
invoke the "dynamic sched domains" functionality, which means that some 
cpu-exclusive (a.k.a. "isolated") cpusets will continue to have the 
2.6.12-and-earlier behavior of being periodically examined by the CPU 
Scheduler in load-balancing activities.  That is, Paul's patch simply reverts 
cpuset/sched domain behavior to pre-2.6.13 status (for some cpusets).

The pre-2.6.13 non-"dynamic sched domains" behavior will in fact produce bad 
load-balancing behavior if a cpu-exclusive cpuset is so heavily loaded with 
executing processes, all pinned to the cpu(s) in the cpuset, that the other 
cpus in the system see this cpu(s)/node as the most-heavily-loaded and just 
focus on it during load-balancing -- which would be futile, of course, since 
the processes pinned to this highest-load cpu (and node) cannot be offloaded. 
Since load-balancing looks only at the most-heavily-loaded cpu as a cpu to 
offload, this means that all system load-balancing would be effectively turned 
off.

John Hawkes 

