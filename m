From: Jes Sorensen <jes@sgi.com>
Date: Sat, 23 Sep 2006 20:05:33 +0000
Subject: Re: IA64 without ZONE_DMA?
Message-Id: <yq08xkacprm.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Christoph" = Christoph Lameter <clameter@sgi.com> writes:

Christoph> There is code in Andrews tree that allows getting rid of
Christoph> ZONE_DMA. I know that SGI machines do not use ZONE_DMA. I
Christoph> looked through the arch code and I do not see ZONE_DMA or
Christoph> GFP_DMA uses that I cannot account for. However, I am not
Christoph> familiar with the code for other IA64 platforms.

Christoph> This patch will make IA64 have a single zone in each
Christoph> node. As a result loops are unrolled, various VM macros can
Christoph> be optimized further and the memory load balancing code
Christoph> between different zones in one node is no longer
Christoph> necessary. Note that having no ZONE_DMA means that GFP_DMA
Christoph> will be ignored. If you know of any devices depending on
Christoph> ZONE_DMA (memory returned must be below 4GB) then we first
Christoph> need to deal with those possibly by modifying
Christoph> dma_alloc_coherent functions to obtain memory in a
Christoph> different way than via GFP_DMA.

If you want to take this path, are you then planning to move the < 4GB
memory into ZONE_DMA32? We need a way to allocate memory within the
4GB zone for 32 bit DMA devices, especially on systems without an
IOMMU. In fact, it's attractive to be able to get memory in the 4GB
zone when possible even if a device supports DAC as it reduces the
number of bus transactions since it can be done with a single address
cycle instead of a dual.

Jes
