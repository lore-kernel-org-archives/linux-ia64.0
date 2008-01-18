From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Fri, 18 Jan 2008 08:28:42 +0000
Subject: Re: runqueue locks in schedule()
Message-Id: <200801181928.43249.nickpiggin@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470801161629t3870da59hb6ac371c44126b07@mail.gmail.com> <200801181307.53026.nickpiggin@yahoo.com.au> <7c86c4470801172233s333b5993q8b10e37f8ad151d@mail.gmail.com>
In-Reply-To: <7c86c4470801172233s333b5993q8b10e37f8ad151d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stephane eranian <eranian@googlemail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, ia64 <linux-ia64@vger.kernel.org>, Stephane Eranian <eranian@gmail.com>, Corey J Ashford <cjashfor@us.ibm.com>, Ingo Molnar <mingo@elte.hu>

On Friday 18 January 2008 17:33, stephane eranian wrote:
> Nick,

> > It is arch specific. If an architecture wants interrupts on during
> > context switch, or runqueue unlocked, then they set it (btw
> > INTERRUPTS_ON_CTXSW also implies UNLOCKED_CTXSW).
>
> Yes , I noticed that. I am only interested in UNLOCKED_CTXSW.
> But it appears that the approach suggested my Peter does work. We are
> running some tests.

OK, that might be OK.


> > Although, eg on x86, you would hold off interrupts and runqueue lock for
> > slightly less time if you defined those, it results in _slightly_ more
> > complicated context switching... although I did once find a workload
> > where the reduced runqueue contention improved throughput a bit, it is
> > not much problem in general to hold the lock.
>
> By complicated you mean that now you'd have to make sure you don't
> need to access runqueue data?

Well, not speaking about the arch-specific code (which may involve
more complexities), but the core scheduler needs the
task_struct->oncpu variable wheras that isn't required if the
runqueue is locked while switching tasks.
