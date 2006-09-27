From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 27 Sep 2006 16:15:26 +0000
Subject: Re: __get_free_pages() problem on ia64
Message-Id: <20060927161526.GR5017@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1159283801.4407.16.camel@triumph>
In-Reply-To: <1159283801.4407.16.camel@triumph>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 27, 2006 at 09:11:37AM -0700, Luck, Tony wrote:
> > > Ok, thanks, I will look into it. But the question is why do I get
> > > addresses beyond 4G (virt_to_phys() of returned addresses) even when I
> > > use GFP_DMA. Is this a known problem on ia64?
> >
> > All memory is DMAable as we have an IOMMU.  ZONE_DMA doesn't mean what
> > you think it means.
> 
> You have an IOMMU ... but not all ia64 systems do (hence the need for swiotlb).

From the device driver's point of view, all ia64 systems have an IOMMU,
whether it be implemented in hardware (all sane systems) or software
(Intel ones).
