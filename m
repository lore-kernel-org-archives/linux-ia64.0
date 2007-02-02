From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Fri, 02 Feb 2007 11:53:00 +0000
Subject: Re: [PATCH] kexec: Fix CONFIG_SMP=n compilation (ia64)
Message-Id: <aec7e5c30702020353h31fe9287nbf63612819a8c08f@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070201131347.3807.87075.sendpatchset@localhost>
	 <20070201163320.eb4fa2c7.akpm@osdl.org>
	 <aec7e5c30702011838g6e9edd23sc782321aacb07297@mail.gmail.com>
In-Reply-To: <aec7e5c30702011838g6e9edd23sc782321aacb07297@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, fastboot@lists.osdl.org, nanhai.zou@intel.com

On 2/2/07, Magnus Damm <magnus.damm@gmail.com> wrote:
> On 2/2/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > Magnus Damm <magnus@valinux.co.jp> wrote:
> >
> > > kexec: Fix CONFIG_SMP=n compilation (ia64)
> > >
> > > This patch makes it possible to compile kexec for ia64 without SMP support.
> > > --- 0002/arch/ia64/kernel/machine_kexec.c
> > > +++ work/arch/ia64/kernel/machine_kexec.c     2007-02-01 12:35:46.000000000 +0900
> > > @@ -70,12 +70,14 @@ void machine_kexec_cleanup(struct kimage
> > >
> > >  void machine_shutdown(void)
> > >  {
> > > +#ifdef CONFIG_SMP
> > >       int cpu;
> > >
> > >       for_each_online_cpu(cpu) {
> > >               if (cpu != smp_processor_id())
> > >                       cpu_down(cpu);
> > >       }
> > > +#endif
> > >       kexec_disable_iosapic();
> > >  }
> >
> > hm.  I suspect this one should have been #ifndef CONFIG_HOTPLUG_CPU?

Re-reading this I assume you mean #ifdef CONFIG_HOTPLUG_CPU.

I would be happy to resend a new updated version of the patch, but I
wonder if it may be better to fail miserably during the build than
fail silently in the case of CONFIG_SMP=y but CONFIG_HOTPLUG_CPU=n.

Any ideas?

Nan hai, is there any particular reason why the ia64 kexec code builds
on top of cpu hotplug instead of smp functions such as
smp_send_stop()?

Thanks!

/ magnus
