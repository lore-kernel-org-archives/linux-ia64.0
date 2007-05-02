From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 02 May 2007 01:57:40 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <4637F014.7080409@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704281757.l3SHvUrs026921@smtp.corp.google.com>	 <46372706.5030609@yahoo.com.au> <1178066178.19466.67.camel@galaxy.corp.google.com>
In-Reply-To: <1178066178.19466.67.camel@galaxy.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rohitseth@google.com
Cc: 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Hugh Dickins' <hugh@veritas.com>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Rohit Seth wrote:
> On Tue, 2007-05-01 at 21:39 +1000, Nick Piggin wrote:
> 
>>Rohit Seth wrote:
> 
> 
>>>If a user is requesting kernel to do (for example) write on a page that is
>>>already mapped with execute and write permissions then it should be treated
>>>as if the user space is doing modifications to that page.  There is no
>>>change in protections so lazy_prot_mmu_update shouldn't be called even
>>>though PG_arch_1 is (I think) set.  Does it answer your concern?
>>
>>I'm not sure that I would agree. For direct modifications of memory via
>>a passed in user virtual address, perhaps. For operations on pagecache,
>>we may not even have a handle to issue the flush cache instruction on (ie.
>>a user virtual address), let alone know whether anyone else is mapping
>>the page.
>>
> 
> 
> Can you please describe the page cache scenario in more detail?  IMO, if
> a page is user mapped with at least one execute and write permission
> then the responsibility of update caches lies with user.

What if a different user write(2)s the underlying page?


>>>>What if you were to say remove all the PG_arch_1 code, and do 
>>>>something really simple like flush icache in 
>>>>flush_dcache_page? Would performance suffer horribly?
>>>
>>>
>>>On Itanium, I think it will have some performance penalty (horrible or not I
>>>don't know) as you will be invalidating the caches more often.  And they
>>>alsways look for last 0.1% performance that they can get.
>>
>>Sure, but if we _only_ flushed when page_mapcount was raised,
> 
> 
> You will need this every time there is change in protection (e.g.
> mprotect) not only when page_mapcount is raised.

Yeah, you would retain the flush on fault, I meant you would
introduce a flush in flush_dcache_page for when mapcount is raised.

-- 
SUSE Labs, Novell Inc.
