From: Jes Sorensen <jes@sgi.com>
Date: Tue, 12 Sep 2006 08:30:11 +0000
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
Message-Id: <yq0r6yhfpws.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Nick" = Nick Piggin <nickpiggin@yahoo.com.au> writes:

Nick> Christoph Lameter wrote:
>> On Tue, 12 Sep 2006, Nick Piggin wrote:
>>> I can't see from your patches, but what happens if someone asks
>>> for a GFP_DMA page or dma slab allocation when there is no
>>> ZONE_DMA?
>>> 
>>  The page/slab allocator will simply ignore the flag and return
>> ZONE_NORMAL memory. See gfp_zone().

Nick> That's wrong, I think? It should return NULL surely? (and
Nick> possibly do a printk telling the user they should enable
Nick> ZONE_DMA config, although some users have valid fallback
Nick> strategies).

That was what hit my mind first as well when I saw these patches. The
other issue is what about 64 bit machines that are trying to allocate
32 bit addresses because they are either out of IOMMU slots or needs
to allocate bounce buffers for swiotlb support?  Silently trying to
feed a device a 64 bit address could have some 'interesting' side
effects.

So I totally agree, GFP_DMA allocations really ought to fail in this
situation and we should fixup the users instead.

Cheers,
Jes
