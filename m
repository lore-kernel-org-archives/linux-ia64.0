From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jan 2002 20:32:28 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805900@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jan 2002, Erich Focht wrote:

> Unfortunately the context switch in Ingo's scheduler happens with the
> runqueue lock held, which can lead to a deadlock eg. if the timer
> interrupt is called inside and sched_tick spinlocks on the runqueue
> lock held by schedule(). On IA64 (HZ24) this probably happens much
> more frequently than on IA32 (HZ0).

we call context_switch() with irqs disabled. The ia64 version of
switch_to() should not re-enable IRQs or it will deadlock.

	Ingo


