From: Jes Sorensen <jes@sgi.com>
Date: Fri, 10 Feb 2006 23:26:34 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <yq0d5hu3idx.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Ken" = Chen, Kenneth W <kenneth.w.chen@intel.com> writes:

Ken> By hardware, upon an interrupt, both psr.i and psr.ic bit are off
Ken> when the control goes into the ivt:interrupt().  In there,
Ken> pt_regs is saved and only psr.ic bit is turned on.  It eventually
Ken> calls down to handle_IRQ_event(). Since SA_INTERRUPT flag is on
Ken> for timer interrupt, kernel doesn't enable irq when invoking the
Ken> handler.

Ken> In fact, most of the interrupts having SA_INTERRUPT flag set.  So
Ken> the blind spots you worried about for PMU is a lot wider.  For
Ken> example, on my system, serial, e1000, mpt fusion, qla2300
Ken> interrupts all have that flag set. Looks like kernel executes
Ken> these handlers with irq disabled all the way through.

Ken,

I wonder if that isn't mostly bugs on the driver authors side?
SA_INTERRUPT was really introduced to handle UART interrupts, whereas
I think  all the other drivers you mention ought to be able to handle
it correctly.

Cheers,
Jes
