From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 16:16:14 +0000
Subject: Re: r996 - in trunk/kernel/ia64/kernel-patch-2.6.7-ia64-2.6.7: . debian
Message-Id: <200408130916.14198.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040810071417.GA5080@lst.de>
In-Reply-To: <20040810071417.GA5080@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday, August 13, 2004 9:02 am, Alex Williamson wrote:
> On Fri, 2004-08-13 at 08:29 -0700, Jesse Barnes wrote:
> > On Friday, August 13, 2004 2:32 am, Christoph Hellwig wrote:
> > > --- /dev/null	Wed Dec 31 16:00:00 196900
> > > +++ b/arch/ia64/kernel/numa.c	2004-08-12 18:28:06 -07:00
> > > @@ -0,0 +1,46 @@
> > > +#include <linux/config.h>
> > > +#include <linux/topology.h>
> > > +#include <linux/module.h>
> > > +#include <asm/processor.h>
> > > +#include <asm/smp.h>
> > > +
> > > +#ifdef CONFIG_NUMA
> > >
> > > You build this file conditional on CONFIG_
> > > UMA, no need for this ifdef.
> >
> > Yep, you're right.
>
>    Ok, so you _can_ build NUMA in on a non-SMP kernel and you could even
> imagine a single cpu box w/ multiple memory nodes.  I think our code
> base should be able to support such a system.  However, for a distro
> kernel, the purpose of a UP kernel is to ditch some of the high-end
> overhead and tune it for a little box.  What's the performance hit on a
> box that doesn't need NUMA/DISCONTIG to turn these on for a UP kernel?
> Maybe it's small enough I shouldn't be worried.  Is there any way an
> Altix could survive using the virtual memmap code on a UP build?

I benchmarked CONFIG_DISCONTIGMEM awhile back, and it doesn't have a 
measurable impact.  CONFIG_NUMA is probably a little more expensive though, 
but I have no way of testing it since there's no real way to turn it off atm.  
Theoretically Altix could get away with just a virtual memmap (which probably 
has the most impact on performance of the three), but I've never tried 
that...

Jesse
