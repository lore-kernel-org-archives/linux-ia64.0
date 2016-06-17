From: Waiman Long <waiman.long@hpe.com>
Date: Fri, 17 Jun 2016 18:17:27 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <57643EB7.6030600@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com> <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com> <20160615080446.GA28443@insomnia> <5761A5FF.5070703@hpe.com> <20160616021951.GA16918@insomnia> <57631BBA.9070505@hpe.com> <20160617004837.GB16918@insomnia> <576416B1.6020006@hpe.com> <20160617154536.GB1284@arm.com>
In-Reply-To: <20160617154536.GB1284@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>
Cc: Boqun Feng <boqun.feng@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 06/17/2016 11:45 AM, Will Deacon wrote:
> On Fri, Jun 17, 2016 at 11:26:41AM -0400, Waiman Long wrote:
>> On 06/16/2016 08:48 PM, Boqun Feng wrote:
>>> On Thu, Jun 16, 2016 at 05:35:54PM -0400, Waiman Long wrote:
>>>> If you look into the actual code:
>>>>
>>>>          next = xchg_release(&node->next, NULL);
>>>>          if (next) {
>>>>                  WRITE_ONCE(next->locked, 1);
>>>>                  return;
>>>>          }
>>>>
>>>> There is a control dependency that WRITE_ONCE() won't happen until
>>> But a control dependency only orders LOAD->STORE pairs, right? And here
>>> the control dependency orders the LOAD part of xchg_release() and the
>>> WRITE_ONCE().
>>>
>>> Along with the fact that RELEASE only orders the STORE part of xchg with
>>> the memory operations preceding the STORE part, so for the following
>>> code:
>>>
>>> 	WRTIE_ONCE(x,1);
>>> 	next = xchg_release(&node->next, NULL);
>>> 	if (next)
>>> 		WRITE_ONCE(next->locked, 1);
>>>
>>> such a reordering is allowed to happen on ARM64v8
>>>
>>> 	next = ldxr [&node->next] // LOAD part of xchg_release()
>>>
>>> 	if (next)
>>> 		WRITE_ONCE(next->locked, 1);
>>>
>>> 	WRITE_ONCE(x,1);
>>> 	stlxr NULL [&node->next]  // STORE part of xchg_releae()
>>>
>>> Am I missing your point here?
>> My understanding of the release barrier is that both prior LOADs and STOREs
>> can't move after the barrier. If WRITE_ONCE(x, 1) can move to below as shown
>> above, it is not a real release barrier and we may need to change the
>> barrier code.
> You seem to be missing the point.
>
> {READ,WRITE}_ONCE accesses appearing in program order after a release
> are not externally ordered with respect to the release unless they
> access the same location.
>
> This is illustrated by Boqun's example, which shows two WRITE_ONCE
> accesses being reordered before a store-release forming the write
> component of an xchg_release. In both cases, WRITE_ONCE(x, 1) remains
> ordered before the store-release.
>
> Will

I am sorry that I misread the mail. I am not used to treating xchg as 
two separate instructions. Yes, it is a problem. In that case, we have 
to either keep the xchg() function as it is or use 
smp_store_release(&next->locked, 1). So which one is a better 
alternative for ARM or PPC?

Cheers,
Longman
