From: Stephane Eranian <eranian@hpl.hp.com>
Date: Mon, 13 Feb 2006 20:12:39 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <20060213201239.GH11285@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 13, 2006 at 12:13:06PM -0800, Chen, Kenneth W wrote:
> Stephane Eranian wrote on Monday, February 13, 2006 12:02 PM
> > On Fri, Feb 10, 2006 at 03:04:57PM -0800, Chen, Kenneth W wrote:
> > > In fact, most of the interrupts having SA_INTERRUPT flag set.  So the
> > > blind spots you worried about for PMU is a lot wider.  For example, on
> > > my system, serial, e1000, mpt fusion, qla2300 interrupts all have that
> > > flag set. Looks like kernel executes these handlers with irq disabled
> > > all the way through.
> > > 
> > Looking at my 2.6.16-rc1, it appears that neither e1000 nor mpt fusion
> > are using SA_INTERRUPT anymore. The qla2xxx still does, though.
> 
> Yeah, I think you are correct.

Jes seems to believe than this is more historical than anything for qla2xxx.
Now what about the timer interrupt, why does it really need SA_INTERRUPT especially
given that it is so high priority and with the TPR mechanism. IT seems to be
a protection against MCA, IPI, IPI_RESCHEDULE based on the current layout.


-- 

-Stephane
