From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 16 Dec 2004 01:44:22 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151743070.14617@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 15 Dec 2004, Linus Torvalds wrote:

> It's easy to only scrub pages above a certain order, by just looking at
> the buddy order lists. No locking even required, ie you could do something
> like
>
> 	for (order = min_order ; order < MAX_ORDER; order++) {
> 		struct free_area *area = zone->free_area + order;
> 		struct list_head *n = area->free_list.prev;
>
> 		/* This is opportunistic, with no locking */
> 		barrier();
> 		if (n = area->free_list)
> 			continue;
> 		p = list_entry(n, struct page, lru);
> 		/* Already pre-zeroed? */
> 		if (p->flags & PAGE_PREZERO)
> 			continue;
>
> 		/* Ok, found a possible candidate, now we need to be more careful */
> 		spin_lock_irqsave(&zone->lock, flags);
> 		.. re-do the tests,
> 		   remove the page from the list,
> 		   drop the lock,
> 		   clear the page,
> 		   mark it zeroed,
> 		   get the lock,
> 		   put the page at the head of the list
> 		...
>
> No?

Yes that is what my patch does. I am missing the barrier though. Why would
that be needed?


