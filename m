From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 09 Nov 2007 10:44:38 +0000
Subject: conflict between tickless and perfmon2
Message-Id: <20071109104438.GB18909@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: perfmon2-devel@lists.sourceforge.net
Cc: perfmon@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Stephane Eranian <eranian@hpl.hp.com>

Hello,

We have identified a conflict between TICKLESS (CONFIG_NO_HZ) and
the current perfmon2 implementation. The problem impacts system-wide
sessions using timeout-based event set multiplexing.

Event set multiplexing allows monitoring tools to measure more events
than there are actual performance counters on the processor. Events
are grouped in sets which are then multiplexed onto the actual counters.
Switching can be triggered either by a timeout or by a counter overflow.
This is supported for per-thread and system-wide sessions.

For timeout-based switching, the duration expressed in nanoseconds is
meant to represent wall-clock time in system-wide mode, and execution
time in per-thread mode. Granularity is limited by HZ.

The current implementation for timeout is a simple hook on the timer
interrupt path in apic_*.c:smp_local_timer_interrupt(). Unfortunately,
this does not work when tickless is enabled: we get much less set
switches than expected on an idle system.

It looks like a solution would be to change the implementation of
timeout-based switching to use HR timers instead. Similar to what is
done for ITIMER_REAL and ITIMER_VIRTUAL.

Unless someone has a better proposal, I will experiment with this on
2.6.24-rc2.

Thanks.

-- 
-Stephane
