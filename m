From: Bernhard Walle <bwalle@suse.de>
Date: Sun, 23 Nov 2008 13:37:22 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <20081123143722.03dbbfcc@kopernikus.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081117173930.35342b31@hale.suse.de>
	<200811181408.mAIE8BHH057134@fcbayern.americas.sgi.com>
In-Reply-To: <200811181408.mAIE8BHH057134@fcbayern.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

[Sorry for the late reply and for not following the whole thread, I'm
just busy.]

* John Keller [2008-11-18 08:08]:
> 
> This patch addresses a problem on SN Altix systems with < 4GB, where
> device drivers using the dma_get_required_mask() API would be told
> to use 32 bit DMA, when 64 bit is more efficient.
> 
> How exactly the use of dma_get_required_mask() relates to the crash
> kernel code you refer to is unclear to me.

I'm not sure myself. The crashkernel reservation code on IA64 (for
other architectures I don't know any machines that have basically their
whole memory except a small amount which is used for booting mapped
above 4 GiB physical address space) needs to check if it's okay to
use memory for the crashkernel that is *all* above 4 GiB.

This is only possible if a hardware IO/MMU is present (and working
correctly in the kdump case which isn't the case on HP IA64) and SWIOTBL
is not used because SWIOTBL needs some memory below that 4 GiB margin.

Now I thought that there's a relationship between "memory above 4 GiB
can be used for DMA" and the return value of dma_get_required_mask().
My assumption was:

  (dma_get_required_mask() & 0xffffffff00000000ull) > 0
  -> memory above 4 GiB can be used for DMA and so the
     crashkernel memory can reside above 4 GiB

  (dma_get_required_mask() & 0xffffffff00000000ull) = 0
  -> memory above 4 GiB can not be used for DMA and so the
     crashkernel memory can not all reside above 4 GiB

Is that wrong?

> If, for all platforms, the crash kernel code could use the mask returned
> from dma_get_required_mask() to do its check, then switching the code
> might be OK. But, if that's not possible for some platforms, then I'd
> wonder if dma_get_required_mask() is being used in the wrong context in
> this case.

The crashkernel reservation code is different for every platform, so it
does not matter. However, in theory I think the check would return
correct results.


Regards,
Bernhard
-- 
Bernhard Walle, SUSE LINUX Products GmbH, Architecture Development
