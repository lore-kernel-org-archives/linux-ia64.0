From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 02 Sep 2004 16:16:43 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <200409020916.43718.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, September 2, 2004 9:10 am, Randolph Chung wrote:
> > > If DISCONTIGMEM now works properly, I think VIRTUAL_MEM_MAP can
> > > disappear.
> >
> > Except that the former uses the latter, and that won't change without a
> > bit more work.  Even then, CONFIG_NUMA and CONFIG_DISCONTIGMEM are
> > somewhat intertwined at this point, so using the discontig code to deal
> > with a zx1 memory layout isn't a good match.
>
> fwiw we recently implemented CONFIG_DISCONTIGMEM for parisc-linux to better
> support N-class (and pa8800, which uses zx1). You are right that
> CONFIG_NUMA and CONFIG_DISCONTIGMEM are a bit intertwined, but it can be
> made to work
>
> :)
>
> For reference we are targetting these three memory layouts:
>  * Astro: 0-3.75, 67.75-68, 4-64
>  * zx1: 0-1, 257-260, 4-256
>  * Stretch (N-class): 0-2, 4-32, 34-xxx
>
> Astro and Stretch have been verified (up to 32GB, so 3 zones), zx1
> verification is still pending, but i don't see why it wouldn't work (famous
> last words? :)

Are you creating the whole memmap and then freeing up the holes?  IIRC that's 
what's done for x86 NUMA boxes, but that won't work if the inital memmap is 
too big to fit in memory in the first place.

Jesse
