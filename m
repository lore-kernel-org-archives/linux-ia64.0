From: Russ Anderson <rja@sgi.com>
Date: Fri, 14 May 2004 13:49:07 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405141349.i4EDn7p1053131@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keiichiro Tokunaga wrote:
> Dave Hansen <haveblue@us.ibm.com> wrote:
> > On Wed, 2004-05-12 at 23:35, Keiichiro Tokunaga wrote:
> > > 
> > > I'm rather focusing on ACPI based container device hotplug.
> > > A scope of LHNS includes a container device that contains
> > > IO devices.  I think such a devices couldn't be handled by NUMA
> > > hotplug.
> > 
> > Why not?  We already export the information about which PCI busses are
> > attached to which NUMA nodes.  How are I/O devices different from CPU or
> > memory?  
> 
> I have just one concern.
> How about a container device that contains IO devices only?
>   - Does it count as a NUMA node?
>   - Is it having a NUMA node ID?

Yes, it would count as NUMA node with a NUMA ID.

So a NUMA node could have CPUs, memory, and I/O,
where each of those may or may not be present.

There could be a node without any CPU, memory, or I/O.
An example would be an I/O only node with PCI devices
that are hot plug.  The PCI devices may or may not be
connected at any point in time.

And Yes, SGI does have I/O only nodes (and memory only nodes).

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
