From: Gerrit Huizenga <gh@us.ibm.com>
Date: Wed, 24 Sep 2003 19:32:29 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106443206906619@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This might be worth comparing notes on with the CKRM folks (cc:'d above).

gerrit

On Wed, 24 Sep 2003 17:59:01 +0200, Simon Derr wrote:
> 
> Hi,
> 
> We have developped a new feature in the Linux kernel, controlling CPU
> placements, which are useful on large SMP machines, especially NUMA ones.
> We call it CPUSETS, and we would highly appreciate to know about anyone
> who would be interested in such a feature. This has been somewhat inspired
> by the pset or cpumemset patches existing for Linux 2.4.
> 
> CPUSETs are lightweight objects in the linux kernel that enable users to
> partition their multiprocessor machine by creating execution areas. A
> virtualization layer has been added so it becomes possible to split a
> machine in terms of CPUs.
> 
> Furthermore, HPC applications often need to bind their processes to a
> specific CPU, and can achieve this by calling sched_setaffinity() in the
> recent Linux kernels. But running several HPC applications on a large
> system will result in several processes running on the same processor.
> This problem is addressed by the CPUSET mechanism.
> 
> 
> CPUSETS allow to:
> ----------------
> 1/ create sets of CPUs on the system, and bind applications to them
> 
> 2/ translate the masks of CPUs given to sched_setaffinity() so they stay
>    inside the set of CPUs. With this mechanism, processors are virtualized,
>    for the use of sched_setaffinity() and /proc information. Thus, any former
>    application using this syscall to bind processes to processors will
>    work with virtual CPUs without any change.
> 
> 3/ provide a way to create sets of cpus *inside* a set of cpus : hence a
>    system administrator can partition a system among users, and users can
>    partition their partition among their applications.
> 
> 4/ Change on the fly the execution area of a whole set of processes (to
>    give more resources to a critical application, for example).
> 
> ...
> 5/ In the future, probably associate a memory allocation policy (such as
> local node, or round robin) to a set of cpus.
> 
> 
> These features have been implemented as a kernel patch for Linux 2.6 and a
> suite of userland tools.
> 
> You can find the associated manpages and a slightly more detailed
> explanation here: http://www.bullopensource.org/cpuset/
> 
> Any feedback, comment or opinion is welcome:
> 	Simon.Derr@Bull.net,
> 	Sylvain.Jaugey@bull.net
> 
> Thanks,
> 
> 	Simon and Sylvain.
