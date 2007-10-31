From: Russ Anderson <rja@sgi.com>
Date: Wed, 31 Oct 2007 20:00:01 +0000
Subject: Re: [patch] __do_IRQ does not check IRQ_DISABLED when IRQ_PER_CPU is set
Message-Id: <20071031200000.GB22855@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071030162657.GA21728@sgi.com> <617E1C2C70743745A92448908E030B2A02D2142E@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A02D2142E@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org

On Wed, Oct 31, 2007 at 09:20:27AM -0700, Luck, Tony wrote:
> > One user encountering this behavior is the CPE handler (in 
> > arch/ia64/kernel/mca.c).  When the CPE handler encounters too many
> > CPEs (such as a solid single bit error), it sets up a polling timer
> > and disables the CPE interrupt (to avoid excessive overhead logging
> > the stream of single bit errors).  disable_irq_nosync() is called
> > which sets IRQ_DISABLED.  The IRQ_PER_CPU flag was previously set
> > (in ia64_mca_late_init()).  The net result is the CPE handler gets
> > called even though it is marked disabled.
> 
> Presumably we are in this situation because there are still some
> pending CPE interrupts on some cpus when we disable CPE?  Or is
> there a more serious problem that we aren't manage to disable CPE
> on all cpus properly?

The latter.   If IRQ_PER_CPU is set, IRQ_DISABLED is not checked
in __do_IRQ(), so the handler is always called.  It is not a race
condition type thing where a few pended interrupts get handled after
IRQ_DISABLED is set.

My assumption is that setting IRQ_PER_CPU should not change the
behavior of IRQ_DISABLED.

disable_irq_nosync() does call chip->disable() to provide a chipset
specific interface for disabling the interrupt.  That avoids
the issue by having the chipset not issue the interrupt.  If a 
disable handler is required to disable the interrupt, then setting
IRQ_DISABLED is not necessary (and misleading).  

I think the intended behavior is for chip->disable() to 
disable the interrupt in the chipset.  If, for some reason,
the interrupt cannot be disabled in the hardware, the IRQ_DISABLED
would prevent the interrupt handler from being called.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
