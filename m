From: Christoph Lameter <christoph@engr.sgi.com>
Date: Tue, 12 Sep 2006 18:05:53 +0000
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
Message-Id: <Pine.LNX.4.64.0609121102170.11481@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Sep 2006, Nick Piggin wrote:

> Christoph Lameter wrote:
> > On Tue, 12 Sep 2006, Nick Piggin wrote:
> > > I can't see from your patches, but what happens if someone asks
> > > for a GFP_DMA page or dma slab allocation when there is no ZONE_DMA?
> > The page/slab allocator will simply ignore the flag and return ZONE_NORMAL
> > memory. See gfp_zone().
> That's wrong, I think? It should return NULL surely? (and possibly do
> a printk telling the user they should enable ZONE_DMA config, although
> some users have valid fallback strategies).

Ignoring GFP_DMA is consistent with how GFP_DMA32 and GFP_HIGHMEM ar 
treated.

There are subsystems that sporadically set GFP_DMA and the earlier 
patchset was so full of #ifdefs because it attempted to cover all cases.

ZONE_DMA must be enabled if a device drivers relies on ISA DMA or 
GENERIC DMA. Otherwise we do not allow the selection of the driver.

We could add a BUG in gfp_zone which will give us all locations.




