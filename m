From: Yasunori Goto <ygoto@us.fujitsu.com>
Date: Fri, 14 May 2004 00:13:15 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040513150842.22F5.YGOTO@us.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello.

> > Iam not sure what specifically you are looking for ...
> 
> I was looking for the short and sweet overview such as you just
> presented ;).  Thanks.
> 
> I need to start following this hotplug work because it is next door to
> the cpu/memory placement work that I am most focused on, such as
> cpusets, led by Simon Derr of Bull, sitting on top of sched_setaffinity
> and Andi Kleen's numa work.  A cpuset is a set of cpu and memory
> resources that several tasks share, perhaps exclusively (all other
> tasks kept out).
> 
> At some point, questions such as "what happens when a node is unplugged
> from a cpuset" will need to be answered.  And even earlier, "what happens
> when a cpu is unplugged that was in a tasks cpus_allowed, or a memory
> node unplugged, that was in a vma's list of allowed memory zones."
> 
> Or perhaps the answers to these questions are already known ??

At least, there aren't enough answer about memory hotplug yet
if there is a process that is using memory affinity.

But did you see Iwamoto-san's patch ?
This is infrastructure that contents of memory can 
migrate from a node to other node.
If remap_onepage() of his patch execute on same cpus of that process 
or 'node id' is specified, it will migrate to appriciate node.
I think it can be your help.

But, probably you might think many other works are necessary, right?

Thanks.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


