From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 21 Jan 2002 20:23:08 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805906@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 21 Jan 2002 23:11:49 +0100 (CET), Ingo Molnar <mingo@elte.hu> said:

  Ingo> On Mon, 21 Jan 2002, David Mosberger wrote:

  Ingo> we call context_switch() with irqs disabled. The ia64 version
  Ingo> of switch_to() should not re-enable IRQs or it will deadlock.
  >>  The existing switch_to() enables interrupts if the new task's
  >> stack is on a different (kernel-) page.

  Ingo> oh, i see. Why were irqs enabled explicitly? The old scheduler
  Ingo> called switch_to() with irqs enabled, all the time.

Eh, that's not true.  The old scheduler did spin_unlock_irq() before
calling switch_to().  If your scheduler requires irq's to be disabled
during context switch, it's going to have bigger interrupt response
latency.  That's a disadvantage.

	--david

