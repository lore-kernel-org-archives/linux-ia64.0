From: Christopher Wedgwood <cw@sgi.com>
Date: Thu, 17 Jul 2003 17:57:55 +0000
Subject: Re: [PATCH] (2.4.21-bjorn-bk) Minimalist PAL mapping for SN2
Message-Id: <marc-linux-ia64-105846473611128@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105832171829546@msgid-missing>
In-Reply-To: <marc-linux-ia64-105832171829546@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 17, 2003 at 11:42:23AM -0600, Bjorn Helgaas wrote:

> - I hate to clutter the generic efi.c with so much platform-
> specific stuff.

Me too.  I tried hard to make this simply in the generic code at the
cost of code-duplication and ugliness.  I figured simple-less-elegant
wins this time since it's __init code and we throw it away.

That said, at some point this should become non __init code for
hot-swap CPUs but I'd like to ignore that for now.

>   What are the implications of making this a platform vector?  I
>   don't see any obvious dependencies that prevent us from doing
>   machvec_init() earlier.

It's too early on to have the machvec stuff setup otherwise I would so
this.  I did consider doing phyiscal calls to abstract this but it
makes the code larger and more complex --- the current code means the
only issue is a strncmp in the generic path and then we drop out to
core where I assume non-SN2 people don't care much about.

What about the above check or something more generic and I'll move the
offending code to arch/ia64/sn/kernel/* then?

> As Tony mentioned, you might want to verify that there's nothing
> else in the granule that requires run-time mapping.

I had code to do this previously for a generic implementation so there
was no SN2 specific hack.  DavidM had a look at this and said he would
prefer an approach less invasive.

The patch submitted was mostly to make it obvious what generic code
was affect so that people can mentaly verify that only SN2 was
affected by this.

> If there are different cacheability attributes within a granule,
> efi_memmap_walk should remove the granule from efi_memmap.  Do you
> see that happening?

Yes.

>   I guess since PAL is mapped with a TR, we probably can live
>   without it being in the EFI memmap, but since we use the memmap to
>   validate accesses to /dev/mem, the wrong thing will probably
>   happen if you try to read the PAL space.

This does happen which is why I cache the PAL bounds.  The trim code
runs after the boot-CPUs PAL mapping.

As some point I'd like to restructure the efi code and various things
that use it but I'm far to short on cycles to even contemplate this so
its definately a 2.7.x project I would guess.  Part of the reason for
this desire is probably idealistic and unimportant and thus merits a
different discussion altogether.

So how about the strncmp as above and I'll hide the code elsewhere as
a compromise?


  --cw
