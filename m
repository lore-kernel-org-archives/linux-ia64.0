From: David Miller <davem@davemloft.net>
Date: Sun, 11 Mar 2007 20:59:46 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <20070311.135946.28788670.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

From: Christoph Lameter <clameter@sgi.com>
Date: Sat, 10 Mar 2007 18:09:23 -0800 (PST)

> Page table pages have the characteristics that they are typically zero
> or in a known state when they are freed. This is usually the exactly
> same state as needed after allocation. So it makes sense to build a list
> of freed page table pages and then consume the pages already in use
> first. Those pages have already been initialized correctly (thus no
> need to zero them) and are likely already cached in such a way that
> the MMU can use them most effectively.

I'm going to make the radical declaration that it be perhaps often
better to always initialize page table chunks to all zeros on
allocation.

The reason is that every time I've monitored the allocation patterns
of these things on SMP, the page table chunks always get released on a
different cpu than where they were initialized.

It's precisely suboptimal for a workload that forks off a lot of
very short lived jobs, watch what happens during runs of lmbench's
lat_proc for example.

The allocator side just does nothing but emit L2 cache line ownership
transactions as the pte page is touched.  Especially on chips like
PowerPC where zero initialization is absurdly cheap, we can avoid all
of the cache line transfers if we just initialize it at allocation
time.

Look, I like this trick too, sparc and sparc64 were the first Linux
platforms to implement page table caching about 8 years ago, but
I'm wondering whether it really makes sense any more.

