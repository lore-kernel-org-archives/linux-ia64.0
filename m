From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 12 Sep 2006 00:35:19 +0000
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
Message-Id: <450600C7.7090801@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote:
> Make ZONE_DMA optional in core code.
> 
> - ifdef definitions for ZONE_DMA and related code following
>   the example for ZONE_DMA32 and ZONE_HIGHMEM.
> 
> - Without ZONE_DMA, ZONE_HIGHMEM and ZONE_DMA32 we get to a
>   ZONES_SHIFT of 0.
> 
> - Modify the VM statistics to work correctly without a DMA
>   zone.
> 
> - Modify slab to not create DMA slabs if there is no
>   ZONE_DMA.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Nice. Looks like it should remove a bit of overhead.

I can't see from your patches, but what happens if someone asks
for a GFP_DMA page or dma slab allocation when there is no ZONE_DMA?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
