From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 31 Jan 2003 00:42:51 +0000
Subject: [Linux-ia64] Preemption patch
Message-Id: <marc-linux-ia64-105590709805783@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	here's the latest edition of my preemption patch.
It's been tested on UP only so far... on McKinley, Itanium and the
Simulator.

The main changes are in entry.S to check the RESCHEDULE flag for
kernel threads if preempt_count() is zero, and call schedule() if so.
As my IA64 assembly language skills are shaky, I'd appreciate someone
reviewing that bit of code (as it's also performance critical).

The main other changes are to use get_cpu()/put_cpu() pairs where it's
important not to migrate (instead of smp_processor_id()); and of
course the entry in the Kconfig file.

There's a bug somewhere, that I haven't been able to track down ---
Every now and then, I get a kernel page fault from IA64_leave_kernel
with an IP in region 0, which implies stack corruption to me.

Anyway, here's the patch against the 2.5.59+IA64 kernel:

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/Kconfig linux-2.5-preempt/arch/ia64/Kconfig
--- linux-2.5-EXPORT/arch/ia64/Kconfig	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/Kconfig	Thu Jan 30 14:14:13 2003
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
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5-EXPORT/arch/ia64/hp/sim/simserial.c linux-2.5-preempt/arch/ia64/hp/sim/simserial.c
--- linux-2.5-EXPORT/arch/ia64/hp/sim/simserial.c	Fri Dec 20 11:46:35 2002
+++ linux-2.5-preempt/arch/ia64/hp/sim/simserial.c	Fri Jan 31 10:54:10 2003
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
--- linux-2.5-EXPORT/arch/ia64/kernel/entry.S	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/kernel/entry.S	Fri Jan 31 10:54:10 2003
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
+(pKStk)	cmp4.eq	p6,p0=r21,r0		// p6 <- preempt_count = 0
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
 	tbit.z p6,p0=r18,TIF_NEED_RESCHED		// current_thread_info()->need_resched=0?
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
--- linux-2.5-EXPORT/arch/ia64/kernel/irq.c	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/kernel/irq.c	Thu Jan 30 14:14:13 2003
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
--- linux-2.5-EXPORT/arch/ia64/kernel/palinfo.c	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/kernel/palinfo.c	Thu Jan 30 14:14:13 2003
@@ -895,10 +895,12 @@
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
--- linux-2.5-EXPORT/arch/ia64/kernel/perfmon.c	Thu Jan 30 14:16:26 2003
+++ linux-2.5-preempt/arch/ia64/kernel/perfmon.c	Thu Jan 30 14:14:13 2003
@@ -1634,6 +1634,7 @@
 	DBprintk(("ctx_last_cpu=%d for [%d]\n", atomic_read(&ctx->ctx_last_cpu), task->pid));
 
 	for (i = 0; i < count; i++, req++) {
+		int me;
 #if __GNUC__ < 3
 		foo = __get_user(cnum, &req->reg_num);
 		if (foo) return -EFAULT;
@@ -1661,7 +1662,8 @@
 		 * PMU state is still in the local live register due to lazy ctxsw.
 		 * If true, then we read directly from the registers.
 		 */
-		if (atomic_read(&ctx->ctx_last_cpu) = smp_processor_id()){
+		me = get_cpu();
+		if (atomic_read(&ctx->ctx_last_cpu) = me){
 			ia64_srlz_d();
 			val = ia64_get_pmd(cnum);
 			DBprintk(("reading pmd[%u]=0x%lx from hw\n", cnum, val));
@@ -1687,6 +1689,9 @@
 			/* context has been saved */
 			val = th->pmd[cnum];
 		}
+
+		put_cpu();
+
 		if (PMD_IS_COUNTING(cnum)) {
 			/*
 			 * XXX: need to check for overflow
@@ -2364,9 +2369,13 @@
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
 
@@ -2410,12 +2419,14 @@
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
 
@@ -2706,7 +2717,7 @@
 	 * initialize entry header
 	 */
 	h->pid  = current->pid;
-	h->cpu  = smp_processor_id();
+	h->cpu  = get_cpu();
 	h->last_reset_value = ovfl_mask ? ctx->ctx_soft_pmds[ffz(~ovfl_mask)].lval : 0UL;
 	h->ip   = regs ? regs->cr_iip | ((regs->cr_ipsr >> 41) & 0x3): 0x0UL;
 	h->regs = ovfl_mask; 			/* which registers overflowed */
@@ -2733,7 +2744,7 @@
 		DBprintk_ovfl(("e=%p pmd%d =0x%lx\n", (void *)e, j, *e));
 		e++;
 	}
-	pfm_stats[smp_processor_id()].pfm_recorded_samples_count++;
+	pfm_stats[h->cpu].pfm_recorded_samples_count++;
 
 	/*
 	 * make the new entry visible to user, needs to be atomic
@@ -2750,9 +2761,11 @@
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
 
@@ -2785,6 +2798,8 @@
 	 * valid one, i.e. the one that caused the interrupt.
 	 */
 
+	preempt_disable();
+
 	t   = &task->thread;
 
 	/*
@@ -2794,6 +2809,7 @@
 	if ((t->flags & IA64_THREAD_PM_VALID) = 0 && ctx->ctx_fl_system = 0) {
 		printk("perfmon: Spurious overflow interrupt: process %d not using perfmon\n", 
 			task->pid);
+		preempt_enable();
 		return 0x1;
 	}
 	/*
@@ -2802,6 +2818,7 @@
 	if ((pmc0 & 0x1) = 0) {
 		printk("perfmon: pid %d pmc0=0x%lx assumption error for freeze bit\n", 
 			task->pid, pmc0);
+		preempt_enable();
 		return 0x0;
 	}
 
@@ -2884,6 +2901,7 @@
 	if (ovfl_notify = 0UL) {
 		if (ovfl_pmds) 
 			pfm_reset_regs(ctx, &ovfl_pmds, PFM_PMD_SHORT_RESET);
+		preempt_enable();
 		return 0x0;
 	}
 
@@ -3027,6 +3045,7 @@
 	DBprintk_ovfl(("return pmc0=0x%x must_block=%ld\n",
 				ctx->ctx_fl_frozen ? 0x1 : 0x0, t->pfm_ovfl_block_reset));
 
+	preempt_enable();
 	return ctx->ctx_fl_frozen ? 0x1 : 0x0;
 }
 
@@ -3037,7 +3056,7 @@
 	struct task_struct *task;
 	pfm_context_t *ctx;
 
-	pfm_stats[smp_processor_id()].pfm_ovfl_intr_count++;
+	pfm_stats[get_cpu()].pfm_ovfl_intr_count++;
 
 	/*
 	 * if an alternate handler is registered, just bypass the default one
@@ -3068,6 +3087,7 @@
 		if (!ctx) {
 			printk("perfmon: Spurious overflow interrupt: process %d has no PFM context\n", 
 				task->pid);
+			put_cpu();
 			return;
 		}
 #ifdef CONFIG_SMP
@@ -3105,6 +3125,7 @@
 	} else {
 		pfm_stats[smp_processor_id()].pfm_spurious_ovfl_intr_count++;
 	}
+	put_cpu();
 }
 
 /* for debug only */
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
 
-	if (cpuid = smp_processor_id()) {
+	if (cpuid = me) {
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
--- linux-2.5-EXPORT/arch/ia64/mm/fault.c	Wed Jan 29 13:55:00 2003
+++ linux-2.5-preempt/arch/ia64/mm/fault.c	Thu Jan 30 14:14:13 2003
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
+++ linux-2.5-preempt/include/asm-ia64/hardirq.h	Thu Jan 30 14:15:27 2003
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
+++ linux-2.5-preempt/include/asm-ia64/thread_info.h	Thu Jan 30 14:46:13 2003
@@ -15,7 +15,8 @@
 #define TI_ADDR_LIMIT	0x10
 #define TI_PRE_COUNT	0x18
 
-#define PREEMPT_ACTIVE	0x4000000
+#define PREEMPT_ACTIVE_BIT 26
+#define PREEMPT_ACTIVE	(1<<PREEMPT_ACTIVE_BIT)
 
 #ifndef __ASSEMBLY__
 

