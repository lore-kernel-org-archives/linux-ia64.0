From: Bob Picco <bob.picco@hp.com>
Date: Fri, 04 Nov 2005 00:10:39 +0000
Subject: Re: [PATCH] fix memory less node allocation
Message-Id: <20051104001039.GC22938@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051029212305.GA6019@localhost.localdomain>
In-Reply-To: <20051029212305.GA6019@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Thu Nov 03 2005, 05:33:53PM EST]
> -	if (!ptr)
> -		panic("NO memory for memory less node\n");
> 
> Why did you drop this panic?  Although your patch now
> makes sure to never try to alloc from a memory less
> node ... surely it is still possible (though unlikely)
> that the call to __alloc_bootmem_node() might fail. A
> panic here might be easier to debug than letting it run
> until fill_pernode() does a memset(__va(0), 0, ...).
> 
> -Tony
I dropped it because it seemed redundant. __alloc_bootmem_node calls 
__alloc_bootmem_node_limit who calls __alloc_bootmem_core for this
node. Should __alloc_bootmem_core core fail, then call __alloc_bootmem_limit.
__alloc_bootmem_limit attempts to allocate from any node. Should 
__alloc_bootmem_limit (old name __alloc_bootmem)  fail, then it panics.

bob
