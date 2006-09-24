From: Christoph Lameter <clameter@sgi.com>
Date: Sun, 24 Sep 2006 01:59:20 +0000
Subject: Re: IA64 without ZONE_DMA?
Message-Id: <Pine.LNX.4.64.0609231857340.16383@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 23 Sep 2006, Jes Sorensen wrote:

> If you want to take this path, are you then planning to move the < 4GB
> memory into ZONE_DMA32? We need a way to allocate memory within the
> 4GB zone for 32 bit DMA devices, especially on systems without an
> IOMMU. In fact, it's attractive to be able to get memory in the 4GB
> zone when possible even if a device supports DAC as it reduces the
> number of bus transactions since it can be done with a single address
> cycle instead of a dual.

IA64 has no ZONE_DMA32. ZONE_DMA has a 4GB boundary for some architectures
on IA64. The new page allocator call alloc_pages_range() would be able to 
allocate pages below the 4GB without having a ZONE_DMA (if necessary 
for 32 bit devices without proper IOMMU support).
