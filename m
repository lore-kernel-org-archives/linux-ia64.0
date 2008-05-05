From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 05 May 2008 18:37:20 +0000
Subject: RE: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1FE6DD409037234FAB833C420AA843EC014389BD@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> and, I found easy reproduce way. 
> that is
>
>      % pstack $$
>
> Can you reproduce it?

I tried 2.6.26-rc1 (actually about 50 commits past -rc1 as pulled
from kernel.org this morning) and could not reproduce this.

I was using the pstack(1) that shipped with Redhat EL4.5

I ran thousands of "pstack $$" with the system:
1) idle
2) busy (running kernel build with make -j16)
3) swapping (running hackbench)

and did not see the "BUG: sleeping function" message.

So Seto-san is off the hook (his patch is definitely in -rc1).

This is probably some other patch in -mm ... unless there is
something different about your .config.  Do you have PREEMPT
enabled (or anything else that looks "interesting" for this
problem)?

-Tony
