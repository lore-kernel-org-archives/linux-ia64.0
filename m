From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 22 Nov 2004 23:13:25 +0000
Subject: Re: deferred rss update instead of sloppy rss
Message-Id: <Pine.LNX.4.58.0411221510470.24333@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>
 <20041122141148.1e6ef125.akpm@osdl.org> <Pine.LNX.4.58.0411221408540.22895@schroedinger.engr.sgi.com>
 <20041122144507.484a7627.akpm@osdl.org> <Pine.LNX.4.58.0411221444410.22895@schroedinger.engr.sgi.com>
 <41A271AE.7090802@yahoo.com.au>
In-Reply-To: <41A271AE.7090802@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, torvalds@osdl.org, benh@kernel.crashing.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 23 Nov 2004, Nick Piggin wrote:

> > The timer tick occurs every 1 ms. The maximum pagefault frequency that I
> > have  seen is 500000 faults /second. The max deviation is therefore
> > less than 500 (could be greater if page table lock / mmap_sem always held
> > when the tick occurs).
> I think that by the time you get the spilling code in, the mm-list method
> will be looking positively elegant!

I do not care what gets in as long as something goes in to address the
performance issues. So far everyone seems to have their pet ideas. By all
means do the mm-list method and post it. But we have already seen
objections by other against loops in proc. So that will also cause
additional controversy.
