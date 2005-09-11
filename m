From: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>
Date: Sun, 11 Sep 2005 17:04:54 +0000
Subject: RE: [RFC] timer_interrupt: Avoid device timeouts by freezing time if system froze
Message-Id: <516F50407E01324991DD6D07B0531AD5695995@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509091501240.12956@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It seems like both "test for too much time passed"
and "recover from too much time passed" at least ought
to be out-of-line and easily overridden, e.g. by adding
a level of abstraction along the lines of default_idle.

> -----Original Message-----
> From: dmosberger@gmail.com [mailto:dmosberger@gmail.com] On 
> Behalf Of David Mosberger-Tang
> Sent: Friday, September 09, 2005 5:18 PM
> To: Christoph Lameter
> Cc: Magenheimer, Dan (HP Labs Fort Collins); 
> linux-ia64@vger.kernel.org
> Subject: Re: [RFC] timer_interrupt: Avoid device timeouts by 
> freezing time if system froze
> 
> I see your point about non-interrupt sources but the idea can be
> generalized: rather than letting time catch up in a single huge jump,
> do it gradually.  Say for every timer tick, you advance by one extra
> tick.  I _think_ that could work well in practice.
> 
>   --david
> 
> On 9/9/05, Christoph Lameter <clameter@engr.sgi.com> wrote:
> > On Fri, 9 Sep 2005, David Mosberger-Tang wrote:
> > 
> > > I also would be nervous about the proposed patch.
> > 
> > Yes, I am also a bit concerned but there seems to be no other
> > good solution.
> > 
> > > I'm wondering: could the problem be avoided perhaps by running all
> > > other pending (lower-priority) interrupts first when you detect a
> > > large jump in elapsed time?  In other words, when you 
> detect a jump
> > > from time T1 to T2 with (T2-T1) greater than some 
> threshold, you make
> > > sure you run all pending interrupts while still at time 
> T1 and only
> > > after that is done you let time catch up to T2.
> > 
> > I think we are not talking about hardware interupts. Those 
> can happen
> > anytime and given the system was frozen for an extended time period
> > likely have already completed before the timer interrupt happens for
> > the first time after the system begins to unfreeze.
> > 
> > I think the main issue are drivers events. These are 
> dependent on jiffies
> > (which may be checked by drivers in a varity of ways) or 
> are timer events
> > (which also may expect jiffies to have a certain value).
> > 
> 
> 
> -- 
> Mosberger Consulting LLC, voice/fax: 510-744-9372,
> http://www.mosberger-consulting.com/
> 35706 Runckel Lane, Fremont, CA 94536
> 
