From: Rohit Seth <rohitseth@google.com>
Date: Wed, 02 May 2007 00:36:27 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <1178066187.19466.69.camel@galaxy.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704281830.l3SIUqOo004230@smtp.corp.google.com>
	 <463728EB.8030308@yahoo.com.au>
In-Reply-To: <463728EB.8030308@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2007-05-01 at 21:47 +1000, Nick Piggin wrote:
> Rohit Seth wrote:
> >
> > 
> > It is invalidating any entries (containing same physical address) in both I
> > and D caches.  Any dirty lines in D cache are written back to memory before
> > getting invalidated (ofcourse).
> 
> OK. (should it be issuing both fc and fc.i to be robust in case a
> new implementation doesn't flush the dcache with fc.i?)
> 

For the Itanium case specifically, you only want to invalidate a stale
icache line.  Once that is done, next time icache will pick the correct
updated contents.

> 
> >>There are supposedly no icache lines at that point[**]:
> > 
> > 
> > For this bug to trigger there has to be a (stale) entry in icache containing
> > the old contents of a page that just got updated by kernel as explicit
> > copying of data (DMAs are coherent on ia64, meaning if a device were to
> > write to memory then architecture guarnatees that both I and D caches are
> > invalidated).
> 
> So if we have a dirty dcache line for a given physical address,
> it will _always_ be the case that a subsequent icache load will
> find that dirty data?

yes for ia64.

-rohit

