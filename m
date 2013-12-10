From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Date: Tue, 10 Dec 2013 03:59:33 +0000
Subject: Re: [PATCH 1/9] PCI: Use dev_is_pci() to check whether it is pci device
Message-Id: <1386647973.32037.57.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <1386244373-35796-1-git-send-email-wangyijing@huawei.com>
	 <20131210000154.GE4699@google.com>
In-Reply-To: <20131210000154.GE4699@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Yijing Wang <wangyijing@huawei.com>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-pci@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Mon, 2013-12-09 at 17:01 -0700, Bjorn Helgaas wrote:
> [+cc arch lists]
> 
> On Thu, Dec 05, 2013 at 07:52:53PM +0800, Yijing Wang wrote:
> > Use dev_is_pci() instead of directly compare
> > pci_bus_type to check whether it is pci device.
> > 
> > Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> 
> I applied all these to my pci/yijing-dev_is_pci branch for v3.14, thanks!
> 
> Browse them here: http://git.kernel.org/cgit/linux/kernel/git/helgaas/pci.git/log/?h=pci/yijing-dev_is_pci

Ah ok. I also have the powerpc one in powerpc -next, no biggie though

Cheers,
Ben.

> This should be no functional change.
> 
>  arch/alpha/kernel/pci_iommu.c        |    2 +-
>  arch/arm/common/it8152.c             |    4 ++--
>  arch/arm/mach-ixp4xx/common-pci.c    |    6 +++---
>  arch/ia64/hp/common/sba_iommu.c      |    2 +-
>  arch/ia64/sn/pci/pci_dma.c           |   24 ++++++++++++------------
>  arch/parisc/kernel/drivers.c         |   22 +++++-----------------
>  arch/powerpc/sysdev/fsl_pci.c        |    2 +-
>  arch/sparc/include/asm/dma-mapping.h |   10 ++++------
>  arch/sparc/kernel/iommu.c            |    2 +-
>  arch/sparc/kernel/ioport.c           |    4 +---
>  arch/x86/kernel/acpi/boot.c          |    4 +---
>  drivers/pci/pci-acpi.c               |    2 +-
>  12 files changed, 33 insertions(+), 51 deletions(-)
> 
> Bjorn
> 
> > ---
> >  drivers/pci/pci-acpi.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/pci/pci-acpi.c b/drivers/pci/pci-acpi.c
> > index 577074e..e0431f1 100644
> > --- a/drivers/pci/pci-acpi.c
> > +++ b/drivers/pci/pci-acpi.c
> > @@ -358,7 +358,7 @@ static void pci_acpi_cleanup(struct device *dev)
> >  
> >  static bool pci_acpi_bus_match(struct device *dev)
> >  {
> > -	return dev->bus = &pci_bus_type;
> > +	return dev_is_pci(dev);
> >  }
> >  
> >  static struct acpi_bus_type acpi_pci_bus = {
> > -- 
> > 1.7.1
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev


