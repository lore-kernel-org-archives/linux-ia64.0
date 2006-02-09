From: Jack Steiner <steiner@sgi.com>
Date: Thu, 09 Feb 2006 18:16:50 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <20060209181650.GB27921@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 09, 2006 at 09:16:48AM -0800, Stephane Eranian wrote:
> Hello,
> 
> It was recently pointed out to me that the PMU interrupt
> vector is set to 0xee just below the timer interrupt at 0xef.
> As such, the timer interrupt has higher priority than the PMU
> interrupt. This would make sense except that a side effect is
> that it is not possible to collect samples from within the timer
> interrupt, i.e. we have a blind spot. Another side effect is
> that events happening during the timer handler, may be falsely
> attributed to the point where we write the EOI register.

If your intent is to allow a PMU interrupt to interrupt the timer 
interrupt code, don't you need to put the PMU interrupt into a
higher priority class than the timer interrupt? Interrupt vectors
are grouped into 16 interrupt classes. An in-service interrupt masks
all other interrupts in the same class. (See the TPR register).

For example, PMU = 0xe0 & timer = 0xdf?
(This obviously ripples thu additional interrupt numbers....)
 
> I looked at the timer_interrupt() path, and I did not see anything special
> that would prevent us from swapping the interrupt vectors thereby removing
> the blind spot we have.
> 
> Does anybody see a problem with this?
> 
> -- 
> -Stephane
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


