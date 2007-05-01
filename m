From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Tue, 01 May 2007 11:39:50 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <46372706.5030609@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704281757.l3SHvUrs026921@smtp.corp.google.com>
In-Reply-To: <200704281757.l3SHvUrs026921@smtp.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rohit Seth <rohitseth@google.com>
Cc: 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Hugh Dickins' <hugh@veritas.com>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Rohit Seth wrote:
>  
> 
> -----Original Message-----
> From: Nick Piggin [mailto:nickpiggin@yahoo.com.au] 
> Sent: Friday, April 27, 2007 7:00 PM
> To: rohitseth@google.com
> Cc: Mike Stroyan; Andrew Morton; Hugh Dickins; Luck, Tony;
> linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
> 
> Rohit Seth wrote:
> 
>>
>>>You mean by user space? If so, then it is user space responsibility to 
>>>do the appropriate operations (like flush icache in this case).
> 
> 
>>No, I mean places that set PG_arch_1. flush_dcache_page. This can happen 
>>for mapped pages in write, splice, install_arg_page looks questionable,
> 
> direct IO...
> 
> 
> If a user is requesting kernel to do (for example) write on a page that is
> already mapped with execute and write permissions then it should be treated
> as if the user space is doing modifications to that page.  There is no
> change in protections so lazy_prot_mmu_update shouldn't be called even
> though PG_arch_1 is (I think) set.  Does it answer your concern?

I'm not sure that I would agree. For direct modifications of memory via
a passed in user virtual address, perhaps. For operations on pagecache,
we may not even have a handle to issue the flush cache instruction on (ie.
a user virtual address), let alone know whether anyone else is mapping
the page.

>>What if you were to say remove all the PG_arch_1 code, and do 
>>something really simple like flush icache in 
>>flush_dcache_page? Would performance suffer horribly?
> 
> 
> On Itanium, I think it will have some performance penalty (horrible or not I
> don't know) as you will be invalidating the caches more often.  And they
> alsways look for last 0.1% performance that they can get.

Sure, but if we _only_ flushed when page_mapcount was raised, then we
should have most of the benefits of lazy flushing, and the main places
were we do extra flushes are those where aliases could potentially occur
under the old scheme.

-- 
SUSE Labs, Novell Inc.
