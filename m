From: "DE-DINECHIN,CHRISTOPHE (HP-Cupertino,ex1)" <christophe_de-dinechin@hp.com>
Date: Fri, 11 May 2001 02:24:17 +0000
Subject: RE: [Linux-ia64] Kernel Bug
Message-Id: <marc-linux-ia64-105590693005568@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005565@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005565@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Apparently, I cannot reproduce the original BUG situation, sorry.

On my current kernel, a test case rebuilt from memory causes "Unable to
handle kernel paging request at VA ...". I believe that the code that
triggered it was an infinite loop on __get_free_page with the GFP_DMA flag,
until I would get NULL, followed by a matching loop to free the allocated
memory.

Unfortunately, since the code was simply to test what kind of physical
addresses I would get, I never checked it in my CVS tree, so I can't
guarantee that I'm exactly reproducing the original test case... And since
the case was seriously broken code anyways, I did not bother reporting the
issue either...


Christophe

-----Original Message-----
From: Maribasavaiah, Prasad [mailto:prasad.maribasavaiah@intel.com]
Sent: Thursday, May 10, 2001 5:05 PM
To: 'DE-DINECHIN,CHRISTOPHE (HP-Cupertino,ex1)';
'linux-ia64@linuxia64.org'
Subject: RE: [Linux-ia64] Kernel Bug


Chritophe,

Can tell me more about this?

Prasad
-----Original Message-----
From: DE-DINECHIN,CHRISTOPHE (HP-Cupertino,ex1)
[mailto:christophe_de-dinechin@hp.com]
Sent: Thursday, May 10, 2001 4:25 PM
To: 'Maribasavaiah, Prasad'; 'linux-ia64@linuxia64.org'
Subject: RE: [Linux-ia64] Kernel Bug


I don't know if this is the same thing, but I observed that on some older
kernels when trying to allocate all memory from a driver. I did not re-test
recently.

Christophe

-----Original Message-----
From: linux-ia64-admin@linuxia64.org
[mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Maribasavaiah,
Prasad
Sent: Thursday, May 10, 2001 2:12 PM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] Kernel Bug



We are getting kernel BUG message when running a stress test on Redhat Linux
Beta 1,  the message says bug at line 82 in page_alloc.c. The line 82 calls
function BUG().
When I looked at the function it is in __free_pages_ok().

The line 81 & 82 in the below function corresponds to 
if (page->buffers)
	BUG();

I would like to know is this a know issue or it is already fixed in the next
kernel?

static void __free_pages_ok (struct page *page, unsigned long order)
{
	unsigned long index, page_idx, mask, flags;
	free_area_t *area;
	struct page *base;
	zone_t *zone;

	/*
	 * Subtle. We do not want to test this in the inlined part of
	 * __free_page() - it's a rare condition and just increases
	 * cache footprint unnecesserily. So we do an 'incorrect'
	 * decrement on page->count for reserved pages, but this part
	 * makes it safe.
	 */
	if (PageReserved(page))
		return;

	if (page->buffers)
		BUG();
	if (page->mapping)
		BUG();
	if (!VALID_PAGE(page))
		BUG();
	if (PageSwapCache(page))
		BUG();
	if (PageLocked(page))
		BUG();
	if (PageDecrAfter(page))
		BUG();
	if (PageDirty(page))
		BUG();
	if (PageActive(page))
		BUG();
	if (PageInactiveDirty(page))
		BUG();
	if (PageInactiveClean(page))
		BUG();

	page->flags &= ~(1<<PG_referenced);
	page->age = PAGE_AGE_START;
	
	zone = page->zone;

	mask = (~0UL) << order;
	base = mem_map + zone->offset;
	page_idx = page - base;
	if (page_idx & ~mask)
		BUG();
	index = page_idx >> (1 + order);

	area = zone->free_area + order;

	spin_lock_irqsave(&zone->lock, flags);

	zone->free_pages -= mask;

	while (mask + (1 << (MAX_ORDER-1))) {
		struct page *buddy1, *buddy2;

		if (area >= zone->free_area + MAX_ORDER)
			BUG();
		if (!test_and_change_bit(index, area->map))
			/*
			 * the buddy page is still allocated.
			 */
			break;
		/*
		 * Move the buddy up one level.
		 */
		buddy1 = base + (page_idx ^ -mask);
		buddy2 = base + page_idx;
		if (BAD_RANGE(zone,buddy1))
			BUG();
		if (BAD_RANGE(zone,buddy2))
			BUG();

		memlist_del(&buddy1->list);
		mask <<= 1;
		area++;
		index >>= 1;
		page_idx &= mask;
	}
	memlist_add_head(&(base + page_idx)->list, &area->free_list);

	spin_unlock_irqrestore(&zone->lock, flags);

	/*
	 * We don't want to protect this variable from race conditions
	 * since it's nothing important, but we do want to make sure
	 * it never gets negative.
	 */
	if (memory_pressure > NR_CPUS)
		memory_pressure--;
}

void __free_pages(struct page *page, unsigned long order)
{
	if (put_page_testzero(page))
		__free_pages_ok(page, order);
}

void free_pages(unsigned long addr, unsigned long order)
{
	struct page *fpage;

#ifdef CONFIG_DISCONTIGMEM
	if (addr = 0) return;
#endif
	fpage = virt_to_page(addr);
	if (VALID_PAGE(fpage))
		__free_pages(fpage, order);
}


Prasad Maribasavaiah
DP CV Debug
Intel Corporation
Phone : (253) 371 4803




_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

