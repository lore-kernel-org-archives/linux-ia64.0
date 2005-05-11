From: Jesse Barnes <jesse.barnes@intel.com>
Date: Wed, 11 May 2005 15:29:37 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <200505110829.37451.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 10, 2005 7:42 pm, colin ngam wrote:
> This is the correct result - with respect to which node the
> bus/device/function is directly connected.

Not really, since the kernel is only aware of nodes (for most purposes) 
that actually have memory.  If the I/O and memoryless nodes were listed 
in the SLIT and SRAT tables, this would be the case (the kernel would 
build empty node structures for those nodes), but it's not at the 
moment.

> Either than using this 
> function in pcibus_to_cpumask(), what other purpose is this routine
> targeted?

You mean 'other than pcibus_to_cpumask'?  The idea is to use it for 
memory allocation in device drivers, as well as the obvious use in the 
actual DMA mapping layer (e.g. pci_alloc_consistent).  It could also be 
used to simplify the interrupt targetting code a little, iirc, assuming 
the above condition was met (that is, that all nodes, regardless of 
configuration, had pgdat structures associated with them).

> Depending on what you want, you have to test the node id to see if it
> contains memory or if it contains cpus or both.

That's certainly another way to go--just make the function do a search 
to find the closest node with memory (and/or CPUs) all by itself.  The 
obvious disadvantage is that you'll incur that cost on every function 
call unless you build a lookup table at boot time or somesuch.

> There is always a node associated with the device - the issue is that
> the node may not have cpu but has memory, or may not have both memory
> and cpu.

That's where things get confusing, since 'node' is an overloaded term 
here.  It does *not* return a node that you can pass into 
alloc_pages_node for instance, which I think is what Christoph wants.  
It does, however, return a node id in the cnodeid sense, but one that 
could be useless in most parts of the kernel.

Jesse
