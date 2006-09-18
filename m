From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 18 Sep 2006 13:54:16 +0000
Subject: Re: [PATCH 1/6] Deal with cases of ZONE_DMA meaning the first zone
Message-Id: <20060918135416.GA15096@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222734.4849.55947.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222734.4849.55947.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 11, 2006 at 03:27:34PM -0700, Christoph Lameter wrote:
> Optional DMA zone: Replace uses of ZONE_DMA as the first zone
> 
> In two places in the VM we use ZONE_DMA to refer to the first zone.
> If ZONE_DMA is optional then other zones may be first. So simply
> replace ZONE_DMA with zone 0.
> 
> This also fixes ZONETABLE_PGSHIFT. If we have only a single zone then
> ZONES_PGSHIFT may become 0 because there is no need anymore to encode the
> zone number related to a pgdat. However, we still need a zonetable to index
> all the zones for each node if this is a NUMA system. Therefore define
> ZONETABLE_SHIFT unconditionally as the offset of the ZONE field in page flags.

ACK.  This is a nice cleanup that should go in independent of what the fate
of the rest of the series is.

