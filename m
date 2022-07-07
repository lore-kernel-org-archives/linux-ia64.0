From: Marc Zyngier <maz@kernel.org>
Date: Thu, 07 Jul 2022 08:22:26 +0000
Subject: Re: [PATCH v3 1/8] irqchip/mips-gic: Only register IPI domain when SMP is enabled
Message-Id: <87czehmiwt.wl-maz@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220701200056.46555-1-samuel@sholland.org>
        <20220701200056.46555-2-samuel@sholland.org>
        <20220705135243.ydbwfo4kois64elr@mobilestation>
In-Reply-To: <20220705135243.ydbwfo4kois64elr@mobilestation>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Serge Semin <fancer.lancer@gmail.com>
Cc: Samuel Holland <samuel@sholland.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Shevchenko <andy.shevchenko@gmail.com>, Bartosz Golaszewski <brgl@bgdev.pl>, Bjorn Helgaas <bhelgaas@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Broadcom internal kernel review list <bcm-kernel-feedback-list@broadcom.com>, Chris Zankel <chris@zankel.net>, Colin Ian King <colin.king@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dexuan Cui <decui@microsoft.com>, Florian Fainelli <f.fainelli@gmail.com>, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Haiyang Zhang <haiyangz@microsoft.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Jan Beulich <jbeulich@suse.com>, Joerg Roedel <joro@8bytes.org>, Juergen Gross <jgross@suse.com>, Julia Lawall <Julia.Lawall@inria.fr>, "K. Y. Srinivasan" <kys@microsoft.com>, Kees Cook <keescook@chromium.org>, Krzysztof =?UTF-8?B?V2lsY3p5xYRza2k=?= <kw@linux.com>, Linus Walleij <linus.walleij@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Maximilian Heyne <mheyne@amazon.de>, Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Rikard Falkeborn <rikard.falkeborn@gmail.com>, Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Sven Schnelle <svens@stackframe.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Wei Liu <wei.liu@kernel.org>, Wei Xu <xuwei5@hisilicon.com>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, iommu@lists.linux-foundation.org, iommu@lists.linux.dev, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hyperv@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-pci@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, xen-devel@lists.xenproject.org, kernel test robot <lkp@intel.com>

On Tue, 05 Jul 2022 14:52:43 +0100,
Serge Semin <fancer.lancer@gmail.com> wrote:
> 
> Hi Samuel
> 
> On Fri, Jul 01, 2022 at 03:00:49PM -0500, Samuel Holland wrote:
> > The MIPS GIC irqchip driver may be selected in a uniprocessor
> > configuration, but it unconditionally registers an IPI domain.
> > 
> > Limit the part of the driver dealing with IPIs to only be compiled when
> > GENERIC_IRQ_IPI is enabled, which corresponds to an SMP configuration.
> 
> Thanks for the patch. Some comment is below.
> 
> > 
> > Reported-by: kernel test robot <lkp@intel.com>
> > Signed-off-by: Samuel Holland <samuel@sholland.org>
> > ---
> > 
> > Changes in v3:
> >  - New patch to fix build errors in uniprocessor MIPS configs
> > 
> >  drivers/irqchip/Kconfig        |  3 +-
> >  drivers/irqchip/irq-mips-gic.c | 80 +++++++++++++++++++++++-----------
> >  2 files changed, 56 insertions(+), 27 deletions(-)
> > 
> > diff --git a/drivers/irqchip/Kconfig b/drivers/irqchip/Kconfig
> > index 1f23a6be7d88..d26a4ff7c99f 100644
> > --- a/drivers/irqchip/Kconfig
> > +++ b/drivers/irqchip/Kconfig
> > @@ -322,7 +322,8 @@ config KEYSTONE_IRQ
> >  
> >  config MIPS_GIC
> >  	bool
> > -	select GENERIC_IRQ_IPI
> > +	select GENERIC_IRQ_IPI if SMP
> 
> > +	select IRQ_DOMAIN_HIERARCHY
> 
> It seems to me that the IRQ domains hierarchy is supposed to be
> created only if IPI is required. At least that's what the MIPS GIC
> driver implies. Thus we can go further and CONFIG_IRQ_DOMAIN_HIERARCHY
> ifdef-out the gic_irq_domain_alloc() and gic_irq_domain_free()
> methods definition together with the initialization:
> 
>  static const struct irq_domain_ops gic_irq_domain_ops = {
>  	.xlate = gic_irq_domain_xlate,
> +#ifdef CONFIG_IRQ_DOMAIN_HIERARCHY
>  	.alloc = gic_irq_domain_alloc,
>  	.free = gic_irq_domain_free,
> +#endif
>  	.map = gic_irq_domain_map,
> };
> 
> If the GENERIC_IRQ_IPI config is enabled, CONFIG_IRQ_DOMAIN_HIERARCHY
> will be automatically selected (see the config definition in
> kernel/irq/Kconfig). If the IRQs hierarchy is needed for some another
> functionality like GENERIC_MSI_IRQ_DOMAIN or GPIOs then they will
> explicitly enable the IRQ_DOMAIN_HIERARCHY config thus activating the
> denoted .alloc and .free methods definitions.
> 
> To sum up you can get rid of the IRQ_DOMAIN_HIERARCHY config
> force-select from this patch and make the MIPS GIC driver code a bit
> more coherent.
> 
> @Marc, please correct me if were wrong.

Either way probably works correctly, but Samuel's approach is more
readable IMO. It is far easier to reason about a high-level feature
(GENERIC_IRQ_IPI) than an implementation detail (IRQ_DOMAIN_HIERARCHY).

If you really want to save a handful of bytes, you can make the
callbacks conditional on GENERIC_IRQ_IPI, and be done with it. But
this can come as an additional patch.

Thanks,

	M.

-- 
Without deviation from the norm, progress is not possible.
