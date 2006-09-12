From: Andi Kleen <ak@suse.de>
Date: Tue, 12 Sep 2006 06:40:22 +0000
Subject: Re: [PATCH 5/6] Optional ZONE_DMA for x86_64
Message-Id: <200609120840.22808.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222755.4849.17749.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222755.4849.17749.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday 12 September 2006 00:27, Christoph Lameter wrote:
> x86_64: optional ZONE_DMA/ZONE_DMA32
>
> Allow the use to specify CONFIG_ZONE_DMA32 and CONFIG_ZONE_DMA (via
> CONFIG_GENERIC_ISA_DMA).
>
> If CONFIG_ZONE_DMA is off then devices requiring ISA DMA can no
> longer be selected.
>
> There are no drivers depending on CONFIG_ZONE_DMA32. If CONFIG_ZONE_DMA32
> is not set then the system assumes that DMA devices are capable of
> doing DMA to all of memory (which is mostly the case since most
> x86_64 motherboards only allow a max of 4GB of memory and advanced
> systems have DMA subsystems that handle I/O properly).

Pretty much all have this problem (or do you know of a system with no
USB controller?) 

I think I would prefer to not make GFP_DMA32 optional.
Adding a 4GB limit CONFIG to a 64bit kernel just seems somewhat
dumb.

Also what happens when someone still sets GFP_DMA? 
iirc the SCSI stack tended to do that for some structures.
Will it fail?

Making GFP_DMA optional would be an interesting
experiment (I think it will break the floppies but other than that 
a modern system might be fine). But it would be better
to warn the user stronger against it (most likely it will still
break a lot of older addin cards) and tell them about
the floppy.

BTW we still call it x86-64, not x64.

-Andi
