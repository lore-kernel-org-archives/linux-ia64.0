From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 17 Jun 2016 16:46:59 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160617164659.GC14591@linux-80c1.suse>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615165659.GC2094@linux-80c1.suse>
 <20160615171250.GO30921@twins.programming.kicks-ass.net>
 <20160615182724.GD2094@linux-80c1.suse>
 <20160615184007.GW30921@twins.programming.kicks-ass.net>
 <20160617011155.GA14591@linux-80c1.suse>
 <576408F7.8020901@hpe.com>
 <20160617162926.GB14591@linux-80c1.suse>
In-Reply-To: <20160617162926.GB14591@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <waiman.long@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Fri, 17 Jun 2016, Davidlohr Bueso wrote:

>On Fri, 17 Jun 2016, Waiman Long wrote:
>
>>On 06/16/2016 09:11 PM, Davidlohr Bueso wrote:
>>>On Wed, 15 Jun 2016, Peter Zijlstra wrote:
>>>
>>>>Yeah, see a few patches further in this series, where he guards a
>>>>variables with the osq_lock.
>>>
>>>So one problem I have with all this is that if we are hardening 
>>>osq_lock/unlock()
>>>because of some future use that is specific to rwsems, then we 
>>>will immediately
>>>be hurting mutexes for no good reason.
>>>
>>
>>I am going to change it to use smp_acquire__after_ctrl_dep() as 
>>suggested by PeterZ. Is that a good enough compromise? I have also 
>>changed the xchg in the unlock side to xchg_release which could help 
>>performance in some archs. The thing is when developers see the name 
>>osq_lock/osq_unlock, they will naturally assume the proper barrriers 
>>are provided which is not currently the case.
>
>Oh, from your discussions with Boqun, I was under the impression that ->locked
>was now going to be properly ordered in all cases now, which is why
>I worry about mutexes.
>
>>Anyway, the change won't affect x86, it is probably ARM or PPC that 
>>may have an impact.
>
>Yes, that xchg() won't affect x86, but adding an smp_store_release(node->locked, 1)
>or such will obviously.

nm this last part, you're right, x86 smp_store_release is a nop.
