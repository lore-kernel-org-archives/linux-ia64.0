From: Erich Focht <efocht@ess.nec.de>
Date: Wed, 10 Jul 2002 09:05:29 +0000
Subject: [Linux-ia64] Re: O(1) scheduler "complex" macros
Message-Id: <marc-linux-ia64-105590701905752@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ingo,

thanks for the quick response!

> the best solution might be to just lock the 'next' task - this needs a new
> per-task irq-safe spinlock, to avoid deadlocks. This way whenever a task
> is in the middle of a context-switch it cannot be scheduled on another
> CPU.

We tested this and it looked good. But inserting a udelay(100) like:
	...
	prepare_arch_switch(rq, next);
	udelay(100);
	prev = context_switch(prev, next);
	...
leads to a crash after 10 minutes. Again this looks like accessing an
empty page.

Does anything speak against such a test? It is there just to show up
quickly problems which we might normally get only after hours of running.

Regards,
Erich
 

