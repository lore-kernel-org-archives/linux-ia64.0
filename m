From: Nick Piggin <piggin@cyberone.com.au>
Date: Sat, 20 Dec 2003 15:12:45 +0000
Subject: Re: [RFC][PATCH] 2.6.0-test11 sched_clock() broken for "drifty ITC"
Message-Id: <marc-linux-ia64-107193415625580@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107178053026093@msgid-missing>
In-Reply-To: <marc-linux-ia64-107178053026093@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>
>>
>>Ingo Molnar wrote:
>>
>>
>>>So i believe the generic relaxing of sched_clock() synchronization is
>>>the right thing to do. I like your patch. It adds minimal overhead and
>>>solves a hard problem - nice work! Andrew, please apply it.
>>>
>>>
>>>
>>Its a great looking patch if you must have high res sched_clock. So
>>I guess I agree with it.
>>
>
>miaow ;)
>

I'm just thinking that computers with unsynched clocks have less
need for good interactivity, but thats probably too narrow and x86
a view anyway.

>
>>Can we have a scheduler day when Andrew is ready to take patches for
>>it? I have a few small changes that I'd like to get merged soon too
>>(not sched domains - that should probably go to the mm tree for a while)
>>
>>Relevant patches are
>>sched-ctx-count-preempt.patch
>>sched-fork-cleanup.patch
>>sched-migrate-comment.patch
>>sched-style.patch
>>sched-migrate-affinity-race.patch
>>
>>
>
>Post 'em.
>

OK, I'll trim the cc list though...


