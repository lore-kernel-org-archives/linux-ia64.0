From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Date: Wed, 19 Nov 2014 11:49:53 +0000
Subject: Re: [PATCH 5/5] PCI: Rip out pci_bus_add_devices() from pci_scan_root_bus()
Message-Id: <20141119114953.GA12544@red-moon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1416382369-13587-1-git-send-email-wangyijing@huawei.com>
 <1416382369-13587-6-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1416382369-13587-6-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Wed, Nov 19, 2014 at 07:32:49AM +0000, Yijing Wang wrote:
> Just like pci_scan_bus(), we also should rip out
> pci_bus_add_devices() from pci_scan_root_bus().
> Lots platforms first call pci_scan_root_bus(), but
> after that, they call pci_bus_size_bridges() and
> pci_bus_assign_resources(). Place pci_bus_add_devices()
> in pci_scan_root_bus() hurts PCI scan logic.
> Should no functional change.

I agree with the patch, I do not agree it provides no functional change.
You are actually fixing an issue on systems where the root bus
is scanned at device_initcall time and pci drivers may have already been
registered, so they end up being probed with possibly unassigned
resources as you correctly mention in the log.

You could move the sequence:

if (!pci_has_flag(PCI_PROBE_ONLY)) {
	pci_bus_size_bridges();
	pci_bus_assign_resources();
}

in pci_scan_root_bus() instead of taking pci_bus_add_devices() out ?

Would this break any code ? Or add a helper function:

pci_scan_root_bus(..., bool assign) ?

arm64 xgene code has already been fixed by reshuffling the scanning code
sequence.

I think we should have a look at eg drivers/pci/host/pcie-xilinx.c, I
think there is a possible initcall ordering issue there (drivers being probed
with unassigned resources).

Lorenzo

> 
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: linux-alpha@vger.kernel.org
> CC: linux-ia64@vger.kernel.org
> CC: linux-mips@linux-mips.org
> CC: linux-xtensa@linux-xtensa.org
> CC: linux-arm-kernel@lists.infradead.org
> CC: linux-sh@vger.kernel.org
> CC: sparclinux@vger.kernel.org
> ---
>  arch/alpha/kernel/pci.c          |    2 ++
>  arch/frv/mb93090-mb00/pci-vdk.c  |    6 ++++--
>  arch/ia64/sn/kernel/io_init.c    |    1 +
>  arch/microblaze/pci/pci-common.c |    1 +
>  arch/mips/pci/pci.c              |    1 +
>  arch/mn10300/unit-asb2305/pci.c  |    5 ++++-
>  arch/s390/pci/pci.c              |    2 +-
>  arch/sh/drivers/pci/pci.c        |    1 +
>  arch/sparc/kernel/leon_pci.c     |    1 +
>  arch/tile/kernel/pci.c           |    2 ++
>  arch/tile/kernel/pci_gx.c        |    2 ++
>  arch/x86/pci/common.c            |    1 +
>  arch/xtensa/kernel/pci.c         |    2 ++
>  drivers/pci/host/pci-xgene.c     |    1 +
>  drivers/pci/probe.c              |    1 -
>  15 files changed, 24 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
> index 076c35c..97f9730 100644
> --- a/arch/alpha/kernel/pci.c
> +++ b/arch/alpha/kernel/pci.c
> @@ -334,6 +334,8 @@ common_init_pci(void)
>  
>  		bus = pci_scan_root_bus(NULL, next_busno, alpha_mv.pci_ops,
>  					hose, &resources);
> +		if (bus)
> +			pci_bus_add_devices(bus);
>  		hose->bus = bus;
>  		hose->need_domain_info = need_domain_info;
>  		next_busno = bus->busn_res.end + 1;
> diff --git a/arch/frv/mb93090-mb00/pci-vdk.c b/arch/frv/mb93090-mb00/pci-vdk.c
> index efa5d65..2b36044 100644
> --- a/arch/frv/mb93090-mb00/pci-vdk.c
> +++ b/arch/frv/mb93090-mb00/pci-vdk.c
> @@ -316,6 +316,7 @@ void pcibios_fixup_bus(struct pci_bus *bus)
>  
>  int __init pcibios_init(void)
>  {
> +	struct pci_bus *bus;
>  	struct pci_ops *dir = NULL;
>  	LIST_HEAD(resources);
>  
> @@ -383,12 +384,13 @@ int __init pcibios_init(void)
>  	printk("PCI: Probing PCI hardware\n");
>  	pci_add_resource(&resources, &pci_ioport_resource);
>  	pci_add_resource(&resources, &pci_iomem_resource);
> -	pci_scan_root_bus(NULL, 0, pci_root_ops, NULL, &resources);
> +	bus = pci_scan_root_bus(NULL, 0, pci_root_ops, NULL, &resources);
>  
>  	pcibios_irq_init();
>  	pcibios_fixup_irqs();
>  	pcibios_resource_survey();
> -
> +	if (bus)
> +		pci_bus_add_devices(bus);
>  	return 0;
>  }
>  
> diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
> index 0b5ce82..63b43a6 100644
> --- a/arch/ia64/sn/kernel/io_init.c
> +++ b/arch/ia64/sn/kernel/io_init.c
> @@ -272,6 +272,7 @@ sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
>  		kfree(res);
>  		kfree(controller);
>  	}
> +	pci_bus_add_devices(bus);
>  }
>  
>  /*
> diff --git a/arch/microblaze/pci/pci-common.c b/arch/microblaze/pci/pci-common.c
> index 9037914..651e25d 100644
> --- a/arch/microblaze/pci/pci-common.c
> +++ b/arch/microblaze/pci/pci-common.c
> @@ -1346,6 +1346,7 @@ static void pcibios_scan_phb(struct pci_controller *hose)
>  	hose->bus = bus;
>  
>  	hose->last_busno = bus->busn_res.end;
> +	pci_bus_add_devices(bus);
>  }
>  
>  static int __init pcibios_init(void)
> diff --git a/arch/mips/pci/pci.c b/arch/mips/pci/pci.c
> index 1bf60b1..f083688 100644
> --- a/arch/mips/pci/pci.c
> +++ b/arch/mips/pci/pci.c
> @@ -113,6 +113,7 @@ static void pcibios_scanbus(struct pci_controller *hose)
>  		if (!pci_has_flag(PCI_PROBE_ONLY)) {
>  			pci_bus_size_bridges(bus);
>  			pci_bus_assign_resources(bus);
> +			pci_bus_add_devices(bus);
>  		}
>  	}
>  }
> diff --git a/arch/mn10300/unit-asb2305/pci.c b/arch/mn10300/unit-asb2305/pci.c
> index 6b4339f..860aa35 100644
> --- a/arch/mn10300/unit-asb2305/pci.c
> +++ b/arch/mn10300/unit-asb2305/pci.c
> @@ -345,6 +345,7 @@ void pcibios_fixup_bus(struct pci_bus *bus)
>   */
>  static int __init pcibios_init(void)
>  {
> +	struct pci_bus *bus;
>  	resource_size_t io_offset, mem_offset;
>  	LIST_HEAD(resources);
>  
> @@ -376,11 +377,13 @@ static int __init pcibios_init(void)
>  
>  	pci_add_resource_offset(&resources, &pci_ioport_resource, io_offset);
>  	pci_add_resource_offset(&resources, &pci_iomem_resource, mem_offset);
> -	pci_scan_root_bus(NULL, 0, &pci_direct_ampci, NULL, &resources);
> +	bus = pci_scan_root_bus(NULL, 0, &pci_direct_ampci, NULL, &resources);
>  
>  	pcibios_irq_init();
>  	pcibios_fixup_irqs();
>  	pcibios_resource_survey();
> +	if (bus)
> +		pci_bus_add_devices(bus);
>  	return 0;
>  }
>  
> diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
> index 552b990..98247f8 100644
> --- a/arch/s390/pci/pci.c
> +++ b/arch/s390/pci/pci.c
> @@ -755,7 +755,7 @@ static int zpci_scan_bus(struct zpci_dev *zdev)
>  		zpci_cleanup_bus_resources(zdev);
>  		return -EIO;
>  	}
> -
> +	pci_bus_add_devices(zdev->bus);
>  	zdev->bus->max_bus_speed = zdev->max_bus_speed;
>  	return 0;
>  }
> diff --git a/arch/sh/drivers/pci/pci.c b/arch/sh/drivers/pci/pci.c
> index 1bc09ee..efc1051 100644
> --- a/arch/sh/drivers/pci/pci.c
> +++ b/arch/sh/drivers/pci/pci.c
> @@ -69,6 +69,7 @@ static void pcibios_scanbus(struct pci_channel *hose)
>  
>  		pci_bus_size_bridges(bus);
>  		pci_bus_assign_resources(bus);
> +		pci_bus_add_devices(bus);
>  	} else {
>  		pci_free_resource_list(&resources);
>  	}
> diff --git a/arch/sparc/kernel/leon_pci.c b/arch/sparc/kernel/leon_pci.c
> index 899b720..2971076 100644
> --- a/arch/sparc/kernel/leon_pci.c
> +++ b/arch/sparc/kernel/leon_pci.c
> @@ -40,6 +40,7 @@ void leon_pci_init(struct platform_device *ofdev, struct leon_pci_info *info)
>  
>  		/* Assign devices with resources */
>  		pci_assign_unassigned_resources();
> +		pci_bus_add_devices(root_bus);
>  	} else {
>  		pci_free_resource_list(&resources);
>  	}
> diff --git a/arch/tile/kernel/pci.c b/arch/tile/kernel/pci.c
> index 1f80a88..007466e 100644
> --- a/arch/tile/kernel/pci.c
> +++ b/arch/tile/kernel/pci.c
> @@ -308,6 +308,8 @@ int __init pcibios_init(void)
>  			pci_add_resource(&resources, &iomem_resource);
>  			bus = pci_scan_root_bus(NULL, 0, controller->ops,
>  						controller, &resources);
> +			if (bus)
> +				pci_bus_add_devices(bus);
>  			controller->root_bus = bus;
>  			controller->last_busno = bus->busn_res.end;
>  		}
> diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
> index e39f9c5..3f8fb2c 100644
> --- a/arch/tile/kernel/pci_gx.c
> +++ b/arch/tile/kernel/pci_gx.c
> @@ -889,6 +889,8 @@ int __init pcibios_init(void)
>  		controller->first_busno = next_busno;
>  		bus = pci_scan_root_bus(NULL, next_busno, controller->ops,
>  					controller, &resources);
> +		if (bus)
> +			pci_bus_add_devices(bus);
>  		controller->root_bus = bus;
>  		next_busno = bus->busn_res.end + 1;
>  	}
> diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
> index 7b20bcc..300d39e 100644
> --- a/arch/x86/pci/common.c
> +++ b/arch/x86/pci/common.c
> @@ -475,6 +475,7 @@ void pcibios_scan_root(int busnum)
>  		pci_free_resource_list(&resources);
>  		kfree(sd);
>  	}
> +	pci_bus_add_devices(bus);
>  }
>  
>  void __init pcibios_set_cache_line_size(void)
> diff --git a/arch/xtensa/kernel/pci.c b/arch/xtensa/kernel/pci.c
> index 5b34033..f2ae64e 100644
> --- a/arch/xtensa/kernel/pci.c
> +++ b/arch/xtensa/kernel/pci.c
> @@ -185,6 +185,8 @@ static int __init pcibios_init(void)
>  		pci_controller_apertures(pci_ctrl, &resources);
>  		bus = pci_scan_root_bus(NULL, pci_ctrl->first_busno,
>  					pci_ctrl->ops, pci_ctrl, &resources);
> +		if (bus)
> +			pci_bus_add_devices(bus);
>  		pci_ctrl->bus = bus;
>  		pci_ctrl->last_busno = bus->busn_res.end;
>  		if (next_busno <= pci_ctrl->last_busno)
> diff --git a/drivers/pci/host/pci-xgene.c b/drivers/pci/host/pci-xgene.c
> index 9ecabfa..c17afe5 100644
> --- a/drivers/pci/host/pci-xgene.c
> +++ b/drivers/pci/host/pci-xgene.c
> @@ -635,6 +635,7 @@ static int xgene_pcie_probe_bridge(struct platform_device *pdev)
>  	if (!bus)
>  		return -ENOMEM;
>  
> +	pci_bus_add_devices(bus);
>  	platform_set_drvdata(pdev, port);
>  	return 0;
>  }
> diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
> index 79775b5..2ab5a40 100644
> --- a/drivers/pci/probe.c
> +++ b/drivers/pci/probe.c
> @@ -2084,7 +2084,6 @@ struct pci_bus *pci_scan_root_bus(struct device *parent, int bus,
>  	if (!found)
>  		pci_bus_update_busn_res_end(b, max);
>  
> -	pci_bus_add_devices(b);
>  	return b;
>  }
>  EXPORT_SYMBOL(pci_scan_root_bus);
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
