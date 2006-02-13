From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 13 Feb 2006 20:32:17 +0000
Subject: RE: PMU and timer interrupts
Message-Id: <200602132032.k1DKWHg13773@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote on Monday, February 13, 2006 12:13 PM
> Jes seems to believe than this is more historical than anything for qla2xxx.
> Now what about the timer interrupt, why does it really need SA_INTERRUPT especially
> given that it is so high priority and with the TPR mechanism. IT seems to be
> a protection against MCA, IPI, IPI_RESCHEDULE based on the current layout.

scheduler_tick function expects irq off because it calls load_balance and
will muck around with runqueue list.  Won't that race with resched IPI if
irq is not masked?

- Ken

