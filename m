From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 05 Jul 2007 03:54:27 +0000
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
Message-Id: <20070705125427.9a3b8e8b.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
	<468B3EAA.9070905@yahoo.com.au>
	<20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
	<468C51A7.3070505@yahoo.com.au>
	<20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
	<468C634D.9050306@yahoo.com.au>
In-Reply-To: <468C634D.9050306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com

On Thu, 05 Jul 2007 13:19:41 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> >> From what I can work out, it is something like "at this point the page
> >>should be uptodate, so at least the icache won't contain *inconsistent*
> >>data, just old data which userspace should take care of flushing if it
> >>modifies". Is that always true?
> > 
> >  
> > I think it's true. But, in this case, i-cache doesn't contain *incositent* data.
> > There are inconsistency between L2-Dcache and L3-mixed-cache. At L2-icache-miss,
> > a cpu fetches data from L3 cache.
> > This case seems defficult to be generalized...
> 
> If there is something in the icache line that isn't the last data to
> be stored at that address, isn't that inconsistent?
> 
Hmm..do we have a chance to add do_flush_cache_if_not_filled_by_dma(page)
before SetPageUptodate(page) ?

-Kame

