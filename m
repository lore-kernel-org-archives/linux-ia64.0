From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 27 Jan 2006 21:48:07 +0000
Subject: RE: boot-time slowdown for measure_migration_cost
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F058CC7A6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601271403.27065.bjorn.helgaas@hp.com>
In-Reply-To: <200601271403.27065.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, Ingo Molnar <mingo@redhat.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> The boot-time migration cost auto-tuning stuff seems to have
> been merged to Linus' tree since 2.6.15.  On little one- or
> two-processor systems, the time required to measure the
> migration costs isn't very noticeable, but by the time we
> get to even a four-processor ia64 box, it adds about
> 30 seconds to the boot time, which seems like a lot.

I only see about 16 seconds for a 4-way tiger (not that 16 seconds
is good ... but it not as bad as 30).  This was with a build
from tiger_defconfig that sets CONFIG_NR_CPUS=4 ... so I wonder
what's causing the factor of two.  I measured with a printk
each side of build_sched_domains() and booted with the "time"
command line arg to get:

[    0.540718] Building sched domains
[   16.124693] migration_cost091
[   16.124789] Done

More importantly, how does this time scale as the number of
cpus increases?  Linear, or worse?  What happens on a 512 cpu
Altix (if it's quadratic, they may be still waiting for the
boot to finish :-)

-Tony
