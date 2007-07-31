From: Thomas Renninger <trenn@suse.de>
Date: Tue, 31 Jul 2007 13:24:14 +0000
Subject: Re: regression on HP zx1 platform from ACPI autoload modules
Message-Id: <1185888255.18821.178.camel@queen.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1185836238.31298.36.camel@deimos.americas.hpqcorp.net>
	 <6bffcb0e0707301607x5484f114q9117007d131f7118@mail.gmail.com>
	 <1185883574.14987.6.camel@athlon>
	 <1185886862.18821.168.camel@queen.suse.de>
In-Reply-To: <1185886862.18821.168.camel@queen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Chapman <doug.chapman@hp.com>
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Len Brown <lenb@kernel.org>, "Luck, Tony" <tony.luck@intel.com>

On Tue, 2007-07-31 at 15:01 +0200, Thomas Renninger wrote:
> On Tue, 2007-07-31 at 08:06 -0400, Doug Chapman wrote:
> > On Tue, 2007-07-31 at 01:07 +0200, Michal Piotrowski wrote:
> > > Hi Doug,
> > > 
> > > On 31/07/07, Doug Chapman <doug.chapman@hp.com> wrote:
> > > > I am seeing a regression on the HP ia64 zx1 platforms when using
> > > > a .config with CONFIG_IA64_HP_ZX1=y.  Oddly it works OK with
> > > > CONFIG_IA64_GENERIC=y.
> > > >
> > > >
> > > > During bootup it panics with:
> > > >
> > > > Kernel panic - not syncing: Unable to find SBA IOMMU: Try a generic or DIG kernel
> > > >
> > > > I can provide the full console output if that is helpful.
> > > 
> > > Yes, it is very useful.
> > > 
> > > >  Also, please let
> > > > me know if there is any other data I can provide that would be helpful.
> > > 
> > > Kernel .config file.
> > 
> > 
> > Michal,
> > 
> > Attached are the full console output up to the panic and the .config
> > file I used to build the kernel.  Let me know if there is anything else
> > you need or if you would like me to try a patch.
> 
> This patch should fix it.
> It's already sent to Len. Bjorn/Myron already tested this one and gave
> an acked-by, but it has not hit Len's git tree yet.
> Len?
> Or should it be picked up by an IA64 tree?

We should have included the IA64 list on the other thread..., Tony
wanted to take it (already has?):
-------------------------
I have a few other ia64 cleanup bits from the vector-domain change, so
I can drop this in with them for a pull from ia64 later today.
--------------------------
> 
>    Thomas
> 
> -----------------
> 
> Use new acpi_device_id struct for HID init in ia64/hp/common/sba_iommu.c
> 
> Forgot to adjust this one with the acpi autoloading patches.
> 
> Signed-off-by: Thomas Renninger <trenn@suse.de>
> Acked-by: Myron Stowe <myron.stowe@hp.com>
> 
> ---
>  arch/ia64/hp/common/sba_iommu.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.23-rc1/arch/ia64/hp/common/sba_iommu.c
> =================================> --- linux-2.6.23-rc1.orig/arch/ia64/hp/common/sba_iommu.c
> +++ linux-2.6.23-rc1/arch/ia64/hp/common/sba_iommu.c
> @@ -2015,9 +2015,14 @@ acpi_sba_ioc_add(struct acpi_device *dev
>  	return 0;
>  }
>  
> +static const struct acpi_device_id hp_ioc_iommu_device_ids[] = {
> +	{"HWP0001", 0},
> +	{"HWP0004", 0},
> +	{"", 0},
> +};
>  static struct acpi_driver acpi_sba_ioc_driver = {
>  	.name		= "IOC IOMMU Driver",
> -	.ids		= "HWP0001,HWP0004",
> +	.ids		= hp_ioc_iommu_device_ids,
>  	.ops		= {
>  		.add	= acpi_sba_ioc_add,
>  	},
> 
> 

