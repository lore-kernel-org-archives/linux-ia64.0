From: Robin Holt <holt@sgi.com>
Date: Fri, 10 Sep 2004 11:31:37 +0000
Subject: Re: [RFC 2/2] Add SN2 Special Memory driver.
Message-Id: <20040910113137.GG25060@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040909175425.GB23863@lnx-holt.americas.sgi.com>
In-Reply-To: <20040909175425.GB23863@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> This allocator seems like a really big hammer for a fairly small nail.
> Since there has not really been a demonstrated need for an allocator
> that works on less than a page size, can we reimplement something like
> the page_alloc function and then later on, the entity needing an allocation
> of less than a page can write their own slab type allocator on top of
> this?
> 
> Are there any other suggestions besides me having to write a large allocator
> which will only be used to hand out page sized, page aligned chunks of
> memory?
> 

Since I can not mix cached an uncached references, I will need to work
with this memory as uncached.  The performance of this type allocator
will really stink.

Would it be better to handle the management functions using cached
structures with a physical address of the memory being allocated.
Is there any need inside the kernel for a virtual address?

Speaking for the fetchop driver, I know we only use physical addresses.
Will the MCA code ever need the virtual?

Thanks,
Robin
