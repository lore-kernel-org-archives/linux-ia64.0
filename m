From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 01 Jul 2011 13:43:42 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary physical addresses
Message-Id: <201107011543.43000.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<201106291106.00070.ptesarik@suse.cz>
	<20110701125802.GE12605@elte.hu>
In-Reply-To: <20110701125802.GE12605@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-arm-kernel@lists.infradead.org

Dne Pá 1. července 2011 14:58:02 Ingo Molnar napsal(a):
> * Petr Tesarik <ptesarik@suse.cz> wrote:
> > Dne Pá 17. června 2011 11:30:32 Ingo Molnar napsal(a):
> > > * Petr Tesarik <ptesarik@suse.cz> wrote:
> > > > This patch series enhances /dev/mem, so that read and write is
> > > > possible at any address. The patchset includes actual
> > > > implementation for x86.
> > > 
> > > This series lacks a description of why this is desired.
> > >
> > >[...]
> > >
> > > Are you aware of any legitimate usecases?
> > 
> > Looking back at the mail tread, I'd say there are people who have
> > legitimate usecases. However, this may not be the most important
> > question. At the moment, the /dev/mem interface is broken (it
> > doesn't implement the specification correctly), and my patchset
> > fixes it.
> > 
> > If there are no technical objections, [...]
> 
> Well, my objections were entirely technical:
> 
>  - the device never implemented above-4G support upstream
> 
>  - there's colorful variants of abuse (drivers with binary-only
>    userspace) even if we ignore the obvious fact that the
>    main use of /dev/mem today is /dev/rootkit ...
> 
> Now my objections might be outweighed by the advantages of improving
> this driver, but you misrepresenting my position really does not help
> that process.
> 
> So what was not mentioned in your series, what is *your* motivation
> and your usecase? Enabling closed-source userspace drivers? Enabling
> the crash utility?

I think I made it clear that my use-case is enabling the crash utility. But I 
can re-state it now, no problem. ;)

> If the former then shame on you, if the latter then how do you
> explain that distros appear to disable the RAM aspect of /dev/mem:
> 
>  $ grep DEVMEM $(rpm -ql kernel-2.6.38-0.rc7.git2.3.fc16.x86_64 | grep
> config-2.6 ) CONFIG_STRICT_DEVMEM=y

I've already addressed this point as well. Fedora and RHEL ship with 
CONFIG_STRICT_DEVMEM=y. openSUSE and SLES ship with CONFIG_STRICT_DEVMEM=n.

> So the crash utility use-case does not work on unpatched, default
> kernels, right?

Right. And even told you how RedHat "solved" that issue. They re-implemented 
the /dev/mem driver and called it /dev/crash. RHEL4 and RHEL5 included this as 
a separate module (called crash.ko), so you can at least blacklist it. With 
RHEL6, the driver is built into the kernel, so it's probably always there.

In short, if you're breaking into a system, remember to symlink /dev/rootkit 
to /dev/crash instead of /dev/mem, and your rootkit will continue to work. 
Anyway, I fail to see how this can be a problem. To acces /dev/mem you must 
have root privileges already, so what else does it protect?

> As i said i have no problem with extending this, as long as it
> couples to a non-default flag (for example !STRICT_DEVMEM or a boot
> flag) and thus does not extend by default and does not extend the
> abuse.

I'm not sure what you mean. If you have a kernel compiled with 
CONFIG_STRICT_DEVMEM, then my patchset doesn't change anything in practice 
(unless you have an MMIO device mapped above 4G, in which case it will allow 
you to program it by writing to /dev/mem, instead of wrapping around to a 
random area in the first 4G and corrupting innocent data).

Hope that helps,
Petr Tesarik

> > @Ingo: you can also send a patchset that rips off the /dev/mem
> > driver completely if you believe that would get through. [...]
> 
> Why would we want to do that? Existing users can become more and more
> obsolete just fine.
> 
> What i'm asking for is to not enable new abuse by default ...
> 
> Thanks,
> 
> 	Ingo
