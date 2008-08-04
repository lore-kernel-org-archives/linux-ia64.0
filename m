From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 20:37:52 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
In-Reply-To: <20080804194646.GA17390@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> Bisection on an x455 (2-node IA64) showed that commit
> 27ec4407790d075c325e1f4da0a19c56953cce23 (sched: make cpu_clock()
> globally synchronous) broke booting.

I'd bet resonable sums of money that we are (once again) accessing
per-cpu variables in code before ia64 has a chance to initialize
things so that they can actually work. :-(

-Tony
