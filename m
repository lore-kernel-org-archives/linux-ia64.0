From: Jack Steiner <steiner@sgi.com>
Date: Tue, 27 Apr 2004 21:31:57 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <20040427213157.GA8270@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 27, 2004 at 12:50:16PM -0700, David Mosberger wrote:
> >>>>> On Tue, 27 Apr 2004 09:24:41 -0500, Jack Steiner <steiner@sgi.com> said:
> 
>   Jack> On Tue, Apr 27, 2004 at 05:52:28AM -0500, Robin Holt wrote:
>   >> On Mon, Apr 26, 2004 at 05:03:23PM -0700, David Mosberger wrote:
>   >> > >>>>> On Mon, 26 Apr 2004 16:35:55 -0500, Robin Holt <holt@sgi.com> said:
>   >> > Are you just re-stating my caveat about memory-attribute-aliasing or
>   >> > are you saying something else?  If the latter, I'm not following.  If
>   >> > the former, I certainly agree: memory attribute-aliasing leads to
>   >> > really nasty-to-track-down bugs.  Hence, you want to make sure
>   >> > _upfront_ that it doesn't occur.
> 
>   >> Restating.  Don't you love the person who plays the master of the obvious
>   >> role.  I started writing the email and was at the same time looking for
>   >> examples of kernel code from 2.4 which we had found that was speculating
> 
>   Jack> IIRC, one place that got us in trouble in 2.4 was in
>   Jack> free_one_pgd(). The code prefetches a dirty cacheline that is
>   Jack> one cache line BEYOND the end of the PT page. The line is
>   Jack> marked dirty (prefetchw()) in the cache even though the
>   Jack> function does not actually modify it. The line will
>   Jack> subsequently be written back to memory. If the following page
>   Jack> is in the same granule & is being used uncached
>   Jack> (memory-attribute-aliasing), bad things will happen......
> 
> Yes, of course.  Violating a correctness requirement (no
> memory-attribute aliasing) can cause bad things to happen.  Duh.

Maybe I was not clear. I *know* that memory attribute aliasing is a bad
thing to do. I was commenting on Robin's mail and providing a real-life
example on where/how it causes problems. Prefetching is a perfectly
valid thing for the cpu to do. Any time there is a valid TLB entry, prefetching
can & will happen. DONT allow a TLB entry to cover both cached &
uncached pages.


> 
> I don't mean this as a criticism.  I only want to be clear that the
> bug here was caused by ignoring a correctness requirement ("no
> attribute aliasing").  The kernel is perfectly entitled to prefetch
> any address of its choosing.  In fact, even without explicit data
> prefetches, you'll get implicit code prefetching (not to mention
> speculative loads when using a modern compiler).
> 
> The moral of the story: we're not kidding when we say memory-attribute
> aliasing needs to be taken seriously.  (And it's not an ia64-only
> concern, as the nasty AGP-related attribute-aliasing bug revealed on
> Linux for certain x86 CPUs.)
> 
> 	--david

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


