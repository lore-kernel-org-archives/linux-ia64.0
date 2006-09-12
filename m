From: Jack Steiner <steiner@sgi.com>
Date: Tue, 12 Sep 2006 13:34:57 +0000
Subject: Re: [PATCH 0/8] Optional ZONE_DMA V1
Message-Id: <20060912133457.GC10689@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Sep 11, 2006 at 03:27:29PM -0700, Christoph Lameter wrote:
> Optional ZONE_DMA
> 
> This patch follows up on the earlier work in Andrew's tree to reduce
> the number of zones. The patches allow to go to a minimum of 2 zones.
> This one allows also to make ZONE_DMA optional and therefore the
> number of zones can be reduced to one.
> 
> ZONE_DMA is usually used for ISA DMA devices. Typically modern hardware
> does not have any of these anymore. So we frequently do not need
> the zone anymore. The presence of an additional zone unnecessarily
> complicates VM operations. It must be scanned and balancing logic
> must operate in it etc etc. If one has a 1-1 correspondence between
> zones and nodes in a NUMA system then various other optimizations
> become possible.
> 
> Many systems today (especially 64 bit but also 32 bit machines with less
> than 4G of memory) can therefore operate just fine with a single zone.
> With a single zone various loops can be optimized away by the
> compiler. Many system currently do not place anything in ZONE_DMA. On
> most of my systems ZONE_DMA is completely empty. Why constantly look
> at an empty zone in /proc/zoneinfo and empty slab in /proc/slabinfo?
> Non i386 also frequently have no need for ZONE_DMA and zones stay
> empty.
> 
I'm missing something here. On Altix, currently ALL of the memory is reported
as being in the DMA zone:

	% cat /proc/budd*
	Node 0, zone      DMA   3015    116      4      1    ...
	Node 1, zone      DMA   4243    355     15      3    ...
	Node 2, zone      DMA   4384    113      6      4    ...

	% cat /proc/zoneinfo
	Node 0, zone      DMA
	  pages free     5868
	  ...

The DMA slabs are empty, though.

I assume your patch will switch Altix memory to a different zone, but what happens when
drivers specify GFP_DMA. 

-- jack
