From: David Miller <davem@davemloft.net>
Date: Mon, 04 Aug 2008 22:02:49 +0000
Subject: Re: [BISECTION RESULT] sched: revert cpu_clock to
Message-Id: <20080804.150249.71509974.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080804194646.GA17390@us.ibm.com>
	<57C9024A16AD2D4C97DC78E552063EA308328FB4@orsmsx505.amr.corp.intel.com>
	<57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA308329110@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: nacc@us.ibm.com, mingo@elte.hu, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 4 Aug 2008 15:00:47 -0700

> > I'd bet resonable sums of money that we are (once again) accessing
> > per-cpu variables in code before ia64 has a chance to initialize
> > things so that they can actually work. :-(
> 
> I tried this simple hack to check ... per-cpu variables are
> not usable until cpu_init() sets up the "ar.k3" register on
> ia64.  So this hack checks to see if it is set before calling
> cpu_clock():

Can you guys on IA64 possibly set ar.k3 simply to zero or to some
other similar value which cancels out the per-cpu computation?

That's what sparc64 and other platforms do.
