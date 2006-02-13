From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 13 Feb 2006 22:49:57 +0000
Subject: RE: PMU and timer interrupts
Message-Id: <200602132249.k1DMnvg15069@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote on Monday, February 13, 2006 12:32 PM
> Stephane Eranian wrote on Monday, February 13, 2006 12:13 PM
> > Jes seems to believe than this is more historical than anything for qla2xxx.
> > Now what about the timer interrupt, why does it really need SA_INTERRUPT especially
> > given that it is so high priority and with the TPR mechanism. IT seems to be
> > a protection against MCA, IPI, IPI_RESCHEDULE based on the current layout.
> 
> scheduler_tick function expects irq off because it calls load_balance and
> will muck around with runqueue list.  Won't that race with resched IPI if
> irq is not masked?

NO! Ken needs more coffee Monday morning ....

I forgot that we don't check TIF_ flag when we are still on kernel stack.
So resched IPI should be safe w.r.t timer interrupt because schedule is
called after timer_interrupt finishes.

- Ken

