From: David Brownell <david-b@pacbell.net>
Date: Sat, 06 Mar 2004 16:37:43 +0000
Subject: Re: [linux-usb-devel] Re: serious 2.6 bug in USB subsystem?
Message-Id: <4049FE57.2060809@pacbell.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <200310272235.h9RMZ9x1000602@napali.hpl.hp.com>	<20031028013013.GA3991@kroah.com>	<200310280300.h9S30Hkw003073@napali.hpl.hp.com>	<3FA12A2E.4090308@pacbell.net>	<16289.29015.81760.774530@napali.hpl.hp.com>	<16289.55171.278494.17172@napali.hpl.hp.com>	<3FA28C9A.5010608@pacbell.net>	<16457.12968.365287.561596@napali.hpl.hp.com>	<404959A5.6040809@pacbell.net> <16457.26208.980359.82768@napali.hpl.hp.com>
In-Reply-To: <16457.26208.980359.82768@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Greg KH <greg@kroah.com>, vojtech@suse.cz, linux-usb-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, pochini@shiny.it

David Mosberger wrote:

>   David.B> The reason I keep ending up thinking that readl-elimination
>   David.B> must be OK (me agreeing with Martin) is that the memory
>   David.B> there came from dma_alloc_coherent() ... so if anything's
>   David.B> wrong, it'd be at most lack of rmb(), not a stale-cache
>   David.B> kind of thing.
> 
> It's not an issue of DMA coherency, it's an issue of DMA vs. interrupt
> ordering.  I believe the WHD interrupt is arriving at the CPU before

Which is what I sketched to Martin, as the reason to be interested
in a patch that was equivalent to your second patch.

Unfortunately that doesn't check out as being "the" fix here.
Martin still saw the problem.  (And I don't see how it'd be
what gave me several hard lockups ... but it didn't work either,
and the day before, without that change, no lockup.)


> the DMA update to the HCCA is done.  In my second patch, the readl()
> at the beginning of the interrupt ensures that the DMA update to
> the HCCA is completed before the readl() returns data.

DMA-coherent memory is defined as "memory for which a write by either
the device or the processor can immediately be read by the processor
or device without having to worry about caching effects."  Such a
write-buffering mechanism is clearly a type of (write-)caching effect,
and readl() would be a kind of dma_rmb(), if you will.  I suspect the
docs are wrong about what dma-coherent means.


> If this is correct, then the first patch is probably a better
> approach:
> 
> ...
> -	ed->tick = OHCI_FRAME_NO(ohci->hcca) + 1;
> +	ed->tick = OHCI_FRAME_NO(ohci->hcca) + 2;
> ..
> 
> This actually makes tons of sense if you think of it like jiffies: you
> need to make sure you delay at least one full frame-interval.  

Right, I had that theory too.  As I reported, it doesn't check out
as the only issue.  Plus, even assuming it's correct, adding another
millisecond slows down some common operations even more.  I'd rather
just slow down just the "right" paths, rather than all of them ... :)

- Dave





