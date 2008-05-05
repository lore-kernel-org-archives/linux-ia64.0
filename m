From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 05 May 2008 08:40:41 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1209976841.32260.11.camel@elijah.suse.cz>
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

You're right, this patch is not present in -mm1. I'm sorry for the
noise.

> and, I found easy reproduce way. 
> that is
> 
>       % pstack $$
> 
> Can you reproduce it?

Thank you for isolating the test case!

I tried SUSE Factory, which is a 2.6.25 (and was readily available to
me), and I could not reproduce it. I used gstack from gdb 6.6, because I
couldn't find a true pstack for Linux. I'm now compiling -mm1 to see if
it makes any difference. I can also try on a larger machine (the testing
one is a real small Altix 350 with 2 cores).

Regards,
Petr Tesarik

