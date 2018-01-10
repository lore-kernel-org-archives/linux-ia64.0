From: Christoph Hellwig <hch@lst.de>
Date: Wed, 10 Jan 2018 15:46:49 +0000
Subject: Re: [PATCH 10/22] swiotlb: refactor coherent buffer allocation
Message-Id: <20180110154649.GA18529@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180110080932.14157-1-hch@lst.de> <20180110080932.14157-11-hch@lst.de> <cecc98cf-2e6a-a7bc-7390-d6dcced038c4@arm.com>
In-Reply-To: <cecc98cf-2e6a-a7bc-7390-d6dcced038c4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, Michal Simek <monstr@monstr.eu>, linux-ia64@vger.kernel.org, Christian =?iso-8859-1?Q?K=F6nig?= <ckoenig.leichtzumerken@gmail.com>, x86@kernel.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Wed, Jan 10, 2018 at 12:22:18PM +0000, Robin Murphy wrote:
>> +	if (phys_addr = SWIOTLB_MAP_ERROR)
>> +		goto out_warn;
>>   -		/* Confirm address can be DMA'd by device */
>> -		if (dev_addr + size - 1 > dma_mask) {
>> -			printk("hwdev DMA mask = 0x%016Lx, dev_addr = 0x%016Lx\n",
>> -			       (unsigned long long)dma_mask,
>> -			       (unsigned long long)dev_addr);
>> +	*dma_handle = swiotlb_phys_to_dma(dev, phys_addr);
>
> nit: this should probably go after the dma_coherent_ok() check (as with the 
> original logic).

But the originall logic also needs the dma_addr_t for the
dma_coherent_ok check:

		dev_addr = swiotlb_phys_to_dma(hwdev, paddr);
		/* Confirm address can be DMA'd by device */
		if (dev_addr + size - 1 > dma_mask) {
			...
			goto err_warn;
		}

or do you mean assining to *dma_handle?  The dma_handle is not
valid for a failure return, so I don't think this should matter.

>> +	if (ret) {
>> +		*dma_handle = swiotlb_virt_to_bus(hwdev, ret);
>> +		if (dma_coherent_ok(hwdev, *dma_handle, size)) {
>> +			memset(ret, 0, size);
>> +			return ret;
>> +		}
>
> Aren't we leaking the pages here?

Yes, that free_pages got lost somewhere in the rebases, I've added
it back.
