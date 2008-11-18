From: John Keller <jpk@sgi.com>
Date: Tue, 18 Nov 2008 14:08:11 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <200811181408.mAIE8BHH057134@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20081117173930.35342b31@hale.suse.de> from "Bernhard Walle" at Nov 17, 2008 05:39:30 PM
References: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bernhard Walle <bwalle@suse.de>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> 
> * John Keller [2008-11-17 10:24]:
> >
> > Create a platform specific version of dma_get_required_mask()
> > for ia64 SN Altix. All SN Altix platforms support 64 bit DMA
> > addressing regardless of the size of system memory.
> > Create a ia64 machvec for dma_get_required_mask, with the
> > SN version unconditionally returning DMA_64BIT_MASK.
> 
> Maybe we should then switch the ia64_platform_is("sn2")
> in check_crashkernel_memory() to dma_get_required_mask() =
> DMA_64BIT_MASK because that's basically what the check is about.
> 
> BTW: What about UV?
> 
> 
> Regards,
> Bernhard
> -- 
> Bernhard Walle, SUSE Linux Products GmbH, Architecture Development
> 


This patch addresses a problem on SN Altix systems with < 4GB, where
device drivers using the dma_get_required_mask() API would be told
to use 32 bit DMA, when 64 bit is more efficient.

How exactly the use of dma_get_required_mask() relates to the crash
kernel code you refer to is unclear to me.

If, for all platforms, the crash kernel code could use the mask returned
from dma_get_required_mask() to do its check, then switching the code
might be OK. But, if that's not possible for some platforms, then I'd
wonder if dma_get_required_mask() is being used in the wrong context in
this case.

For UV systems, the default/generic dma_get_required_mask() will be used,
returning a value based on the size of system memory.

John
