From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 28 Jul 2005 10:29:20 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <42E8B380.1070003@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <10613.1122538148@kao2.melbourne.sgi.com> <42E897FD.6060506@yahoo.com.au> <20050728083544.GA22740@elte.hu> <42E89BE6.6040304@yahoo.com.au> <20050728091638.GA25846@elte.hu> <42E8A688.7070802@yahoo.com.au> <20050728100429.GA27030@elte.hu>
In-Reply-To: <20050728100429.GA27030@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:

[...]

> 	prefetch_area(void *first_addr, void *last_addr)
> 
> (or as addr,len)
> 

Yep. We have prefetch_range.


>>
>>Yeah, then a specific field _within_ next->mm or thread_info may want 
>>to be fetched. In short, I don't see any argument why we shouldn't 
>>call the function prefetch_task().
> 
> 
> it's a fundamental thing: we _dont_ want to push generic code into 
> architectures, and there's nothing per-arch about next->mm.
> 

Yeah, I mean within mm, ie. prefetch(&mm->random_cacheline).

>>Secondly, I don't really like your prefetch(kernel_stack()) function 
>>because it doesn't really give architectures enough control over 
>>exactly what cachelines they get in memory.
> 
> 
> my point is, it comes down to concrete examples, it may or may not make 
> sense to do things per-arch.
> 

I thought the concrete example there was ia64's switch_stack,
which looks to be over half a K... oh I see you've asked Ken
whether this will be sufficient. OK in that case let's wait and
see.

> 
>>[...] I see nothing wrong with having a prefetch_task() call.  
>>(Although I agree things like thread_info->flags and next->mm can be 
>>done in generic code).
> 
> 
> great that we now agree wrt. thread_info and next->mm. My remaining 
> point is, once we prefetch ->thread_info, ->mm and the kernel stack, 
> nothing else significant remains! (It's still very much possible that 
> something needs to be prefetched per-arch, but i'd like to see a robust 
> case be made for it, instead of your global 'it might happen' argument.)
> 

Well to be clear, I think we have always agreed, except that I
thought it 'did happen' with the ia64 example. If it turns out
that your prefetch is good enough then I will have been mistaken.

Actually to be even clearer, I was never really arguing about what
to prefetch or whether to prefetch from arch code or not. Just that
the name, if any, should be prefetch_task as opposed to
prefetch_stack :)

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
