From: Grant Grundler <iod00d@hp.com>
Date: Fri, 27 Feb 2004 02:07:33 +0000
Subject: Re: Excessive time to handle interrupts
Message-Id: <20040227020733.GK15022@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16446.34009.722204.259663@wombat.chubb.wattle.id.au>
In-Reply-To: <16446.34009.722204.259663@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 26, 2004 at 04:06:07PM -0800, David Mosberger wrote:
> See:
> 
>   http://www.intel.com/design/itanium/downloads/25135001.pdf

I just reviewed section 2.3.2.2 I/O xAPIC Redirection Table.
(See Figure 2-4. I/O xAPIC Redirection Table Entry Definition)

...
> AFAIR, the I/O SAPIC interrupt masking is entirely under control of
> the CPU (i.e., the hw never changes the mask of its own) so caching
> sounds like a good idea.

ISTR the same thing and reviewing the section gave me the warm
fuzzies it is safe to do.

My only concern is other parts of the code which touch IO SAPIC
redirection table entries need to update the cached copy as well.
Here's a list of places that touch IOSAPIC_RTE_LOW:
	set_rte()
	mask_irq()
	unmask_irq()
	iosapic_set_affinity()


BTW, enable/disable_irq() are not barriers for IRQ delivery.
disable_irq() will return before IO SAPIC knows to mask IRQs.
mask/unmask_irq doesn't force the last writel out of the CPU
and adding a readl to flush the writel wouldn't help performance.

Avoiding these calls in the performance path is the best strategy.

grant
