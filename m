From: Jesse Barnes <jbarnes@sgi.com>
Date: Wed, 13 Oct 2004 19:28:21 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <200410131428.21615.jbarnes@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, October 13, 2004 2:07 pm, Luck, Tony wrote:
> >With this patch I got a significant improvement in page fault time.
> >Standard 2.4.x was about 700ns on average.  Generic 2.6.9rc4 is 3-4
> >usec, whereas the slabified pgtcache drops us back down to 600-700 ns.
>
> What was the benchmark you were running when you measured these?
>
> >Tested on zx1 and sn2.
>
> How does this scale on big sn2 systems? I assume that the answers are
> going to be just fine as the slab allocator per-cpu lists should be
> just as nice as local quicklists, but it would be nice to see some
> data.

Yeah, it would be interesting, though page faults in general don't scale very 
well due to the way page_table_lock is used.  Christoph had some patches for 
that, but I don't think he's had time to work on them lately.

> Overall looks nice ... less code, and goes faster too, what more
> could we ask for!
>
> Perhaps "zero_cache" isn't as descriptive a name as it might be (not
> that I have any better suggestions :-(

Maybe pgtable_zero_cache or something?

Jesse
