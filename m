From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 17 Jan 2002 21:17:42 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805874@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Jan 2002, Erich Focht wrote:

> Hmm, doesn't work, yet with 2.4.17 :-(
>
> There must be some path where a rq->lock remains set, with some sort of
> print-eip-like tool I see lockups with
>
> load_balance  vs.   __wake_up
> __wake_up     vs.   sched_tick
> etc...

are you sure interrupts are properly disabled in all cases where the
runqueue is touched? Eg. sched_tick() relies on having IRQs disabled.

	Ingo


