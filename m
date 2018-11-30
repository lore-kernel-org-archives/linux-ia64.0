From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Fri, 30 Nov 2018 18:59:20 +0000
Subject: Re: remove the ->mapping_error method from dma_map_ops V3
Message-Id: <20181130185920.GG30658@n2100.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181130132231.16512-1-hch@lst.de>
In-Reply-To: <20181130132231.16512-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, x86@kernel.org, Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org, Jon Mason <jdmason@kudzu.us>, xen-devel@lists.xenproject.org, David Woodhouse <dwmw2@infradead.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, Nov 30, 2018 at 02:22:08PM +0100, Christoph Hellwig wrote:
> Error reporting for the dma_map_single and dma_map_page operations is
> currently a mess.  Both APIs directly return the dma_addr_t to be used for
> the DMA, with a magic error escape that is specific to the instance and
> checked by another method provided.  This has a few downsides:
> 
>  - the error check is easily forgotten and a __must_check marker doesn't
>    help as the value always is consumed anyway
>  - the error checking requires another indirect call, which have gotten
>    incredibly expensive
>  - a lot of code is wasted on implementing these methods
> 
> The historical reason for this is that people thought DMA mappings would
> not fail when the API was created, which sounds like a really bad
> assumption in retrospective, and then we tried to cram error handling
> onto it later on.
> 
> There basically are two variants:  the error code is 0 because the
> implementation will never return 0 as a valid DMA address, or the error
> code is all-F as the implementation won't ever return an address that
> high.  The old AMD GART is the only one not falling into these two camps
> as it picks sort of a relative zero relative to where it is mapped.
> 
> The 0 return doesn't work for direct mappings that have ram at address
> zero and a lot of IOMMUs that start allocating bus space from address
> zero, so we can't consolidate on that, but I think we can move everyone
> to all-Fs, which the patch here does.  The reason for that is that
> there is only one way to ever get this address: by doing a 1-byte long,
> 1-byte aligned mapping, but all our mappings are not only longer but
> generally aligned, and the mappings have to keep at least the basic
> alignment.
> 
> A git tree is also available here:
> 
>     git://git.infradead.org/users/hch/misc.git dma-mapping-error.3

Hi Chris,

For patches 1, 3 and 23,

Acked-by: Russell King <rmk+kernel@armlinux.org.uk>

Thanks.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
