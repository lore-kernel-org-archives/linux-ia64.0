From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 14 Jan 2005 04:59:02 +0000
Subject: Re: page table lock patch V15 [0/7]: overview II
Message-Id: <1105678742.5402.109.camel@npiggin-nld.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <41E5AFE6.6000509@yahoo.com.au>
	 <20050112153033.6e2e4c6e.akpm@osdl.org> <41E5B7AD.40304@yahoo.com.au>
	 <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com>
	 <41E5BC60.3090309@yahoo.com.au>
	 <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
	 <20050113031807.GA97340@muc.de>
	 <Pine.LNX.4.58.0501130907050.18742@schroedinger.engr.sgi.com>
	 <20050113180205.GA17600@muc.de>
	 <Pine.LNX.4.58.0501131701150.21743@schroedinger.engr.sgi.com>
	 <20050114043944.GB41559@muc.de>  <m14qhkr4sd.fsf_-_@muc.de>
In-Reply-To: <m14qhkr4sd.fsf_-_@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: clameter@sgi.com, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org

On Fri, 2005-01-14 at 05:52 +0100, Andi Kleen wrote:
> Andi Kleen <ak@muc.de> writes:
> > As you can see cmpxchg is slightly faster for the cache hot case,
> > but incredibly slow for cache cold (probably because it does something
> > nasty on the bus). This is pretty consistent to Intel and AMD CPUs.
> > Given that page tables are likely more often cache cold than hot 
> > I would use the lazy variant. 
> 
> Sorry, my benchmark program actually had a bug (first loop included
> page faults). Here are updated numbers. They are somewhat different:
> 
> Athlon 64:
> readpte hot 25
> readpte cold 171
> readpte_cmp hot 18
> readpte_cmp cold 162
> 
> Nocona:
> readpte hot 118
> readpte cold 443
> readpte_cmp hot 22
> readpte_cmp cold 224
> 
> The difference is much smaller here.  Assuming cache cold cmpxchg8b is
> better, at least on the Intel CPUs which have a slow rmb().
> 

I have a question for the x86 gurus. We're currently using the lock
prefix for set_64bit. This will lock the bus for the RMW cycle, but
is it a prerequisite for the atomic 64-bit store? Even on UP?



Find local movie times and trailers on Yahoo! Movies.
http://au.movies.yahoo.com
