From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 10 Feb 2006 23:21:30 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <20060210232130.GE28658@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ken,

On Fri, Feb 10, 2006 at 03:04:57PM -0800, Chen, Kenneth W wrote:
> 
> > Where is the masking happening exactly?
> 
> By hardware, upon an interrupt, both psr.i and psr.ic bit are off when
> the control goes into the ivt:interrupt().  In there, pt_regs is saved
> and only psr.ic bit is turned on.  It eventually calls down to
> handle_IRQ_event(). Since SA_INTERRUPT flag is on for timer interrupt,
> kernel doesn't enable irq when invoking the handler.
> 
> In fact, most of the interrupts having SA_INTERRUPT flag set.  So the
> blind spots you worried about for PMU is a lot wider.  For example, on
> my system, serial, e1000, mpt fusion, qla2300 interrupts all have that
> flag set. Looks like kernel executes these handlers with irq disabled
> all the way through.
> 
Yes, it is coded that way. The definition of SA_INTERRUPT  is far from
clear because it is obsolete when used by applications for signal
handlers. Yet the flag is overloaded for irq handlers, apparently
where it takes a completely different meaning.

Does it make sense to have the handlers run while interrupts mask 
during their entire execution? 

I need to correct the PMU interrupt handler because it is using this
flag while also explcitely masking interrupts again.

You are right that this creates very large blind spots when monitoring,
at least with the regular interrupt-based approach.

By construction, I would not expect those in the top class (15)
to have this flag set.

-- 
-Stephane
