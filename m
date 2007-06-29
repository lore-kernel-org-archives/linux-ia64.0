From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 29 Jun 2007 23:20:47 +0000
Subject: RE: [RFC][PATCH take2 0/13] Support vector domain on ia64
Message-Id: <617E1C2C70743745A92448908E030B2A01D0A803@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46779036.5050602@jp.fujitsu.com>
In-Reply-To: <46779036.5050602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> include/asm/hardirq.h:30:3: #error HARDIRQ_BITS is too low!

This one is a direct consequence of the new definition of NR_IRQS:

#define NR_IRQS (NR_VECTORS + 32 * NR_CPUS))

With a large NR_CPUS value, this gets too big.  Do we really need to scale
it with the number of cpus?  I don't think this is the right thing to do.
While large cpu count systems may also have a large number of I/O devices,
the two parameters aren't strongly connected.

We could prevent it blowing up by doing:

/* NR_IRQS is limited by HARDIRQ_BITS */
#if (NR_VECTORS + 32 * NR_CPUS)) < 16363
#define NR_IRQS (NR_VECTORS + 32 * NR_CPUS))
#else
#define NR_IRQS 16383
#endif


But that looks rather ugly and still fails to build because of overflow of the percpu area.
This gets big because of include/linux/kernel_stat.h:

DECLARE_PERCPU(struct kernel_stat, kstat);

With the current allocation of percpu stuff, it looks like we can push NR_IRQS up
to around 7.5K, but that would leave no space for other additions to percpu space.
So if large systems are going to need as many as 7.5K IRQs, then we'll also need to
do something about kstat.

-Tony
