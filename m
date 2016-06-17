From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 17 Jun 2016 01:11:55 +0000
Subject: Re: [RFC PATCH-tip v2 1/6] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20160617011155.GA14591@linux-80c1.suse>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-2-git-send-email-Waiman.Long@hpe.com>
 <20160615165659.GC2094@linux-80c1.suse>
 <20160615171250.GO30921@twins.programming.kicks-ass.net>
 <20160615182724.GD2094@linux-80c1.suse>
 <20160615184007.GW30921@twins.programming.kicks-ass.net>
In-Reply-To: <20160615184007.GW30921@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Waiman Long <Waiman.Long@hpe.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Wed, 15 Jun 2016, Peter Zijlstra wrote:

>Yeah, see a few patches further in this series, where he guards a
>variables with the osq_lock.

So one problem I have with all this is that if we are hardening osq_lock/unlock()
because of some future use that is specific to rwsems, then we will immediately
be hurting mutexes for no good reason.

Thanks,
Davidlohr
