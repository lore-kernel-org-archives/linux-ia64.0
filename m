From: Anton Blanchard <anton@samba.org>
Date: Sun, 14 Mar 2004 04:06:34 +0000
Subject: Re: [Lse-tech] Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040314040634.GC19737@krispykreme>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com> <20040313034840.GF4638@wotan.suse.de> <20040313184547.6e127b51.akpm@osdl.org>
In-Reply-To: <20040313184547.6e127b51.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Andi Kleen <ak@suse.de>, raybry@sgi.com, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org


> Demand-paging the hugepages is a decent feature to have, and ISTR resisting
> it before for this reason.
> 
> Even though it's early in the 2.6 series I'd be a bit worried about
> breaking existing hugetlb users in this way.  Yes, the pages are
> preallocated so it is unlikely that a working setup is suddenly going to
> break.  Unless someone is using the return value from mmap to find out how
> many pages they can get.

Hmm what a coincidence, I was chasing a problem where large page
allocations would fail even though I clearly had enough large page memory
free.

It turns out we were tripping the overcommit logic in do_mmap. I had
30GB of large page and 2GB of small pages and of course cap_vm_enough_memory
was looking at the small page pool. Setting overcommit to 1 fixed it.

It seems we can solve both problems by having a separate hugetlb overcommit
policy. Make it strict and you wont have OOM problems on large pages
and I wont hit my 30GB / 2GB problem.

Anton
