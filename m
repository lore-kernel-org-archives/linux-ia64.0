From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 20 Nov 2004 00:56:13 +0000
Subject: Re: pte bit spin lock
Message-Id: <419E962D.4010801@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <419D9911.1080306@yahoo.com.au>
In-Reply-To: <419D9911.1080306@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
>>I was wondering if it might be possible to change arch/ia64/kernel/ivt.S
>>routines that modify pte access bits, to first take a "spin 
>>lock bit" in the pte before any other modifications to it, and clear the 
>>lock bit when done?
> 
> 
> Possible?  Anything is possible.  Is it a good idea?  I don't know, you'd

OK that's a good start.

> need some benchmark data to show which applications win, and which lose.
> Obviously this spin-lock-bit will make some operations that are now cheap
> become much more expensive ... whether you have an overall win would
> depend on a lot of factors.
> 

Yes it will, you're right. It adds an extra atomic rmw operation to pte
manipulation in place of the page table lock. So in practice, it won't
be much different on single-pte operations like page faults, but the
batched operation 'copy_page_range' will suffer.

zap_pte_range, while being a batched operation, must currently also do an
atomic operation per-pte (so it doesn't lose the dirty bit), so this
doesn't suffer any extra atomic ops.

But the copy_page_range issue seems to cost about 7% on lmbench fork
which is fairly significant (with i386 using pte cmpxchg; pte locks
shouldn't be worse than cmpxchg, hopefully cheaper if anything).

I don't think you will see significant contention on the pte lock, so the
cost to ivt.S should be essentially an extra atomic op. But this could
mean that subsequent modification of the pte accessed bits need not be
atomic RMWs as seems to be the case there now.

But anyway it is not very productive to try to extrapolate results to ia64,
so yes it would need to be carefully tested.

> 
>>And second question, a pte's memory doesn't ever get updated 
>>transparently by the hardware on ia64, does it?
> 
> 
> No.  The h/w VHPT walker on ia64 only _reads_ page tables, all updates
> (setting dirty bits) are done by s/w in ivt.S or elsewhere in Linux.
> 

Thanks.
