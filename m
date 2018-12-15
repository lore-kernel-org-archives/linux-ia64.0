From: Guenter Roeck <linux@roeck-us.net>
Date: Sat, 15 Dec 2018 17:46:54 +0000
Subject: Re: [15/15] dma-mapping: bypass indirect calls for dma-direct
Message-Id: <20181215174654.GA25694@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-16-hch@lst.de>
In-Reply-To: <20181207190720.18517-16-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Hi,

On Fri, Dec 07, 2018 at 11:07:20AM -0800, Christoph Hellwig wrote:
> Avoid expensive indirect calls in the fast path DMA mapping
> operations by directly calling the dma_direct_* ops if we are using
> the directly mapped DMA operations.
> 

This patch results in arm64 boot failures. Reverting the patch fixes
the problem. Bisect results are attached. Per logs, the system fails
to instantiate the root device. Examples from two logs:

[   22.843080] nvme nvme0: pci function 0000:00:02.0
[   22.853820] nvme 0000:00:02.0: enabling device (0000 -> 0002)
[   22.884178] nvme nvme0: Removing after probe failure status: -12

[   15.451963] xhci_hcd 0000:00:02.0: xHCI Host Controller
[   15.453294] xhci_hcd 0000:00:02.0: new USB bus registered, assigned bus number 1
[   15.456042] xhci_hcd 0000:00:02.0: can't setup: -12
[   15.457003] xhci_hcd 0000:00:02.0: USB bus 1 deregistered
[   15.458340] xhci_hcd 0000:00:02.0: init 0000:00:02.0 fail, -12
[   15.458825] xhci_hcd: probe of 0000:00:02.0 failed with error -12

Guenter

---
# bad: [d14b746c6c1ca310f679ef13f661587454e2c588] Add linux-next specific files for 20181214
# good: [40e020c129cfc991e8ab4736d2665351ffd1468d] Linux 4.20-rc6
git bisect start 'HEAD' 'v4.20-rc6'
# bad: [ddfdda7f7d1ebdca0851f30a814e76749f08be99] Merge remote-tracking branch 'spi-nor/spi-nor/next'
git bisect bad ddfdda7f7d1ebdca0851f30a814e76749f08be99
# bad: [466d2f8b964745cc8db7f126607e19526385f2d5] Merge remote-tracking branch 'file-locks/locks-next'
git bisect bad 466d2f8b964745cc8db7f126607e19526385f2d5
# bad: [c43abf670f074a3eba2eebf9568ba95b2fe57f00] Merge remote-tracking branch 'arm-soc/for-next'
git bisect bad c43abf670f074a3eba2eebf9568ba95b2fe57f00
# good: [e4337d9d50eb940a25d3808ef76bb0eaa61a0146] Merge branch 'next/dt' into for-next
git bisect good e4337d9d50eb940a25d3808ef76bb0eaa61a0146
# bad: [32d851d8e81b1152d3e663b6c0b318474d649098] Merge remote-tracking branch 'dma-mapping/for-next'
git bisect bad 32d851d8e81b1152d3e663b6c0b318474d649098
# good: [32550839013d8e72d35c1cc0a756c818d7f9ae32] Merge remote-tracking branch 'scsi-fixes/fixes'
git bisect good 32550839013d8e72d35c1cc0a756c818d7f9ae32
# good: [8ea3ac17b6557f30697c624d1cd4ff2b30af82e1] Merge remote-tracking branch 'kbuild/for-next'
git bisect good 8ea3ac17b6557f30697c624d1cd4ff2b30af82e1
# good: [ad78dee0b630527bdfed809d1f5ed95c601886ae] dma-debug: Batch dma_debug_entry allocation
git bisect good ad78dee0b630527bdfed809d1f5ed95c601886ae
# good: [55897af63091ebc2c3f239c6a6666f748113ac50] dma-direct: merge swiotlb_dma_ops into the dma_direct code
git bisect good 55897af63091ebc2c3f239c6a6666f748113ac50
# good: [7d32be2e5abb2d88cf321357178d05c461b1cc83] leaking_addresses: do not parse binary files
git bisect good 7d32be2e5abb2d88cf321357178d05c461b1cc83
# good: [9db33987ee2e5abb32a40dca44a2953391786833] leaking_addresses: remove version number
git bisect good 9db33987ee2e5abb32a40dca44a2953391786833
# good: [7fd0d1346c1f96371a9a4996a590b86d570098f9] Merge remote-tracking branch 'leaks/leaks-next'
git bisect good 7fd0d1346c1f96371a9a4996a590b86d570098f9
# bad: [356da6d0cde3323236977fce54c1f9612a742036] dma-mapping: bypass indirect calls for dma-direct
git bisect bad 356da6d0cde3323236977fce54c1f9612a742036
# good: [190d4e5916a2d70a11009022b968fca948fb5dc7] vmd: use the proper dma_* APIs instead of direct methods calls
git bisect good 190d4e5916a2d70a11009022b968fca948fb5dc7
# first bad commit: [356da6d0cde3323236977fce54c1f9612a742036] dma-mapping: bypass indirect calls for dma-direct
