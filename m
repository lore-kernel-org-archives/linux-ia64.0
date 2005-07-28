From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 28 Jul 2005 08:48:38 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <42E89BE6.6040304@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <10613.1122538148@kao2.melbourne.sgi.com> <42E897FD.6060506@yahoo.com.au> <20050728083544.GA22740@elte.hu>
In-Reply-To: <20050728083544.GA22740@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>>No, they can be up to 30K apart.  See include/asm-ia64/ptrace.h.
>>>thread_info is at ~0xda0, depending on the config.  The switch_stack
>>>can be as high as 0x7bd0 in the kernel stack, depending on why the task
>>>is sleeping.
>>>
>>
>>Just a minor point, I agree with David: I'd like it to be called 
>>prefetch_task(), because some architecture may want to prefetch other 
>>memory.
> 
> 
> such as?
> 

Not sure. thread_info? Maybe next->timestamp or some other fields
in next, something in next->mm?

I didn't really have a concrete example, but in the interests of
being future proof...

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
