From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 22:53:03 +0000
Subject: RE: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3083291DF@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
 <57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com>
 <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
 <20080804224533.GC30096@us.ibm.com>
In-Reply-To: <20080804224533.GC30096@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: "mingo@elte.hu" <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> Would you like me to test this patch on the box, to verify? It seems
> like you were able to reproduce the non-booting kernel?

As soon as I turned on CONFIG_PRINTK_TIME=y I hit what I presume
was the same problem.

If you have time to do so, then confirming that this is the
same issue that you are seeing on your system would be good.

Thanks

-Tony
