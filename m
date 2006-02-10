From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 10 Feb 2006 23:04:57 +0000
Subject: RE: PMU and timer interrupts
Message-Id: <200602102304.k1AN4ug27682@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote on Friday, February 10, 2006 1:23 PM
> > If your goal is to be able to sample timer interrupt with PMU, you
> > won't get it even after you move PMU vector one class up.  Because
> > just like PMU vector, timer interrupt handler is run with interrupt
> > off all the through.
> > 
> Are you talking about timer_interrupt()?

Yes.


> Where is the masking happening exactly?

By hardware, upon an interrupt, both psr.i and psr.ic bit are off when
the control goes into the ivt:interrupt().  In there, pt_regs is saved
and only psr.ic bit is turned on.  It eventually calls down to
handle_IRQ_event(). Since SA_INTERRUPT flag is on for timer interrupt,
kernel doesn't enable irq when invoking the handler.

In fact, most of the interrupts having SA_INTERRUPT flag set.  So the
blind spots you worried about for PMU is a lot wider.  For example, on
my system, serial, e1000, mpt fusion, qla2300 interrupts all have that
flag set. Looks like kernel executes these handlers with irq disabled
all the way through.

- Ken

