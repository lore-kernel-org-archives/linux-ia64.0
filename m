From: James Bottomley <James.Bottomley@steeleye.com>
Date: Mon, 15 Mar 2004 21:48:34 +0000
Subject: Re: [PATCH] move consistent_dma_mask to the generic device
Message-Id: <1079387315.1804.38.camel@mulgrave>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403151439.20917.bjorn.helgaas@hp.com>
In-Reply-To: <200403151439.20917.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2004-03-15 at 16:39, Bjorn Helgaas wrote:
> The patch that moved and renamed consistent_dma_mask neglected
> to fix up arch/ia64/hp/common/sba_iommu.c.  I think we need the
> attached patch (booted, but not otherwise tested):

How did that happen?  I thought I fixed up all of sba_iommu, oh well.

erm, the patch is a bit redundant isn't it?

&to_pci_dev(dev)->dev = dev

James


