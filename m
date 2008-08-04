From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Mon, 04 Aug 2008 22:45:33 +0000
Subject: Re: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080804224533.GC30096@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com> <57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com> <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "mingo@elte.hu" <mingo@elte.hu>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 04.08.2008 [15:00:47 -0700], Luck, Tony wrote:
> > I'd bet resonable sums of money that we are (once again) accessing
> > per-cpu variables in code before ia64 has a chance to initialize
> > things so that they can actually work. :-(
> 
> I tried this simple hack to check ... per-cpu variables are
> not usable until cpu_init() sets up the "ar.k3" register on
> ia64.  So this hack checks to see if it is set before calling
> cpu_clock():

Would you like me to test this patch on the box, to verify? It seems
like you were able to reproduce the non-booting kernel?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
