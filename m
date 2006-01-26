From: Brent Casavant <bcasavan@sgi.com>
Date: Thu, 26 Jan 2006 19:29:49 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060126132440.L40136@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 26 Jan 2006, Prarit Bhargava wrote:

> > diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
> > index e510dce..06f08b3 100644
> > --- a/arch/ia64/sn/kernel/setup.c
> > +++ b/arch/ia64/sn/kernel/setup.c
> > @@ -654,7 +655,8 @@ void __init sn_cpu_init(void)
> >  			SH2_PIO_WRITE_STATUS_1, SH2_PIO_WRITE_STATUS_3};
> >  		u64 *pio;
> >  		pio = is_shub1() ? pio1 : pio2;
> > -		pda->pio_write_status_addr = (volatile unsigned long *)
> > LOCAL_MMR_ADDR(pio[slice]);
> > +		pda->pio_write_status_addr = (volatile unsigned long *)
> > +			GLOBAL_MMR_ADDR(nasid, pio[slice]);
> 
> ALIGNMENT.

I don't see a better way to handle it without violating 80 columns.

> >  diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c
> > b/arch/ia64/sn/kernel/sn2/sn2_smp.c
> > index 471bbaa..bd0e138 100644
> > --- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
> > +++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
> > @@ -169,6 +169,26 @@ static inline unsigned long wait_piowc(v
> >  	return ws;
> >  }
> >  +/**
> > + * sn_migrate - SN-specific task migration actions
> > + * @task: Task being migrated to new CPU
> > + *
> > + * SN2 PIO writes from separate CPUs are not guaranteed to arrive in order.
> > + * Context switching user threads which have memory-mapped MMIO may cause
> > + * PIOs to issue from seperate CPUs, thus the PIO writes must be drained
> > + * from the previous CPU's Shub before execution resumes on the new CPU.
> > + */
> > +void sn_migrate(struct task_struct *task)
> > +{
> > +	pda_t *last_pda = pdacpu(task_thread_info(task)->last_cpu);
> > +	volatile unsigned long *adr = last_pda->pio_write_status_addr;
> > +	unsigned long val = last_pda->pio_write_status_val;
> > +
> > +	/* Drain PIO writes from old CPU's Shub */
> > +	while (unlikely((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK)
> > != val))
> 
> 80 COLUMNS.

Again, tell me how to split this such that it fits in 80 and I'll gladly
do it.  I don't see it.

> >  diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
> > index 09b9902..8eabfec 100644
> > --- a/include/asm-ia64/processor.h
> > +++ b/include/asm-ia64/processor.h
> > @@ -50,7 +50,7 @@
> >  #define IA64_THREAD_PM_VALID	(__IA64_UL(1) << 2)	/* performance
> > registers valid? */
> >  #define IA64_THREAD_UAC_NOPRINT	(__IA64_UL(1) << 3)	/* don't log
> > unaligned accesses */
> >  #define IA64_THREAD_UAC_SIGBUS	(__IA64_UL(1) << 4)	/* generate
> > SIGBUS on unaligned acc. */
> > -							/* bit 5 is currently
> > unused */
> > +#define IA64_THREAD_MIGRATION	(__IA64_UL(1) << 5)	/* require
> > migration sync at ctx sw */
> 
> 80 COLUMNS.

Ditto.

> >  diff --git a/include/asm-ia64/system.h b/include/asm-ia64/system.h
> > index 80c5a23..f382dea 100644
> > --- a/include/asm-ia64/system.h
> > +++ b/include/asm-ia64/system.h
> > @@ -244,6 +244,12 @@ extern void ia64_load_extra (struct task
> >  		__ia64_save_fpu((prev)->thread.fph);
> > \
> >  	}
> > \
> >  	__switch_to(prev, next, last);
> > \
> > +	/* "next" in old context is "current" in new context */
> > \
> > +	if (unlikely((current->thread.flags & IA64_THREAD_MIGRATION) &&
> > \
> > +		     (task_cpu(current) !> > task_thread_info(current)->last_cpu))) { \
> > +		platform_migrate(current);
> > \
> > +		task_thread_info(current)->last_cpu = task_cpu(current);
> > \
> > +	}
> > \
> 
> 80 COLUMNS.

Following existing precedent in the same macro, and again no better
way to do it.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
