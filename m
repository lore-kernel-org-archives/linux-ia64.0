From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 12 Mar 2007 11:12:32 +0000
Subject: Re: [QUICKLIST 0/6] Arch independent quicklists V1
Message-Id: <Pine.LNX.4.64.0703120409150.25910@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070311020923.19905.49260.sendpatchset@schroedinger.engr.sgi.com>
 <20070311.135946.28788670.davem@davemloft.net>
In-Reply-To: <20070311.135946.28788670.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, ak@suse.com, holt@sgi.com, linux-ia64@vger.kernel.org, mpm@selenic.com

On Sun, 11 Mar 2007, David Miller wrote:

> I'm going to make the radical declaration that it be perhaps often
> better to always initialize page table chunks to all zeros on
> allocation.

That is the case if most of the page is going to be used soon. If we have 
sparse access patterns then not zeroing can avoid uselessly bringing 
cachelines in.

> The reason is that every time I've monitored the allocation patterns
> of these things on SMP, the page table chunks always get released on a
> different cpu than where they were initialized.

But its even advantageous in that case for sparse allocs.
 
> The allocator side just does nothing but emit L2 cache line ownership
> transactions as the pte page is touched.  Especially on chips like
> PowerPC where zero initialization is absurdly cheap, we can avoid all
> of the cache line transfers if we just initialize it at allocation
> time.

We have no need to touch all the cache lines w/o initialization if we 
alloc from the quicklist. And that is a performance benefit.

