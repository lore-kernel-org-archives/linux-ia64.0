From: Robin Holt <holt@sgi.com>
Date: Thu, 23 Sep 2004 23:01:52 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <20040923230152.GA6396@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 23, 2004 at 03:12:40PM -0700, Luck, Tony wrote:
> 
> >I am not sure what will be acceptable at this point.  Should I write
> >an uncached allocator which grabs the granules at boot time before they
> >are ever initialized for cacheable use?  If so, would it be acceptable
> >to just shrink each efi memory map entry by a command line specified
> >size during the efi_memmap_walk callout?  At this point I am so vague
> >on what I should be doing that I am afraid to do much of anything.
> 
> We already make adjustments to the efi memory map (to trim sections to
> granule boundaries) ... but another hack on top of the layers of ugliness
> there already is going to make things worse.  Perhaps someday we can
> delete it all and start over.
> 
> Grabbing your memory out of the map before any of the rest of Linux
> ever sees it sounds to be a good idea ... it avoids wasting memory
> for page structures in mem_map that can only get you into trouble
> if anyone ever looks at them.
> 
> If your allocator only needs a small number of pages from each node, then
> it is possible that you'd be able to feed it the trimmed off scraps
> from incomplete granules, rather than pull a whole granule.  So you
> might want to run your scan through the efi map before anyone else
> messes with it.

Sounds like I have a direction.  I will try to put together a patch
tomorrow morning to at least get the discussion started.

Thanks,
Robin
