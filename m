From: Jason Low <jason.low2@hp.com>
Date: Tue, 04 Oct 2016 21:28:59 +0000
Subject: Re: [RFC PATCH-tip v4 01/10] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <CAGQ1y=6o6iuHJwtSc2+OPgFUpv7+z4+tcycTVRKjYNvHsg2E8g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
 <1471554672-38662-2-git-send-email-Waiman.Long@hpe.com> <20161004190601.GD24086@linux-80c1.suse>
In-Reply-To: <20161004190601.GD24086@linux-80c1.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Waiman Long <Waiman.Long@hpe.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, jason.low2@hpe.com

On Tue, Oct 4, 2016 at 12:06 PM, Davidlohr Bueso <dave@stgolabs.net> wrote:
> On Thu, 18 Aug 2016, Waiman Long wrote:
>
>> The osq_lock() and osq_unlock() function may not provide the necessary
>> acquire and release barrier in some cases. This patch makes sure
>> that the proper barriers are provided when osq_lock() is successful
>> or when osq_unlock() is called.
>
>
> But why do we need these guarantees given that osq is only used internally
> for lock owner spinning situations? Leaking out of the critical region will
> obviously be bad if using it as a full lock, but, as is, this can only hurt
> performance of two of the most popular locks in the kernel -- although yes,
> using smp_acquire__after_ctrl_dep is nicer for polling.
>
> If you need tighter osq for rwsems, could it be refactored such that mutexes
> do not take a hit?

I agree with David, the OSQ is meant to be used internally as a
queuing mechanism than as something for protecting critical regions,
and so these guarantees of preventing critical section leaks don't
seem to be necessary for the OSQ. If that is the case, then it would
be better to avoid the performance hit to mutexes and rwsems.

Jason
