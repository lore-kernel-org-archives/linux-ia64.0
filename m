From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 Feb 2004 22:49:40 +0000
Subject: Re: Duplicated do_softirq in the interrupt path
Message-Id: <16446.30724.151510.91590@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB501F2AB3C@scsmsx401.sc.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB501F2AB3C@scsmsx401.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Feb 2004 14:20:33 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> do_softirq appeared twice in the interrupt path, once in do_IRQ() and
  Ken> once in the higher level function ia64_handle_irq().  The condition
  Ken> check for running do_softirq in ia64_handle_irq() doesn't do preemption
  Ken> check and obviously a leftover code.  But I'm more concerned with
  Ken> softirq being executed while lower priority interrupt is blocked due
  Ken> to eoi and tpr only gets updated after the return of do_IRQ, which
  Ken> already executed bottom half for the higher priority interrupt.  Isn't
  Ken> it better to execute all critical part of interrupts (including lower
  Ken> priority) and batch processing all the bottom half handler?

Absolutely!  In fact, wouldn't that explain the keyboard problems that
were reported for Lion?

I think the correct fix is to move irq_exit() from do_IRQ() to the
point where ia64_handle_irq() calls do_softirq().  Unfortunately, this
makes for one more difference compared to arch/i386/kernel/irq.c but I
don't see any other reasonable way to resolve the problem.

	--david
