From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 31 Oct 2007 16:20:27 +0000
Subject: RE: [patch] __do_IRQ does not check IRQ_DISABLED when IRQ_PER_CPU is set
Message-Id: <617E1C2C70743745A92448908E030B2A02D2142E@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071030162657.GA21728@sgi.com>
In-Reply-To: <20071030162657.GA21728@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org

> One user encountering this behavior is the CPE handler (in 
> arch/ia64/kernel/mca.c).  When the CPE handler encounters too many
> CPEs (such as a solid single bit error), it sets up a polling timer
> and disables the CPE interrupt (to avoid excessive overhead logging
> the stream of single bit errors).  disable_irq_nosync() is called
> which sets IRQ_DISABLED.  The IRQ_PER_CPU flag was previously set
> (in ia64_mca_late_init()).  The net result is the CPE handler gets
> called even though it is marked disabled.

Presumably we are in this situation because there are still some
pending CPE interrupts on some cpus when we disable CPE?  Or is
there a more serious problem that we aren't manage to disable CPE
on all cpus properly?

-Tony
