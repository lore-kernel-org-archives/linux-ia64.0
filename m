From: Paul Jackson <pj@sgi.com>
Date: Fri, 23 Sep 2005 07:00:16 +0000
Subject: Using Cpusets with HyperThreads
Message-Id: <20050923000016.2cc416ac.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This note explains the support provided by cpusets for job placement
on hyperthreaded CPUs in upcoming products, enabling one to control
what can run on the A and B sides of each core, if anything.

How does this look?  Is the document itself clear and complete?
Will the following serve your needs?  What's missing, wrong-headed
or useless?  Is there a better way we should consider?

The cpuset command and library technology currently shipping in the
latest ProPack 4 versions already includes the following technology,
so it is quite unlikely that we would remove any of this.  But there
may well be additional features, and improved documentation, that
would be useful.

Your feedback is welcome.

Using Cpusets with HyperThreads
===============
   In addition to their traditional use to control the placement of
   jobs on the CPUs and Memory Nodes of a system, cpusets also provides
   a convenient mechanism to control the use of hyperthreading (HT).

   Some jobs achieve better performance using both of the hyperthread
   sides, A and B, of a processor core, and some run better using
   just one of the sides, letting the other side idle.

   Since each logical (hyperthreaded) processor in a core has a
   distinct CPU number, one can easily specify a cpuset that contains
   both, or contains just one side, from each of the processor cores
   in the cpuset.

   Cpusets can be configured to include any combination of the logical
   CPUs in a system.

   For example the cpuset configuration file:

	cpus 0-127:2    # the even numbered CPUs 0, 2, 4, ... 126
	mems 0-63       # all memory nodes 0, 1, 2, ... 63

   would include the A sides of an HT enabled system, along with
   all the memory, on the first 64 nodes. The colon ':' prefixes the
   stride. The stride of '2' in this example means use every other
   logical CPU.

   The following commands would create a cpuset 'foo' according to
   the above example, and run the job 'bar' in that cpuset, given that
   'cpuset.cfg' is a file containing the above 2 example lines:

	cpuset -c /foo < cpuset.cfg     # create '/foo' on A sides
	cpuset -i /foo -I bar           # run 'bar' in cpuset /foo

   To specify both sides of the first 64 cores, use:

	cpus 0-127

   To specify just the B sides, use:

	cpus 1-127:2

   The above assumes that CPUs are uniformly numbered, with the even
   numbers for the A side and odd numbers for the B side. This is
   usually the case, but not guaranteed. One could still place a
   job on a system that was not uniformly numbered, but currently
   it would involve a longer argument list to the 'cpus' option,
   explicitly listing the desired CPUs. When time permits, we can add
   more options to the cpuset command and libcpuset C interfaces, to
   make it convenient to manage hyperthread placement on non-uniformly
   numbered systems.

   We do not need to create a separate cpuset with just the B side
   CPUs to avoid having something run there. Tasks can only run where
   there are cpusets allowing it.

   If there is no cpuset for the B sides except the all encompassing
   root cpuset, and if only root can put tasks in that cpuset, then
   no one other than root can run on the B sides.

   The dplace command can be used to manage more detailed placement of
   job tasks within a such a cpuset. Since dplace numbering of CPUs is
   relative to the cpuset, it does not affect the dplace configuration
   whether the cpuset includes both sides of hyperthreaded cores,
   or just one side, or even is on a system that does not support
   hyperthreading.

   Typically, the logical numbering of CPUs puts the even numbered
   CPUs on the A sides, and the odd numbered CPUs on the B side. The
   stride suffix (":2", above) makes it easy to specify that only
   every other side will be used. If the CPU number range starts with
   an even number, this will be the A sides, and if the range starts
   with an odd number, this will be the B sides.

   Use the following steps, for example, to setup a job to run only
   on the A sides of its hyperthreaded cores, and to ensure that
   nothing runs on the B sides (they remain idle).
 
    1. The whole system is covered by a root cpuset (always the case).
    2. A boot cpuset is defined to keep the kernel, system daemon and
       user login session threads off other cpus.
    3. The sys admin or batch scheduler with root permission creates
       a cpuset that includes on the A sides of the processors to be
       used for this job.
    4. The sys admin or batch scheduler does not create any cpuset
       with the B side CPUs in these processors. Then nothing disruptive
       ever runs on the corresponding B side CPUs.

   This is different from cpusets on IRIX. On IRIX, not all CPUs were
   necessarily included in cpusets, and not all jobs were placed in
   cpusets. Jobs not in a cpuset could run without constraint on the
   CPUs not in cpusets. So, on IRIX, one would have to also create a
   cpuset for the B sides, to ensure that other jobs did not run there.

   The cpuset model for Linux 2.6 kernels is different. If a site uses
   a bootcpuset to confine the traditional Unix load, then nothing
   will run on the other CPUs in the system, except when those CPUs
   are included in a cpuset that has a job assigned to it. These CPUs
   are of course in the root cpuset, but this cpuset would normally
   only be usable by a system administrator or batch scheduler with
   root permissions. This prevents anyone without root permission
   from running a task on those CPUs, unless an administrator or
   service with root permission allows it.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
