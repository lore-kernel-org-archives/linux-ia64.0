From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 01 Jan 2005 02:22:04 +0000
Subject: Re: Increase page fault rate by prezeroing V1 [2/3]: zeroing and
Message-Id: <41D6094C.3040908@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com> <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412211156090.1313@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0412211156090.1313@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Robin Holt <holt@sgi.com>, Adam Litke <agl@us.ibm.com>, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@vger.kernel.org, linux-kernel@vger.kernel.org

Christoph Lameter wrote:
> o Add page zeroing
> o Add scrub daemon
> o Add ability to view amount of zeroed information in /proc/meminfo
> 

I quite like how you're handling the page zeroing now. It seems
less intrusive and cleaner in its interface to the page allocator
now.

I think this is pretty close to what I'd be happy with if we decide
to go with zeroing.

Just one small comment - there is a patch in the -mm tree that may
be of use to you; mm-keep-count-of-free-areas.patch is used later
by kswapd to handle and account higher order free areas properly.
You may be able to use it to better implement triggers/watermarks
for the scrub daemon.

Also...

> +
> +/*
> + * zero_highest_order_page takes a page off the freelist
> + * and then hands it off to block zeroing agents.
> + * The cleared pages are added to the back of
> + * the freelist where the page allocator may pick them up.
> + */
> +int zero_highest_order_page(struct zone *z)
> +{
> +	int order;
> +
> +	for(order = MAX_ORDER-1; order >= sysctl_scrub_stop; order--) {
> +		struct free_area *area = z->free_area[NOT_ZEROED] + order;
> +		if (!list_empty(&area->free_list)) {
> +			struct page *page = scrubd_rmpage(z, area, order);
> +			struct list_head *l;
> +
> +			if (!page)
> +				continue;
> +
> +			page->index = order;
> +
> +			list_for_each(l, &zero_drivers) {
> +				struct zero_driver *driver = list_entry(l, struct zero_driver, list);
> +				unsigned long size = PAGE_SIZE << order;
> +
> +				if (driver->start(page_address(page), size) = 0) {
> +
> +					unsigned ticks = (size*HZ)/driver->rate;
> +					if (ticks) {
> +						/* Wait the minimum time of the transfer */
> +						current->state = TASK_INTERRUPTIBLE;
> +						schedule_timeout(ticks);
> +					}
> +					/* Then keep on checking until transfer is complete */
> +					while (!driver->check())
> +						schedule();
> +					goto out;
> +				}

Would you be better off to just have a driver->zero_me(...) call, with this
logic pushed into those like your BTE which need it? I'm thinking this would
help flexibility if you had say a BTE-thingy that did an interrupt on
completion, or if it was done synchronously by the CPU with cache bypassing
stores.

Also, would there be any use in passing a batch of pages to the zeroing driver?
That may improve performance on some implementations, but could also cut down
the inefficiency in your timeout mechanism due to timer quantization (I guess
probably not much if you are only zeroing quite large areas).

BTW, that while loop is basically a busy-wait. Not a critical problem, but you
may want to renice scrubd to the lowest scheduling priority to be a bit nicer?
(I think you'd want to do that anyway). And put a cpu_relax() call in there?

Just some suggestions.

Nick
