From: Bruce Losure <blosure@sgi.com>
Date: Fri, 11 Feb 2005 20:40:32 +0000
Subject: Re: [PATCH 2.6.11-rc2 1/1] altix: Device driver support for the CX
Message-Id: <Pine.LNX.4.44.0502111429240.4772-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
In-Reply-To: <20050211140321.20148.62620.40637@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Thanks for your quick review.

On Fri, 11 Feb 2005, Christoph Hellwig wrote:

> > -#include "xtalk/xwidgetdev.h"
> > +#include <asm/sn/xtalk/xwidgetdev.h>
> >  #include <asm/sn/geo.h>
> > -#include "xtalk/hubdev.h"
> > +#include <asm/sn/xtalk/hubdev.h>
> 
> please put moving around headers in a separate patch.
> 

I tried to do that, for some reason the first patch (0/1) didn't make it
to the mailing list.    Is it important to separate the #include lines
as well as the actual file moves?

> >  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> > +EXPORT_PER_CPU_SYMBOL(pda_percpu);
> 
> As mentioned the last time you posted it please use a proper accessor.
> 

I don't understand what you want.   The symbol is exported so that I can
use existing macros from the tiocx code if it's built as a module. 

> > +static void tiocx_bus_release(struct device *dev)
> > +{
> > +}
> 
> this is broken.  See the tweleve gazillion times it came up on lkml.
> The driver core doesn't warn about the lack of a release function because
> it's a nice way to waste time but because there's an actual reason.
> 

I'll move the kfree into that routine.

> > +struct cx_drv {
> > +	char *name;
> > +	const struct cx_device_id *id_table;
> > +	struct device_driver driver;
> > +	int (*probe) (struct cx_dev * dev, const struct cx_device_id * id);
> > +};
> 
> To make it work sanely you also need a ->remove callout.

Yes, I didn't see that, thanks.

> 
> With the above issues fixed it's fine to be queued up until you submit
> an actual user of this interface.
> 

I will work on providing an acceptable, meaningful, driver but it will
take a bit.   Would it be feasible for this code to go in now and for
me to follow up with the driver later?

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121

