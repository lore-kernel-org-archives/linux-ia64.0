From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 06 Jan 2009 20:34:06 +0000
Subject: RE: [PATCH] configure HAVE_UNSTABLE_SCHED_CLOCK for SGI_SN systems
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35CB955B4@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090106162741.GA7991@sgi.com>
 <57C9024A16AD2D4C97DC78E552063EA35CB95575@orsmsx505.amr.corp.intel.com>
 <20090106201950.GA3850@sgi.com>
In-Reply-To: <20090106201950.GA3850@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Robin Holt <holt@sgi.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Greg KH <greg@kroah.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Gregory Haskins <ghaskins@novell.com>, Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@gmail.com>

> > All ia64 systems are potentially affected ... but perhaps you might
> > never see the problem on most because the itc clocks are synced as close
> > as s/w can get them when cpus are brought on line.
>
> Do you want Dimitri to resubmit with this set for all IA64 or leave it
> as is?

I'd like to understand the impact of turning on HAVE_UNSTABLE_SCHED_CLOCK

It looks like both the i386_defconfig and x86_64_defconfig choose this,
so at least ia64 will be hitting the well tested code paths

Have the other architectures just not hit this yet?  Or do they all have
"stable" sched_clock() functions?


sched_clock() seemed like such a straightforward thing to begin with. A
quick & easy way to measure a time delta ON THE SAME CPU.  I'm not at
all sure why it has been co-opted for general time measurement.

-Tony
