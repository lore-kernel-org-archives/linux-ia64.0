From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 17 May 2004 23:36:48 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405171636.48530.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, May 17, 2004 4:28 pm, Dave Hansen wrote:
> > Is anyone doing anything to optimize access to such beasts?  Binding
> > processes that are accessing such I/O devices to nearby nodes ...
> > sounds possible for NIC, and ugly for disks.
>
> Well, binding isn't the best thing to do, but simple preference and
> error recovery would be great.  The NUMAQ (and I'm sure others) used to
> have a few fiber channel cards in each node that allowed multiple paths
> to I/O devices.  You could be fast, and recover from errors since
> everything was multiply connected.  We do this on some drivers today,
> but not everything.

We do a few more things on Altix.  IRQs are already routed to close CPUs, and 
I have patches to allocate DMA memory from the node closest to a given 
devices.  Drivers can use pci_to_nodemask (currently pcibus_to_cpumask) to 
get a list of nodes close to their device, and there are patches floating 
about to link PCI busses to nodes in /sys, which would allow user level 
applications to intelligently place themselves.

Jesse
