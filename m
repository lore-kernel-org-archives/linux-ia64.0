From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 09 Nov 2007 20:17:11 +0000
Subject: Re: conflict between tickless and perfmon2
Message-Id: <20071109201711.GA20390@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071109104438.GB18909@frankl.hpl.hp.com> <1194605991.6289.162.camel@twins> <alpine.LRH.0.999.0711091934210.1196@www.tglx.de>
In-Reply-To: <alpine.LRH.0.999.0711091934210.1196@www.tglx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, perfmon2-devel@lists.sourceforge.net, perfmon@napali.hpl.hp.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Ingo Molnar <mingo@elte.hu>

Thomas,

On Fri, Nov 09, 2007 at 07:40:31PM +0100, Thomas Gleixner wrote:
> 
> > > It looks like a solution would be to change the implementation of
> > > timeout-based switching to use HR timers instead. Similar to what is
> > > done for ITIMER_REAL and ITIMER_VIRTUAL.
> 
> Using a hrtimer is perfrectly fine, I'd say it's preferred over hooks in 
> some code which has absoluty no guarantee of being executed periodically 
> or even executed at all. OTOH it seems rather stupid to measure stuff 
> while the system is idle and doing nothing.
> 
I'll start looking into this soon. To answer your point about idle,
this is not because the core is idle that counters do not capture events
related to buses or caches for instance.

-- 
-Stephane
