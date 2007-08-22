From: Jes Sorensen <jes@sgi.com>
Date: Wed, 22 Aug 2007 17:03:07 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <46CC6C4B.1030202@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com>	 <200708220903.23702.jbarnes@virtuousgeek.org>	 <1187801095.3410.49.camel@localhost.localdomain>	 <200708220951.05101.jbarnes@virtuousgeek.org> <1187802272.3410.58.camel@localhost.localdomain>
In-Reply-To: <1187802272.3410.58.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, akepner@sgi.com, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

James Bottomley wrote:
> I really don't think a work around for a PCI spec violation belongs in
> the generic DMA code, do you?  The correct fix for this should be to set
> the device hints to strict ordering, which presumably altix respects?
> In which case, it sounds like what needs exposing are access to the PCI
> device hints.  I believe both PCI-X and PCIe have these hints as
> optional specifiers in the bridges, so it should be in a current Rev of
> the PCI spec.  Or are you proposing adding an additional PCI API that
> allows transaction flushes to be inserted into the stream for devices
> and bridges that have already negotiated relaxed ordering? ... in which
> case we need to take this to the PCI list.

James,

I don't believe it respects those hints - I agree, it's a pita, but
thats the state of the situation. Even if it did, it would make
performance suck as Jesse also pointed out.

As I pointed out in my email to Willy is that the NUMA fabric is routed,
there's not one path through the system, which is what makes this
happen.

Jes
