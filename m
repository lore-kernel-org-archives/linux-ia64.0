From: "David Mosberger-Tang" <dmosberger@gmail.com>
Date: Wed, 01 Aug 2007 13:44:31 +0000
Subject: Re: [PATCH] flush icache before set_pte take6. [4/4] optimization for cpus other than montecito
Message-Id: <ed5aea430708010644t5eb961f3nb133354ee5cb071a@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A020E3B1C@scsmsx411.amr.corp.intel.com>
	 <46B0549A.1010308@bull.net>
In-Reply-To: <46B0549A.1010308@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>

On 8/1/07, Zoltan Menyhart <Zoltan.Menyhart@bull.net> wrote:

> You do have model specific I cache semantics.
> Not taking it into account will oblige you to flush in vain for the models
> which do not require it. Why do you want to take this option?

Given unlimited resources, your proposal makes perfect sense.  We
could have a Linux version for Merced, one for McKinley, one for
Madison, etc., etc.

(Un)fortunately, resources are limited and with that constraint in
place, rather than spending lots of time optimizing the kernel for
particular idiosyncrasies of a CPU model, it is generally much better
to optimize it for the things the hardware designers promised us would
stay the same across CPU models (i.e., the "architecture").  Sure, it
may mean that on occasion certain things are slightly slower than they
could be but it does have the decided advantage of letting the
maintainers sleep at night... ;-)  Moreover, higher-level
optimizations usually have much higher payoff, so even though you may
do things a bit more slowly at the lowest level, you may end up with a
faster system overall because you were able to spend more time
optimizing at a higher level.

  --david
