From: Robin Holt <holt@sgi.com>
Date: Wed, 13 Oct 2004 19:49:29 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <20041013194929.GA11320@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Oct 13, 2004 at 03:32:43PM -0400, Martin K. Petersen wrote:
> >>>>> "Tony" = Luck, Tony <tony.luck@intel.com> writes:
> 
> Tony,
> 
> Tony> What was the benchmark you were running when you measured these?
> 
> I'm going to let Robin send you his test case.

Martin, can you send your updated test case.  I believe yours is just mine
with a higher resolution timer.  If you are uncomfortable with that, let
me know.

> 
> 
> Tony> How does this scale on big sn2 systems? I assume that the
> Tony> answers are going to be just fine as the slab allocator per-cpu
> Tony> lists should be just as nice as local quicklists, but it would
> Tony> be nice to see some data.
> 
> The tests above are from a 64-way Altix.
> 
> I'm still looking into the issue of freed data ending up in other
> nodes' slabs.  Don't know if anybody else have been working on this?

When I tried to measure these on a large multi-threaded job, the difference
got lost in the noise.

> 
> 
> >> The biggest caveat is that I've had to postpone setting up the gate
> >> page until the pgt slab has been initialized.  That wasn't an issue
> >> with the existing page-based allocation scheme.  David - how do you
> >> prefer I handle this?
> 
> Tony> I don't see the code for this postponement in this patch.
> 
> It's there.  End of the mm/init.c hunk.
> 
> 
> Tony> Perhaps "zero_cache" isn't as descriptive a name as it might be
> Tony> (not that I have any better suggestions :-(
> 
> Yeah, this is what Bill called it on ppc64.  pgtable_cache perhaps?

If we are renaming things, can we rename zero_ctor to something a little
more sensible.
> 
> -- 
> Martin K. Petersen	Wild Open Source, Inc.
> mkp@wildopensource.com	http://www.wildopensource.com/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
