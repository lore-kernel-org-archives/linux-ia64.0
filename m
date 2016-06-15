From: Waiman Long <waiman.long@hpe.com>
Date: Wed, 15 Jun 2016 19:31:51 +0000
Subject: Re: [RFC PATCH-tip v2 5/6] locking/rwsem: Change RWSEM_WAITING_BIAS for better disambiguation
Message-Id: <5761AD27.9020106@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com> <1465944489-43440-6-git-send-email-Waiman.Long@hpe.com> <20160615174348.GT30921@twins.programming.kicks-ass.net>
In-Reply-To: <20160615174348.GT30921@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 06/15/2016 01:43 PM, Peter Zijlstra wrote:
> On Tue, Jun 14, 2016 at 06:48:08PM -0400, Waiman Long wrote:
>> even the reduced maximum of about 16k (32-bit) or 1G (64-bit) should
>> be more than enough for the foreseeable future.
> So what happens if I manage to create 16k+ threads on my 32bit kernel
> and get them all to do mmap() or so at the same time.
>
> That doesn't seem too far fetched.
>
> Then again, with double that (the current limit) that doesn't seem
> impossible either.

To hit the limit, we need to have all the threads calling down_write() 
at exactly the same instance in time which, I think, is pretty hard to 
do. Also, I don't believe you will ever see a 16k-cpu massive SMP system 
running on 32-bit kernel. I can imagine such a system running on 64-bit 
kernel, but certainly not 32-bit.

Cheers,
Longman
