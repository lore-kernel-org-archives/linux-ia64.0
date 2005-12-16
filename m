From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Date: Fri, 16 Dec 2005 01:52:02 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <Pine.LNX.4.64.0512151750500.1678@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051214232526.9039.15753.sendpatchset@tomahawk.engr.sgi.com>
 <20051215225040.GA9086@agluck-lia64.sc.intel.com>
In-Reply-To: <20051215225040.GA9086@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

On Thu, 15 Dec 2005, Luck, Tony wrote:

> On Wed, Dec 14, 2005 at 03:25:26PM -0800, hawkes@sgi.com wrote:
> > Sending this to a wider audience:
> > 
> > The udelay() inline for ia64 uses the ITC.  If CONFIG_PREEMPT is enabled
> > and the platform has unsynchronized ITCs and the calling task migrates
> > to another CPU while doing the udelay loop, then the effective delay may
> > be too short or very, very long.
> > 
> > The most simple fix is to disable preemption around the udelay looping.
> > The downside is that this inhibits realtime preemption for cases of long
> > udelays.  One datapoint:  an SGI realtime engineer reports that if
> > CONFIG_PREEMPT is turned off, that no significant holdoffs are
> > are attributed to udelay().
> > 
> > I am reluctant to propose a much more complicated patch (that disables
> > preemption only for "short" delays, and uses the global RTC as the time
> > base for longer, preemptible delays) unless this patch introduces
> > significant and unacceptable preemption delays.
> 
> Stuck between a rock and the proverbial hard place.
> 
> I think that the more complex patch is needed though.  If some crazy
> driver has a pre-emptible udelay(10000), then you really don't want
> to spin for that long without allowing preemption.

If it's a preemptible sleep period it should just use msleep.
