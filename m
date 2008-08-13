From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Aug 2008 20:11:45 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3084A65FD@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
 <57C9024A16AD2D4C97DC78E552063EA30844B26C@orsmsx505.amr.corp.intel.com>
 <20080813162553.GA5720@elte.hu> <20080813192909.GA31685@us.ibm.com>
In-Reply-To: <20080813192909.GA31685@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>, Ingo Molnar <mingo@elte.hu>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> Well Peter's patch was tested-by me, so I know it fixes the problem on
> the box I have access to, I'm verifying that -rc3 is ok.
>
> Tony, would you like me to test your patch in isolation (reverting
> c1955a3d4762e7a9bf84035eb3c4886a900f0d15) to see if it also fixes it?

It would be nice to know ... I expect that you'll see crazy numbers
for the timestamps on the first few printk()s without Peter's fix (I
did on my system).

-Tony
