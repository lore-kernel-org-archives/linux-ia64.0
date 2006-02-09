From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Feb 2006 18:20:18 +0000
Subject: RE: PMU and timer interrupts
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05AA18A4@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>It was recently pointed out to me that the PMU interrupt
>vector is set to 0xee just below the timer interrupt at 0xef.
>As such, the timer interrupt has higher priority than the PMU
>interrupt. This would make sense except that a side effect is
>that it is not possible to collect samples from within the timer
>interrupt, i.e. we have a blind spot. Another side effect is
>that events happening during the timer handler, may be falsely
>attributed to the point where we write the EOI register.
>
>I looked at the timer_interrupt() path, and I did not see anything special
>that would prevent us from swapping the interrupt vectors thereby removing
>the blind spot we have.
>
>Does anybody see a problem with this?

How much would this help?  Both 0xEF and 0xEE are part of the
same priority class (see table 5-8 on p. 2-112 of SDM).

-Tony
