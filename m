From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 14 Feb 2003 04:16:15 +0000
Subject: [Linux-ia64] Preemption patch against ~2.5.60
MIME-Version: 1
Content-Type: multipart/mixed; boundary="S9pJAoJoTi"
Message-Id: <marc-linux-ia64-105590709805847@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--S9pJAoJoTi
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit


OK, here's the latest preemption patch.

--S9pJAoJoTi
Content-Type: text/plain
Content-Disposition: inline;
	filename="ia64-2.5.60-preempt.patch"
Content-Transfer-Encoding: 7bit

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/Kconfig linux-2.5-preempt/arch/ia64/Kconfig
--- linux-2.5-EXPORT/arch/ia64/Kconfig	Thu Feb 13 13:26:52 2003
+++ linux-2.5-preempt/arch/ia64/Kconfig	Thu Feb 13 13:57:07 2003
@@ -424,6 +424,18 @@
 
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
@@ -874,6 +886,12 @@
 	  and certain other kinds of spinlock errors commonly made.  This is
 	  best used in conjunction with the NMI watchdog so that spinlock
 	  deadlocks are also debuggable.
+
+config DEBUG_SPINLOCK_SLEEP
+	  bool "Sleep-inside-spinlock checking"
+	  help
+	    If you say Y here, various routines which may sleep will become very
+	    noisy if they are called with a spinlock held.        
 
 config IA64_DEBUG_CMPXCHG
 	bool "Turn on compare-and-exchange bug checking (slow!)"
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/hp/sim/simserial.c linux-2.5-preempt/arch/ia64/hp/sim/simserial.c
--- linux-2.5-EXPORT/arch/ia64/hp/sim/simserial.c	Mon Feb 10 10:20:14 2003
+++ linux-2.5-preempt/arch/ia64/hp/sim/simserial.c	Thu Feb 13 13:43:47 2003
@@ -63,7 +63,6 @@
 
 static char *serial_name = "SimSerial driver";
 static char *serial_version = "0.6";
-static spinlock_t serial_lock = SPIN_LOCK_UNLOCKED;
 
 /*
  * This has been extracted from asm/serial.h. We need one eventually but
@@ -235,14 +234,14 @@
 
 	if (!tty || !info->xmit.buf) return;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_irq_save(flags);
 	if (CIRC_SPACE(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE) == 0) {
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
@@ -250,7 +249,8 @@
 	int count;
 	unsigned long flags;
 
-	spin_lock_irqsave(&serial_lock, flags);
+
+	local_irq_save(flags);
 
 	if (info->x_char) {
 		char c = info->x_char;
@@ -293,7 +293,7 @@
 		info->xmit.tail += count;
 	}
 out:
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 static void rs_flush_chars(struct tty_struct *tty)
@@ -334,7 +334,7 @@
 				break;
 			}
 
-			spin_lock_irqsave(&serial_lock, flags);
+			local_irq_save(flags);
 			{
 				c1 = CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail,
 						       SERIAL_XMIT_SIZE);
@@ -344,7 +344,7 @@
 				info->xmit.head = ((info->xmit.head + c) &
 						   (SERIAL_XMIT_SIZE-1));
 			}
-			spin_unlock_irqrestore(&serial_lock, flags);
+			local_irq_restore(flags);
 
 			buf += c;
 			count -= c;
@@ -352,7 +352,7 @@
 		}
 		up(&tmp_buf_sem);
 	} else {
-		spin_lock_irqsave(&serial_lock, flags);
+		local_irq_save(flags);
 		while (1) {
 			c = CIRC_SPACE_TO_END(info->xmit.head, info->xmit.tail, SERIAL_XMIT_SIZE);
 			if (count < c)
@@ -367,7 +367,7 @@
 			count -= c;
 			ret += c;
 		}
-		spin_unlock_irqrestore(&serial_lock, flags);
+		local_irq_restore(flags);
 	}
 	/*
 	 * Hey, we transmit directly from here in our case
@@ -398,9 +398,9 @@
 	struct async_struct *info = (struct async_struct *)tty->driver_data;
 	unsigned long flags;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_irq_save(flags);
 	info->xmit.head = info->xmit.tail = 0;
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 
 	wake_up_interruptible(&tty->write_wait);
 
@@ -573,7 +573,7 @@
 	       state->irq);
 #endif
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_irq_save(flags);
 	{
 		/*
 		 * First unlink the serial port from the IRQ chain...
@@ -611,7 +611,7 @@
 
 		info->flags &= ~ASYNC_INITIALIZED;
 	}
-	spin_unlock_irqrestore(&serial_lock, flags);
+	local_irq_restore(flags);
 }
 
 /*
@@ -634,13 +634,13 @@
 
 	state = info->state;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_irq_save(flags);
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
@@ -665,11 +665,11 @@
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
@@ -776,7 +776,7 @@
 	if (!page)
 		return -ENOMEM;
 
-	spin_lock_irqsave(&serial_lock, flags);
+	local_irq_save(flags);
 
 	if (info->flags & ASYNC_INITIALIZED) {
 		free_page(page);
@@ -857,11 +857,11 @@
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
--- linux-2.5-EXPORT/arch/ia64/ia32/ia32_support.c	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/ia32/ia32_support.c	Thu Jan 30 14:14:13 2003
@@ -93,7 +93,7 @@
 {
 	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd, tssd;
 	struct pt_regs *regs = ia64_task_regs(t);
-	int nr = smp_processor_id();	/* LDT and TSS depend on CPU number: */
+	int nr = get_cpu();	/* LDT and TSS depend on CPU number: */
 
 	eflag = t->thread.eflag;
 	fsr = t->thread.fsr;
@@ -119,6 +119,7 @@
 
 	regs->r17 = (_TSS(nr) << 48) | (_LDT(nr) << 32) | (__u32) regs->r17;
 	regs->r30 = load_desc(_LDT(nr));				/* LDTD */
+	put_cpu();
 }
 
 /*
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/entry.S linux-2.5-preempt/arch/ia64/kernel/entry.S
--- linux-2.5-EXPORT/arch/ia64/kernel/entry.S	Thu Feb 13 13:26:52 2003
+++ linux-2.5-preempt/arch/ia64/kernel/entry.S	Thu Feb 13 13:43:47 2003
@@ -586,10 +586,21 @@
 	// work.need_resched etc. mustn't get changed by this CPU before it returns to
 	// user- or fsys-mode:
 (pUStk)	cmp.eq.unc p6,p0=r0,r0			// p6 <- pUStk
+#ifdef CONFIG_PREEMPT
+	rsm psr.i				// disable interrupts
+	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+(pKStk) adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+(pKStk) ld4  r21=[r20]			// preempt_count ->r21
+	;;
+(pKStk)	cmp4.eq	p6,p0=r21,r0		// p6 <- preempt_count == 0
+	;;
+#else // CONFIG_PREEMPT
 (pUStk)	rsm psr.i
 	;;
 (pUStk)	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
 	;;
+#endif // CONFIG_PREEMPT
 .work_processed:
 (p6)	ld4 r18=[r17]				// load current_thread_info()->flags
 	adds r2=PT(R8)+16,r12
@@ -810,15 +821,27 @@
 .work_pending:
 	tbit.z p6,p0=r18,TIF_NEED_RESCHED		// current_thread_info()->need_resched==0?
 (p6)	br.cond.sptk.few .notify
+#ifdef CONFIG_PREEMPT
+(pKStk)	dep r21=-1,r0,PREEMPT_ACTIVE_BIT,1
+	;;
+(pKStk) st4 [r20]=r21
+	ssm  psr.i		// enable interrupts
+#endif
+	
 #if __GNUC__ < 3
 	br.call.spnt.many rp=invoke_schedule
 #else
 	br.call.spnt.many rp=schedule
 #endif
 .ret9:	cmp.eq p6,p0=r0,r0				// p6 <- 1
-	rsm psr.i
+	rsm psr.i		// disable interrupts
 	;;
 	adds r17=TI_FLAGS+IA64_TASK_SIZE,r13
+#if CONFIG_PREEMPT
+(pKStk)	adds r20=TI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+(pKStk)	st4 [r20]=r0	// preempt_count() <- 0
+#endif
 	br.cond.sptk.many .work_processed		// re-check
 
 .notify:
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/irq.c linux-2.5-preempt/arch/ia64/kernel/irq.c
--- linux-2.5-EXPORT/arch/ia64/kernel/irq.c	Mon Feb 10 10:20:14 2003
+++ linux-2.5-preempt/arch/ia64/kernel/irq.c	Thu Feb 13 13:43:47 2003
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
 	kstat_cpu(cpu).irqs[irq]++;
 
 	if (desc->status & IRQ_PER_CPU) {
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/palinfo.c linux-2.5-preempt/arch/ia64/kernel/palinfo.c
--- linux-2.5-EXPORT/arch/ia64/kernel/palinfo.c	Mon Feb 10 10:20:14 2003
+++ linux-2.5-preempt/arch/ia64/kernel/palinfo.c	Thu Feb 13 13:43:47 2003
@@ -894,10 +894,12 @@
 	 * in SMP mode, we may need to call another CPU to get correct
 	 * information. PAL, by definition, is processor specific
 	 */
-	if (f->req_cpu == smp_processor_id())
+	if (f->req_cpu == get_cpu())
 		len = (*palinfo_entries[f->func_id].proc_read)(page);
 	else
 		len = palinfo_handle_smp(f, page);
+
+	put_cpu();
 
 	if (len <= off+count) *eof = 1;
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/perfmon.c linux-2.5-preempt/arch/ia64/kernel/perfmon.c
--- linux-2.5-EXPORT/arch/ia64/kernel/perfmon.c	Thu Feb 13 13:26:52 2003
+++ linux-2.5-preempt/arch/ia64/kernel/perfmon.c	Fri Feb 14 14:43:03 2003
@@ -1523,6 +1523,7 @@
 	 * Cannot do anything before PMU is enabled 
 	 */
 	if (!CTX_IS_ENABLED(ctx)) return -EINVAL;
+	preempt_disable();
 
 	/* XXX: ctx locking may be required here */
 
@@ -1599,10 +1600,12 @@
 				ctx->ctx_used_pmds[0],
 				ctx->ctx_soft_pmds[cnum].reset_pmds[0]));
 	}
-
+	preempt_enable();
 	return 0;
 
 abort_mission:
+	preempt_enable();
+
 	/*
 	 * for now, we have only one possibility for error
 	 */
@@ -1647,6 +1650,7 @@
 	DBprintk(("ctx_last_cpu=%d for [%d]\n", atomic_read(&ctx->ctx_last_cpu), task->pid));
 
 	for (i = 0; i < count; i++, req++) {
+		int me;
 #if __GNUC__ < 3
 		foo = __get_user(cnum, &req->reg_num);
 		if (foo) return -EFAULT;
@@ -1674,13 +1678,16 @@
 		 * PMU state is still in the local live register due to lazy ctxsw.
 		 * If true, then we read directly from the registers.
 		 */
-		if (atomic_read(&ctx->ctx_last_cpu) == smp_processor_id()){
+		me = get_cpu();
+		if (atomic_read(&ctx->ctx_last_cpu) == me){
 			ia64_srlz_d();
 			val = ia64_get_pmd(cnum);
 			DBprintk(("reading pmd[%u]=0x%lx from hw\n", cnum, val));
 		} else {
 			val = th->pmd[cnum];
 		}
+
+
 		if (PMD_IS_COUNTING(cnum)) {
 			/*
 			 * XXX: need to check for overflow
@@ -1702,6 +1709,8 @@
 
 		PFM_REG_RETFLAG_SET(reg_flags, ret);
 
+		put_cpu();
+
 		DBprintk(("read pmd[%u] ret=%d value=0x%lx pmc=0x%lx\n", 
 					cnum, ret, val, ia64_get_pmc(cnum)));
 
@@ -1839,6 +1848,7 @@
 			ctx->ctx_fl_frozen,
 			ctx->ctx_ovfl_regs[0]));
 
+		preempt_disable();
 		pfm_reset_regs(ctx, ctx->ctx_ovfl_regs, PFM_PMD_LONG_RESET);
 
 		ctx->ctx_ovfl_regs[0] = 0UL;
@@ -1857,6 +1867,8 @@
 		/* simply unfreeze */
 		pfm_unfreeze_pmu();
 
+		preempt_enable();
+
 		return 0;
 	} 
 	/* restart on another task */
@@ -1914,6 +1926,7 @@
 				ctx->ctx_fl_system, PMU_OWNER(),
 				current));
 
+	preempt_disable();
 	/* simply stop monitoring but not the PMU */
 	if (ctx->ctx_fl_system) {
 
@@ -1941,6 +1954,7 @@
 		 */
 		ia64_psr(regs)->up = 0;
 	}
+	preempt_enable();
 	return 0;
 }
 
@@ -1953,6 +1967,7 @@
 
 	if (!CTX_IS_ENABLED(ctx)) return -EINVAL;
 
+	preempt_disable();
 	/*
 	 * stop monitoring, freeze PMU, and save state in context
 	 * this call will clear IA64_THREAD_PM_VALID for per-task sessions.
@@ -1973,6 +1988,7 @@
 	DBprintk(("enabling psr.sp for [%d]\n", current->pid));
 
 	ctx->ctx_flags.state = PFM_CTX_DISABLED;
+	preempt_enable();
 
 	return 0;
 }
@@ -2322,6 +2338,7 @@
 		return -EINVAL;
 	}
 
+	preempt_disable();
 	if (ctx->ctx_fl_system) {
 		
 		PFM_CPUINFO_SET(PFM_CPUINFO_DCR_PP);
@@ -2339,6 +2356,7 @@
 
 	} else {
 		if ((task->thread.flags & IA64_THREAD_PM_VALID) == 0) {
+			preempt_enable();
 			printk(KERN_DEBUG "perfmon: pfm_start task flag not set for [%d]\n",
 			       task->pid);
 			return -EINVAL;
@@ -2352,6 +2370,7 @@
 		ia64_srlz_i();
 	}
 
+	preempt_enable();
 	return 0;
 }
 
@@ -2359,9 +2378,13 @@
 pfm_enable(struct task_struct *task, pfm_context_t *ctx, void *arg, int count, 
 	   struct pt_regs *regs)
 {
+	int me;
+
 	/* we don't quite support this right now */
 	if (task != current) return -EINVAL;
 
+	me = get_cpu();  /* make sure we're not migrated or preempted */
+
 	if (ctx->ctx_fl_system == 0 && PMU_OWNER()  && PMU_OWNER() != current) 
 		pfm_lazy_save_regs(PMU_OWNER());
 
@@ -2405,11 +2428,13 @@
 	SET_PMU_OWNER(task);
 
 	ctx->ctx_flags.state = PFM_CTX_ENABLED;
-	atomic_set(&ctx->ctx_last_cpu, smp_processor_id());
+	atomic_set(&ctx->ctx_last_cpu, me);
 
 	/* simply unfreeze */
 	pfm_unfreeze_pmu();
 
+	put_cpu();
+
 	return 0;
 }
 
@@ -2826,7 +2851,7 @@
 	 * initialize entry header
 	 */
 	h->pid  = current->pid;
-	h->cpu  = smp_processor_id();
+	h->cpu  = get_cpu();
 	h->last_reset_value = ovfl_mask ? ctx->ctx_soft_pmds[ffz(~ovfl_mask)].lval : 0UL;
 	h->ip   = regs ? regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3): 0x0UL;
 	h->regs = ovfl_mask; 			/* which registers overflowed */
@@ -2853,7 +2878,7 @@
 		DBprintk_ovfl(("e=%p pmd%d =0x%lx\n", (void *)e, j, *e));
 		e++;
 	}
-	pfm_stats[smp_processor_id()].pfm_recorded_samples_count++;
+	pfm_stats[h->cpu].pfm_recorded_samples_count++;
 
 	/*
 	 * make the new entry visible to user, needs to be atomic
@@ -2870,9 +2895,11 @@
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
 
@@ -2904,6 +2931,8 @@
 	 * valid one, i.e. the one that caused the interrupt.
 	 */
 
+	preempt_disable();
+
 	t   = &task->thread;
 
 	/*
@@ -2913,6 +2942,7 @@
 	if ((t->flags & IA64_THREAD_PM_VALID) == 0 && ctx->ctx_fl_system == 0) {
 		printk(KERN_DEBUG "perfmon: Spurious overflow interrupt: process %d not "
 		       "using perfmon\n", task->pid);
+		preempt_enable_no_resched();
 		return 0x1;
 	}
 	/*
@@ -2921,6 +2951,7 @@
 	if ((pmc0 & 0x1) == 0) {
 		printk(KERN_DEBUG "perfmon: pid %d pmc0=0x%lx assumption error for freeze bit\n",
 		       task->pid, pmc0);
+		preempt_enable_no_resched();
 		return 0x0;
 	}
 
@@ -3003,6 +3034,7 @@
 	if (ovfl_notify == 0UL) {
 		if (ovfl_pmds) 
 			pfm_reset_regs(ctx, &ovfl_pmds, PFM_PMD_SHORT_RESET);
+		preempt_enable_no_resched();
 		return 0x0UL;
 	}
 
@@ -3038,6 +3070,7 @@
 		t->pfm_ovfl_block_reset,
 		ctx->ctx_fl_trap_reason));
 
+	preempt_enable_no_resched();
 	return 0x1UL;
 }
 
@@ -3048,13 +3081,14 @@
 	struct task_struct *task;
 	pfm_context_t *ctx;
 
-	pfm_stats[smp_processor_id()].pfm_ovfl_intr_count++;
+	pfm_stats[get_cpu()].pfm_ovfl_intr_count++;
 
 	/*
 	 * if an alternate handler is registered, just bypass the default one
 	 */
 	if (pfm_alternate_intr_handler) {
 		(*pfm_alternate_intr_handler->handler)(irq, arg, regs);
+		put_cpu();
 		return;
 	}
 
@@ -3079,6 +3113,7 @@
 		if (!ctx) {
 			printk(KERN_DEBUG "perfmon: Spurious overflow interrupt: process %d has "
 			       "no PFM context\n", task->pid);
+			put_cpu();
 			return;
 		}
 
@@ -3104,6 +3139,7 @@
 	} else {
 		pfm_stats[smp_processor_id()].pfm_spurious_ovfl_intr_count++;
 	}
+	put_cpu_no_resched();
 }
 
 /* for debug only */
@@ -3174,6 +3210,7 @@
 	unsigned long dcr;
 	unsigned long dcr_pp;
 
+	preempt_disable();
 	dcr_pp = info & PFM_CPUINFO_DCR_PP ? 1 : 0;
 
 	/*
@@ -3184,6 +3221,7 @@
 		regs = (struct pt_regs *)((unsigned long) task + IA64_STK_OFFSET);
 		regs--;
 		ia64_psr(regs)->pp = is_ctxswin ? dcr_pp : 0;
+		preempt_enable();
 		return;
 	}
 	/*
@@ -3199,6 +3237,7 @@
 			ia64_set_dcr(dcr & ~IA64_DCR_PP);
 			pfm_clear_psr_pp();
 			ia64_srlz_i();
+			preempt_enable();
 			return;
 		}
 		/* 
@@ -3212,6 +3251,7 @@
 		pfm_set_psr_pp();
 		ia64_srlz_i();
 	}
+	preempt_enable();
 }
 
 void
@@ -3222,6 +3262,8 @@
 	u64 psr;
 	int i;
 
+	preempt_disable();
+
 	ctx = task->thread.pfm_context;
 
 
@@ -3275,6 +3317,7 @@
 	 */
 	atomic_set(&ctx->ctx_last_cpu, -1);
 #endif
+	preempt_enable();
 }
 
 static void
@@ -3285,6 +3328,7 @@
 	unsigned long mask;
 	int i;
 
+	preempt_disable();
 	DBprintk(("on [%d] by [%d]\n", task->pid, current->pid));
 
 	t   = &task->thread;
@@ -3311,6 +3355,7 @@
 
 	/* not owned by this CPU */
 	atomic_set(&ctx->ctx_last_cpu, -1);
+	preempt_enable();
 }
 
 void
@@ -3323,11 +3368,14 @@
 	u64 psr;
 	int i;
 
+	preempt_disable();
+
 	owner = PMU_OWNER();
 	ctx   = task->thread.pfm_context;
 	t     = &task->thread;
 
 	if (ctx == NULL) {
+		preempt_enable();
 		printk("perfmon: pfm_load_regs: null ctx for [%d]\n", task->pid);
 		return;
 	}
@@ -3366,7 +3414,7 @@
 
 		psr = ctx->ctx_saved_psr;
 		pfm_set_psr_l(psr);
-
+		preempt_enable();
 		return;
 	}
 
@@ -3428,6 +3476,7 @@
 	 * restore the psr we changed in pfm_save_regs()
 	 */
 	psr = ctx->ctx_saved_psr;
+	preempt_enable();
 	pfm_set_psr_l(psr);
 }
 
@@ -3445,6 +3494,7 @@
 		printk("perfmon: invalid task in pfm_reset_pmu()\n");
 		return;
 	}
+	preempt_disable();
 
 	/* Let's make sure the PMU is frozen */
 	pfm_freeze_pmu();
@@ -3527,6 +3577,7 @@
 	ctx->ctx_used_dbrs[0] = 0UL;
 
 	ia64_srlz_d();
+	preempt_enable();
 }
 
 /*
@@ -3556,6 +3607,7 @@
 	 */
 	if (ctx->ctx_flags.state == PFM_CTX_DISABLED) return;
 
+	preempt_disable();
 	/*
 	 * stop monitoring:
 	 * This is the only way to stop monitoring without destroying overflow
@@ -3683,7 +3735,7 @@
 	 * indicates that context has been saved
 	 */
 	atomic_set(&ctx->ctx_last_cpu, -1);
-
+	preempt_enable();
 }
 
 
@@ -3706,6 +3758,7 @@
 	ctx    = task->thread.pfm_context;
 	thread = &task->thread;
 
+	preempt_disable();
 	/*
 	 * make sure child cannot mess up the monitoring session
 	 */
@@ -3760,6 +3813,8 @@
 		 */
 	 	ia64_psr(regs)->up = 0;
 
+		preempt_enable();
+
 		/* copy_thread() clears IA64_THREAD_PM_VALID */
 		return 0;
 	}
@@ -3865,6 +3920,8 @@
 		thread->flags |= IA64_THREAD_PM_VALID;
 	}
 
+	preempt_enable();
+
 	return 0;
 }
 
@@ -3886,6 +3943,7 @@
 	/*
 	 * check sampling buffer
 	 */
+	preempt_disable();
 	if (ctx->ctx_psb) {
 		pfm_smpl_buffer_desc_t *psb = ctx->ctx_psb;
 
@@ -3978,6 +4036,7 @@
 	}
 
 	UNLOCK_CTX(ctx);
+	preempt_enable();
 
 	pfm_unreserve_session(task, ctx->ctx_fl_system, 1UL << ctx->ctx_cpu);
 
@@ -4156,17 +4215,27 @@
 {
 	int ret;
 
+
 	/* some sanity checks */
-	if (hdl == NULL || hdl->handler == NULL) return -EINVAL;
+	if (hdl == NULL || hdl->handler == NULL) {
+		return -EINVAL;
+	}
 
 	/* do the easy test first */
-	if (pfm_alternate_intr_handler) return -EBUSY;
+	if (pfm_alternate_intr_handler) {
+		return -EBUSY;
+	}
 
+	preempt_disable();
 	/* reserve our session */
 	ret = pfm_reserve_session(NULL, 1, cpu_online_map);
-	if (ret) return ret;
+	if (ret) {
+		preempt_enable();
+		return ret;
+	}
 
 	if (pfm_alternate_intr_handler) {
+		preempt_enable();
 		printk(KERN_DEBUG "perfmon: install_alternate, intr_handler not NULL "
 		       "after reserve\n");
 		return -EINVAL;
@@ -4174,17 +4243,21 @@
 
 	pfm_alternate_intr_handler = hdl;
 
+	preempt_enable();
 	return 0;
 }
 
 int
 pfm_remove_alternate_syswide_subsystem(pfm_intr_handler_desc_t *hdl)
 {
-	if (hdl == NULL) return -EINVAL;
+	if (hdl == NULL)
+		return -EINVAL;
 
 	/* cannot remove someone else's handler! */
-	if (pfm_alternate_intr_handler != hdl) return -EINVAL;
+	if (pfm_alternate_intr_handler != hdl) 
+		return -EINVAL;
 
+	preempt_disable();
 	pfm_alternate_intr_handler = NULL;
 
 	/* 
@@ -4192,6 +4265,8 @@
 	 */
 	pfm_unreserve_session(NULL, 1, cpu_online_map);
 
+	preempt_enable();
+
 	return 0;
 }
 
@@ -4272,8 +4347,9 @@
 pfm_init_percpu(void)
 {
 	int i;
+	int me = get_cpu();
 
-	if (smp_processor_id() == 0)
+	if (me == 0)
 		register_percpu_irq(IA64_PERFMON_VECTOR, &perfmon_irqaction);
 
 	ia64_set_pmv(IA64_PERFMON_VECTOR);
@@ -4297,6 +4373,7 @@
 		if (PMD_IS_IMPL(i) == 0) continue;
 		ia64_set_pmd(i, 0UL);
 	}
+	put_cpu();
 	pfm_freeze_pmu();
 }
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/kernel/smp.c linux-2.5-preempt/arch/ia64/kernel/smp.c
--- linux-2.5-EXPORT/arch/ia64/kernel/smp.c	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/kernel/smp.c	Thu Jan 30 14:14:13 2003
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
@@ -247,9 +266,11 @@
 {
 	struct call_data_struct data;
 	int cpus = 1;
+	int me = get_cpu(); /* prevent preemption and reschedule on another processor */
 
-	if (cpuid == smp_processor_id()) {
+	if (cpuid == me) {
 		printk("%s: trying to call self\n", __FUNCTION__);
+		put_cpu();
 		return -EBUSY;
 	}
 
@@ -276,6 +297,7 @@
 	call_data = NULL;
 
 	spin_unlock_bh(&call_lock);
+	put_cpu();
 	return 0;
 }
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/mm/fault.c linux-2.5-preempt/arch/ia64/mm/fault.c
--- linux-2.5-EXPORT/arch/ia64/mm/fault.c	Thu Feb 13 13:26:52 2003
+++ linux-2.5-preempt/arch/ia64/mm/fault.c	Thu Feb 13 13:43:47 2003
@@ -55,7 +55,7 @@
 	/*
 	 * If we're in an interrupt or have no user context, we must not take the fault..
 	 */
-	if (in_interrupt() || !mm)
+	if (in_atomic() || !mm)
 		goto no_context;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/mm/tlb.c linux-2.5-preempt/arch/ia64/mm/tlb.c
--- linux-2.5-EXPORT/arch/ia64/mm/tlb.c	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/mm/tlb.c	Thu Jan 30 14:14:13 2003
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
 	local_flush_tlb_all();
 }
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/include/asm-ia64/hardirq.h linux-2.5-preempt/include/asm-ia64/hardirq.h
--- linux-2.5-EXPORT/include/asm-ia64/hardirq.h	Fri Dec 20 11:47:33 2002
+++ linux-2.5-preempt/include/asm-ia64/hardirq.h	Wed Feb  5 11:03:22 2003
@@ -32,18 +32,18 @@
  *
  * - bits 0-7 are the preemption count (max preemption depth: 256)
  * - bits 8-15 are the softirq count (max # of softirqs: 256)
- * - bits 16-31 are the hardirq count (max # of hardirqs: 65536)
+ * - bits 16-29 are the hardirq count (max # of hardirqs: 16384)
  *
  * - (bit 63 is the PREEMPT_ACTIVE flag---not currently implemented.)
  *
  * PREEMPT_MASK: 0x000000ff
  * SOFTIRQ_MASK: 0x0000ff00
- * HARDIRQ_MASK: 0xffff0000
+ * HARDIRQ_MASK: 0x3fff0000
  */
 
 #define PREEMPT_BITS	8
 #define SOFTIRQ_BITS	8
-#define HARDIRQ_BITS	16
+#define HARDIRQ_BITS	14
 
 #define PREEMPT_SHIFT	0
 #define SOFTIRQ_SHIFT	(PREEMPT_SHIFT + PREEMPT_BITS)
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
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/include/asm-ia64/spinlock.h linux-2.5-preempt/include/asm-ia64/spinlock.h
--- linux-2.5-EXPORT/include/asm-ia64/spinlock.h	Wed Jan 29 13:55:21 2003
+++ linux-2.5-preempt/include/asm-ia64/spinlock.h	Wed Feb  5 09:35:40 2003
@@ -189,4 +189,19 @@
 	clear_bit(31, (x));								\
 })
 
+#define _raw_write_trylock(rw)			\
+({						\
+ 	register long result;			\
+	                                        \
+	__asm__ __volatile__ (			\
+		"mov ar.ccv = r0\n"             \
+		"dep r29 = -1, r0, 31, 1\n"	\
+		";;\n"				\
+		"1:\n"				\
+		"cmpxchg4.acq %0 = [%1], r29, ar.ccv\n"		       	     \
+		:"=r"(result) :"r"(rw) : "ar.ccv", "r2", "r29", "memory");    \
+		(result == 0);			\
+})
+
+
 #endif /*  _ASM_IA64_SPINLOCK_H */
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/include/asm-ia64/system.h linux-2.5-preempt/include/asm-ia64/system.h
--- linux-2.5-EXPORT/include/asm-ia64/system.h	Wed Jan 29 13:55:21 2003
+++ linux-2.5-preempt/include/asm-ia64/system.h	Thu Jan 30 14:15:28 2003
@@ -206,7 +206,7 @@
 
 #ifdef CONFIG_PERFMON
   DECLARE_PER_CPU(unsigned long, pfm_syst_info);
-# define PERFMON_IS_SYSWIDE() (get_cpu_var(pfm_syst_info) & 0x1)
+# define PERFMON_IS_SYSWIDE() (__get_cpu_var(pfm_syst_info) & 0x1)
 #else
 # define PERFMON_IS_SYSWIDE() (0)
 #endif
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/include/asm-ia64/thread_info.h linux-2.5-preempt/include/asm-ia64/thread_info.h
--- linux-2.5-EXPORT/include/asm-ia64/thread_info.h	Wed Jan 29 13:55:21 2003
+++ linux-2.5-preempt/include/asm-ia64/thread_info.h	Wed Feb  5 11:03:22 2003
@@ -15,7 +15,8 @@
 #define TI_ADDR_LIMIT	0x10
 #define TI_PRE_COUNT	0x18
 
-#define PREEMPT_ACTIVE	0x4000000
+#define PREEMPT_ACTIVE_BIT 30
+#define PREEMPT_ACTIVE	(1<<PREEMPT_ACTIVE_BIT)
 
 #ifndef __ASSEMBLY__
 

--S9pJAoJoTi--

