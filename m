From: Andrew Morton <akpm@osdl.org>
Date: Sat, 11 Dec 2004 00:18:35 +0000
Subject: Re: page fault scalability patch V12 [0/7]: Overview and
Message-Id: <20041210161835.5b0b0828.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041210141258.491f3d48.akpm@osdl.org>
	<Pine.LNX.4.44.0412102346470.521-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0412102346470.521-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh@veritas.com>
Cc: clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hugh Dickins <hugh@veritas.com> wrote:
>
> On Fri, 10 Dec 2004, Andrew Morton wrote:
> > Hugh Dickins <hugh@veritas.com> wrote:
> > >
> > > > > (I do wonder why do_anonymous_page calls mark_page_accessed as well as
> > > > > lru_cache_add_active.  The other instances of lru_cache_add_active for
> > > > > an anonymous page don't mark_page_accessed i.e. SetPageReferenced too,
> > > > > why here?  But that's nothing new with your patch, and although you've
> > > > > reordered the calls, the final page state is the same as before.)
> > 
> > The point is a good one - I guess that code is a holdover from earlier
> > implementations.
> > 
> > This is equivalent, no?
> 
> Yes, it is equivalent to use SetPageReferenced(page) there instead.
> But why is do_anonymous_page adding anything to lru_cache_add_active,
> when its other callers leave it at that?  What's special about the
> do_anonymous_page case?

do_swap_page() is effectively doing the same as do_anonymous_page(). 
do_wp_page() and do_no_page() appear to be errant.
