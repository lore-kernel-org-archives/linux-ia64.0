From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Wed, 02 May 2007 02:05:15 +0000
Subject: Re: Fw: [PATCH] ia64: race flushing icache in do_no_page path
Message-Id: <4637F1DB.2010507@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200704281817.l3SIHu0P001764@smtp.corp.google.com>	 <46372A12.9080802@yahoo.com.au> <1178066180.19466.68.camel@galaxy.corp.google.com>
In-Reply-To: <1178066180.19466.68.camel@galaxy.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rohitseth@google.com
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Mike Stroyan' <mike.stroyan@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "'Luck, Tony'" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Rohit Seth wrote:
> On Tue, 2007-05-01 at 21:52 +1000, Nick Piggin wrote:
> 
>>Rohit Seth wrote:
>>
>>
>>>>and 
>>>>it's only interested when it's executable i.e. "lazy_mmu_prot_update"
>>>>is a name concealing some overdesign.
>>>
>>>
>>>You are right that ia64 is only interested in whne the execute permissions
>>>kick in (and FWIW ia64 used to use update_mmu_cache API to do what it is now
>>>doing lazy_mmu_prot_update).  Though the idea was to design an API that any
>>>arch can use to know when ever there is change in protections on a mapping.
>>
>>What I think what we should do is audit flush_icache_page coverage, and
>>convert ia64 to use that (because it needs this to happen _before_ the
>>pte is set).
>>
> 
> 
> That doesn't address the underlying requirement that arch specific code
> should be told of change in protections. 

But you would add the flush_icache_page_chprot to address that.


> For ia64, you are right that
> it equates to flushing icache in some cases, but this API is more
> generic.

And it is also broken, because it needs to be done before the set_pte
for ia64. It needs to be done where flush_icache_page is done. And on
ia64 it flushes the icache. So I don't understand why ia64 would not
use flush_icache_page but add something completely new "because it is
more generic".


>>All we should need to do is add a pte argument to flush_icache,
> 
> 
> I'm sure this is doable.  Though it is more of design issue of whether
> that is the right way to do it.  I understand this extra API is
> difficult at this time because of one single consumer.

There is just no point in adding something else if you already have
a hook that seems to do what ia64 wants (or could, with a small amount
of work).

-- 
SUSE Labs, Novell Inc.
