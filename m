From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 27 Jan 2006 21:03:27 +0000
Subject: boot-time slowdown for measure_migration_cost
Message-Id: <200601271403.27065.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@redhat.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The boot-time migration cost auto-tuning stuff seems to have
been merged to Linus' tree since 2.6.15.  On little one- or
two-processor systems, the time required to measure the
migration costs isn't very noticeable, but by the time we
get to even a four-processor ia64 box, it adds about
30 seconds to the boot time, which seems like a lot.

Is that expected?  Is the information we get really worth
that much?  Could the measurement be done at run-time
instead?  Is there a smaller hammer we could use, e.g.,
flushing just the buffer rather than the *entire* cache?
Did we just implement sched_cacheflush() incorrectly for
ia64?

Only ia64, x86, and x86_64 currently have a non-empty
sched_cacheflush(), and the x86* ones contain only "wbinvd()".
So I suspect that only ia64 sees this slowdown.  But I would
guess that other arches will implement it in the future.

Bjorn
