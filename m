From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Thu, 22 Jul 2004 06:16:17 +0000
Subject: Re: take2: [PATCH] Vector sharing (Large I/O system support)
Message-Id: <40FF5BB1.4070107@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE09B5.7020109@jp.fujitsu.com>
In-Reply-To: <40FE09B5.7020109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Kenji,
> Inside HP I've suggested linux use multiple vector domains
> (one CPU could belong in only one domain). Would that sufficiently
> solve this same problem or is someone hard coded to share a particular
> vector?

Hi Grant,

As far as I know, there are three methods to handle many
interrupt sources:

(1) Share a single RTE with multiple level-triggered interrupts (e.g.
multiple PCI devices share the same interrupt line). Of course,
current linux can handle it. Whether to use this method depend on
hardware design.

(2) Share a single vector with multiple RTEs. This is what my vector
sharing patch is doing.

(3) Use multiple vector domains on the multi-node system. This method
strongly depends on hardware design, and it will be implemented in the
architecture specific code. I guess SGI machine is using this method.

I guess the method you mentioned is extension of method (3), which
use multiple vector domains on a generic SMP machine (I'll call this
"method (4)" below). Is it correct?

I think method (4) is interesting and it would be able to solve the
same problem. I have discussed it a little with Bjorn Helgaas before.
(please see http://www.gelato.unsw.edu.au/linux-ia64/0404/9363.html)

However, method (4) will not work if system has only a few CPUs (or
it is an UP machine). So vector sharing is still needed. In addition,
though I have not investigated it much, I think there would be a lot
of issues need to be considered for method (4).
For example:

    o How to separate CPUs and devices into multiple vector domains
    o How to associate vector number with IRQ number
    o How to prepare multiple 'irq_desc' arrays for each vector domains
    o How to install interrupt handlers into each 'irq_desc'
    o Need to consider the case some CPUs are hot-removed
    o How to display the IRQ infomation through /proc filesystem

    and so on...

Most of those need a much time and a lot of changes to kernel.

After all, I think the good way is to implement vector sharing first,
and then consider the method (4) next. I beleave vector sharing and
method (4) can work together.

By the way, do you have specific reasons to suggest method (4)?
Performance issue?
And do you already have a patch for method (4)? If so, can I see
it?

Thanks,
Kenji Kaneshige

