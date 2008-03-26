From: David Miller <davem@davemloft.net>
Date: Wed, 26 Mar 2008 23:21:43 +0000
Subject: Re: larger default page sizes...
Message-Id: <20080326.162143.244048620.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <87wsnrgg9q.fsf@basil.nowhere.org>
	<18409.56843.909298.717089@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.64.0803261052550.29859@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803261052550.29859@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: clameter@sgi.com
Cc: paulus@samba.org, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org

From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 26 Mar 2008 10:56:17 -0700 (PDT)

> One should emphasize that this test was a kernel compile which is not 
> a load that gains much from larger pages.

Actually, ever since gcc went to a garbage collecting allocator, I've
found it to be a TLB thrasher.

It will repeatedly randomly walk over a GC pool of at least 8MB in
size, which to fit fully in the TLB with 4K pages reaquires a TLB with
2048 entries assuming gcc touches no other data which is of course a
false assumption.

For some compiles this GC pool is more than 100MB in size.

GCC does not fit into any modern TLB using it's base page size.
