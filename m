From: Paul Jackson <pj@sgi.com>
Date: Fri, 26 Sep 2003 09:58:19 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106457035809649@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simon wrote:
> The control on memory provided by future versions of CPUSET might be ...


I anticipate that we end up with a kernel "mems_allowed" attribute
of a task (or perhaps of a vma), that is quite similar to cpus_allowed.

The mems_allowed field is a multiword (well, one word, until someone
ventures above 64 memory nodes) bit vector of node numbers, and
indicates on which one _or_more_ nodes memory may be allocated.  It
controls allocation in mm/page_alloc.c:__alloc_pages(), and related such
places.  Allocation by the kernel for user address space is
distinguished from allocation for the kernel's own needs.

Actually, the mems_allowed field should not be directly in the task (or
vma?) struct, but in the shared cpuset struct, referenced from the task
or vma.   Simon and Sylvain's cpuset proposal already does this for the
cpus_allowed bit vector, moving it from the task struct to the shared
cpuset struct referenced from the task struct.

On the larger scale mems_allowed is set administratively (via convenient
tools such as batch and job managers) for an entire job or related set
of jobs.  On the smaller scale, it is set for various tasks (or vmas) of
a job, relative to the cpuset that job is executing on.  It is usually
set from user level code, sometimes by admin utilities, sometimes by
system services, sometimes by a numa aware application itself.

There may be a need for kernel or low level library assistance in
setting it, for situations such as when a multithreaded scientific
program that is tuned for running on an SMP system knows enough to get
the number of threads right, but doesn't know enough to place them
across nodes optimally.  In such cases, one sometimes has to intercede
at a relatively low level, behind the applications back, to get the
proper distribution of tasks and vmas across cpus and memory nodes for
optimal performance.

Additional work is required to handle cases where one runs out of memory
on allowed nodes - one might want to steal memory from other nodes, or
swap or kill or sleep or grant more nodes to the greedy application,
depending on administrative policies.  Eventually, the kernel should
provide minimal mechanisms in support of each such policy.

The essential attribute of NUMA systems is "non-uniform memory access"
(not surprisingly).  Getting memory placed is just as essential for
optimum performance as getting cpu usage placed.  The two must work
together.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
