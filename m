From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jan 2002 22:27:51 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805907@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jan 2002, David Mosberger wrote:

>   Ingo> oh, i see. Why were irqs enabled explicitly? The old scheduler
>   Ingo> called switch_to() with irqs enabled, all the time.
>
> Eh, that's not true.  The old scheduler did spin_unlock_irq() before
> calling switch_to().  [...]

hey, thats the same thing i said. "The old scheduler called switch_to()
with irqs enabled". Ie. with irqs not turned off. I should know, i
implemented that particular aspect of the old scheduler.

> [...] If your scheduler requires irq's to be disabled during context
> switch, it's going to have bigger interrupt response latency.  That's
> a disadvantage.

we disable interrupts for a microsecond or two pretty often. (i'm not sure
about ia64's context switch speed, but it should be well below 10 usecs,
right?)

Disabling interrupts for possibly hundreds of microseconds like the old
scheduler did, with the runqueue lock held, that was a disadvantage, i
agree.

	Ingo


