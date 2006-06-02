From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 02 Jun 2006 20:24:33 +0000
Subject: Re: [RFC 1/2] Xen/ia64 modified files
Message-Id: <20060602202433.GM32143@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1149275354.5999.83.camel@lappy>
In-Reply-To: <1149275354.5999.83.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jun 02, 2006 at 01:09:14PM -0600, Alex Williamson wrote:
> diff -r 016512c08f6b -r 4489a633a5de arch/ia64/Kconfig
> --- a/arch/ia64/Kconfig	Thu May 25 03:00:07 2006 +0000
> +++ b/arch/ia64/Kconfig	Fri Jun 02 09:54:29 2006 -0600
> @@ -506,3 +520,5 @@ source "security/Kconfig"
>  source "security/Kconfig"
>  
>  source "crypto/Kconfig"
> +
> +source "drivers/xen/Kconfig"

This should really be in drivers/Kconfig, though I suspect that's
something for the xensource people.

> diff -r 016512c08f6b -r 4489a633a5de arch/ia64/Makefile
> --- a/arch/ia64/Makefile	Thu May 25 03:00:07 2006 +0000
> +++ b/arch/ia64/Makefile	Fri Jun 02 09:54:29 2006 -0600
> @@ -45,6 +45,12 @@ endif
>  endif
>  
>  CFLAGS += $(cflags-y)
> +
> +cppflags-$(CONFIG_XEN) += \
> +	-D__XEN_INTERFACE_VERSION__=$(CONFIG_XEN_INTERFACE_VERSION)
> +
> +CPPFLAGS += $(cppflags-y)
> +

That seems a little weird; again something for the xensource people to
fix.

>  drivers-$(CONFIG_PCI)		+= arch/ia64/pci/
> +ifneq ($(CONFIG_XEN),y)
>  drivers-$(CONFIG_IA64_HP_SIM)	+= arch/ia64/hp/sim/
> +endif
> +ifneq ($(CONFIG_IA64_GENERIC),y)
> +drivers-$(CONFIG_XEN)		+= arch/ia64/hp/sim/
> +endif

What're you trying to achieve here?  Why isn't it sufficient to add:

drivers-$(CONFIG_XEN) += arch/ia64/hp/sim/

and leave all the ifneqs out?

> @@ -70,6 +82,8 @@ all: compressed unwcheck
>  all: compressed unwcheck
>  
>  compressed: vmlinux.gz
> +
> +vmlinuz: vmlinux.gz

This could be added independently

>  vmlinux.gz: vmlinux
>  	$(Q)$(MAKE) $(build)=$(boot) $@
> @@ -85,8 +99,8 @@ boot:	lib/lib.a vmlinux
>  boot:	lib/lib.a vmlinux
>  	$(Q)$(MAKE) $(build)=$(boot) $@
>  
> -install: vmlinux.gz
> -	sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) $< System.map "$(INSTALL_PATH)"
> +install:
> +	-yes | sh $(srctree)/arch/ia64/install.sh $(KERNELRELEASE) vmlinux.gz System.map "$(INSTALL_PATH)"

Huh?

> @@ -653,6 +712,11 @@ register_intr (unsigned int gsi, int vec
>  	iosapic_intr_info[vector].polarity = polarity;
>  	iosapic_intr_info[vector].dmode    = delivery;
>  	iosapic_intr_info[vector].trigger  = trigger;
> +
> +#ifdef CONFIG_XEN
> +	if (is_running_on_xen())
> +		return 0;
> +#endif

I would suggest defining this in a header with the standard

#ifdef CONFIG_XEN
#define is_running_on_xen() ...
#else
#define is_running_on_xen() 0
#endif

trick.  This applies to just about every use of is_running_on_xen(),
so I shan't comment on that further.

> diff -r 016512c08f6b -r 4489a633a5de arch/ia64/kernel/irq_ia64.c
> --- a/arch/ia64/kernel/irq_ia64.c	Thu May 25 03:00:07 2006 +0000
> +++ b/arch/ia64/kernel/irq_ia64.c	Fri Jun 02 09:54:29 2006 -0600
> @@ -66,6 +66,11 @@ assign_irq_vector (int irq)
>  assign_irq_vector (int irq)
>  {
>  	int pos, vector;
> +#ifdef CONFIG_XEN
> +	extern int xen_assign_irq_vector(int);
> +	if (is_running_on_xen())
> +		return xen_assign_irq_vector(irq);

The extern should certainly be in a header file.

I'll review the rest of the irq stuff in a later mail.

> @@ -260,6 +272,7 @@ reserve_memory (void)
>  	n++;
>  
>  	num_rsvd_regions = n;
> +	BUG_ON(IA64_MAX_RSVD_REGIONS + 1 < n);

Could be included now?

> @@ -333,6 +346,16 @@ early_console_setup (char *cmdline)
>  {
>  	int earlycons = 0;
>  
> +#ifdef CONFIG_XEN
> +#ifndef CONFIG_IA64_HP_SIM
> +	if (is_running_on_xen()) {
> +		extern struct console hpsim_cons;
> +		hpsim_cons.flags |= CON_BOOT;
> +		register_console(&hpsim_cons);
> +		earlycons++;
> +	}
> +#endif
> +#endif

I'm not sure why you need the ifndef CONFIG_IA64_HP_SIM here?

> diff -r 016512c08f6b -r 4489a633a5de arch/ia64/mm/ioremap.c
> --- a/arch/ia64/mm/ioremap.c	Thu May 25 03:00:07 2006 +0000
> +++ b/arch/ia64/mm/ioremap.c	Fri Jun 02 09:54:29 2006 -0600
> @@ -15,6 +15,9 @@ static inline void __iomem *
>  static inline void __iomem *
>  __ioremap (unsigned long offset, unsigned long size)
>  {
> +#ifdef CONFIG_XEN
> +	offset = HYPERVISOR_ioremap(offset, size);
> +#endif
>  	return (void __iomem *) (__IA64_UNCACHED_OFFSET | offset);
>  }

I think this would be another great candidate for a dummy function.

> -#define ia64_intrin_local_irq_restore(x)		\
> +#define __ia64_intrin_local_irq_restore(x)		\

I presume with all these changes, the Xen header file does something
like:

#ifdef CONFIG_XEN
#define ia64_intrin_local_irq_restore(x) xen_ia64_intrin_local_irq_restore(x)
#else
#define ia64_intrin_local_irq_restore(x) __ia64_intrin_local_irq_restore(x)
#endif

> +// XXX
> +// the following drivers are broken because they use page_to_phys() to
> +// get bus address. fix them.
> +// drivers/ide/cris/ide-cris.c
> +// drivers/scsi/dec_esp.c

Um, well, I don't see Xen running on DECstations or CRIS cameras any
time soon ;-)  We can probably let those drivers rust in pieces.

>  #define __local_irq_save(x)			\
>  do {						\
>  	ia64_stop();				\
> -	(x) = ia64_getreg(_IA64_REG_PSR);	\
> +	(x) = ia64_get_psr_i();			\

Looks like a good cleanup to submit ahead of time.

>  #endif /* !CONFIG_IA64_DEBUG_IRQ */
>  
>  #define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I); ia64_srlz_d(); })
> -#define local_save_flags(flags)	({ ia64_stop(); (flags) = ia64_getreg(_IA64_REG_PSR); })
> +#define local_save_flags(flags)	({ ia64_stop(); (flags) = ia64_get_psr_i(); })
>  

Ditto.

Overall, looks good.  I'll sit down at some point and really review the
IRQ stuff, but this seems pretty clean to me.

