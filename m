From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 28 May 2018 06:10:40 +0000
Subject: Re: [PATCH 7/7] x86: switch the VIA 32-bit DMA quirk to use the struct device flag
Message-Id: <alpine.DEB.2.21.1805280808280.1585@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de> <20180525143512.1466-8-hch@lst.de>
In-Reply-To: <20180525143512.1466-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

n Fri, 25 May 2018, Christoph Hellwig wrote:

x86/pci-dma: ...

Please

> Instead of globally disabling > 32bit DMA using the arch_dma_supported
> hook walk the PCI bus under the actually affected bridge and mark every
> device with the dma_32bit_limit flag.  This also gets rid of the
> arch_dma_supported hook entirely.

Shouldn't this go before the other two? 
 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
