From: Christoph Hellwig <hch@lst.de>
Date: Tue, 12 Apr 2022 06:21:20 +0000
Subject: Re: [PATCH 10/15] swiotlb: add a SWIOTLB_ANY flag to lift the low memory restriction
Message-Id: <20220412062120.GA7796@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220404050559.132378-1-hch@lst.de> <20220404050559.132378-11-hch@lst.de> <Yk4vfAd0J5u+wUsq@char.us.oracle.com>
In-Reply-To: <Yk4vfAd0J5u+wUsq@char.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Wed, Apr 06, 2022 at 08:25:32PM -0400, Konrad Rzeszutek Wilk wrote:
> > diff --git a/arch/powerpc/platforms/pseries/svm.c b/arch/powerpc/platforms/pseries/svm.c
> > index c5228f4969eb2..3b4045d508ec8 100644
> > --- a/arch/powerpc/platforms/pseries/svm.c
> > +++ b/arch/powerpc/platforms/pseries/svm.c
> > @@ -28,7 +28,7 @@ static int __init init_svm(void)
> >  	 * need to use the SWIOTLB buffer for DMA even if dma_capable() says
> >  	 * otherwise.
> >  	 */
> > -	swiotlb_force = SWIOTLB_FORCE;
> > +	ppc_swiotlb_flags |= SWIOTLB_ANY | SWIOTLB_FORCE;
> 
> This is the only place you set the ppc_swiotlb_flags.. so I wonder why
> the '|=' instead of just '=' ?

Preparing for setting others and not clobbering the value.
