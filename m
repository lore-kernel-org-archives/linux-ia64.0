From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 03 May 2008 07:28:40 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <20080503162758.6425.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > This surely is a bug. I bet this was introduced by Hidetoshi's latest
> > commit:
> >
> > commit 38477ad75188b2a7370fef7145f956e6c446928b
> > Author: Hidetoshi Seto
> > Date:   Mon Apr 21 14:34:39 2008 -0700
> >
> >    [IA64] disable interrupts on exit of ia64_trace_syscall
> 
> Can you try reverting this patch and re-running the
> same stress tests?

OK, I'll try it at head of next week.

Thank you!




