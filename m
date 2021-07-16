From: Robin Murphy <robin.murphy@arm.com>
Date: Fri, 16 Jul 2021 12:11:33 +0000
Subject: Re: [PATCH v1 14/16] x86/amd_gart: return error code from gart_map_sg()
Message-Id: <98c09e65-35d0-dde5-75fc-e3d99864d078@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210715164544.6827-1-logang@deltatee.com>
 <20210715164544.6827-15-logang@deltatee.com> <20210716063241.GC13345@lst.de>
In-Reply-To: <20210716063241.GC13345@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, iommu@lists.linux-foundation.org, linux-parisc@vger.kernel.org, xen-devel@lists.xenproject.org, Marek Szyprowski <m.szyprowski@samsung.com>, Stephen Bates <sbates@raithlin.com>, Martin Oliveira <martin.oliveira@eideticom.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Niklas Schnelle <schnelle@linux.ibm.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Michael Ellerman <mpe@ellerman.id.au>

On 2021-07-16 07:32, Christoph Hellwig wrote:
> On Thu, Jul 15, 2021 at 10:45:42AM -0600, Logan Gunthorpe wrote:
>> @@ -458,7 +460,7 @@ static int gart_map_sg(struct device *dev, struct scatterlist *sg, int nents,
>>   	iommu_full(dev, pages << PAGE_SHIFT, dir);
>>   	for_each_sg(sg, s, nents, i)
>>   		s->dma_address = DMA_MAPPING_ERROR;
>> -	return 0;
>> +	return ret;
> 
> While we're at it - setting the ->dma_address to DMA_MAPPING_ERROR is
> not part of the ->map_sg calling convention.  Might be worth to fix
> up while we're at it.

Especially since it's not even zeroing dma_length, which at least is a 
documented indicator of validity (even if it's not strictly defined for 
failure cases either).

Robin.
