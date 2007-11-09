From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 09 Nov 2007 18:40:31 +0000
Subject: Re: conflict between tickless and perfmon2
Message-Id: <alpine.LRH.0.999.0711091934210.1196@www.tglx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071109104438.GB18909@frankl.hpl.hp.com>
 <1194605991.6289.162.camel@twins>
In-Reply-To: <1194605991.6289.162.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: eranian@hpl.hp.com, perfmon2-devel@lists.sourceforge.net, perfmon@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>

On Fri, 9 Nov 2007, Peter Zijlstra wrote:

> On Fri, 2007-11-09 at 02:44 -0800, Stephane Eranian wrote:
> > Hello,
> > 
> > We have identified a conflict between TICKLESS (CONFIG_NO_HZ) and
> > the current perfmon2 implementation. The problem impacts system-wide
> > sessions using timeout-based event set multiplexing.
> > 
> > Event set multiplexing allows monitoring tools to measure more events
> > than there are actual performance counters on the processor. Events
> > are grouped in sets which are then multiplexed onto the actual counters.
> > Switching can be triggered either by a timeout or by a counter overflow.
> > This is supported for per-thread and system-wide sessions.
> > 
> > For timeout-based switching, the duration expressed in nanoseconds is
> > meant to represent wall-clock time in system-wide mode, and execution
> > time in per-thread mode. Granularity is limited by HZ.
> > 
> > The current implementation for timeout is a simple hook on the timer
> > interrupt path in apic_*.c:smp_local_timer_interrupt(). Unfortunately,
> > this does not work when tickless is enabled: we get much less set
> > switches than expected on an idle system.

What a surprise. :)

> > It looks like a solution would be to change the implementation of
> > timeout-based switching to use HR timers instead. Similar to what is
> > done for ITIMER_REAL and ITIMER_VIRTUAL.

Using a hrtimer is perfrectly fine, I'd say it's preferred over hooks in 
some code which has absoluty no guarantee of being executed periodically 
or even executed at all. OTOH it seems rather stupid to measure stuff 
while the system is idle and doing nothing.

	tglx

