From: Bruce Losure <blosure@sgi.com>
Date: Mon, 31 Jan 2005 23:13:15 +0000
Subject: Re: [PATCH 2.6.11] Altix patch for device driver support for the CX
Message-Id: <Pine.LNX.4.44.0501311708460.30646-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Christoph,

Thanks for your comments.   I'll make the typedef and #include line
changes.  Should'a caught the include stuff myself :-(.    I plan to
go ahead and move the code into drivers/char/sn and make the Kconfig
changes.   Is that what you mean by 'driver model'?

Also, what is the alternative to the ioctl interface?   Should I move
that functionality to /proc?

-Bruce

On Mon, 31 Jan 2005, Christoph Hellwig wrote:

> On Mon, Jan 31, 2005 at 03:11:01PM -0600, Bruce Losure wrote:
> > 
> > This patch provide support for the CX port of the SGI TIO chip.
> > The CX port of the SGI TIO chip may be connected to FPGA based
> > hardware.  The changes in this patch may be used in support of device
> > driver developers who are writing drivers for that FPGA hardware.
> > The module provides driver registration/unregistration routines, device
> > registration/unregistration routines, interrupt allocation/deallocation
> > and an ioctl.
> 
> Comment one: please use the driver model to get rid of all your internal
> bookkeeping.
> 
> Comment two:  without an actual user this won't go into the tree.
> 
> > +typedef struct cx_id_s {
> > +	unsigned int part_num;
> > +	unsigned int mfg_num;
> > +	int nasid;
> > +} cx_id_t;
> 
> please avoid typedefs (also in lots of other places)
> 
> > +#define TIOCX_IOCTL_BASE	0xdd	// see Documentation/ioctl-number.txt
> > +#define TIOCX_IOCTL_CX_RELOAD   _IO(TIOCX_IOCTL_BASE, 1)
> > +#define TIOCX_IOCTL_DEV_LIST    _IO(TIOCX_IOCTL_BASE, 2)
> 
> also avoid new ioctl-based interfaces.
> 
> > +#include <asm-ia64/sn/types.h>
> 
> always use <asm/foo.h>
> 
> > +obj-m 				+= tiocx.o
> 
> this is broken.  Either it's unconditionally built in or should
> be a config option - unconditionally modular is not an option.
> 
> >  DEFINE_PER_CPU(struct pda_s, pda_percpu);
> > +EXPORT_PER_CPU_SYMBOL(pda_percpu);
> 
> don't think it's something that should be exported.  explain what you
> need and provide accessors.
> 
> > +#include <asm/sn/types.h>
> > +#include <linux/module.h>
> > +#include <linux/kernel.h>
> > +#include <linux/version.h>
> > +#include <linux/slab.h>
> > +#include <linux/spinlock.h>
> > +#include <linux/proc_fs.h>
> > +#include <asm/sn/sn_sal.h>
> > +#include <asm/sn/addrs.h>
> > +#include <asm/sn/io.h>
> > +#include "shubio.h"
> > +#include "tio.h"
> > +#include "tiocx.h"
> > +#include "xtalk/xwidgetdev.h"
> > +#include "xtalk/hubdev.h"
> > +#include <asm-ia64/delay.h>
> > +#include <asm/uaccess.h>
> 
> <linux/*.h> before <asm/*.h> before local headers please.
> 

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121

