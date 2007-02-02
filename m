From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 02 Feb 2007 00:33:20 +0000
Subject: Re: [PATCH] kexec: Fix CONFIG_SMP=n compilation (ia64)
Message-Id: <20070201163320.eb4fa2c7.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070201131347.3807.87075.sendpatchset@localhost>
In-Reply-To: <20070201131347.3807.87075.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, fastboot@lists.osdl.org


(added ia64 list)
(added ia64 maintainer)
(added kexec list)

On Thu, 01 Feb 2007 22:13:47 +0900
Magnus Damm <magnus@valinux.co.jp> wrote:

> kexec: Fix CONFIG_SMP=n compilation (ia64)
> 
> This patch makes it possible to compile kexec for ia64 without SMP support.
> 

Please always include the compiler stderr when fixing build errors or
warnings.

> 
>  Applies on top of 2.6.20-rc7.
> 
>  arch/ia64/kernel/crash.c         |   11 +++++++----
>  arch/ia64/kernel/machine_kexec.c |    2 ++
>  2 files changed, 9 insertions(+), 4 deletions(-)
> 
> --- 0002/arch/ia64/kernel/crash.c
> +++ work/arch/ia64/kernel/crash.c	2007-02-01 12:42:38.000000000 +0900
> @@ -79,6 +79,7 @@ crash_save_this_cpu()
>  	final_note(buf);
>  }
>  
> +#ifdef CONFIG_SMP
>  static int
>  kdump_wait_cpu_freeze(void)
>  {
> @@ -91,6 +92,7 @@ kdump_wait_cpu_freeze(void)
>  	}
>  	return 1;
>  }
> +#endif

I think this is a warning fix?

>  void
>  machine_crash_shutdown(struct pt_regs *pt)
> @@ -132,11 +134,12 @@ kdump_cpu_freeze(struct unw_frame_info *
>  	atomic_inc(&kdump_cpu_freezed);
>  	kdump_status[cpuid] = 1;
>  	mb();
> -	if (cpuid = 0) {
> -		for (;;)
> -			cpu_relax();
> -	} else
> +#ifdef CONFIG_HOTPLUG_CPU
> +	if (cpuid != 0)
>  		ia64_jump_to_sal(&sal_boot_rendez_state[cpuid]);
> +#endif
> +	for (;;)
> +		cpu_relax();
>  }

I trust ia64_jump_to_sal doesn't return.

>  static int
> --- 0002/arch/ia64/kernel/machine_kexec.c
> +++ work/arch/ia64/kernel/machine_kexec.c	2007-02-01 12:35:46.000000000 +0900
> @@ -70,12 +70,14 @@ void machine_kexec_cleanup(struct kimage
>  
>  void machine_shutdown(void)
>  {
> +#ifdef CONFIG_SMP
>  	int cpu;
>  
>  	for_each_online_cpu(cpu) {
>  		if (cpu != smp_processor_id())
>  			cpu_down(cpu);
>  	}
> +#endif
>  	kexec_disable_iosapic();
>  }

hm.  I suspect this one should have been #ifndef CONFIG_HOTPLUG_CPU?

I was wondering if we should have stubs for cpu_down() if !CONFIG_HOTPLUG_CPU,
but perhaps that doesn't make sense.

