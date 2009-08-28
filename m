From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 28 Aug 2009 06:22:12 +0000
Subject: Re: [RFC PATCH] Add TRACE_IRQFLAGS_SUPPORT, LOCKDEP_SUPPORT then
Message-Id: <20090828062212.GB11552@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
In-Reply-To: <3877989d0908272018va6ee8f7n7ab2838fdf1b26e6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Luming Yu <luming.yu@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Yu, Fenghua" <fenghua.yu@intel.com>, "Luck, Tony" <tony.luck@intel.com>, Felix Blyakher <felixb@sgi.com>, Shaohua Li <shaohua.li@intel.com>, Bob Picco <bob.picco@hp.com>


* Luming Yu <luming.yu@gmail.com> wrote:

> Hi there,
> 
> The following rfc patch is to add lockdep support and IRQ-flags 
> state tracing support for ia64 architecture based on instructions 
> described in irqflags-tracing.
> 
> The next step is to fix issues. I plan to target it for -32 or 
> -33.
> 
> Ps. Bob Picco had done similar things before.
> 
> Ps. The patch is enclosed in attachment. The inlined one is c&p of 
> it for reading.
> 
> 
> Thanks,
> Luming
> 
> Signed-off-by: Bob Picco <bob.picco@hp.com>
> Signed-off-by: Yu Luming <luming.yu@intel.com>

> diff -BruN linux-2.6.31-rc6/arch/ia64/include/asm/page.h
> linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/page.h
> --- linux-2.6.31-rc6/arch/ia64/include/asm/page.h	2009-08-13
> 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/page.h	2009-08-23
> 18:59:00.000000000 -0700
> @@ -41,7 +41,7 @@
>  #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
>  #define PAGE_MASK		(~(PAGE_SIZE - 1))
> 
> -#define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
> +#define PERCPU_PAGE_SHIFT	20	/*16 log2() of max. size of per-CPU area */
>  #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)

Why was this seemingly unrelated change done in a lockdep patch?

> diff -BruN linux-2.6.31-rc6/arch/ia64/include/asm/rwsem.h
> linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/rwsem.h
> --- linux-2.6.31-rc6/arch/ia64/include/asm/rwsem.h	2009-08-13
> 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/rwsem.h	2009-08-23
> 18:59:00.000000000 -0700
> @@ -37,6 +37,9 @@
>  	signed long		count;
>  	spinlock_t		wait_lock;
>  	struct list_head	wait_list;
> +#ifdef CONFIG_DEBUG_LOCK_ALLOC
> +	struct lockdep_map dep_map;
> +#endif
>  };
> 
>  #define RWSEM_UNLOCKED_VALUE		__IA64_UL_CONST(0x0000000000000000)
> diff -BruN linux-2.6.31-rc6/arch/ia64/include/asm/system.h
> linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/system.h
> --- linux-2.6.31-rc6/arch/ia64/include/asm/system.h	2009-08-13
> 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/include/asm/system.h	2009-08-23
> 18:59:00.000000000 -0700
> @@ -107,88 +107,6 @@
>   */
>  #define set_mb(var, value)	do { (var) = (value); mb(); } while (0)
> 
> -#define safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
> -
> -/*
> - * The group barrier in front of the rsm & ssm are necessary to ensure
> - * that none of the previous instructions in the same group are
> - * affected by the rsm/ssm.
> - */
> -/* For spinlocks etc */
> -
> -/*
> - * - clearing psr.i is implicitly serialized (visible by next insn)
> - * - setting psr.i requires data serialization
> - * - we need a stop-bit before reading PSR because we sometimes
> - *   write a floating-point register right before reading the PSR
> - *   and that writes to PSR.mfl
> - */
> -#ifdef CONFIG_PARAVIRT
> -#define __local_save_flags()	ia64_get_psr_i()
> -#else
> -#define __local_save_flags()	ia64_getreg(_IA64_REG_PSR)
> -#endif
> -
> -#define __local_irq_save(x)			\
> -do {						\
> -	ia64_stop();				\
> -	(x) = __local_save_flags();		\
> -	ia64_stop();				\
> -	ia64_rsm(IA64_PSR_I);			\
> -} while (0)
> -
> -#define __local_irq_disable()			\
> -do {						\
> -	ia64_stop();				\
> -	ia64_rsm(IA64_PSR_I);			\
> -} while (0)
> -
> -#define __local_irq_restore(x)	ia64_intrin_local_irq_restore((x) & IA64_PSR_I)
> -
> -#ifdef CONFIG_IA64_DEBUG_IRQ
> -
> -  extern unsigned long last_cli_ip;
> -
> -# define __save_ip()		last_cli_ip = ia64_getreg(_IA64_REG_IP)
> -
> -# define local_irq_save(x)					\
> -do {								\
> -	unsigned long __psr;					\
> -								\
> -	__local_irq_save(__psr);				\
> -	if (__psr & IA64_PSR_I)					\
> -		__save_ip();					\
> -	(x) = __psr;						\
> -} while (0)
> -
> -# define local_irq_disable()	do { unsigned long __x;
> local_irq_save(__x); } while (0)
> -
> -# define local_irq_restore(x)					\
> -do {								\
> -	unsigned long __old_psr, __psr = (x);			\
> -								\
> -	local_save_flags(__old_psr);				\
> -	__local_irq_restore(__psr);				\
> -	if ((__old_psr & IA64_PSR_I) && !(__psr & IA64_PSR_I))	\
> -		__save_ip();					\
> -} while (0)
> -
> -#else /* !CONFIG_IA64_DEBUG_IRQ */
> -# define local_irq_save(x)	__local_irq_save(x)
> -# define local_irq_disable()	__local_irq_disable()
> -# define local_irq_restore(x)	__local_irq_restore(x)
> -#endif /* !CONFIG_IA64_DEBUG_IRQ */
> -
> -#define local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I);
> ia64_srlz_d(); })
> -#define local_save_flags(flags)	({ ia64_stop(); (flags) > __local_save_flags(); })
> -
> -#define irqs_disabled()				\
> -({						\
> -	unsigned long __ia64_id_flags;		\
> -	local_save_flags(__ia64_id_flags);	\
> -	(__ia64_id_flags & IA64_PSR_I) = 0;	\
> -})
> -
>  #ifdef __KERNEL__
> 
>  #ifdef CONFIG_IA32_SUPPORT
> @@ -274,7 +192,7 @@
>  #define __ARCH_WANT_UNLOCKED_CTXSW
>  #define ARCH_HAS_PREFETCH_SWITCH_STACK
>  #define ia64_platform_is(x) (strcmp(x, platform_name) = 0)
> -
> +#include <linux/irqflags.h>
>  void cpu_idle_wait(void);
> 
>  #define arch_align_stack(x) (x)
> diff -BruN linux-2.6.31-rc6/arch/ia64/Kconfig
> linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig
> --- linux-2.6.31-rc6/arch/ia64/Kconfig	2009-08-13 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig	2009-08-23
> 18:59:00.000000000 -0700
> @@ -143,6 +143,13 @@
> 
>  endif
> 
> +config LOCKDEP_SUPPORT
> +	bool
> +	default y
> +
> +config STACKTRACE_SUPPORT
> +	bool
> +	default y

The (shorter) form we generally use when architectures enable a 
feature is:

 config LOCKDEP_SUPPORT
         def_bool y

 config STACKTRACE_SUPPORT
         def_bool y

( Separate cleanup patch: it might make sense to offer this in
  generic code and just select a HAVE_LOCKDEP_SUPPORT flag. This 
  affects all lockdep architectures so should be handled 
  separately. )

>  choice
>  	prompt "System type"
>  	default IA64_GENERIC
> diff -BruN linux-2.6.31-rc6/arch/ia64/Kconfig.debug
> linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig.debug
> --- linux-2.6.31-rc6/arch/ia64/Kconfig.debug	2009-08-13 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/Kconfig.debug	2009-08-23
> 18:58:59.000000000 -0700
> @@ -2,6 +2,10 @@
> 
>  source "lib/Kconfig.debug"
> 
> +config TRACE_IRQFLAGS_SUPPORT
> +	bool
> +	default y

(same comment as above.)

> +
>  choice
>  	prompt "Physical memory granularity"
>  	default IA64_GRANULE_64MB
> diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/ivt.S
> linux-2.6.31-rc6-lockdep/arch/ia64/kernel/ivt.S
> --- linux-2.6.31-rc6/arch/ia64/kernel/ivt.S	2009-08-13 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/ivt.S	2009-08-23
> 18:58:59.000000000 -0700
> @@ -1603,6 +1603,11 @@
>  	SAVE_REST
>  	;;
>  	MCA_RECOVER_RANGE(interrupt)
> +#ifdef CONFIG_TRACE_IRQFLAGS
> +	;;
> +	br.call.sptk.many rp=trace_hardirqs_off
> +	;;
> +#endif
>  	alloc r14=ar.pfs,0,0,2,0 // must be first in an insn group
>  	MOV_FROM_IVR(out0, r8)	// pass cr.ivr as first arg
>  	add out1,sp		// pass pointer to pt_regs as second arg
> diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/Makefile
> linux-2.6.31-rc6-lockdep/arch/ia64/kernel/Makefile
> --- linux-2.6.31-rc6/arch/ia64/kernel/Makefile	2009-08-13
> 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/Makefile	2009-08-23
> 18:58:59.000000000 -0700
> @@ -40,6 +40,7 @@
>  obj-$(CONFIG_PCI_MSI)		+= msi_ia64.o
>  mca_recovery-y			+= mca_drv.o mca_drv_asm.o
>  obj-$(CONFIG_IA64_MC_ERR_INJECT)+= err_inject.o
> + obj-$(CONFIG_STACKTRACE)	+= stacktrace.o
> 
>  obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirtentry.o \
>  				   paravirt_patch.o
> diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/smpboot.c
> linux-2.6.31-rc6-lockdep/arch/ia64/kernel/smpboot.c
> --- linux-2.6.31-rc6/arch/ia64/kernel/smpboot.c	2009-08-13
> 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/smpboot.c	2009-08-23
> 18:58:59.000000000 -0700
> @@ -504,7 +504,7 @@
>  	struct create_idle c_idle = {
>  		.work = __WORK_INITIALIZER(c_idle.work, do_fork_idle),
>  		.cpu	= cpu,
> -		.done	= COMPLETION_INITIALIZER(c_idle.done),
> +		.done	= COMPLETION_INITIALIZER_ONSTACK(c_idle.done),
>  	};
> 
>   	c_idle.idle = get_idle_for_cpu(cpu);
> diff -BruN linux-2.6.31-rc6/arch/ia64/kernel/stacktrace.c
> linux-2.6.31-rc6-lockdep/arch/ia64/kernel/stacktrace.c
> --- linux-2.6.31-rc6/arch/ia64/kernel/stacktrace.c	1969-12-31
> 16:00:00.000000000 -0800
> +++ linux-2.6.31-rc6-lockdep/arch/ia64/kernel/stacktrace.c	2009-08-23
> 18:58:59.000000000 -0700
> @@ -0,0 +1,23 @@
> +/*
> + * arch/x86_64/kernel/stacktrace.c
> + *
> + * Stack trace management functions
> + *
> + *  Copyright (C) 2006 Red Hat, Inc., Ingo Molnar <mingo@redhat.com>
> + */
> +#include <linux/sched.h>
> +#include <linux/stacktrace.h>
> +#include <linux/module.h>
> +#include <asm/stacktrace.h>
> +
> +/*
> + * Save stack-backtrace addresses into a stack_trace buffer.
> + */
> +void save_stack_trace(struct stack_trace *trace)
> +{
> +}
> +EXPORT_SYMBOL(save_stack_trace);
> +void __ia64_save_stack_nonlocal(struct stack_trace *trace)

(nit: missing newline)

> +{
> +}
> +EXPORT_SYMBOL(__ia64_save_stack_nonlocal);

also, these functions should be implemented, for lockdep reports to 
be readable. Generally this is done by librarizing the dump_stack() 
et al architecture code into stacktrace.c.

> diff -BruN linux-2.6.31-rc6/include/asm-ia64/irqflags.h
> linux-2.6.31-rc6-lockdep/include/asm-ia64/irqflags.h
> --- linux-2.6.31-rc6/include/asm-ia64/irqflags.h	1969-12-31
> 16:00:00.000000000 -0800
> +++ linux-2.6.31-rc6-lockdep/include/asm-ia64/irqflags.h	2009-08-23
> 18:59:14.000000000 -0700
> @@ -0,0 +1,92 @@
> +#ifndef _ASM_IRQFLAGS_H
> +#define _ASM_IRQFLAGS_H
> +#include <asm/kregs.h>
> +#include <asm/pal.h>
> +/*
> + * The group barrier in front of the rsm & ssm are necessary to ensure
> + * that none of the previous instructions in the same group are
> + * affected by the rsm/ssm.
> + */
> +/* For spinlocks etc */
> +

( nit: looks a bit disorganized - could be merged into a single 
       comment block? )

> +/*
> + * - clearing psr.i is implicitly serialized (visible by next insn)
> + * - setting psr.i requires data serialization
> + * - we need a stop-bit before reading PSR because we sometimes
> + *   write a floating-point register right before reading the PSR
> + *   and that writes to PSR.mfl
> + */
> +#define __local_irq_save(x)			\
> +do {						\
> +	ia64_stop();				\
> +	(x) = ia64_getreg(_IA64_REG_PSR);	\
> +	ia64_stop();				\
> +	ia64_rsm(IA64_PSR_I);			\
> +} while (0)

please use C inline functions for all of irqflags.h (x86 does that 
too). Macros have all sorts of disadvantages: they are harder to 
read and also double evaluation side-effects are harder to keep 
under control.

> +
> +#define __local_irq_disable()			\
> +do {						\
> +	ia64_stop();				\
> +	ia64_rsm(IA64_PSR_I);			\
> +} while (0)
> +
> +#define __local_irq_restore(x)	ia64_intrin_local_irq_restore((x) & IA64_PSR_I)
> +
> +#ifdef CONFIG_IA64_DEBUG_IRQ
> +
> +  extern unsigned long last_cli_ip;
> +
> +# define __save_ip()		last_cli_ip = ia64_getreg(_IA64_REG_IP)
> +
> +# define raw_local_irq_save(x)					\
> +do {								\
> +	unsigned long psr;					\
> +								\
> +	__local_irq_save(psr);					\
> +	if (psr & IA64_PSR_I)					\
> +		__save_ip();					\
> +	(x) = psr;						\
> +} while (0)
> +
> +# define raw_local_irq_disable()	do { unsigned long x;
> raw_local_irq_save(x); } while (0)

( the patch seems line-wrapped, see Documentation/email-clients.txt
  about how to send plain-text patches. )

> +
> +# define raw_local_irq_restore(x)					\
> +do {								\
> +	unsigned long old_psr, psr = (x);			\
> +								\
> +	local_save_flags(old_psr);				\
> +	__local_irq_restore(psr);				\
> +	if ((old_psr & IA64_PSR_I) && !(psr & IA64_PSR_I))	\
> +		__save_ip();					\
> +} while (0)
> +
> +#else /* !CONFIG_IA64_DEBUG_IRQ */
> +# define raw_local_irq_save(x)	__local_irq_save(x)
> +# define raw_local_irq_disable()	__local_irq_disable()
> +# define raw_local_irq_restore(x)	__local_irq_restore(x)
> +#endif /* !CONFIG_IA64_DEBUG_IRQ */
> +
> +#define raw_local_irq_enable()	({ ia64_stop(); ia64_ssm(IA64_PSR_I);
> ia64_srlz_d(); })
> +#define raw_local_save_flags(flags)	({ ia64_stop(); (flags) > ia64_getreg(_IA64_REG_PSR); })
> +
> +#define raw_irqs_disabled()				\
> +({						\
> +	unsigned long __ia64_id_flags;		\
> +	raw_local_save_flags(__ia64_id_flags);	\
> +	(__ia64_id_flags & IA64_PSR_I) = 0;	\
> +})
> +
> +#define raw_safe_halt()         ia64_pal_halt_light()    /* PAL_HALT_LIGHT */
> +#define raw_irqs_disabled_flags(flags)	\
> +({						\
> +	(int)((flags) & IA64_PSR_I) = 0;	\
> +})
> +	
> +#ifdef CONFIG_TRACE_IRQFLAGS
> +#define TRACE_IRQS_ON br.call.sptk.many b0=trace_hardirqs_on
> +#define TRACE_IRQS_OFF br.call.sptk.many b0=trace_hardirqs_off
> +#else
> +#define TRACE_IRQS_ON
> +#define TRACE_IRQS_OFF
> +#endif
> +#endif
> diff -BruN linux-2.6.31-rc6/include/asm-ia64/stacktrace.h
> linux-2.6.31-rc6-lockdep/include/asm-ia64/stacktrace.h
> --- linux-2.6.31-rc6/include/asm-ia64/stacktrace.h	1969-12-31
> 16:00:00.000000000 -0800
> +++ linux-2.6.31-rc6-lockdep/include/asm-ia64/stacktrace.h	2009-08-23
> 18:59:14.000000000 -0700
> @@ -0,0 +1,7 @@
> +#ifndef _ASM_STACKTRACE_H
> +#define _ASM_STACKTRACE_H 1
> +
> +/* Generic stack tracer with callbacks */
> +
> +
> +#endif
>
> linux-2.6.31-rc6-lockdep/include/linux/lockdep.h
> --- linux-2.6.31-rc6/include/linux/lockdep.h	2009-08-13 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/include/linux/lockdep.h	2009-08-23
> 18:59:20.000000000 -0700
> @@ -162,7 +162,7 @@
>  	u64				chain_key;
>  };
> 
> -#define MAX_LOCKDEP_KEYS_BITS		13
> +#define MAX_LOCKDEP_KEYS_BITS		10

Why did you have to do this bit?

> linux-2.6.31-rc6-lockdep/lib/Kconfig.debug
> --- linux-2.6.31-rc6/lib/Kconfig.debug	2009-08-13 15:43:34.000000000 -0700
> +++ linux-2.6.31-rc6-lockdep/lib/Kconfig.debug	2009-08-23
> 18:59:06.000000000 -0700
> @@ -504,7 +504,7 @@
> 
>  config DEBUG_LOCKDEP
>  	bool "Lock dependency engine debugging"
> -	depends on DEBUG_KERNEL && LOCKDEP
> +	depends on DEBUG_KERNEL && LOCKDEP && !IA64
>  	help

That should be fixed (and this chunk will then not be needed) before 
this is merged.

Also, a few general comments:

 - There's no lockdep_sys_exit support implemented. (This callback
   is needed to detect lock counts leaking to user-space. Just call
   it in the return-from-syscall codepath(s).)

 - There's no changes to exception code assembly AFAICS - such as
   debug traps, special exceptions, etc. You should review all
   places in the IA64 code where there's open-coded or
   hardware-implicit enable-irqs or disable-irqs instructions, not
   just the main local_irq_*() functions. A starting point would be:

      git grep IA64_PSR_I arch/ia64/ | grep .S:

   but there may be instructions and trap entries where there's 
   implicit irq-flags behavior - those need to be examined too.

 - Do kprobes work with this patch?

 - No NMI support AFAICS - all NMI codepaths should be exempted from 
   irqflags coverage.

Thanks,

	Ingo
