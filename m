From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Date: Wed, 30 Jan 2008 15:27:02 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="-584349381-142965727-1201706760=:11859"
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org>
In-Reply-To: <200801301414.m0UEEgCC006371@hera.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Mike Travis <travis@sgi.com>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---584349381-142965727-1201706760=:11859
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-ID: <Pine.LNX.4.64.0801301626081.11859@vixen.sonytel.be>

On Wed, 30 Jan 2008, Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=dd5af90a7f3d79e04b7eace9a98644dbf2038f4d
> Commit:     dd5af90a7f3d79e04b7eace9a98644dbf2038f4d
> Parent:     3212bff370c2f22e4987c6679ba485654cefb178
> Author:     Mike Travis <travis@sgi.com>
> AuthorDate: Wed Jan 30 13:33:32 2008 +0100
> Committer:  Ingo Molnar <mingo@elte.hu>
> CommitDate: Wed Jan 30 13:33:32 2008 +0100
> 
>     x86/non-x86: percpu, node ids, apic ids x86.git fixup
>     
>     Signed-off-by: Ingo Molnar <mingo@elte.hu>
>     Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/Kconfig             |    2 +-
>  include/asm-generic/percpu.h |   12 ++----------
>  init/main.c                  |    4 ++--
>  kernel/module.c              |    8 ++++++++

This broke powerpc (and presumably ia64 and sparc64) in current linux-2.6.git:

| init/main.c:376: error: static declaration of 'setup_per_cpu_areas' follows non-static declaration
| include2/asm/percpu.h:33: error: previous declaration of 'setup_per_cpu_areas' was here

as the generic and x86-specific parts were integrated, while the
powerpc/ia64/sparc64-specific parts are still missing.

>  4 files changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index f0887d1..8e1b33c 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -97,7 +97,7 @@ config GENERIC_TIME_VSYSCALL
>  	bool
>  	default X86_64
>  
> -config ARCH_SETS_UP_PER_CPU_AREA
> +config HAVE_SETUP_PER_CPU_AREA
>  	def_bool X86_64
>  
>  config ARCH_SUPPORTS_OPROFILE
> diff --git a/include/asm-generic/percpu.h b/include/asm-generic/percpu.h
> index c41b1a7..4b8d31c 100644
> --- a/include/asm-generic/percpu.h
> +++ b/include/asm-generic/percpu.h
> @@ -47,7 +47,7 @@ extern unsigned long __per_cpu_offset[NR_CPUS];
>  #endif
>  
>  /*
> - * A percpu variable may point to a discarded reghions. The following are
> + * A percpu variable may point to a discarded regions. The following are
>   * established ways to produce a usable pointer from the percpu variable
>   * offset.
>   */
> @@ -59,18 +59,10 @@ extern unsigned long __per_cpu_offset[NR_CPUS];
>  	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), __my_cpu_offset))
>  
>  
> -#ifdef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
> +#ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
>  extern void setup_per_cpu_areas(void);
>  #endif
>  
> -/* A macro to avoid #include hell... */
> -#define percpu_modcopy(pcpudst, src, size)			\
> -do {								\
> -	unsigned int __i;					\
> -	for_each_possible_cpu(__i)				\
> -		memcpy((pcpudst)+per_cpu_offset(__i),		\
> -		       (src), (size));				\
> -} while (0)
>  #else /* ! SMP */
>  
>  #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu_var(var)))
> diff --git a/init/main.c b/init/main.c
> index 5843fe9..3316dff 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -363,7 +363,7 @@ static inline void smp_prepare_cpus(unsigned int maxcpus) { }
>  
>  #else
>  
> -#ifndef CONFIG_ARCH_SETS_UP_PER_CPU_AREA
> +#ifndef CONFIG_HAVE_SETUP_PER_CPU_AREA
>  unsigned long __per_cpu_offset[NR_CPUS] __read_mostly;
>  
>  EXPORT_SYMBOL(__per_cpu_offset);
> @@ -384,7 +384,7 @@ static void __init setup_per_cpu_areas(void)
>  		ptr += size;
>  	}
>  }
> -#endif /* CONFIG_ARCH_SETS_UP_CPU_AREA */
> +#endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
>  
>  /* Called by boot processor to activate the rest. */
>  static void __init smp_init(void)
> diff --git a/kernel/module.c b/kernel/module.c
> index f6a4e72..bd60278 100644
> --- a/kernel/module.c
> +++ b/kernel/module.c
> @@ -430,6 +430,14 @@ static unsigned int find_pcpusec(Elf_Ehdr *hdr,
>  	return find_sec(hdr, sechdrs, secstrings, ".data.percpu");
>  }
>  
> +static void percpu_modcopy(void *pcpudest, const void *from, unsigned long size)
> +{
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu)
> +		memcpy(pcpudest + per_cpu_offset(cpu), from, size);
> +}
> +
>  static int percpu_modinit(void)
>  {
>  	pcpu_num_used = 2;
> -
> To unsubscribe from this list: send the line "unsubscribe git-commits-head" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Network and Software Technology Center Europe
The Corporate Village · Da Vincilaan 7-D1 · B-1935 Zaventem · Belgium

Phone:    +32 (0)2 700 8453
Fax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

Sony Network and Software Technology Center Europe
A division of Sony Service Centre (Europe) N.V.
Registered office: Technologielaan 7 · B-1840 Londerzeel · Belgium
VAT BE 0413.825.160 · RPR Brussels
Fortis Bank Zaventem · Swift GEBABEBB08A · IBAN BE39001382358619
---584349381-142965727-1201706760=:11859--
