From: Christoph Hellwig <hch@lst.de>
Date: Tue, 25 Jun 2019 10:47:02 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <20190625104702.GA2569@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 25, 2019 at 12:46:39PM +0200, Frank Scheiner wrote:
> Do you suspect a firmware issue? Because the firmware of that machine is
> actually quite old (the model was retired in 2015):

No, probably something in the Linux ia64-specific code.

>>   	if (!page)
>> -		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
>> +		page = alloc_pages(gfp, page_order);
>>
>>   	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
>>   		__free_pages(page, page_order);
>>
>
> Ok, will try that patch - actually (1) in addition or (2) without the
> first one?

Instead.
