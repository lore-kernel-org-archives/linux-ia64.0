From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 28 Jul 2005 09:16:38 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <20050728091638.GA25846@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <10613.1122538148@kao2.melbourne.sgi.com> <42E897FD.6060506@yahoo.com.au> <20050728083544.GA22740@elte.hu> <42E89BE6.6040304@yahoo.com.au>
In-Reply-To: <42E89BE6.6040304@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


* Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> >>Just a minor point, I agree with David: I'd like it to be called 
> >>prefetch_task(), because some architecture may want to prefetch other 
> >>memory.
> >
> >such as?
> 
> Not sure. thread_info? Maybe next->timestamp or some other fields in 
> next, something in next->mm?

next->thread_info we could and should prefetch - but from the generic 
scheduler code (see the patch i just sent).

i'm not sure what you mean by prefetching next->timestamp, it's an 
inline field to 'next', in the first cacheline of it, which we've 
already used so it's present. (If you mean the value of next->timestamp, 
that has no address meaning at all so would lead to unpredictable 
results on some arches.)

next->mm we might want to prefetch, but it's probably not worth it 
because we are referencing it too soon, in context_switch(). (while the 
kernel stack itself wont be referenced until the full context-switch is 
done) But might be worth trying - but even then, it should be done from 
the generic code, like the thread_info and kernel-stack prefetching.

> I didn't really have a concrete example, but in the interests of being 
> future proof...

i'd like to keep generic bits in generic code, and only move things to 
per-arch include files if absolutely necessary. next->mm is generic.

	Ingo
