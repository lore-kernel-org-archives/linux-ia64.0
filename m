From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jan 2002 21:11:57 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805903@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jan 2002, Erich Focht wrote:

> what's the problem with the following code?
>
> switch_tasks:
> 	prev->need_resched = 0;
>
> 	if (likely(prev != next)) {
> 		rq->nr_switches++;
> 		rq->curr = next;
> 		spin_unlock_irq(&rq->lock);          // <-
> 		context_switch(prev, next, 0);

the runqueue must not be unlocked before the current task is completely
inactive - otherwise another CPU could grab (or even free) this task.

	Ingo


