From: akepner@sgi.com
Date: Tue, 21 Aug 2007 21:37:07 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <20070821213707.GH5592@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com> <46C94FD5.6000006@sgi.com> <20070821193522.GD5592@sgi.com> <20070821201631.GF9163@parisc-linux.org>
In-Reply-To: <20070821201631.GF9163@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Jes Sorensen <jes@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

On Tue, Aug 21, 2007 at 02:16:32PM -0600, Matthew Wilcox wrote:
> 
> So, let me try to understand ... your hardware allows writes from the
> device to pass other writes from the device?  Doesn't that violate the
> PCI spec?  I'm thinking about this (page 43 of PCI 2.3):
> ....

I should have stated this more carefully, but it's not a PCI reordering 
that's being addressed here, it's a reordering that can occur within 
the NUMA-interconnect. 

-- 
Arthur

