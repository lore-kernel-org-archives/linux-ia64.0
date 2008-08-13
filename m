From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Aug 2008 00:37:28 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30844B26C@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
In-Reply-To: <20080804194646.GA17390@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>, "mingo@elte.hu" <mingo@elte.hu>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> I'm happy to test any better patches.

Linus just took a patch from my tree that should solve this
once and for all for ia64.

commit 10617bbe84628eb18ab5f723d3ba35005adde143
Author: Tony Luck <tony.luck@intel.com>
Date:   Tue Aug 12 10:34:20 2008 -0700

    [IA64] Ensure cpu0 can access per-cpu variables in early boot code


When you get a chance please test with your config against this
tree just to confirm that this is fixed.

Thanks

-Tony
