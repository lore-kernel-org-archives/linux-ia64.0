From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 25 Jan 2006 09:04:01 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <200601250904.k0P941g22471@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Brent Casavant wrote on Tuesday, January 24, 2006 4:11 PM
> > Brent Casavant wrote on Tuesday, January 24, 2006 3:29 PM
> > > Take 4.  Moved "really migrated?" check as late as possible in
> > > __switch_task(), and moved thread_info last_cpu field closer to
> > > flags and cpu fields.  Some nomenclature changes as well.
> > 
> > I think you should seriously consider my other proposal :-)
> 
> Well... if Ingo is amenable to the arch hook in the scheduler, I'm
> OK with changing directions.  Again.  :-)

Hmm, I'm not proposing for arch hook at all.


> The arch hook would be a lot simpler this time -- simply setting
> a flag instead of performing the PIO write drain.  Not sure if
> that's enough to argue in favor of the hook or not.
> 
> Truth be told, I have no strong preference either way.  I'd just
> like to break out of this Brownian motion.  :-)


This is the "what the heck is he talking about?" patch, on top of
"take 4" patch:

---
Optimize platform_migrate(): call platform specific vector only
if machine requires it.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>

--- linus-2.6.git/include/asm-ia64/processor.h.orig	2006-01-21 10:58:06.000000000 -0800
+++ linus-2.6.git/include/asm-ia64/processor.h	2006-01-25 01:09:34.169421315 -0800
@@ -50,7 +50,7 @@
 #define IA64_THREAD_PM_VALID	(__IA64_UL(1) << 2)	/* performance registers valid? */
 #define IA64_THREAD_UAC_NOPRINT	(__IA64_UL(1) << 3)	/* don't log unaligned accesses */
 #define IA64_THREAD_UAC_SIGBUS	(__IA64_UL(1) << 4)	/* generate SIGBUS on unaligned acc. */
-							/* bit 5 is currently unused */
+#define IA64_THREAD_MIGRATION	(__IA64_UL(1) << 5)	/* require migration sync at ctx sw */
 #define IA64_THREAD_FPEMU_NOPRINT (__IA64_UL(1) << 6)	/* don't log any fpswa faults */
 #define IA64_THREAD_FPEMU_SIGFPE  (__IA64_UL(1) << 7)	/* send a SIGFPE for fpswa faults */
 
--- linus-2.6.git/include/asm-ia64/system.h.orig	2006-01-25 01:14:07.661605464 -0800
+++ linus-2.6.git/include/asm-ia64/system.h	2006-01-25 01:17:36.173321660 -0800
@@ -221,23 +221,12 @@ extern void ia64_load_extra (struct task
 	((t)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID)	\
 	 || IS_IA32_PROCESS(task_pt_regs(t)) || PERFMON_IS_SYSWIDE())
 
-#ifdef CONFIG_SMP
-# define arch_migrate(task) 						\
-	if (task_cpu(task) != task_thread_info(task)->last_cpu) {	\
-		platform_migrate(task);					\
-		task_thread_info(task)->last_cpu = task_cpu(task);	\
-	}
-#else
-# define arch_migrate(task) do { } while(0)
-#endif
-
 #define __switch_to(prev,next,last) do {							 \
 	if (IA64_HAS_EXTRA_STATE(prev))								 \
 		ia64_save_extra(prev);								 \
 	if (IA64_HAS_EXTRA_STATE(next))								 \
 		ia64_load_extra(next);								 \
 	ia64_psr(task_pt_regs(next))->dfh = !ia64_is_local_fpu_owner(next);			 \
-	arch_migrate(next);									 \
 	(last) = ia64_switch_to((next));							 \
 } while (0)
 
@@ -255,6 +244,8 @@ extern void ia64_load_extra (struct task
 		__ia64_save_fpu((prev)->thread.fph);				\
 	}									\
 	__switch_to(prev, next, last);						\
+	if (unlikely((next)->thread.flags & IA64_THREAD_MIGRATION))		\
+		platform_migrate(next);						\
 } while (0)
 #else
 # define switch_to(prev,next,last)	__switch_to(prev, next, last)
--- linus-2.6.git/arch/ia64/sn/kernel/sn2/sn2_smp.c.orig	2006-01-25 01:13:56.322738416 -0800
+++ linus-2.6.git/arch/ia64/sn/kernel/sn2/sn2_smp.c	2006-01-25 01:19:27.169414050 -0800
@@ -184,9 +184,13 @@ void sn_migrate(struct task_struct *task
 	volatile unsigned long *adr = last_pda->pio_write_status_addr;
 	unsigned long val = last_pda->pio_write_status_val;
 
+	if (task_cpu(task) = task_thread_info(task)->last_cpu)
+		return;
+
 	/* Drain PIO writes from old CPU's Shub */
 	while ((*adr & SH_PIO_WRITE_STATUS_PENDING_WRITE_COUNT_MASK) != val)
 		cpu_relax();
+	task_thread_info(task)->last_cpu = task_cpu(task);
 }
 
 void sn_tlb_migrate_finish(struct mm_struct *mm)
--- linus-2.6.git/arch/ia64/sn/kernel/setup.c.orig	2006-01-25 01:02:30.830559313 -0800
+++ linus-2.6.git/arch/ia64/sn/kernel/setup.c	2006-01-25 01:09:57.794421025 -0800
@@ -496,6 +496,7 @@ void __init sn_setup(char **cmdline_p)
 	 * for sn.
 	 */
 	pm_power_off = ia64_sn_power_down;
+	current->thread.flags |= IA64_THREAD_MIGRATION;
 }
 
 /**

