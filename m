From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 13 May 2004 06:50:58 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <1084431058.3189.7.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2004-05-12 at 23:35, Keiichiro Tokunaga wrote:
> > Node Hotplug support - Tokunaga-san (fujitsu) mostly concentrating on 
> > 		ACPI based numa node hotplug. This work is independent
> > of rest of the hotplug (atleast mostly) and would invoke other module
> > hotplug code as required.  (roughly @10000 ft level)
> 
> I'm rather focusing on ACPI based container device hotplug.
> A scope of LHNS includes a container device that contains
> IO devices.  I think such a devices couldn't be handled by NUMA
> hotplug.

Why not?  We already export the information about which PCI busses are
attached to which NUMA nodes.  How are I/O devices different from CPU or
memory?  

BTW, what *is* NUMA hotplug? :)

-- Dave

