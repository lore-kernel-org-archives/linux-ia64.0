From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 05 May 2008 15:48:31 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1210002511.32260.22.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2008-05-05 at 00:47 +0900, KOSAKI Motohiro wrote:
> Hi Tony-san,
> 
> > > > This surely is a bug. I bet this was introduced by Hidetoshi's latest
> > > > commit:
> > > >
> > > > commit 38477ad75188b2a7370fef7145f956e6c446928b
> > > > Author: Hidetoshi Seto
> > > > Date:   Mon Apr 21 14:34:39 2008 -0700
> > > >
> > > >    [IA64] disable interrupts on exit of ia64_trace_syscall
> > > 
> > > Can you try reverting this patch and re-running the
> > > same stress tests?
> > 
> > OK, I'll try it at head of next week.
> 
> Hmmm,
> if I am not stupid, I think 2.6.25-mm1 doesn't contain this patch.
> I am very confusing now...
> 
> 
> and, I found easy reproduce way. 
> that is
> 
>       % pstack $$
> 
> Can you reproduce it?

Oh, by the way, could it be related to Stephen Eranian's note on
do_notify_resume_user being called too frequently? In other words, are
you running with perfmon?

Petr
