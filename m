From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Sep 2006 17:28:50 +0000
Subject: Re: [PATCH 5/6] Optional ZONE_DMA for x86_64
Message-Id: <Pine.LNX.4.64.0609121026040.11188@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222755.4849.17749.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060911222755.4849.17749.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Sep 2006, Andi Kleen wrote:

> > There are no drivers depending on CONFIG_ZONE_DMA32. If CONFIG_ZONE_DMA32
> > is not set then the system assumes that DMA devices are capable of
> > doing DMA to all of memory (which is mostly the case since most
> > x86_64 motherboards only allow a max of 4GB of memory and advanced
> > systems have DMA subsystems that handle I/O properly).
> 
> Pretty much all have this problem (or do you know of a system with no
> USB controller?) 

Most motherboards do not support more than 4GB ram.

> I think I would prefer to not make GFP_DMA32 optional.
> Adding a 4GB limit CONFIG to a 64bit kernel just seems somewhat
> dumb.

So is delivering motherboards for 64 bit with 4GB Ram.

> Also what happens when someone still sets GFP_DMA? 
> iirc the SCSI stack tended to do that for some structures.
> Will it fail?

No it will be ignored.

 > Making GFP_DMA optional would be an interesting
> experiment (I think it will break the floppies but other than that 
> a modern system might be fine). But it would be better

Right some drivers are not available anymore that includes the floppy 
driver.

> to warn the user stronger against it (most likely it will still
> break a lot of older addin cards) and tell them about
> the floppy.

I still have some dusty set of floppies in my attic. Tried to use floppy a 
year to boot but it was such a hassle that I fell back to a usb stick. 

You can still have your floppies. Just do not disable support for 
ZONE_DMA. Its enabled by default.

