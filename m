From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Tue, 05 Aug 2008 17:34:47 +0000
Subject: Re: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080805173447.GD7812@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com> <1217926585.3589.113.camel@twins>
In-Reply-To: <1217926585.3589.113.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@elte.hu, tony.luck@intel.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Bill Gatliff <bgat@billgatliff.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>

On 05.08.2008 [10:56:25 +0200], Peter Zijlstra wrote:
> On Mon, 2008-08-04 at 12:46 -0700, Nishanth Aravamudan wrote:
> > Bisection on an x455 (2-node IA64) showed that commit
> > 27ec4407790d075c325e1f4da0a19c56953cce23 (sched: make cpu_clock()
> > globally synchronous) broke booting. I see the uncompressing initramfs
> > message and then nothing on the console. I wait about 5 minutes (which
> > is way longer than it takes for the first console messages to get
> > printed normally). The commit immediately before it works fine.
> > 
> > The commit no longer cleanly reverts, but I tried to manually put things
> > back to the way they were before in cpu_clock(). The resulting kernel
> > boots fine. I could figure out a clean way to leave cpu_clock() in
> > sched_clock.c because of all the rq dependencies from sched.c. The
> > attempt I tested is below [1]. This patch is *NOT* for inclusion, just
> > to demonstrate what I tested.
> > 
> > I'm happy to test any better patches.
> 
> Does this work for you?
> 
> ---
> Subject: sched_clock: delay using sched_clock()
> 
> Some arch's can't handle sched_clock() being called too early - delay
> this until sched_clock_init() has been called.
> 
> Reported-by: Bill Gatliff <bgat@billgatliff.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Russell King - ARM Linux <linux@arm.linux.org.uk>

Yep, this fixes things on the box, as well.

Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
