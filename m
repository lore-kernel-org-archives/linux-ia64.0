From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 22 Nov 2002 04:53:52 +0000
Subject: [Linux-ia64] First cut at SMP-safe preemption for IA64
Message-Id: <marc-linux-ia64-105590709805470@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	Here's another IA64 preemption patch, agains 2.5.45 plus
David's patches.  It hasn't been tested very much at all yet; in
particular it's not yet clear to me that the patch improves
responsiveness in any way.  

Anyway, share and enjoy.  

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/Kconfig linux-2.5-preempt/arch/ia64/Kconfig
--- linux-2.5-EXPORT/arch/ia64/Kconfig	Fri Nov 22 15:20:00 2002
+++ linux-2.5-preempt/arch/ia64/Kconfig	Fri Nov 22 15:32:51 2002
@@ -380,6 +380,18 @@
 
 	  If you don't know what to do here, say N.
 
+config PREEMPT
+	bool "Preemptible Kernel"
+        help
+          This option reduces the latency of the kernel when reacting to
+          real-time or interactive events by allowing a low priority process to
+          be preempted even if it is in kernel mode executing a system call.
+          This allows applications to run more reliably even when the system is
+          under load.
+
+          Say Y here if you are building a kernel for a desktop, embedded
+          or real-time system.  Say N if you are unsure.
+
 config IA32_SUPPORT
 	bool "Support running of Linux/x86 binaries"
 	help
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/hp/sim/simserial.c linux-2.5-preempt/arch/ia64/hp/sim/simserial.c
--- linux-2.5-EXPORT/arch/ia64/hp/sim/simserial.c	Fri Nov 22 15:20:01 2002
+++ linux-2.5-preempt/arch/ia64/hp/sim/simserial.c	Fri Nov 22 15:32:51 2002
@@ -63,7 +63,6 @@
 
 static char *serial_name = "SimSerial driver";
 static char *serial_version = "0.6";
-static spinlock_t serial_lock = SPIN_LOCK_UNLOCKED;
 
 /*
  * This has been extracted from asm/serial.h. We need one eventually but
@@ -235,14 +234,15 @@
 
 	if (!tty || !info->xmit.buf) return;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 	if (CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) = 0) {
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 		return;
 	}
 	info->xmit.buf[info->xmit.head] = ch;
 	info->xmit.head = (info->xmit.head + 1) & (SERIAL_XMIT_SIZE-1);
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 static _INLINE_ void transmit_chars(struct async_struct *info, int *intr_done)
@@ -250,7 +250,9 @@
 	int count;
 	unsigned long flags;
 
-	spin_lock_irqsave(&serial_lock, flags);
+
+	local_save_flags(flags);
+	local_irq_disable();
 
 	if (info->x_char) {
 		char c = info->x_char;
@@ -293,7 +295,7 @@
 		info->xmit.tail += count;
 	}
 out:
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 static void rs_flush_chars(struct tty_struct *tty)
@@ -334,7 +336,8 @@
 				break;
 			}
 
-			spin_lock_irqsave(&serial_lock, flags);
+			local_save_flags(flags);
+			local_irq_disable();
 			{
 				c1 = CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail,
 						       SERIAL_XMIT_SIZE);
@@ -344,7 +347,7 @@
 				info->xmit.head = ((info->xmit.head + c) &
 						   (SERIAL_XMIT_SIZE-1));
 			}
-			spin_unlock_irqrestore(&serial_lock, flags);
+			local_irq_restore(flags);
 
 			buf += c;
 			count -= c;
@@ -352,7 +355,8 @@
 		}
 		up(&tmp_buf_sem);
 	} else {
-		spin_lock_irqsave(&serial_lock, flags);
+		local_save_flags(flags);
+		local_irq_disable();
 		while (1) {
 			c = CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
 			if (count < c)
@@ -367,7 +371,7 @@
 			count -= c;
 			ret += c;
 		}
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 	}
 	/*
 	 * Hey, we transmit directly from here in our case
@@ -398,9 +402,10 @@
 	struct async_struct *info = (struct async_struct *)tty->driver_data;
 	unsigned long flags;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 	info->xmit.head = info->xmit.tail = 0;
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 
 	wake_up_interruptible(&tty->write_wait);
 
@@ -573,7 +578,8 @@
 	       state->irq);
 #endif
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 	{
 		/*
 		 * First unlink the serial port from the IRQ chain...
@@ -611,7 +617,7 @@
 
 		info->flags &= ~ASYNC_INITIALIZED;
 	}
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 /*
@@ -634,13 +640,14 @@
 
 	state = info->state;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_irq_save(flags);
+	local_irq_disable();
 	if (tty_hung_up_p(filp)) {
 #ifdef SIMSERIAL_DEBUG
 		printk("rs_close: hung_up\n");
 #endif
 		MOD_DEC_USE_COUNT;
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 		return;
 	}
 #ifdef SIMSERIAL_DEBUG
@@ -665,11 +672,11 @@
 	}
 	if (state->count) {
 		MOD_DEC_USE_COUNT;
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 		return;
 	}
 	info->flags |= ASYNC_CLOSING;
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 
 	/*
 	 * Now we wait for the transmit buffer to clear; and we notify
@@ -776,7 +783,8 @@
 	if (!page)
 		return -ENOMEM;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_save_flags(flags);
+	local_irq_disable();
 
 	if (info->flags & ASYNC_INITIALIZED) {
 		free_page(page);
@@ -857,11 +865,11 @@
 	}
 
 	info->flags |= ASYNC_INITIALIZED;
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 	return 0;
 
 errout:
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 	return retval;
 }
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/ia32/ia32_support.c linux-2.5-preempt/arch/ia64/ia32/ia32_support.c
--- linux-2.5-EXPORT/arch/ia64/ia32/ia32_support.c	Fri Nov 22 15:20:01 2002
+++ linux-2.5-preempt/arch/ia64/ia32/ia32_support.c	Fri Nov 22 15:32:51 2002
@@ -93,9 +93,8 @@
 {
 	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd, tssd;
 	struct pt_regs *regs = ia64_task_regs(t);
-	int nr = smp_processor_id();	/* LDT and TSS depend on CPU number: */
+	int nr = get_cpu();	/* LDT and TSS depend on CPU number: */
 
-	nr = smp_processor_id();
 
 	eflag = t->thread.eflag;
 	fsr = t->thread.fsr;
@@ -121,6 +120,7 @@
 
 	regs->r17 = (_TSS(nr) << 48) | (_LDT(nr) << 32) | (__u32) regs->r17;
 	regs->r30 = load_desc(_LDT(nr));				/* LDTD */
+	put_cpu();
 }
 
 /*
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/efivars.c linux-2.5-preempt/arch/ia64/kernel/efivars.c
--- linux-2.5-EXPORT/arch/ia64/kernel/efivars.c	Fri Nov 22 15:20:01 2002
+++ linux-2.5-preempt/arch/ia64/kernel/efivars.c	Fri Nov 22 15:32:51 2002
@@ -66,6 +66,7 @@
 #include <linux/module.h>
 #include <linux/smp.h>
 #include <linux/efi.h>
+#include <linux/smp_lock.h>
 
 #include <asm/uaccess.h>
 
@@ -342,6 +343,9 @@
 
 
 
+/*
+ * Called with BKL held
+ */
 static int __init
 efivars_init(void)
 {
@@ -351,10 +355,11 @@
 	efi_char16_t *variable_name = kmalloc(1024, GFP_KERNEL);
 	unsigned long variable_name_size = 1024;
 
-	spin_lock(&efivars_lock);
 
 	printk(KERN_INFO "EFI Variables Facility v%s\n", EFIVARS_VERSION);
 
+        BUG_ON(!kernel_locked());
+
         /* Since efi.c happens before procfs is available,
            we create the directory here if it doesn't
            already exist.  There's probably a better way
@@ -398,7 +403,6 @@
 	} while (status != EFI_NOT_FOUND);
 
 	kfree(variable_name);
-	spin_unlock(&efivars_lock);
 	return 0;
 }
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/entry.S linux-2.5-preempt/arch/ia64/kernel/entry.S
--- linux-2.5-EXPORT/arch/ia64/kernel/entry.S	Fri Nov 22 15:20:01 2002
+++ linux-2.5-preempt/arch/ia64/kernel/entry.S	Fri Nov 22 15:32:51 2002
@@ -570,11 +570,23 @@
 GLOBAL_ENTRY(ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	// work.need_resched etc. mustn't get changed by this CPU before it returns to userspace:
+.work_recheck:
 (pUser)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUser
+#ifdef CONFIG_PREEMPT
+	rsm psr.i				// disable interrupts
+	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+(pKern) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+(pKern) ld4  r21=[r20]			// preempt_count ->r21
+	;;
+(pKern)	cmp.eq	p6,p0=r21,r0
+	;;
+#else // CONFIG_PREEMPT
 (pUser)	rsm psr.i
 	;;
 (pUser)	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
+#endif // CONFIG_PREEMPT
 .work_processed:
 (p6)	ld4 r18=[r17]				// load current_thread_info()->flags
 	adds r2=PT(R8)+16,r12
@@ -802,6 +814,16 @@
 .work_pending:
 	tbit.z p6,p0=r18,TIF_NEED_RESCHED		// current_thread_info()->need_resched=0?
 (p6)	br.cond.sptk.few .notify
+#ifdef CONFIG_PREEMPT
+(pKern)	dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
+	;;
+(pKern) st4 [r20]=r21
+(pKern) ssm psr.i
+	;;
+	srlz.d	// If we don't serialise here, interrupts may 
+		// remain off until the next exception is taken.
+#endif
+	
 #if __GNUC__ < 3
 	br.call.spnt.many rp=invoke_schedule
 #else
@@ -811,6 +833,11 @@
 	rsm psr.i
 	;;
 	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+#if CONFIG_PREEMPT
+	adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+	st4 [r20]=r0
+#endif
 	br.cond.sptk.many .work_processed		// re-check
 
 .notify:
@@ -844,7 +871,7 @@
 	br.cond.sptk ia64_leave_kernel
 END(handle_syscall_error)
 
-#ifdef CONFIG_SMP
+#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	/*
 	 * Invoke schedule_tail(task) while preserving in0-in7, which may be needed
 	 * in case a system call gets restarted.
@@ -861,7 +888,7 @@
 	br.ret.sptk.many rp
 END(ia64_invoke_schedule_tail)
 
-#endif /* CONFIG_SMP */
+#endif /* CONFIG_SMP || CONFIG_PREEMPT */
 
 #if __GNUC__ < 3
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/irq.c linux-2.5-preempt/arch/ia64/kernel/irq.c
--- linux-2.5-EXPORT/arch/ia64/kernel/irq.c	Fri Nov 22 15:20:02 2002
+++ linux-2.5-preempt/arch/ia64/kernel/irq.c	Fri Nov 22 15:32:52 2002
@@ -340,12 +340,14 @@
 	 * 0 return value means that this irq is already being
 	 * handled by some other CPU. (or is disabled)
 	 */
-	int cpu = smp_processor_id();
+	int cpu;
 	irq_desc_t *desc = irq_desc(irq);
 	struct irqaction * action;
 	unsigned int status;
 
 	irq_enter();
+	cpu = smp_processor_id();
+
 	kstat.irqs[cpu][irq]++;
 
 	if (desc->status & IRQ_PER_CPU) {
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/palinfo.c linux-2.5-preempt/arch/ia64/kernel/palinfo.c
--- linux-2.5-EXPORT/arch/ia64/kernel/palinfo.c	Fri Nov 22 15:20:02 2002
+++ linux-2.5-preempt/arch/ia64/kernel/palinfo.c	Fri Nov 22 15:32:52 2002
@@ -898,10 +898,12 @@
 	 * in SMP mode, we may need to call another CPU to get correct
 	 * information. PAL, by definition, is processor specific
 	 */
-	if (f->req_cpu = smp_processor_id())
+	if (f->req_cpu = get_cpu())
 		len = (*palinfo_entries[f->func_id].proc_read)(page);
 	else
 		len = palinfo_handle_smp(f, page);
+
+	put_cpu();
 
 	if (len <= off+count) *eof = 1;
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/perfmon.c linux-2.5-preempt/arch/ia64/kernel/perfmon.c
--- linux-2.5-EXPORT/arch/ia64/kernel/perfmon.c	Fri Nov 22 15:20:02 2002
+++ linux-2.5-preempt/arch/ia64/kernel/perfmon.c	Fri Nov 22 15:32:52 2002
@@ -1529,6 +1529,7 @@
 	DBprintk(("ctx_last_cpu=%d for [%d]\n", atomic_read(&ctx->ctx_last_cpu), task->pid));
 
 	for (i = 0; i < count; i++, req++) {
+		int me;
 
 		if (__get_user(cnum, &req->reg_num)) return -EFAULT;
 		if (__get_user(reg_flags, &req->reg_flags)) return -EFAULT;
@@ -1549,13 +1550,14 @@
 		 * PMU state is still in the local live register due to lazy ctxsw.
 		 * If true, then we read directly from the registers.
 		 */
-		if (atomic_read(&ctx->ctx_last_cpu) = smp_processor_id()){
+		me = get_cpu();
+		if (atomic_read(&ctx->ctx_last_cpu) = me){
 			ia64_srlz_d();
 			val = ia64_get_pmd(cnum);
 			DBprintk(("reading pmd[%u]=0x%lx from hw\n", cnum, val));
 		} else {
-#ifdef CONFIG_SMP
 			int cpu;
+#ifdef CONFIG_SMP
 			/*
 			 * for SMP system, the context may still be live on another
 			 * CPU so we need to fetch it before proceeding with the read
@@ -1575,6 +1577,9 @@
 			/* context has been saved */
 			val = th->pmd[cnum];
 		}
+
+		put_cpu();
+
 		if (PMD_IS_COUNTING(cnum)) {
 			/*
 			 * XXX: need to check for overflow
@@ -2250,9 +2255,13 @@
 pfm_enable(struct task_struct *task, pfm_context_t *ctx, void *arg, int count, 
 	   struct pt_regs *regs)
 {
+	int me;
+
 	/* we don't quite support this right now */
 	if (task != current) return -EINVAL;
 
+	me = get_cpu();  /* make sure we're not migrated */
+
 	if (ctx->ctx_fl_system = 0 && PMU_OWNER()  && PMU_OWNER() != current) 
 		pfm_lazy_save_regs(PMU_OWNER());
 
@@ -2295,12 +2304,14 @@
 	SET_PMU_OWNER(task);
 
 	ctx->ctx_flags.state = PFM_CTX_ENABLED;
-	atomic_set(&ctx->ctx_last_cpu, smp_processor_id());
+	atomic_set(&ctx->ctx_last_cpu, me);
 
 	/* simply unfreeze */
 	ia64_set_pmc(0, 0);
 	ia64_srlz_d();
 
+	put_cpu();
+
 	return 0;
 }
 
@@ -2590,7 +2601,7 @@
 	 * initialize entry header
 	 */
 	h->pid  = current->pid;
-	h->cpu  = smp_processor_id();
+	h->cpu  = get_cpu();
 	h->last_reset_value = ovfl_mask ? ctx->ctx_soft_pmds[ffz(~ovfl_mask)].lval : 0UL;
 	/* 
 	 * where did the fault happen
@@ -2625,7 +2636,7 @@
 		DBprintk_ovfl(("e=%p pmd%d =0x%lx\n", (void *)e, j, *e));
 		e++;
 	}
-	pfm_stats[smp_processor_id()].pfm_recorded_samples_count++;
+	pfm_stats[h->cpu].pfm_recorded_samples_count++;
 
 	/*
 	 * make the new entry visible to user, needs to be atomic
@@ -2642,9 +2653,11 @@
 		/*
 		 * XXX: must reset buffer in blocking mode and lost notified
 		 */
-		pfm_stats[smp_processor_id()].pfm_full_smpl_buffer_count++;
+		pfm_stats[h->cpu].pfm_full_smpl_buffer_count++;
+		put_cpu();
 		return 1;
 	}
+	put_cpu();
 	return 0;
 }
 
@@ -2677,6 +2690,8 @@
 	 * valid one, i.e. the one that caused the interrupt.
 	 */
 
+	preempt_disable();
+
 	t   = &task->thread;
 
 	/*
@@ -2778,6 +2793,7 @@
 	if (ovfl_notify = 0UL) {
 		if (ovfl_pmds) 
 			pfm_reset_regs(ctx, &ovfl_pmds, PFM_RELOAD_SHORT_RESET);
+		preempt_enable();
 		return 0x0;
 	}
 
@@ -2931,7 +2947,7 @@
 	struct task_struct *task;
 	pfm_context_t *ctx;
 
-	pfm_stats[smp_processor_id()].pfm_ovfl_intr_count++;
+	pfm_stats[get_cpu()].pfm_ovfl_intr_count++;
 
 	/* 
 	 * srlz.d done before arriving here
@@ -2954,6 +2970,7 @@
 		if (!ctx) {
 			printk("perfmon: Spurious overflow interrupt: process %d has no PFM context\n", 
 				task->pid);
+			put_cpu();
 			return;
 		}
 #ifdef CONFIG_SMP
@@ -2991,6 +3008,7 @@
 	} else {
 		pfm_stats[smp_processor_id()].pfm_spurious_ovfl_intr_count++;
 	}
+	put_cpu();
 }
 
 /* for debug only */
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/smp.c linux-2.5-preempt/arch/ia64/kernel/smp.c
--- linux-2.5-EXPORT/arch/ia64/kernel/smp.c	Fri Nov 22 15:20:03 2002
+++ linux-2.5-preempt/arch/ia64/kernel/smp.c	Fri Nov 22 15:32:52 2002
@@ -90,7 +90,7 @@
 void
 handle_IPI (int irq, void *dev_id, struct pt_regs *regs)
 {
-	int this_cpu = smp_processor_id();
+	int this_cpu = get_cpu();
 	unsigned long *pending_ipis = &__get_cpu_var(ipi_operation);
 	unsigned long ops;
 
@@ -146,8 +146,12 @@
 		} while (ops);
 		mb();	/* Order data access and bit testing. */
 	}
+	put_cpu();
 }
 
+/*
+ * Called with preeemption disabled 
+ */
 static inline void
 send_IPI_single (int dest_cpu, int op)
 {
@@ -155,6 +159,9 @@
 	platform_send_ipi(dest_cpu, IA64_IPI_VECTOR, IA64_IPI_DM_INT, 0);
 }
 
+/*
+ * Called with preeemption disabled 
+ */
 static inline void
 send_IPI_allbutself (int op)
 {
@@ -166,6 +173,9 @@
 	}
 }
 
+/*
+ * Called with preeemption disabled 
+ */
 static inline void
 send_IPI_all (int op)
 {
@@ -176,12 +186,18 @@
 			send_IPI_single(i, op);
 }
 
+/*
+ * Called with preeemption disabled 
+ */
 static inline void
 send_IPI_self (int op)
 {
 	send_IPI_single(smp_processor_id(), op);
 }
 
+/*
+ * Called with preeemption disabled 
+ */
 void
 smp_send_reschedule (int cpu)
 {
@@ -197,12 +213,15 @@
 smp_send_reschedule_all (void)
 {
 	int i;
+	int cpu = get_cpu(); /* disable preemption */
 
 	for (i = 0; i < NR_CPUS; i++)
-		if (cpu_online(i) && i != smp_processor_id())
+		if (cpu_online(i) && i != cpu)
 			smp_send_reschedule(i);
+	put_cpu();
 }
 
+
 void
 smp_flush_tlb_all (void)
 {
@@ -228,9 +247,11 @@
 {
 	struct call_data_struct data;
 	int cpus = 1;
+	int me = get_cpu(); /* prevent preemption and reschedule on another processor */
 
-	if (cpuid = smp_processor_id()) {
+	if (cpuid = me) {
 		printk("%s: trying to call self\n", __FUNCTION__);
+		put_cpu();
 		return -EBUSY;
 	}
 
@@ -257,6 +278,7 @@
 	call_data = NULL;
 
 	spin_unlock_bh(&call_lock);
+	put_cpu();
 	return 0;
 }
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/mm/tlb.c linux-2.5-preempt/arch/ia64/mm/tlb.c
--- linux-2.5-EXPORT/arch/ia64/mm/tlb.c	Fri Nov 22 15:20:03 2002
+++ linux-2.5-preempt/arch/ia64/mm/tlb.c	Fri Nov 22 15:32:53 2002
@@ -81,9 +81,13 @@
 	}
 	read_unlock(&tasklist_lock);
 	/* can't call flush_tlb_all() here because of race condition with O(1) scheduler [EF] */
-	for (i = 0; i < NR_CPUS; ++i)
-		if (i != smp_processor_id())
-			per_cpu(ia64_need_tlb_flush, i) = 1;
+	{
+		int cpu = get_cpu(); /* prevent preemption/migration */
+		for (i = 0; i < NR_CPUS; ++i)
+			if (i != cpu)
+				per_cpu(ia64_need_tlb_flush, i) = 1;
+		put_cpu();
+	}
 	__flush_tlb_all();
 }
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/include/asm-ia64/hardirq.h linux-2.5-preempt/include/asm-ia64/hardirq.h
--- linux-2.5-EXPORT/include/asm-ia64/hardirq.h	Fri Nov 22 15:22:49 2002
+++ linux-2.5-preempt/include/asm-ia64/hardirq.h	Fri Nov 22 15:35:02 2002
@@ -83,13 +83,13 @@
 #define hardirq_trylock()	(!in_interrupt())
 #define hardirq_endlock()	do { } while (0)
 
-#define in_atomic()		(preempt_count() != 0)
 #define irq_enter()		(preempt_count() += HARDIRQ_OFFSET)
 
 #if CONFIG_PREEMPT
-# error CONFIG_PREEMT currently not supported.
+# define in_atomic()		((preempt_count() & ~PREEMPT_ACTIVE) != kernel_locked())
 # define IRQ_EXIT_OFFSET (HARDIRQ_OFFSET-1)
 #else
+# define in_atomic()		(preempt_count() != 0)
 # define IRQ_EXIT_OFFSET HARDIRQ_OFFSET
 #endif
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/include/asm-ia64/thread_info.h linux-2.5-preempt/include/asm-ia64/thread_info.h
--- linux-2.5-EXPORT/include/asm-ia64/thread_info.h	Fri Nov 22 15:22:52 2002
+++ linux-2.5-preempt/include/asm-ia64/thread_info.h	Fri Nov 22 15:35:03 2002
@@ -15,7 +15,8 @@
 #define TI_ADDR_LIMIT	0x10
 #define TI_PRE_COUNT	0x18
 
-#define PREEMPT_ACTIVE	0x4000000
+#define PREEMPT_ACTIVE_BIT 26
+#define PREEMPT_ACTIVE	(1<<PREEMPT_ACTIVE_BIT)
 
 #ifndef __ASSEMBLY__
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/kernel/sched.c linux-2.5-preempt/kernel/sched.c
--- linux-2.5-EXPORT/kernel/sched.c	Fri Nov 22 15:23:36 2002
+++ linux-2.5-preempt/kernel/sched.c	Fri Nov 22 15:35:33 2002
@@ -2167,6 +2167,9 @@
 		prev_jiffy = jiffies;
 		printk(KERN_ERR "Debug: sleeping function called from illegal"
 				" context at %s:%d\n", file, line);
+		printk(KERN_ERR "Debug: lock_depth = %d, preempt_count=%d\n",
+		       current->lock_depth,
+		       preempt_count() & ~PREEMPT_ACTIVE);
 		dump_stack();
 	}
 #endif

