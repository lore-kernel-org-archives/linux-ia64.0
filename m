From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 14 Dec 2004 23:24:39 +0000
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-Id: <1103066679.5420.33.camel@npiggin-nld.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com>
	 <9250000.1103050790@flay>  <20041214191348.GA27225@wotan.suse.de>
In-Reply-To: <20041214191348.GA27225@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org

On Tue, 2004-12-14 at 20:13 +0100, Andi Kleen wrote:
> On Tue, Dec 14, 2004 at 10:59:50AM -0800, Martin J. Bligh wrote:
> > > NUMA systems running current Linux kernels suffer from substantial
> > > inequities in the amount of memory allocated from each NUMA node
> > > during boot.  In particular, several large hashes are allocated
> > > using alloc_bootmem, and as such are allocated contiguously from
> > > a single node each.
> > 
> > Yup, makes a lot of sense to me to stripe these, for the caches that
> 
> I originally was a bit worried about the TLB usage, but it doesn't
> seem to be a too big issue (hopefully the benchmarks weren't too
> micro though)
> 

I wonder if you could have an indirection table for the hash, which
may allow you to allocate the hash memory from discontinuous, per
node chunks? Wouldn't the extra pointer chase be a similar cost to
incurring TLB misses when using the vmalloc scheme?

That _may_ help with relocating hashes for hotplug as well (although
I expect the hard part may be synchronising access).

Probably too ugly. Just an idea though.


