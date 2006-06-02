From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 02 Jun 2006 21:32:52 +0000
Subject: Re: [RFC 1/2] Xen/ia64 modified files
Message-Id: <1149283972.5998.150.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <1149275354.5999.83.camel@lappy>
In-Reply-To: <1149275354.5999.83.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Willy,

On Fri, 2006-06-02 at 14:24 -0600, Matthew Wilcox wrote:
> On Fri, Jun 02, 2006 at 01:09:14PM -0600, Alex Williamson wrote:
> > diff -r 016512c08f6b -r 4489a633a5de arch/ia64/Kconfig
> > --- a/arch/ia64/Kconfig	Thu May 25 03:00:07 2006 +0000
> > +++ b/arch/ia64/Kconfig	Fri Jun 02 09:54:29 2006 -0600
> > @@ -506,3 +520,5 @@ source "security/Kconfig"
> >  source "security/Kconfig"
> >  
> >  source "crypto/Kconfig"
> > +
> > +source "drivers/xen/Kconfig"
> 
> This should really be in drivers/Kconfig, though I suspect that's
> something for the xensource people.

   I agree, things like this should flow a little better when the xen
infrastructure is integrated upstream.


> >  drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
> > +ifneq ($(CONFIG_XEN),y)
> >  drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
> > +endif
> > +ifneq ($(CONFIG_IA64_GENERIC),y)
> > +drivers-$(CONFIG_XEN)		+= arch/ia64/hp/sim/
> > +endif
> 
> What're you trying to achieve here?  Why isn't it sufficient to add:
> 
> drivers-$(CONFIG_XEN) += arch/ia64/hp/sim/
> 
> and leave all the ifneqs out?

   Good question.  Some of this is probably kruft and I think we need to
look at whether all of the hpsim changes can simply be removed.  I'll
also mention that we're currently using only CONFIG_IA64_DIG for dom0
and domU kernels.  The zx1 and sn machvecs will need some porting to
understand the virtual physical memory idea (at least for their iommus).

> > @@ -70,6 +82,8 @@ all: compressed unwcheck
> >  all: compressed unwcheck
> >  
> >  compressed: vmlinux.gz
> > +
> > +vmlinuz: vmlinux.gz
> 
> This could be added independently

   Good idea, we should start cherry picking some of these for early
upstream inclusion.

> >  vmlinux.gz: vmlinux
> >  	$(Q)$(MAKE) $(build)=$(boot) $@
> > @@ -85,8 +99,8 @@ boot:	lib/lib.a vmlinux
> >  boot:	lib/lib.a vmlinux
> >  	$(Q)$(MAKE) $(build)=$(boot) $@
> >  
> > -install: vmlinux.gz
> > -	sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) $< System.map "$(INSTALL_PATH)"
> > +install:
> > +	-yes | sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) vmlinux.gz System.map "$(INSTALL_PATH)"
> 
> Huh?

   This is just to get around some build strangeness in the Xen tree,
probably not something that makes sense for the linux-ia64 tree.

> 
> I would suggest defining this in a header with the standard
> 
> #ifdef CONFIG_XEN
> #define is_running_on_xen() ...
> #else
> #define is_running_on_xen() 0
> #endif
> 
> trick.  This applies to just about every use of is_running_on_xen(),
> so I shan't comment on that further.

   Excellent cleanup idea.

> >  
> > +#ifdef CONFIG_XEN
> > +#ifndef CONFIG_IA64_HP_SIM
> > +	if (is_running_on_xen()) {
> > +		extern struct console hpsim_cons;
> > +		hpsim_cons.flags |= CON_BOOT;
> > +		register_console(&hpsim_cons);
> > +		earlycons++;
> > +	}
> > +#endif
> > +#endif
> 
> I'm not sure why you need the ifndef CONFIG_IA64_HP_SIM here?

   IMHO, this whole chunk is dated and probably needs to go.  This
provides something like an early_printk() through the hypervisor when
running on Xen.

> > diff -r 016512c08f6b -r 4489a633a5de arch/ia64/mm/ioremap.c
> > --- a/arch/ia64/mm/ioremap.c	Thu May 25 03:00:07 2006 +0000
> > +++ b/arch/ia64/mm/ioremap.c	Fri Jun 02 09:54:29 2006 -0600
> > @@ -15,6 +15,9 @@ static inline void __iomem *
> >  static inline void __iomem *
> >  __ioremap (unsigned long offset, unsigned long size)
> >  {
> > +#ifdef CONFIG_XEN
> > +	offset = HYPERVISOR_ioremap(offset, size);
> > +#endif
> >  	return (void __iomem *) (__IA64_UNCACHED_OFFSET | offset);
> >  }
> 
> I think this would be another great candidate for a dummy function.

   Yep, good idea.

> > -#define ia64_intrin_local_irq_restore(x)		\
> > +#define __ia64_intrin_local_irq_restore(x)		\
> 
> I presume with all these changes, the Xen header file does something
> like:
> 
> #ifdef CONFIG_XEN
> #define ia64_intrin_local_irq_restore(x) xen_ia64_intrin_local_irq_restore(x)
> #else
> #define ia64_intrin_local_irq_restore(x) __ia64_intrin_local_irq_restore(x)
> #endif

   Yes, where xen_ia64_intrin_local_irq_restore() supports native and
paravirtualized to allow a kernel with CONFIG_XEN to run on either.

> Overall, looks good.  I'll sit down at some point and really review the
> IRQ stuff, but this seems pretty clean to me.

   Great, thanks for jumping on this!  I'll see about incorporating your
suggestions into our tree.  Thanks,

	Alex

-- 
Alex Williamson                             HP Open Source & Linux Org.

