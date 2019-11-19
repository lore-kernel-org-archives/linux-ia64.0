From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 19 Nov 2019 22:59:10 +0000
Subject: Re: [PATCH 04/12] ia64: Replace cpu_down with freeze_secondary_cpus
Message-Id: <alpine.DEB.2.21.1911192344110.6731@nanos.tec.linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191030153837.18107-1-qais.yousef@arm.com> <20191030153837.18107-5-qais.yousef@arm.com> <alpine.DEB.2.21.1911192318400.6731@nanos.tec.linutronix.de> <20191119223234.ov323rcln4slj7br@e107158-lin.cambridge.arm.com>
In-Reply-To: <20191119223234.ov323rcln4slj7br@e107158-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qais Yousef <qais.yousef@arm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 19 Nov 2019, Qais Yousef wrote:
> On 11/19/19 23:21, Thomas Gleixner wrote:
> > On Wed, 30 Oct 2019, Qais Yousef wrote:
> > >  void machine_shutdown(void)
> > >  {
> > >  #ifdef CONFIG_HOTPLUG_CPU
> > > -	int cpu;
> > > -
> > > -	for_each_online_cpu(cpu) {
> > > -		if (cpu != smp_processor_id())
> > > -			cpu_down(cpu);
> > > -	}
> > > +	/* TODO: Can we use disable_nonboot_cpus()? */
> > > +	freeze_secondary_cpus(smp_processor_id());
> > 
> > freeze_secondary_cpus() is only available for CONFIG_PM_SLEEP_SMP=y and
> > disable_nonboot_cpus() is a NOOP for CONFIG_PM_SLEEP_SMP=n :)
> 
> I thought I replied to this :-(
> 
> My plan was to simply make freeze_secondary_cpus() available and protected by
> CONFIG_SMP only instead.
> 
> Good plan?

No. freeze_secondary_cpus() is really for hibernation. Look at the exit
conditions there.

So you really want a seperate function which depends on CONFIG_HOTPLUG_CPU
and provides an inline stub for the CONFIG_HOTPLUG_CPU=n case.

But I have a hard time to see how that stuff works at all on
ia64:

  cpu_down() might sleep, i.e. it must be called from preemptible
  context. smp_processor_id() is invalid from preemtible context.

As this is obviously broken and ia64 is in keep compile mode only, it
should just go away.

Thanks,

	tglx
