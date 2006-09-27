From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Sep 2006 16:11:37 +0000
Subject: RE: __get_free_pages() problem on ia64
Message-Id: <617E1C2C70743745A92448908E030B2A932AF3@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1159283801.4407.16.camel@triumph>
In-Reply-To: <1159283801.4407.16.camel@triumph>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Ok, thanks, I will look into it. But the question is why do I get
> > addresses beyond 4G (virt_to_phys() of returned addresses) even when I
> > use GFP_DMA. Is this a known problem on ia64?
>
> All memory is DMAable as we have an IOMMU.  ZONE_DMA doesn't mean what
> you think it means.

You have an IOMMU ... but not all ia64 systems do (hence the need for swiotlb).

-Tony
