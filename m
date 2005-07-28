From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Thu, 28 Jul 2005 08:31:57 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <42E897FD.6060506@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <10613.1122538148@kao2.melbourne.sgi.com>
In-Reply-To: <10613.1122538148@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@ocs.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Keith Owens wrote:
> On Thu, 28 Jul 2005 09:41:18 +0200,
> Ingo Molnar <mingo@elte.hu> wrote:

>>i'm wondering, is the switch_stack at the same/similar place as
>>next->thread_info? If yes then we could simply do a
>>prefetch(next->thread_info).
> 
> 
> No, they can be up to 30K apart.  See include/asm-ia64/ptrace.h.
> thread_info is at ~0xda0, depending on the config.  The switch_stack
> can be as high as 0x7bd0 in the kernel stack, depending on why the task
> is sleeping.
> 

Just a minor point, I agree with David: I'd like it to be called
prefetch_task(), because some architecture may want to prefetch other
memory.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
