From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 17 May 2004 02:34:09 +0000
Subject: RE: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <MDEEKOKJPMPMKGHIFAMAOEMEEAAA.kaneshige.kenji@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

> > I have just one concern.
> > How about a container device that contains IO devices only?
> >   - Does it count as a NUMA node?
> >   - Is it having a NUMA node ID?
>
> Yes, it would count as NUMA node with a NUMA ID.
>
> So a NUMA node could have CPUs, memory, and I/O,
> where each of those may or may not be present.
>
> There could be a node without any CPU, memory, or I/O.
> An example would be an I/O only node with PCI devices
> that are hot plug.  The PCI devices may or may not be
> connected at any point in time.

I don't know about NUMA much, but I think NUMA node ID is based
on the SRAT at the boot time. But SRAT doesn't have entries for I/O
devices. How should we create the NUMA node ID for I/O nodes at the
boot time?

Thanks,
Kenji Kaneshige


> -----Original Message-----
> From: lhns-devel-admin@lists.sourceforge.net
> [mailto:lhns-devel-admin@lists.sourceforge.net]On Behalf Of Russ Anderson
> Sent: Friday, May 14, 2004 10:49 PM
> To: Keiichiro Tokunaga
> Cc: Dave Hansen; tokunaga.keiich@jp.fujitsu.com; pj@sgi.com;
> ashok.raj@intel.com; lhns-devel@lists.sourceforge.net;
> linux-hotplug-devel@lists.sourceforge.net; colpatch@us.ibm.com;
> linux-ia64@vger.kernel.org; greg@kroah.com; pfg@sgi.com
> Subject: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
>
>
> Keiichiro Tokunaga wrote:
> > Dave Hansen <haveblue@us.ibm.com> wrote:
> > > On Wed, 2004-05-12 at 23:35, Keiichiro Tokunaga wrote:
> > > >
> > > > I'm rather focusing on ACPI based container device hotplug.
> > > > A scope of LHNS includes a container device that contains
> > > > IO devices.  I think such a devices couldn't be handled by NUMA
> > > > hotplug.
> > >
> > > Why not?  We already export the information about which PCI busses are
> > > attached to which NUMA nodes.  How are I/O devices different
> from CPU or
> > > memory?
> >
> > I have just one concern.
> > How about a container device that contains IO devices only?
> >   - Does it count as a NUMA node?
> >   - Is it having a NUMA node ID?
>
> Yes, it would count as NUMA node with a NUMA ID.
>
> So a NUMA node could have CPUs, memory, and I/O,
> where each of those may or may not be present.
>
> There could be a node without any CPU, memory, or I/O.
> An example would be an I/O only node with PCI devices
> that are hot plug.  The PCI devices may or may not be
> connected at any point in time.
>
> And Yes, SGI does have I/O only nodes (and memory only nodes).
>
> Thanks,
> --
> Russ Anderson, OS RAS/Partitioning Project Lead
> SGI - Silicon Graphics Inc          rja@sgi.com
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: SourceForge.net Broadband
> Sign-up now for SourceForge Broadband and get the fastest
> 6.0/768 connection for only $19.95/mo for the first 3 months!
> http://ads.osdn.com/?ad_id%62&alloc_ida84&op=click
> _______________________________________________
> Lhns-devel mailing list
> Lhns-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lhns-devel

