From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 21 Jan 2002 22:11:49 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805905@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 21 Jan 2002, David Mosberger wrote:

>   Ingo> we call context_switch() with irqs disabled. The ia64 version
>   Ingo> of switch_to() should not re-enable IRQs or it will deadlock.
>
> The existing switch_to() enables interrupts if the new task's stack is
> on a different (kernel-) page.

oh, i see. Why were irqs enabled explicitly? The old scheduler called
switch_to() with irqs enabled, all the time.

> [...] If the new scheduler guarantees to call switch_to() with irqs
> disabled, we can simply drop the relevant code.

yes. And this should fix the lockup as well.

	Ingo


