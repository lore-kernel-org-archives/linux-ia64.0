From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 29 Aug 2006 16:13:46 +0000
Subject: idle notifier question
Message-Id: <20060829161346.GL22011@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

In the context of perfmon (and the effort to merge it with mainline),
I am looking at adding support for notification on idle. Basically,
you can register a call back when entering the idle() loop and another
callback when you leave. The callback is surrounding the lowest level
of the idle loop, typically where you go low-power. The callback
covers interrupts that get you out of idle.

Why is this useful for perfmon?

When measuring in system-wide, it is interesting to exclude the useless
execution inside the idle loop. Originally, this meant not counting during
the cycle-burning idle loop. However we are interested in measuring any
interrupt triggered execution in the context of the idle loop.
These days, there is no cycle burning loop anymore but rather the CPU goes
into low power mode. That has an impact on the performance counters.
Depending on the architecture, the PMU may be fully stopped, sometimes only
certain counters are stopped (based on the event they measure), sometimes there
are firmware bugs. In order to provide a uniform interface across all platforms,
we could leverage the idle notification mechanism to explicitely start/stop
monitoring when going in the lowest-level of the idle loop (i.e., low-power).

This callback notification for idle already exists on x86-64. I am
working on adding it to i386. I would need to add it to IA-64 as well.

Looking at cpu_idle(), I see there is already some callback mechanism,
with the mark_idle function pointer. It seems to be used only for the
SGI machines. The way it is currently setup, the entry callback is
invoked only when a task is blocking. I am not sure of the intent
here. I am wondering if the existing callback could also work
with the idle notification scheme.

Any idea?

-- 
-Stephane
