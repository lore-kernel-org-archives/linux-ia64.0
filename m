From: Rohit Seth <rohitseth@google.com>
Date: Sat, 28 Apr 2007 17:57:19 +0000
Subject: RE: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <200704281757.l3SHvUrs026921@smtp.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <4632AAB4.6030303@yahoo.com.au>
References: <20070426001615.GA8908@ldl.fc.hp.com>
In-Reply-To: <20070426001615.GA8908@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Hugh Dickins' <hugh@veritas.com>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

 

-----Original Message-----
From: Nick Piggin [mailto:nickpiggin@yahoo.com.au] 
Sent: Friday, April 27, 2007 7:00 PM
To: rohitseth@google.com
Cc: Mike Stroyan; Andrew Morton; Hugh Dickins; Luck, Tony;
linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path

Rohit Seth wrote:
> 
> 
>> You mean by user space? If so, then it is user space responsibility to 
>> do the appropriate operations (like flush icache in this case).

>No, I mean places that set PG_arch_1. flush_dcache_page. This can happen 
>for mapped pages in write, splice, install_arg_page looks questionable,
direct IO...


If a user is requesting kernel to do (for example) write on a page that is
already mapped with execute and write permissions then it should be treated
as if the user space is doing modifications to that page.  There is no
change in protections so lazy_prot_mmu_update shouldn't be called even
though PG_arch_1 is (I think) set.  Does it answer your concern?

>What if you were to say remove all the PG_arch_1 code, and do 
>something really simple like flush icache in 
>flush_dcache_page? Would performance suffer horribly?

On Itanium, I think it will have some performance penalty (horrible or not I
don't know) as you will be invalidating the caches more often.  And they
alsways look for last 0.1% performance that they can get.

-rohit

