From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Apr 2004 14:24:41 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <20040427142441.GA19680@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 27, 2004 at 05:52:28AM -0500, Robin Holt wrote:
> On Mon, Apr 26, 2004 at 05:03:23PM -0700, David Mosberger wrote:
> > >>>>> On Mon, 26 Apr 2004 16:35:55 -0500, Robin Holt <holt@sgi.com> said:
> > 
> > 
> > Are you just re-stating my caveat about memory-attribute-aliasing or
> > are you saying something else?  If the latter, I'm not following.  If
> > the former, I certainly agree: memory attribute-aliasing leads to
> > really nasty-to-track-down bugs.  Hence, you want to make sure
> > _upfront_ that it doesn't occur.
> 
> Restating.  Don't you love the person who plays the master of the obvious
> role.  I started writing the email and was at the same time looking for
> examples of kernel code from 2.4 which we had found that was speculating

IIRC, one place that got us in trouble in 2.4 was in free_one_pgd(). The code
prefetches a dirty cacheline that is one cache line BEYOND the
end of the PT page. The line is marked dirty (prefetchw()) in the cache even 
though the function does not actually modify it. The line will subsequently be
written back to memory. If the following page is in the same granule &
is being used uncached (memory-attribute-aliasing), bad things will
happen......





> addresses and was going to hopefully point out how difficult it was
> for us to track down.  Unfortunately, I never found the bugs in our
> internal bug tracking system.  I am not sure we ever actually found
> the source of the corruption, only that it was occuring.
> 
> Sorry,
> Robin Holt
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


