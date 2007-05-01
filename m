From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 01 May 2007 11:43:29 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <463727E1.3090203@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704281805.l3SI5JQx030827@smtp.corp.google.com>
In-Reply-To: <200704281805.l3SI5JQx030827@smtp.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rohit Seth <rohitseth@google.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Rohit Seth wrote:
>  
> 
> -----Original Message-----
> From: Hugh Dickins [mailto:hugh@veritas.com] 
> Sent: Friday, April 27, 2007 10:20 PM
> To: Nick Piggin
> Cc: rohitseth@google.com; Mike Stroyan; Andrew Morton; Luck, Tony;
> linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
> 
> On Sat, 28 Apr 2007, Nick Piggin wrote:
> 
>>OIC, you need a virtual address to evict the icache, so you can't 
>>flush at flush_dcache time? Or does ia64 have an instruction to flush 
>>the whole icache? (it would be worth testing, to see how much 
>>performance suffers).
> 
> 
> IIRC, there is a PAL call to flush the whole cache (but that is quite a
> heavy call).  Though you really don't need to be doing this.
> 
> 
>>I'm puzzled by that remark: the ia64 flush_icache_range always has a 
>>virtual address, it uses the kernel virtual address; it takes 
>>no interest in whether there's a user virtual address.
> 
> 
> Caches on Itanium are physical.  So, it doesn't matter what virtual address
> you use to flush a cache line, cache line containing specific physical
> memory will be flushed. 

Really? I was under the vague impression that L1 i/d caches were virtual
and required this flushing... but I guess so long as the ISA says that
fc/fc.i flushes all caches corresponding to the physical address of the
provided virtual address, then that's what matters.

> For the cases where you have virtual caches,
> update_mmu_cache is the API to use.

But it happens after the pte is installed.

-- 
SUSE Labs, Novell Inc.
