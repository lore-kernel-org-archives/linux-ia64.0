From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Date: Fri, 16 Dec 2005 02:37:15 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <Pine.LNX.4.64.0512151835540.20020@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051214232526.9039.15753.sendpatchset@tomahawk.engr.sgi.com> 
 <20051215225040.GA9086@agluck-lia64.sc.intel.com> 
 <Pine.LNX.4.64.0512151750500.1678@montezuma.fsmlabs.com>
 <1134698636.12086.222.camel@mindpipe>
In-Reply-To: <1134698636.12086.222.camel@mindpipe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lee Revell <rlrevell@joe-job.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

On Thu, 15 Dec 2005, Lee Revell wrote:

> On Thu, 2005-12-15 at 17:52 -0800, Zwane Mwaikambo wrote:
> > 
> > If it's a preemptible sleep period it should just use msleep.
> 
> There are 10 drivers that udelay(10000) or more and a TON that
> udelay(1000).  Turning those all into 1ms+ non preemptible sections will
> be very bad.

What i said was _msleep_, if the driver is sleeping for 10ms and it can 
handle being preempted, you can switch it over to _msleep_. The original 
post was regarding making udelay non-preemptible.
