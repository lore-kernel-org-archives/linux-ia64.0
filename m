From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 05 Aug 2009 08:19:59 +0000
Subject: Re: [PATCH 4/4] Bug Fix drivers/pci/intel-iommu.c: convert pfn_lo
Message-Id: <1249460399.9324.350.camel@macbook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <bug-504363-150293@bugzilla.redhat.com>
	 <200908042017.n74KHsNw018095@bz-web1.app.phx.redhat.com>
	 <20090804221119.GA21544@linux-os.sc.intel.com>
In-Reply-To: <20090804221119.GA21544@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fenghua Yu <fenghua.yu@intel.com>
Cc: Tony Luck <tony.luck@intel.com>, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2009-08-04 at 15:11 -0700, Fenghua Yu wrote:
> The iova->pfn_lo should be converted to VTD page address before it's passed to
> iommu_flush_dev_iotlb().
> 
> This issue may cause DMA failure on PAGE_SIZE>VTD_PAGE_SIZE platforms e.g. ia64
> platforms.
> 
> Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

I think this one is wrong. We allocate IOVA space in MM pages, not DMA
pages -- so the pfn_lo is an MM page already, and shifting by PAGE_SHIFT
is the right thing to do.

(I could be tempted to allocate it in DMA pages instead, but that's a
different story).

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

