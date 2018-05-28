From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 28 May 2018 06:07:57 +0000
Subject: Re: [PATCH 5/7] x86: remove the experimental forcesac boot option
Message-Id: <alpine.DEB.2.21.1805280807180.1585@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de> <20180525143512.1466-6-hch@lst.de>
In-Reply-To: <20180525143512.1466-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

On Fri, 25 May 2018, Christoph Hellwig wrote:

x86/pci-dma: ...

Please

> Limiting the dma mask to avoid PCI (pre-PCIe) DAC cycles while paying
> the huge overhead of an IOMMU is rather pointless, and this seriously
> gets in the way of dma mapping work.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
 
