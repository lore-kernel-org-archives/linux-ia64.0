From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Date: Tue, 21 Jan 2020 17:03:50 +0000
Subject: Re: [PATCH v2 01/14] smp: Create a new function to shutdown nonboot cpus
Message-Id: <20200121170350.GC18808@shell.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191125112754.25223-1-qais.yousef@arm.com>
 <20191125112754.25223-2-qais.yousef@arm.com>
In-Reply-To: <20191125112754.25223-2-qais.yousef@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qais Yousef <qais.yousef@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Ingo Molnar <mingo@kernel.org>, Eiichi Tsukata <devel@etsukata.com>, Zhenzhong Duan <zhenzhong.duan@oracle.com>, Nadav Amit <namit@vmware.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 25, 2019 at 11:27:41AM +0000, Qais Yousef wrote:
> This function will be used later in machine_shutdown() for some archs.
> 
> Signed-off-by: Qais Yousef <qais.yousef@arm.com>
> CC: Thomas Gleixner <tglx@linutronix.de>
> CC: Josh Poimboeuf <jpoimboe@redhat.com>
> CC: "Peter Zijlstra (Intel)" <peterz@infradead.org>
> CC: Jiri Kosina <jkosina@suse.cz>
> CC: Nicholas Piggin <npiggin@gmail.com>
> CC: Daniel Lezcano <daniel.lezcano@linaro.org>
> CC: Ingo Molnar <mingo@kernel.org>
> CC: Eiichi Tsukata <devel@etsukata.com>
> CC: Zhenzhong Duan <zhenzhong.duan@oracle.com>
> CC: Nadav Amit <namit@vmware.com>
> CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> CC: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
> CC: Tony Luck <tony.luck@intel.com>
> CC: Fenghua Yu <fenghua.yu@intel.com>
> CC: Russell King <linux@armlinux.org.uk>
> CC: Catalin Marinas <catalin.marinas@arm.com>
> CC: Will Deacon <will@kernel.org>
> CC: linux-arm-kernel@lists.infradead.org
> CC: linux-ia64@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> ---
>  include/linux/cpu.h |  2 ++
>  kernel/cpu.c        | 17 +++++++++++++++++
>  2 files changed, 19 insertions(+)
> 
> diff --git a/include/linux/cpu.h b/include/linux/cpu.h
> index bc6c879bd110..8229932fb053 100644
> --- a/include/linux/cpu.h
> +++ b/include/linux/cpu.h
> @@ -118,6 +118,7 @@ extern void cpu_hotplug_disable(void);
>  extern void cpu_hotplug_enable(void);
>  void clear_tasks_mm_cpumask(int cpu);
>  int cpu_down(unsigned int cpu);
> +extern void smp_shutdown_nonboot_cpus(unsigned int primary_cpu);
>  
>  #else /* CONFIG_HOTPLUG_CPU */
>  
> @@ -129,6 +130,7 @@ static inline int  cpus_read_trylock(void) { return true; }
>  static inline void lockdep_assert_cpus_held(void) { }
>  static inline void cpu_hotplug_disable(void) { }
>  static inline void cpu_hotplug_enable(void) { }
> +static inline void smp_shutdown_nonboot_cpus(unsigned int primary_cpu) { }
>  #endif	/* !CONFIG_HOTPLUG_CPU */
>  
>  /* Wrappers which go away once all code is converted */
> diff --git a/kernel/cpu.c b/kernel/cpu.c
> index e2cad3ee2ead..94055a0d989e 100644
> --- a/kernel/cpu.c
> +++ b/kernel/cpu.c
> @@ -1058,6 +1058,23 @@ int cpu_down(unsigned int cpu)
>  }
>  EXPORT_SYMBOL(cpu_down);
>  
> +void smp_shutdown_nonboot_cpus(unsigned int primary_cpu)
> +{
> +	unsigned int cpu;
> +
> +	if (!cpu_online(primary_cpu)) {
> +		pr_info("Attempting to shutdodwn nonboot cpus while boot cpu is offline!\n");
> +		cpu_online(primary_cpu);
> +	}
> +
> +	for_each_present_cpu(cpu) {
> +		if (cpu = primary_cpu)
> +			continue;
> +		if (cpu_online(cpu))
> +			cpu_down(cpu);
> +	}

How does this avoid racing with userspace attempting to restart CPUs
that have already been taken down by this function?

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up
