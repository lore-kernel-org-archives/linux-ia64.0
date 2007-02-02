From: "Magnus Damm" <magnus.damm@gmail.com>
Date: Fri, 02 Feb 2007 02:38:51 +0000
Subject: Re: [PATCH] kexec: Fix CONFIG_SMP=n compilation (ia64)
Message-Id: <aec7e5c30702011838g6e9edd23sc782321aacb07297@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070201131347.3807.87075.sendpatchset@localhost>
	 <20070201163320.eb4fa2c7.akpm@osdl.org>
In-Reply-To: <20070201163320.eb4fa2c7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, fastboot@lists.osdl.org

On 2/2/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> (added ia64 list)
> (added ia64 maintainer)
> (added kexec list)

Sorry about that.

> On Thu, 01 Feb 2007 22:13:47 +0900
> Magnus Damm <magnus@valinux.co.jp> wrote:
>
> > kexec: Fix CONFIG_SMP=n compilation (ia64)
> >
> > This patch makes it possible to compile kexec for ia64 without SMP support.
> >
>
> Please always include the compiler stderr when fixing build errors or
> warnings.

Ok, will do. With CONFIG_SMP=n and CONFIG_HOTPLUG_CPU=n:

  CC      arch/ia64/kernel/machine_kexec.o
arch/ia64/kernel/machine_kexec.c: In function `machine_shutdown':
arch/ia64/kernel/machine_kexec.c:77: warning: implicit declaration of
function `cpu_down'
  AS      arch/ia64/kernel/relocate_kernel.o
  CC      arch/ia64/kernel/crash.o
arch/ia64/kernel/crash.c: In function `kdump_cpu_freeze':
arch/ia64/kernel/crash.c:139: warning: implicit declaration of
function `ia64_jump_to_sal'
arch/ia64/kernel/crash.c:139: error: `sal_boot_rendez_state'
undeclared (first use in this function)
arch/ia64/kernel/crash.c:139: error: (Each undeclared identifier is
reported only once
arch/ia64/kernel/crash.c:139: error: for each function it appears in.)
arch/ia64/kernel/crash.c: At top level:
arch/ia64/kernel/crash.c:84: warning: 'kdump_wait_cpu_freeze' defined
but not used
make[1]: *** [arch/ia64/kernel/crash.o] Error 1
make: *** [arch/ia64/kernel] Error 2
damm@localhost ~/build/kernel/linux-2.6.20-rc7 $

> > --- 0002/arch/ia64/kernel/crash.c
> > +++ work/arch/ia64/kernel/crash.c     2007-02-01 12:42:38.000000000 +0900
> > @@ -79,6 +79,7 @@ crash_save_this_cpu()
> >       final_note(buf);
> >  }
> >
> > +#ifdef CONFIG_SMP
> >  static int
> >  kdump_wait_cpu_freeze(void)
> >  {
> > @@ -91,6 +92,7 @@ kdump_wait_cpu_freeze(void)
> >       }
> >       return 1;
> >  }
> > +#endif
>
> I think this is a warning fix?

Yes. The file already has some CONFIG_SMP #ifdeffery in it but not
enough to compile properly.

> >  void
> >  machine_crash_shutdown(struct pt_regs *pt)
> > @@ -132,11 +134,12 @@ kdump_cpu_freeze(struct unw_frame_info *
> >       atomic_inc(&kdump_cpu_freezed);
> >       kdump_status[cpuid] = 1;
> >       mb();
> > -     if (cpuid = 0) {
> > -             for (;;)
> > -                     cpu_relax();
> > -     } else
> > +#ifdef CONFIG_HOTPLUG_CPU
> > +     if (cpuid != 0)
> >               ia64_jump_to_sal(&sal_boot_rendez_state[cpuid]);
> > +#endif
> > +     for (;;)
> > +             cpu_relax();
> >  }
>
> I trust ia64_jump_to_sal doesn't return.

So do I. The main problem with the compilation seems to be that
ia64_jump_to_sal() only exists if CONFIG_HOTPLUG_CPU=y.
(include/asm-ia64/sal.h, arch/ia64/kernel/head.S)

> >  static int
> > --- 0002/arch/ia64/kernel/machine_kexec.c
> > +++ work/arch/ia64/kernel/machine_kexec.c     2007-02-01 12:35:46.000000000 +0900
> > @@ -70,12 +70,14 @@ void machine_kexec_cleanup(struct kimage
> >
> >  void machine_shutdown(void)
> >  {
> > +#ifdef CONFIG_SMP
> >       int cpu;
> >
> >       for_each_online_cpu(cpu) {
> >               if (cpu != smp_processor_id())
> >                       cpu_down(cpu);
> >       }
> > +#endif
> >       kexec_disable_iosapic();
> >  }
>
> hm.  I suspect this one should have been #ifndef CONFIG_HOTPLUG_CPU?

Yes, you are right.
Maybe we can replace the entire code block above with smp_send_stop()
later on? That would make the code more similar to the i386 and x86_64
code.

> I was wondering if we should have stubs for cpu_down() if !CONFIG_HOTPLUG_CPU,
> but perhaps that doesn't make sense.

cpu_down() is only used in a few places so I don't think it's worth it.

I wonder why cpu_down() isn't marked as __cpuexit. Maybe because it is
already wrapped in CONFIG_HOTPLUG_CPU.

Thanks!

/ magnus
