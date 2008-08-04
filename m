From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Mon, 04 Aug 2008 23:30:18 +0000
Subject: Re: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080804233018.GD30096@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com> <57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com> <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com> <20080804224533.GC30096@us.ibm.com> <57C9024A16AD2D4C97DC78E552063EA3083291DF@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3083291DF@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "mingo@elte.hu" <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 04.08.2008 [15:53:03 -0700], Luck, Tony wrote:
> > Would you like me to test this patch on the box, to verify? It seems
> > like you were able to reproduce the non-booting kernel?
> 
> As soon as I turned on CONFIG_PRINTK_TIME=y I hit what I presume was
> the same problem.
> 
> If you have time to do so, then confirming that this is the same issue
> that you are seeing on your system would be good.

Turning off PRINTK_TIME or using your patch allows this box to boot, so
I think it is the same.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
