From: Erich Focht <efocht@ess.nec.de>
Date: Tue, 16 Jul 2002 16:23:52 +0000
Subject: [Linux-ia64] O(1) scheduler for 2.4.18-ia64
Message-Id: <marc-linux-ia64-105590701905778@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

for those working with IA64 systems: at
  http://home.arcor.de/efocht/sched/MQO1_ia64-ef7-2.4.18.patch.bz2
you can find a port of the O(1) scheduler. It is the "old" one, i.e.
not having SCHED_BATCH, etc. But it has some important changes compared
to my last port:

  - Uses the "complex" macros which release the RQ lock before switching
    context. This is a MUST on IA64, as there is a potential deadlock
    when the context numbers are wrapped around.

  - cpu_idle() is changed such that platforms which just return from
    pm_idle() don't call schedule() in a tight loop. This was the reason
    for massive cache line bouncings when some CPUs were idle as they
    not only locked their RQs but also loaded nr_running (on the same cache
    line as the lock) for every other RQ. The position of nr_running inside
    the RQ structure is changed, such that it doesn't share the cacheline
    with lock.

  - load_balance() only steals at most one task. Before it could sometimes
    steal half of the tasks of the most loaded CPU. This is OK on small
    machines but on large ones the tasks were bounced around a while until
    "settling" on a particular CPU. Maybe this is not yet optimal, but it
    improves hackbench results.

The patch applies to  2.4.18  +  4th ia64 patch from David. It also can
be applied to the vanilla 2.4.18, (kernel/timer.c needs to be edited by
hand), but this port is not intended to be an alternative to Robert Love's
backports... It is for IA64 and/or the node affine scheduler.

Best regards,

Erich


