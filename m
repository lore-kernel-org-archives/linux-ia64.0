From: Christoph Lameter <clameter@sgi.com>
Date: Sat, 23 Sep 2006 01:38:43 +0000
Subject: Re: IA64 without ZONE_DMA?
Message-Id: <Pine.LNX.4.64.0609221837310.10851@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 23 Sep 2006, KAMEZAWA Hiroyuki wrote:

> looks atractive :) But how to use it ? the devices(codes) can know their
> necessary and available address range on any platform ?

Yes. The PCI DMA layer can provide that information with the dma_mask.

And the good thing is that this is independent of how an architecture sets 
up their ZONE_DMA.


