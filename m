From: Jack Steiner <steiner@sgi.com>
Date: Fri, 05 Nov 2004 19:13:16 +0000
Subject: Re: Externalize SLIT table
Message-Id: <20041105191316.GA30434@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com> <20041104.135721.08317994.t-kochi@bq.jp.nec.com> <20041105160808.GA26719@sgi.com> <200411051813.24231.efocht@hpce.nec.com>
In-Reply-To: <200411051813.24231.efocht@hpce.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Erich Focht <efocht@hpce.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>, ak@suse.de, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Nov 05, 2004 at 06:13:24PM +0100, Erich Focht wrote:
> Hi Jack,
> 
> the patch looks fine, of course.
> > 	# cat ./node/node0/distance
> > 	10 20 64 42 42 22
> Great!
> 
> But:
> > 	# cat ./cpu/cpu8/distance
> > 	42 42 64 64 22 22 42 42 10 10 20 20
> ...
> 
> what exactly do you mean by cpu_to_cpu distance? In analogy with the
> node distance I'd say it is the time (latency) for moving data from
> the register of one CPU into the register of another CPU:
>         cpu*/distance :   cpu -> memory -> cpu
>                          node1   node?    node2
> 

I'm trying to create an easy-to-use metric for finding sets of cpus that
are close to each other. By "close", I mean that the average offnode
reference from a cpu to remote memory in the set is minimized.

The numbers in cpuN/distance represent the distance from cpu N to 
the memory that is local to each of the other cpus. 

I agree that this can be derived from converting cpuN->node, finding
internode distances, then finding the cpus on each remote node.
The cpu metric is much easier to use. 


> On most architectures this means flushing a cacheline to memory on one
> side and reading it on another side. What you actually implement is
> the latency from memory (one node) to a particular cpu (on some
> node). 
>                        memory ->  cpu
>                        node1     node2

I see how the term can be misleading. The metric is intended to 
represent ONLY the cost of remote access to another processor's local memory.
Is there a better way to describe the cpu-to-remote-cpu's-memory metric OR
should we let users contruct their own matrix from the node data?


> 
> That's only half of the story and actually misleading. I don't
> think the complexity hiding is good in this place. Questions coming to
> my mind are: Where is the memory? Is the SLIT matrix really symmetric
> (cpu_to_cpu distance only makes sense for symmetric matrices)? I
> remember talking to IBM people about hardware where the node distance
> matrix was asymmetric.
> 
> Why do you want this distance anyway? libnuma offers you _node_ masks
> for allocating memory from a particular node. And when you want to
> arrange a complex MPI process structure you'll have to think about
> latency for moving data from one processes buffer to the other
> processes buffer. The buffers live on nodes, not on cpus.

One important use is in the creation of cpusets. The batch scheduler needs 
to pick a subset of cpus that are as close together as possible.


-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


