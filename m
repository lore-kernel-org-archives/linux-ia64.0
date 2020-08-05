From: Jessica Clarke <jrtc27@debian.org>
Date: Wed, 05 Aug 2020 20:27:51 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <62A3A375-6B2C-431B-BEAD-EDC23FDEC987@debian.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 5 Aug 2020, at 20:43, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de> wrote:
> 
> Hi Christoph!
> 
> On 8/5/19 9:10 AM, Christoph Hellwig wrote:
>> Seems like we dropped the ball on this..
>> 
>> Did I give you a patch like this (for 5.2 and probably earlier, won't
>> apply to 5.3-rc) to test before as that is anther idea?
>> 
>> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
>> index 2c2772e9702a..e471158c7c6e 100644
>> --- a/kernel/dma/direct.c
>> +++ b/kernel/dma/direct.c
>> @@ -119,7 +119,8 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
>> 		}
>> 	}
>> 	if (!page)
>> -		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
>> +		page = alloc_pages_node(local_memory_node(dev_to_node(dev)),
>> +				gfp, page_order);
>> 
>> 	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
>> 		__free_pages(page, page_order);
> 
> I just applied this patch on top of 4.19.137 and it's crashing with this trace
> when trying to load the "hpsa" module. It definitely looks like an issue with
> dma_direct_alloc():

My guess is dev_to_node gave NUMA_NO_NODE for a random PCI device. Try:

    int nid = dev_to_node(dev);
    if (nid >= 0)
        nid = local_memory_node(nid);

and then pass nid to alloc_pages_node instead.

Jess
