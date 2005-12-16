From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Date: Fri, 16 Dec 2005 02:40:27 +0000
Subject: Re: [PATCH] ia64: disable preemption in udelay()
Message-Id: <Pine.LNX.4.64.0512151837480.20020@montezuma.fsmlabs.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051214232526.9039.15753.sendpatchset@tomahawk.engr.sgi.com>
 <20051215225040.GA9086@agluck-lia64.sc.intel.com>
 <Pine.LNX.4.64.0512151750500.1678@montezuma.fsmlabs.com>
 <1134698636.12086.222.camel@mindpipe> <00b201c601e6$30c87ff0$d6069aa3@johnhaonw7lw1r>
In-Reply-To: <00b201c601e6$30c87ff0$d6069aa3@johnhaonw7lw1r>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Hawkes <hawkes@sgi.com>
Cc: Lee Revell <rlrevell@joe-job.com>, "Luck, Tony" <tony.luck@intel.com>, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Keith Owens <kaos@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>

On Thu, 15 Dec 2005, John Hawkes wrote:

> From: "Lee Revell" <rlrevell@joe-job.com>
> > There are 10 drivers that udelay(10000) or more and a TON that
> > udelay(1000).  Turning those all into 1ms+ non preemptible sections will
> > be very bad.
> 
> What about 100usec non-preemptible sections?
> John Hawkes

100usec should be ok as a non-preemptible udelay is this 1 specific 
driver?

