From: Matthew Dobson <colpatch@us.ibm.com>
Date: Mon, 17 May 2004 23:01:21 +0000
Subject: RE: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <1084834881.4095.20.camel@arrakis>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2004-05-16 at 19:34, Kenji Kaneshige wrote:
> Hi,
> 
> > > I have just one concern.
> > > How about a container device that contains IO devices only?
> > >   - Does it count as a NUMA node?
> > >   - Is it having a NUMA node ID?
> >
> > Yes, it would count as NUMA node with a NUMA ID.
> >
> > So a NUMA node could have CPUs, memory, and I/O,
> > where each of those may or may not be present.
> >
> > There could be a node without any CPU, memory, or I/O.
> > An example would be an I/O only node with PCI devices
> > that are hot plug.  The PCI devices may or may not be
> > connected at any point in time.
> 
> I don't know about NUMA much, but I think NUMA node ID is based
> on the SRAT at the boot time. But SRAT doesn't have entries for I/O
> devices. How should we create the NUMA node ID for I/O nodes at the
> boot time?
> 
> Thanks,
> Kenji Kaneshige

The NUMA node ID *can* be based on the SRAT, but doesn't *have* to be. 
It's really up to each individual architecture how they want to number
their nodes.  Or at least that's the way things should work.  That was a
large part of the motivation behind the nodemask patches I submitted a
while ago.  We would like individual architectures to be able to number
their nodes in any manner they deem appropriate, as long as 0 <= nid <
MAX_NUMNODES.  Currently there is an additional requirement (that the
nodemask code would eliminate) that nodes must be numbered sequentially
without any gaps in the numbering, ie: 0 <= nid < numnodes.  There is
really no good reason that this has to hold, so we should get rid of it.

We want macros like for_each_node_with_cpus(),
for_each_node_with_memory(), etc, that people can use to iterate over
the type of nodes they care about.

I'd look at SGI's IA64 code for examples of how to create NUMA nodes
with only I/O on them.

-Matt

