From: Christoph Hellwig <hch@lst.de>
Date: Fri, 11 Sep 2020 07:14:29 +0000
Subject: Re: [PATCH 09/12] dma-direct: remove __dma_to_phys
Message-Id: <20200911071429.GE22394@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908164758.3177341-1-hch@lst.de> <20200908164758.3177341-10-hch@lst.de> <5d797c06-401d-62b1-f144-ea6e9a5144dd@arm.com>
In-Reply-To: <5d797c06-401d-62b1-f144-ea6e9a5144dd@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, iommu@lists.linux-foundation.org, Tomasz Figa <tfiga@chromium.org>, Joerg Roedel <joro@8bytes.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org

On Thu, Sep 10, 2020 at 02:26:03PM +0100, Robin Murphy wrote:
> On 2020-09-08 17:47, Christoph Hellwig wrote:
>> There is no harm in just always clearing the SME encryption bit, while
>> significantly simplifying the interface.
>
> After a 10-minute diversion into "but hang on, force_dma_unencrypted() is 
> meaningful on PPC and S390 too..." before realising that it all does just 
> come back to __sme_clr(), which is indeed a no-op for everyone other than 
> AMD, any simplification of this mess is indeed welcome :)
>
> Unless I've massively misunderstood how SME is supposed to work,

Exactly.  This weird encryption bit in AMD SME causes all kinds of harm,
and I'm glad no one picked it up.  I've also been wondering if we
should change the interface to explicit set/clear the bit, but I'll
leave that for another pass as fixing up the SME interfaces would turn
into a massive disgression.
