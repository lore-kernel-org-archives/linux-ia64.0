From: Linus Torvalds <torvalds@osdl.org>
Date: Thu, 16 Dec 2004 01:18:50 +0000
Subject: Re: [very very drafty] prezeroing to increase the page fault rate
Message-Id: <Pine.LNX.4.58.0412151706390.3279@ppc970.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412141832350.6975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Wed, 15 Dec 2004, Christoph Lameter wrote:
> 
> The current patch triggers a hardware zeroing device to start zeroing when
> the buddy allocator generates a free pages over a certain order.  The
> order can be configured in /proc/sys/vm/zero_order. This has just minimum
> impact on the system (main impact is that the buddy allocator can no
> longer merge locked free pages) apart from the system bus.
> 
> We could change the idle zeroing to a scrubd which would be
> controlled by a similar mechanism. Set the minimal order to be scrubbed in
> /proc/sys/vm/scrub_order?

Yes. Along with some minimal system inactivity threshold or similar, along
with a way to trigger it actively. For example, there might be loads that
just _know_ that they are doing to do a lot of this, and having a way for
them to say "hey, I'll need a ton of pre-zeroed pages" just sounds like a
good idea if we are going to do this at all.

It's easy to only scrub pages above a certain order, by just looking at
the buddy order lists. No locking even required, ie you could do something 
like

	for (order = min_order ; order < MAX_ORDER; order++) {
		struct free_area *area = zone->free_area + order;
		struct list_head *n = area->free_list.prev;

		/* This is opportunistic, with no locking */
		barrier();
		if (n = area->free_list)
			continue;
		p = list_entry(n, struct page, lru);
		/* Already pre-zeroed? */
		if (p->flags & PAGE_PREZERO)
			continue;

		/* Ok, found a possible candidate, now we need to be more careful */
		spin_lock_irqsave(&zone->lock, flags);
		.. re-do the tests,
		   remove the page from the list,
		   drop the lock,
		   clear the page,
		   mark it zeroed,
		   get the lock, 
		   put the page at the head of the list 
		...

No?

		Linus
