From: Christoph Hellwig <hch@lst.de>
Date: Mon, 28 May 2018 08:39:31 +0000
Subject: Re: [PATCH 7/7] x86: switch the VIA 32-bit DMA quirk to use the struct device flag
Message-Id: <20180528083931.GA7169@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180525143512.1466-1-hch@lst.de> <20180525143512.1466-8-hch@lst.de> <alpine.DEB.2.21.1805280808280.1585@nanos.tec.linutronix.de> <20180528061859.GA4145@lst.de> <alpine.DEB.2.21.1805280817310.1585@nanos.tec.linutronix.de> <20180528062725.GA4309@lst.de> <alpine.DEB.2.21.1805280823240.1585@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1805280823240.1585@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Christoph Hellwig <hch@lst.de>, Ingo Molnar <mingo@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, netdev@vger.kernel.org

On Mon, May 28, 2018 at 08:23:35AM +0200, Thomas Gleixner wrote:
> > > They remove the commandline switch before having the replacement in place
> > > unless I'm misreading something.
> > 
> > The command line switch to force 32-bit dma is removed without
> > replacement.   The PCI quirk for force the 32-bit dma for VIA bridges
> > is kept in place, and switch to a different mechanism in this patch.
> 
> Fair enough

Thanks.  Do you want me to repost them for the x86 tree, or should
just pull the changes with the commit logs fixed to the dma-mapping
tree?
