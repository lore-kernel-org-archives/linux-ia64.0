From: Bruce Losure <blosure@sgi.com>
Date: Mon, 31 Jan 2005 23:08:40 +0000
Subject: Re: [PATCH 2.6.11] Altix patch for device driver support for the CX
Message-Id: <Pine.LNX.4.44.0501311706050.30646-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
In-Reply-To: <Pine.LNX.4.44.0501311506590.30646-100000@fsgi025.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Jesse,

Thanks for your comments.   I think I can make most of these w/o
problem.   I avoided moving the code into drivers/char because it
involved moving the header files but I'll go ahead and do that.

Thanks again,
-Bruce

On Mon, 31 Jan 2005, Jesse Barnes wrote:

> Looks pretty good, Bruce, just a few comments (mostly nit picking).
> 
> On Monday, January 31, 2005 1:11 pm, Bruce Losure wrote:
> > +#include <linux/list.h>
> > +#include <asm-ia64/sn/types.h>
> 
> This should just be <asm/sn/types.h>.
> 
> > +/* create DMA address by stripping AS bits */
> > +#define TIOCX_DMA_ADDR(a) (uint64_t)((uint64_t)(a) & 0xffffcfffffffff)
> 
> Can you suffix your long constants with UL, e.g. 0xffffcfffffffffUL?  Some 
> compilers and source checkers might complain otherwise.
> 
> > diff -Nru a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
> > --- a/arch/ia64/sn/kernel/Makefile 2005-01-31 14:54:21 -06:00
> > +++ b/arch/ia64/sn/kernel/Makefile 2005-01-31 14:54:21 -06:00
> > @@ -10,3 +10,4 @@
> >  obj-y    += setup.o bte.o bte_error.o irq.o mca.o idle.o \
> >         huberror.o io_init.o iomv.o klconflib.o sn2/
> >  obj-$(CONFIG_IA64_GENERIC)      += machvec.o
> > +obj-m     += tiocx.o
> 
> If you want to keep it modular (as opposed to just putting it in the obj-y 
> objects), you should probably add a config option for it (probably under the 
> character devices menu next to the sn system controller driver) and make it 
> obj-$(CONFIG_SGI_TIOCX) instead.  Also, if you put this file under 
> drivers/char it's more likely to be updated as APIs change and such.  It 
> might mean moving some headers that it needs from arch/ia64/sn/include to 
> include/asm-ia64/sn though (which is no biggie).  Maybe like this?  
> 
> === drivers/char/Kconfig 1.59 vs edited ==> --- 1.59/drivers/char/Kconfig   2005-01-06 10:42:18 -08:00
> +++ edited/drivers/char/Kconfig 2005-01-31 14:03:11 -08:00
> @@ -432,6 +432,13 @@
>           controller communication from user space (you want this!),
>           say Y.  Otherwise, say N.
> 
> +config SGI_TIOCX
> +       bool "SGI TIO CX driver support"
> +       depends on (IA64_SGI_SN2 || IA64_GENERIC)
> +       help
> +         If you have an SGI Altix and you want to use fpga devices attached
> +         to your TIO, say Y or M here, otherwise say N.
> +
>  source "drivers/serial/Kconfig"
> 
>  config UNIX98_PTYS
> 
> then in drivers/char/Makefile:
> 
> === drivers/char/Makefile 1.81 vs edited ==> --- 1.81/drivers/char/Makefile  2004-11-07 15:27:25 -08:00
> +++ edited/drivers/char/Makefile        2005-01-31 14:05:38 -08:00
> @@ -45,6 +45,7 @@
>  obj-$(CONFIG_HVC_CONSOLE)      += hvc_console.o hvsi.o
>  obj-$(CONFIG_RAW_DRIVER)       += raw.o
>  obj-$(CONFIG_SGI_SNSC)         += snsc.o
> +obj-$(CONFIG_SGI_TIOCX)                += tiocx.o
>  obj-$(CONFIG_MMTIMER)          += mmtimer.o
>  obj-$(CONFIG_VIOCONS) += viocons.o
>  obj-$(CONFIG_VIOTAPE)          += viotape.o
> 
> And of course we should probably enable it by default in sn2_defconfig and 
> defconfig to make things easy for bleeding edge users (which fpga users may 
> be).
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
> Should probably be linux/delay.h instead (if there's a linux/ version use it 
> over the asm/ version in general).  Please put the #includes in order too, 
> linux/, asm/, asm/sn, then local is probably best.
> 
> > +#define WIDGET_ID 0
> > +
> > +static int tiocx_debug;  /* debug switch */
> > +MODULE_PARM(tiocx_debug, "i");
> > +#define DBG(fmt...)    if (tiocx_debug) printk(KERN_ALERT fmt)
> 
> New compilers may optimize out the tiocx_debug flag, meaning you couldn't 
> reenable it with a kernel debugger later (I'm assuming that's what you want).  
> Making it a #define would work around that but also make it static.  Or you 
> could just remove the debug flag altogether since you've already debugged 
> this code and it's perfect right? :)
> 
> > + cx_dev = (struct cx_dev *)kmalloc(sizeof(struct cx_dev), GFP_KERNEL);
> 
> kmalloc returns void * so you shouldn't need the cast.
> 
> 
> > + spin_lock(&cx_device_spin);
> > + list_add_tail((struct list_head *)cx_dev, &cx_device_list);
> 
> Do you want list_add_tail(&cx_dev->global_list, &cx_device_list) here instead?  
> I.e. shouldn't you be passing in a list_head * instead?
> 
> 
> > + list_for_each_safe(lp, tmp, (struct list_head *)&cx_device_list) {
> 
> I think you can drop the cast since cx_device_list is a struct list_head, 
> therefore &cx_device_list will be a struct list_head *, right?  There are a 
> few cases of this.
> 
> > + ia64_sal_oemcall_nolock(&rv, (u64) SN_SAL_IOIF_INTERRUPT,
> > +    (u64) SAL_INTR_ALLOC, (u64) nasid,
> > +    (u64) widget, (u64) sn_irq_info, (u64) req_irq,
> > +    (u64) req_nasid, (u64) req_slice);
> 
> Most of these casts can be safely removed (elsewhere too).
> 
> > + sn_irq_info = kmalloc(sn_irq_size, GFP_KERNEL);
> > + if (sn_irq_info = NULL)
> > +  return NULL;
> > +
> > + memset(sn_irq_info, 0x0, sn_irq_size);
> 
> You can use kmalloc(sn_irq_size, GFP_KERNEL | __GFP_ZERO); to avoid having to 
> memset it to 0.
> 
> > +static void tio_corelet_reset(nasid_t nasid, int corelet)
> > +{
> > + if (!(nasid & 1))
> > +  return;
> > +
> > + REMOTE_HUB_S(nasid, TIO_ICE_PMI_TX_CFG, 1 << corelet);
> > + udelay(2000);
> > + REMOTE_HUB_S(nasid, TIO_ICE_PMI_TX_CFG, 0);
> > + udelay(2000);
> 
> Are these udelays necessary?  Do we have to wait a certain number of clock 
> ticks before clearing the TIO_ICE_PMI_TX_CFG register or something?
> 
> > +int tiocx_open(struct inode *ip, struct file *fp)
> > +{
> > + if (ip = NULL) {
> > +  return -EINVAL;
> > + }
> > + if (fp = NULL) {
> > +  return -EINVAL;
> > + }
> 
> You can drop the extra {} in both of the ifs above and maybe combine it into
>  if (!ip || !fp)
>   return -EINVAL;
> if you want.
> 
> 
> > +   if (cx_device_register
> > +       (nasid, widgetp->xwi_hwid.part_num,
> > +        widgetp->xwi_hwid.mfg_num, hubdev) < 0)
> > +    return -ENXIO;
> 
> Did you mean to put the function name and the function call arguments on 
> different lines here?
> 
> Thanks,
> Jesse
> 

-- 
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121

