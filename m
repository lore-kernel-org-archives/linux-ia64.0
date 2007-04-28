From: Rohit Seth <rohitseth@google.com>
Date: Sat, 28 Apr 2007 18:05:09 +0000
Subject: RE: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <200704281805.l3SI5JQx030827@smtp.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0704280616470.9554@blonde.wat.veritas.com>
References: <20070426001615.GA8908@ldl.fc.hp.com>
In-Reply-To: <20070426001615.GA8908@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Hugh Dickins' <hugh@veritas.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

 

-----Original Message-----
From: Hugh Dickins [mailto:hugh@veritas.com] 
Sent: Friday, April 27, 2007 10:20 PM
To: Nick Piggin
Cc: rohitseth@google.com; Mike Stroyan; Andrew Morton; Luck, Tony;
linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path

On Sat, 28 Apr 2007, Nick Piggin wrote:
> 
> OIC, you need a virtual address to evict the icache, so you can't 
> flush at flush_dcache time? Or does ia64 have an instruction to flush 
> the whole icache? (it would be worth testing, to see how much 
> performance suffers).

IIRC, there is a PAL call to flush the whole cache (but that is quite a
heavy call).  Though you really don't need to be doing this.

>I'm puzzled by that remark: the ia64 flush_icache_range always has a 
>virtual address, it uses the kernel virtual address; it takes 
>no interest in whether there's a user virtual address.

Caches on Itanium are physical.  So, it doesn't matter what virtual address
you use to flush a cache line, cache line containing specific physical
memory will be flushed.  For the cases where you have virtual caches,
update_mmu_cache is the API to use.

-rohit

