From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 14 Dec 2018 21:17:57 +0000
Subject: Re: [PATCH 14/15] vmd: use the proper dma_* APIs instead of direct methods calls
Message-Id: <20181214211757.GF20725@google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
 <20181207190720.18517-15-hch@lst.de>
In-Reply-To: <20181207190720.18517-15-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Conventional spelling in subject is

  PCI: vmd: Use dma_* APIs instead of direct method calls

On Fri, Dec 07, 2018 at 11:07:19AM -0800, Christoph Hellwig wrote:
> With the bypass support for the direct mapping we might not always have
> methods to call, so use the proper APIs instead.  The only downside is
> that we will create two dma-debug entries for each mapping if
> CONFIG_DMA_DEBUG is enabled.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

You cc'd the VMD maintainers already, and I have no objection to this
from a PCI core point of view, so:

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

> ---
>  drivers/pci/controller/vmd.c | 42 +++++++++++++++---------------------
>  1 file changed, 17 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/pci/controller/vmd.c b/drivers/pci/controller/vmd.c
> index 98ce79eac128..3890812cdf87 100644
> --- a/drivers/pci/controller/vmd.c
> +++ b/drivers/pci/controller/vmd.c
> @@ -307,39 +307,32 @@ static struct device *to_vmd_dev(struct device *dev)
>  	return &vmd->dev->dev;
>  }
>  
> -static const struct dma_map_ops *vmd_dma_ops(struct device *dev)
> -{
> -	return get_dma_ops(to_vmd_dev(dev));
> -}
> -
>  static void *vmd_alloc(struct device *dev, size_t size, dma_addr_t *addr,
>  		       gfp_t flag, unsigned long attrs)
>  {
> -	return vmd_dma_ops(dev)->alloc(to_vmd_dev(dev), size, addr, flag,
> -				       attrs);
> +	return dma_alloc_attrs(to_vmd_dev(dev), size, addr, flag, attrs);
>  }
>  
>  static void vmd_free(struct device *dev, size_t size, void *vaddr,
>  		     dma_addr_t addr, unsigned long attrs)
>  {
> -	return vmd_dma_ops(dev)->free(to_vmd_dev(dev), size, vaddr, addr,
> -				      attrs);
> +	return dma_free_attrs(to_vmd_dev(dev), size, vaddr, addr, attrs);
>  }
>  
>  static int vmd_mmap(struct device *dev, struct vm_area_struct *vma,
>  		    void *cpu_addr, dma_addr_t addr, size_t size,
>  		    unsigned long attrs)
>  {
> -	return vmd_dma_ops(dev)->mmap(to_vmd_dev(dev), vma, cpu_addr, addr,
> -				      size, attrs);
> +	return dma_mmap_attrs(to_vmd_dev(dev), vma, cpu_addr, addr, size,
> +			attrs);
>  }
>  
>  static int vmd_get_sgtable(struct device *dev, struct sg_table *sgt,
>  			   void *cpu_addr, dma_addr_t addr, size_t size,
>  			   unsigned long attrs)
>  {
> -	return vmd_dma_ops(dev)->get_sgtable(to_vmd_dev(dev), sgt, cpu_addr,
> -					     addr, size, attrs);
> +	return dma_get_sgtable_attrs(to_vmd_dev(dev), sgt, cpu_addr, addr, size,
> +			attrs);
>  }
>  
>  static dma_addr_t vmd_map_page(struct device *dev, struct page *page,
> @@ -347,61 +340,60 @@ static dma_addr_t vmd_map_page(struct device *dev, struct page *page,
>  			       enum dma_data_direction dir,
>  			       unsigned long attrs)
>  {
> -	return vmd_dma_ops(dev)->map_page(to_vmd_dev(dev), page, offset, size,
> -					  dir, attrs);
> +	return dma_map_page_attrs(to_vmd_dev(dev), page, offset, size, dir,
> +			attrs);
>  }
>  
>  static void vmd_unmap_page(struct device *dev, dma_addr_t addr, size_t size,
>  			   enum dma_data_direction dir, unsigned long attrs)
>  {
> -	vmd_dma_ops(dev)->unmap_page(to_vmd_dev(dev), addr, size, dir, attrs);
> +	dma_unmap_page_attrs(to_vmd_dev(dev), addr, size, dir, attrs);
>  }
>  
>  static int vmd_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>  		      enum dma_data_direction dir, unsigned long attrs)
>  {
> -	return vmd_dma_ops(dev)->map_sg(to_vmd_dev(dev), sg, nents, dir, attrs);
> +	return dma_map_sg_attrs(to_vmd_dev(dev), sg, nents, dir, attrs);
>  }
>  
>  static void vmd_unmap_sg(struct device *dev, struct scatterlist *sg, int nents,
>  			 enum dma_data_direction dir, unsigned long attrs)
>  {
> -	vmd_dma_ops(dev)->unmap_sg(to_vmd_dev(dev), sg, nents, dir, attrs);
> +	dma_unmap_sg_attrs(to_vmd_dev(dev), sg, nents, dir, attrs);
>  }
>  
>  static void vmd_sync_single_for_cpu(struct device *dev, dma_addr_t addr,
>  				    size_t size, enum dma_data_direction dir)
>  {
> -	vmd_dma_ops(dev)->sync_single_for_cpu(to_vmd_dev(dev), addr, size, dir);
> +	dma_sync_single_for_cpu(to_vmd_dev(dev), addr, size, dir);
>  }
>  
>  static void vmd_sync_single_for_device(struct device *dev, dma_addr_t addr,
>  				       size_t size, enum dma_data_direction dir)
>  {
> -	vmd_dma_ops(dev)->sync_single_for_device(to_vmd_dev(dev), addr, size,
> -						 dir);
> +	dma_sync_single_for_device(to_vmd_dev(dev), addr, size, dir);
>  }
>  
>  static void vmd_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
>  				int nents, enum dma_data_direction dir)
>  {
> -	vmd_dma_ops(dev)->sync_sg_for_cpu(to_vmd_dev(dev), sg, nents, dir);
> +	dma_sync_sg_for_cpu(to_vmd_dev(dev), sg, nents, dir);
>  }
>  
>  static void vmd_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
>  				   int nents, enum dma_data_direction dir)
>  {
> -	vmd_dma_ops(dev)->sync_sg_for_device(to_vmd_dev(dev), sg, nents, dir);
> +	dma_sync_sg_for_device(to_vmd_dev(dev), sg, nents, dir);
>  }
>  
>  static int vmd_dma_supported(struct device *dev, u64 mask)
>  {
> -	return vmd_dma_ops(dev)->dma_supported(to_vmd_dev(dev), mask);
> +	return dma_supported(to_vmd_dev(dev), mask);
>  }
>  
>  static u64 vmd_get_required_mask(struct device *dev)
>  {
> -	return vmd_dma_ops(dev)->get_required_mask(to_vmd_dev(dev));
> +	return dma_get_required_mask(to_vmd_dev(dev));
>  }
>  
>  static void vmd_teardown_dma_ops(struct vmd_dev *vmd)
> -- 
> 2.19.1
> 
