From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Wed, 13 Aug 2008 19:29:09 +0000
Subject: Re: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080813192909.GA31685@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com> <57C9024A16AD2D4C97DC78E552063EA30844B26C@orsmsx505.amr.corp.intel.com> <20080813162553.GA5720@elte.hu>
In-Reply-To: <20080813162553.GA5720@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 13.08.2008 [18:25:53 +0200], Ingo Molnar wrote:
> 
> * Luck, Tony <tony.luck@intel.com> wrote:
> 
> > > I'm happy to test any better patches.
> > 
> > Linus just took a patch from my tree that should solve this
> > once and for all for ia64.
> > 
> > commit 10617bbe84628eb18ab5f723d3ba35005adde143
> > Author: Tony Luck <tony.luck@intel.com>
> > Date:   Tue Aug 12 10:34:20 2008 -0700
> > 
> >     [IA64] Ensure cpu0 can access per-cpu variables in early boot code
> > 
> > 
> > When you get a chance please test with your config against this
> > tree just to confirm that this is fixed.
> 
> there's also Peter's other patch upstream since yesterday (and included 
> in -rc3) which should solve the same problem:
> 
> | commit c1955a3d4762e7a9bf84035eb3c4886a900f0d15
> | Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
> | Date:   Mon Aug 11 08:59:03 2008 +0200
> |
> |    sched_clock: delay using sched_clock()
> |
> |    Some arch's can't handle sched_clock() being called too early - delay
> |    this until sched_clock_init() has been called.
> 
> so i'd be mighty surprised if this dual firepower of commits didnt at 
> least weaken this bug somewhat! ;-)

Well Peter's patch was tested-by me, so I know it fixes the problem on
the box I have access to, I'm verifying that -rc3 is ok.

Tony, would you like me to test your patch in isolation (reverting
c1955a3d4762e7a9bf84035eb3c4886a900f0d15) to see if it also fixes it?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
