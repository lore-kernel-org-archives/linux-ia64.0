From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 25 Mar 2005 05:22:02 +0000
Subject: Re: [PATCH] pte prefetching
Message-Id: <42439FFA.7040300@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <424269B9.9020306@yahoo.com.au>
In-Reply-To: <424269B9.9020306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
>>>>>>On Thu, 24 Mar 2005 18:18:17 +1100, Nick Piggin <nickpiggin@yahoo.com.au> said:
> 
> 
>   Nick> After applying the recent freepgt patchset from Hugh (on
>   Nick> lkml), the time to fork+exit a process mapping 64GB of address
>   Nick> (32MB of page tables) is 0.471s. With the prefetch patch, this
>   Nick> drops to 0.357s.
> 

Sorry, above numbers were wrong:
0.118s versus 0.089s. Improvement ratio is the same, I just used the
wrong divisor.

> Looks like a nice improvement to me.
> 
> Does prefetching 1 line ahead give the best results?  That's only
> 128/8 PTEs.  Assuming a 200 cycle latency, this would allow
> for only 12.5 cycles/iteration.  Especially for large (NUMA) machines,
> prefetching further out might help more.
> 

Hmm... yeah it may do. Although I don't think that changes your cycles
/ iteration ratio, does it? Just allows for for a little bit more
variation.

I just retested, and prefetching 2 lines ahead gives virtually the same
performance.

But actually, my tests are set up so each pte page has only a single
'present' pte (I did it that way to speed up initial faulting time).
So the loop will almost always get stopped by the pte_none tests. So
perhaps that is able to complete in close to or less than 12 cycles.

Nick

