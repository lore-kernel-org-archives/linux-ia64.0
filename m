From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Fri, 14 May 2004 01:14:04 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040514101404.6bedda69.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 12 May 2004 23:50:58 -0700
Dave Hansen <haveblue@us.ibm.com> wrote:

> On Wed, 2004-05-12 at 23:35, Keiichiro Tokunaga wrote:
> > > Node Hotplug support - Tokunaga-san (fujitsu) mostly concentrating on 
> > > 		ACPI based numa node hotplug. This work is independent
> > > of rest of the hotplug (atleast mostly) and would invoke other module
> > > hotplug code as required.  (roughly @10000 ft level)
> > 
> > I'm rather focusing on ACPI based container device hotplug.
> > A scope of LHNS includes a container device that contains
> > IO devices.  I think such a devices couldn't be handled by NUMA
> > hotplug.
> 
> Why not?  We already export the information about which PCI busses are
> attached to which NUMA nodes.  How are I/O devices different from CPU or
> memory?  

I have just one concern.
How about a container device that contains IO devices only?
  - Does it count as a NUMA node?
  - Is it having a NUMA node ID?

> BTW, what *is* NUMA hotplug? :)

I'm sorry, that would have to be "NUMA node hotplug"...

Thanks,
Kei
