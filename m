From: Christoph Hellwig <hch@lst.de>
Date: Tue, 04 Dec 2018 22:33:55 +0000
Subject: Re: [PATCH 01/23] dma-mapping: provide a generic DMA_MAPPING_ERROR
Message-Id: <20181204223355.GA12534@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de> <20181130132231.16512-2-hch@lst.de> <653ca801-63a1-3c19-ee09-ade19fa2bbb8@arm.com>
In-Reply-To: <653ca801-63a1-3c19-ee09-ade19fa2bbb8@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org

On Tue, Dec 04, 2018 at 04:41:34PM +0000, Robin Murphy wrote:
> I'd have been inclined to put the default check here, i.e.
>
> -	return 0
> +	return dma_addr = DMA_MAPPING_ERROR
>
> such that the callback retains full precedence and we don't have to deal 
> with the non-trivial removals immediately if it comes to it. Not that it 
> makes a vast difference though, so either way,

Ok, I've switched it around.
