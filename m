From: Grant Grundler <iod00d@hp.com>
Date: Thu, 22 Jul 2004 16:16:00 +0000
Subject: Re: take2: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <20040722161600.GB24487@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE09B5.7020109@jp.fujitsu.com>
In-Reply-To: <40FE09B5.7020109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kenji,
thank you. I'll try answer your questions below. 

On Thu, Jul 22, 2004 at 03:16:17PM +0900, Kenji Kaneshige wrote:
...
> (3) Use multiple vector domains on the multi-node system. This method
> strongly depends on hardware design, and it will be implemented in the
> architecture specific code. I guess SGI machine is using this method.
> 
> I guess the method you mentioned is extension of method (3), which
> use multiple vector domains on a generic SMP machine (I'll call this
> "method (4)" below). Is it correct?

Yes.

> I think method (4) is interesting and it would be able to solve the
> same problem. I have discussed it a little with Bjorn Helgaas before.
> (please see http://www.gelato.unsw.edu.au/linux-ia64/0404/9363.html)
> 
> However, method (4) will not work if system has only a few CPUs (or
> it is an UP machine).

I'll argue that a system with 1 CPU and is consuming 256 vectors
is just not going to work well. The patch you submitted just
enables this to work, but poorly (your patch is fine, just the result
it enables is not IMHO). I personally don't agree we need to
support such a poor configuration. If david thinks we should,
then I'm not going to argue.

> So vector sharing is still needed. In addition,
> though I have not investigated it much, I think there would be a lot
> of issues need to be considered for method (4).
> For example:
> 
>    o How to separate CPUs and devices into multiple vector domains

We assume one domain now and assign devices to CPU in round robin.
No different for multiple vector domains.

>    o How to associate vector number with IRQ number

ditto.

>    o How to prepare multiple 'irq_desc' arrays for each vector domains

No sure what this means offhand...but assume it's just more code.

>    o How to install interrupt handlers into each 'irq_desc'

Same as now (via request_irq())

>    o Need to consider the case some CPUs are hot-removed

Yes - vector domain need to go away when last CPU is removed from it.

>    o How to display the IRQ infomation through /proc filesystem

Same as now (ie global IRQ #)

> 
>    and so on...
> 
> Most of those need a much time and a lot of changes to kernel.

That's probably true. But the advantage is simpler and shorter
code path when handling interrupts on large configs. I would think
this is more important than all the trouble the setup causes.

> 
> After all, I think the good way is to implement vector sharing first,
> and then consider the method (4) next. I beleave vector sharing and
> method (4) can work together.

I agree.

> By the way, do you have specific reasons to suggest method (4)?
> Performance issue?

Yes.

> And do you already have a patch for method (4)? If so, can I see
> it?

I don't. It will have to wait until OLS2005 (or some other conf that
my management endorses). But I've played enough with IRQ code on parisc
(both HPUX and parisc-linux) to understand the code path pretty well.

A few years ago, I shortened the interrupt code pathes in HPUX 
by removing a switch statement and one/two if () tests.
netperf TCP_RR test improved ~20%. (One interrupt/packet
at the time, IIRC).

Interrupt mitigation helps avoid this cost (as does NAPI) and
I'm aware most workloads attempt to avoid interrupts when possible.
But I still believe there are workloads that will generate
lots of interrupts - eg 10GiGE - and are latency sensitive.

thanks,
grant


> Thanks,
> Kenji Kaneshige
