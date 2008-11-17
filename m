From: Bernhard Walle <bwalle@suse.de>
Date: Mon, 17 Nov 2008 16:39:30 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <20081117173930.35342b31@hale.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, John Keller <jpk@sgi.com>

* John Keller [2008-11-17 10:24]:
>
> Create a platform specific version of dma_get_required_mask()
> for ia64 SN Altix. All SN Altix platforms support 64 bit DMA
> addressing regardless of the size of system memory.
> Create a ia64 machvec for dma_get_required_mask, with the
> SN version unconditionally returning DMA_64BIT_MASK.

Maybe we should then switch the ia64_platform_is("sn2")
in check_crashkernel_memory() to dma_get_required_mask() =
DMA_64BIT_MASK because that's basically what the check is about.

BTW: What about UV?


Regards,
Bernhard
-- 
Bernhard Walle, SUSE Linux Products GmbH, Architecture Development
