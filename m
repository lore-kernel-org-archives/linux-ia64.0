From: Prarit Bhargava <prarit@sgi.com>
Date: Thu, 26 Jan 2006 01:31:14 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <43D82662.70406@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Brent,

Just a quick CodingStyle review.

P.

> diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
> index e510dce..06f08b3 100644
> --- a/arch/ia64/sn/kernel/setup.c
> +++ b/arch/ia64/sn/kernel/setup.c
> @@ -3,7 +3,7 @@
>   * License.  See the file "COPYING" in the main directory of this archive
>   * for more details.
>   *
> - * Copyright (C) 1999,2001-2005 Silicon Graphics, Inc. All rights reserved.
> + * Copyright (C) 1999,2001-2006 Silicon Graphics, Inc. All rights reserved.
>   */
>  
>  #include <linux/config.h>
> @@ -496,6 +496,7 @@ void __init sn_setup(char **cmdline_p)
>  	 * for sn.
>  	 */
>  	pm_power_off = ia64_sn_power_down;
> +	current->thread.flags |= IA64_THREAD_MIGRATION;
>  }
>  
>  /**
> @@ -654,7 +655,8 @@ void __init sn_cpu_init(void)
>  			SH2_PIO_WRITE_STATUS_1, SH2_PIO_WRITE_STATUS_3};
>  		u64 *pio;
>  		pio = is_shub1() ? pio1 : pio2;
> -		pda->pio_write_status_addr = (volatile unsigned long *) LOCAL_MMR_ADDR(pio[slice]);
> +		pda->pio_write_status_addr = (volatile unsigned long *)
> +			GLOBAL_MMR_ADDR(nasid, pio[slice]);

alignment

>  		pda->pio_write_status_val = is_shub1() ? SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK : 0;
>  	}
>  
> diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
> index 471bbaa..87f92b1 100644
> --- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
> +++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
> @@ -5,7 +5,7 @@
>   * License.  See the file "COPYING" in the main directory of this archive
>   * for more details.
>   *
> - * Copyright (C) 2000-2005 Silicon Graphics, Inc. All rights reserved.
> + * Copyright (C) 2000-2006 Silicon Graphics, Inc. All rights reserved.
>   */
>  
>  #include <linux/init.h>
> @@ -169,6 +169,26 @@ static inline unsigned long wait_piowc(v
>  	return ws;
>  }
>  
> +/**
> + * sn_migrate - SN-specific task migration actions
> + * @task: Task being migrated to new CPU
> + *
> + * SN2 PIO writes from separate CPUs are not guaranteed to arrive in order.
> + * Context switching user threads which have memory-mapped MMIO may cause
> + * PIOs to issue from seperate CPUs, thus the PIO writes must be drained
> + * from the previous CPU's Shub before execution resumes on the new CPU.
> + */
> +void sn_migrate(struct task_struct *task)
> +{
> +	pda_t *last_pda = pdacpu(task_thread_info(task)->last_cpu);
> +	unsigned long *adr = last_pda->pio_write_status_addr;;

extra semi-colon -- leads to Tony's compile error.

> +	unsigned long val = last_pda->pio_write_status_val;
> +
> +	/* Drain PIO writes from old CPU's Shub */
> +	while (unlikely((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val))

80 columns

> +		cpu_relax();
> +}
> +
>  void sn_tlb_migrate_finish(struct mm_struct *mm)
>  {
>  	if (mm = current->mm)
> diff --git a/include/asm-ia64/machvec.h b/include/asm-ia64/machvec.h
> index ca5ea99..c3e4ed8 100644
> --- a/include/asm-ia64/machvec.h
> +++ b/include/asm-ia64/machvec.h
> @@ -20,6 +20,7 @@ struct scatterlist;
>  struct page;
>  struct mm_struct;
>  struct pci_bus;
> +struct task_struct;
>  
>  typedef void ia64_mv_setup_t (char **);
>  typedef void ia64_mv_cpu_init_t (void);
> @@ -34,6 +35,7 @@ typedef int ia64_mv_pci_legacy_read_t (s
>  				       u8 size);
>  typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
>  					u8 size);
> +typedef void ia64_mv_migrate_t(struct task_struct * task);
>  
>  /* DMA-mapping interface: */
>  typedef void ia64_mv_dma_init (void);
> @@ -85,6 +87,11 @@ machvec_noop_mm (struct mm_struct *mm)
>  {
>  }
>  
> +static inline void
> +machvec_noop_task (struct task_struct *task)
> +{
> +}
> +
>  extern void machvec_setup (char **);
>  extern void machvec_timer_interrupt (int, void *, struct pt_regs *);
>  extern void machvec_dma_sync_single (struct device *, dma_addr_t, size_t, int);
> @@ -146,6 +153,7 @@ extern void machvec_tlb_migrate_finish (
>  #  define platform_readw_relaxed        ia64_mv.readw_relaxed
>  #  define platform_readl_relaxed        ia64_mv.readl_relaxed
>  #  define platform_readq_relaxed        ia64_mv.readq_relaxed
> +#  define platform_migrate		ia64_mv.migrate
>  # endif
>  
>  /* __attribute__((__aligned__(16))) is required to make size of the
> @@ -194,6 +202,7 @@ struct ia64_machine_vector {
>  	ia64_mv_readw_relaxed_t *readw_relaxed;
>  	ia64_mv_readl_relaxed_t *readl_relaxed;
>  	ia64_mv_readq_relaxed_t *readq_relaxed;
> +	ia64_mv_migrate_t *migrate;
>  } __attribute__((__aligned__(16))); /* align attrib? see above comment */
>  
>  #define MACHVEC_INIT(name)			\
> @@ -238,6 +247,7 @@ struct ia64_machine_vector {
>  	platform_readw_relaxed,			\
>  	platform_readl_relaxed,			\
>  	platform_readq_relaxed,			\
> +	platform_migrate,			\
>  }
>  
>  extern struct ia64_machine_vector ia64_mv;
> @@ -386,5 +396,8 @@ extern ia64_mv_dma_supported		swiotlb_dm
>  #ifndef platform_readq_relaxed
>  # define platform_readq_relaxed	__ia64_readq_relaxed
>  #endif
> +#ifndef platform_migrate
> +# define platform_migrate machvec_noop_task
> +#endif
>  
>  #endif /* _ASM_IA64_MACHVEC_H */
> diff --git a/include/asm-ia64/machvec_sn2.h b/include/asm-ia64/machvec_sn2.h
> index e1b6cd6..6f0021b 100644
> --- a/include/asm-ia64/machvec_sn2.h
> +++ b/include/asm-ia64/machvec_sn2.h
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright (c) 2002-2003 Silicon Graphics, Inc.  All Rights Reserved.
> + * Copyright (c) 2002-2003,2006 Silicon Graphics, Inc.  All Rights Reserved.
>   * 
>   * This program is free software; you can redistribute it and/or modify it 
>   * under the terms of version 2 of the GNU General Public License 
> @@ -71,6 +71,7 @@ extern ia64_mv_dma_sync_single_for_devic
>  extern ia64_mv_dma_sync_sg_for_device	sn_dma_sync_sg_for_device;
>  extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
>  extern ia64_mv_dma_supported		sn_dma_supported;
> +extern ia64_mv_migrate_t		sn_migrate;
>  
>  /*
>   * This stuff has dual use!
> @@ -120,6 +121,7 @@ extern ia64_mv_dma_supported		sn_dma_sup
>  #define platform_dma_sync_sg_for_device	sn_dma_sync_sg_for_device
>  #define platform_dma_mapping_error		sn_dma_mapping_error
>  #define platform_dma_supported		sn_dma_supported
> +#define platform_migrate		sn_migrate
>  
>  #include <asm/sn/io.h>
>  
> diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
> index 09b9902..8eabfec 100644
> --- a/include/asm-ia64/processor.h
> +++ b/include/asm-ia64/processor.h
> @@ -50,7 +50,7 @@
>  #define IA64_THREAD_PM_VALID	(__IA64_UL(1) << 2)	/* performance registers valid? */
>  #define IA64_THREAD_UAC_NOPRINT	(__IA64_UL(1) << 3)	/* don't log unaligned accesses */
>  #define IA64_THREAD_UAC_SIGBUS	(__IA64_UL(1) << 4)	/* generate SIGBUS on unaligned acc. */
> -							/* bit 5 is currently unused */
> +#define IA64_THREAD_MIGRATION	(__IA64_UL(1) << 5)	/* require migration sync at ctx sw */

80 columns.

>  #define IA64_THREAD_FPEMU_NOPRINT (__IA64_UL(1) << 6)	/* don't log any fpswa faults */
>  #define IA64_THREAD_FPEMU_SIGFPE  (__IA64_UL(1) << 7)	/* send a SIGFPE for fpswa faults */
>  
> diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
> index 80c5a23..f382dea 100644
> --- a/include/asm-ia64/system.h
> +++ b/include/asm-ia64/system.h
> @@ -244,6 +244,12 @@ extern void ia64_load_extra (struct task
>  		__ia64_save_fpu((prev)->thread.fph);				\
>  	}									\
>  	__switch_to(prev, next, last);						\
> +	/* "next" in old context is "current" in new context */			\
> +	if (unlikely((current->thread.flags & IA64_THREAD_MIGRATION) &&		\
> +		     (task_cpu(current) != task_thread_info(current)->last_cpu))) { \
> +		platform_migrate(current);					\
> +		task_thread_info(current)->last_cpu = task_cpu(current);	\
> +	}									\
>  } while (0)

whole segment exceeds 80 columns.

>  #else
>  # define switch_to(prev,next,last)	__switch_to(prev, next, last)
> diff --git a/include/asm-ia64/thread_info.h b/include/asm-ia64/thread_info.h
> index 1d6518f..81641a6 100644
> --- a/include/asm-ia64/thread_info.h
> +++ b/include/asm-ia64/thread_info.h
> @@ -26,6 +26,7 @@ struct thread_info {
>  	struct exec_domain *exec_domain;/* execution domain */
>  	__u32 flags;			/* thread_info flags (see TIF_*) */
>  	__u32 cpu;			/* current CPU */
> +	__u32 last_cpu;			/* Last CPU thread ran on */
>  	mm_segment_t addr_limit;	/* user-level address space limit */
>  	int preempt_count;		/* 0=premptable, <0=BUG; will also serve as bh-counter */
>  	struct restart_block restart_block;

