From: Jes Sorensen <jes@sgi.com>
Date: Wed, 22 Aug 2007 07:44:32 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <46CBE960.4090702@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com> <46C94FD5.6000006@sgi.com> <20070821193522.GD5592@sgi.com> <20070821201631.GF9163@parisc-linux.org>
In-Reply-To: <20070821201631.GF9163@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: akepner@sgi.com, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

Matthew Wilcox wrote:
> So, let me try to understand ... your hardware allows writes from the
> device to pass other writes from the device?  Doesn't that violate the
> PCI spec?  I'm thinking about this (page 43 of PCI 2.3):

Hi Matthew,

Yes I believe this behavior on sn2 is 'bending' the PCI spec a bit. The
problem is that the NUMA fabric is a routed network in itself so there
can be multiple paths between the device and the physical memory it DMAs
to/from.

Cheers,
Jes
