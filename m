From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 26 Feb 2004 22:20:33 +0000
Subject: Duplicated do_softirq in the interrupt path
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AB3C@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

do_softirq appeared twice in the interrupt path, once in do_IRQ() and
once in the higher level function ia64_handle_irq().  The condition
check for running do_softirq in ia64_handle_irq() doesn't do preemption
check and obviously a leftover code.  But I'm more concerned with
softirq being executed while lower priority interrupt is blocked due
to eoi and tpr only gets updated after the return of do_IRQ, which
already executed bottom half for the higher priority interrupt.  Isn't
it better to execute all critical part of interrupts (including lower
priority) and batch processing all the bottom half handler?

Am I missing some other code or it is handling interrupt like above?

- Ken
