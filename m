From: Thomas Gleixner <tglx@linutronix.de>
Date: Mon, 28 May 2018 06:08:19 +0000
Subject: Re: [PATCH 6/7] x86: remove the explicit nodac and allowdac option
Message-Id: <alpine.DEB.2.21.1805280808030.1585@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de> <20180525143512.1466-7-hch@lst.de>
In-Reply-To: <20180525143512.1466-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

On Fri, 25 May 2018, Christoph Hellwig wrote:

x86/pci-dma: ...

Please

> This is something drivers should decide (modulo chipset quirks like
> for VIA), which as far as I can tell is how things have been handled
> for the last 15 years.
> 
> Note that we keep the usedac option for now, as it is used in the wild
> to override the too generic VIA quirk.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
