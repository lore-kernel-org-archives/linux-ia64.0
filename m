From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 14 Dec 2018 21:15:33 +0000
Subject: Re: [PATCH 13/15] ACPI / scan: Refactor _CCA enforcement
Message-Id: <20181214211533.GE20725@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
 <20181207190720.18517-14-hch@lst.de>
In-Reply-To: <20181207190720.18517-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Fri, Dec 07, 2018 at 11:07:18AM -0800, Christoph Hellwig wrote:
> From: Robin Murphy <robin.murphy@arm.com>
> 
> Rather than checking the DMA attribute at each callsite, just pass it
> through for acpi_dma_configure() to handle directly. That can then deal
> with the relatively exceptional DEV_DMA_NOT_SUPPORTED case by explicitly
> installing dummy DMA ops instead of just skipping setup entirely. This
> will then free up the dev->dma_ops = NULL case for some valuable
> fastpath optimisations.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/acpi/scan.c      | 5 +++++
>  drivers/base/platform.c  | 3 +--
>  drivers/pci/pci-driver.c | 3 +--

Acked-by: Bjorn Helgaas <bhelgaas@google.com>	# drivers/pci part

>  3 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
> index bd1c59fb0e17..b75ae34ed188 100644
> --- a/drivers/acpi/scan.c
> +++ b/drivers/acpi/scan.c
> @@ -1456,6 +1456,11 @@ int acpi_dma_configure(struct device *dev, enum dev_dma_attr attr)
>  	const struct iommu_ops *iommu;
>  	u64 dma_addr = 0, size = 0;
>  
> +	if (attr = DEV_DMA_NOT_SUPPORTED) {
> +		set_dma_ops(dev, &dma_dummy_ops);
> +		return 0;
> +	}
> +
>  	iort_dma_setup(dev, &dma_addr, &size);
>  
>  	iommu = iort_iommu_configure(dev);
> diff --git a/drivers/base/platform.c b/drivers/base/platform.c
> index eae841935a45..c1ddf191711e 100644
> --- a/drivers/base/platform.c
> +++ b/drivers/base/platform.c
> @@ -1138,8 +1138,7 @@ int platform_dma_configure(struct device *dev)
>  		ret = of_dma_configure(dev, dev->of_node, true);
>  	} else if (has_acpi_companion(dev)) {
>  		attr = acpi_get_dma_attr(to_acpi_device_node(dev->fwnode));
> -		if (attr != DEV_DMA_NOT_SUPPORTED)
> -			ret = acpi_dma_configure(dev, attr);
> +		ret = acpi_dma_configure(dev, attr);
>  	}
>  
>  	return ret;
> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
> index bef17c3fca67..1b58e058b13f 100644
> --- a/drivers/pci/pci-driver.c
> +++ b/drivers/pci/pci-driver.c
> @@ -1602,8 +1602,7 @@ static int pci_dma_configure(struct device *dev)
>  		struct acpi_device *adev = to_acpi_device_node(bridge->fwnode);
>  		enum dev_dma_attr attr = acpi_get_dma_attr(adev);
>  
> -		if (attr != DEV_DMA_NOT_SUPPORTED)
> -			ret = acpi_dma_configure(dev, attr);
> +		ret = acpi_dma_configure(dev, acpi_get_dma_attr(adev));
>  	}
>  
>  	pci_put_host_bridge_device(bridge);
> -- 
> 2.19.1
> 
