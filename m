From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 02 May 2000 06:59:05 +0000
Subject: [Linux-ia64] new kernel diff (relative to v2.3.99-pre6)
Message-Id: <marc-linux-ia64-105590678205061@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205032@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205032@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is the latest kernel diff.  Summary of changes:

	- Make kernel work on SoftSDV again (Don).

	- Don's IA-32 debug-code removal fixes.

	- Make kernel work with HP simulator again (simserial updates).

	- Make IVR workarounds A1-stepping specific.  However,
	  CONFIG_ITANIUM_A1_SPECIFIC MUST be defined for now, even if
	  you're running on A2 or later.  I couldn't yet get the
	  kernel to work without the A1 workarounds, so you can't turn
	  these workarounds off just yet.

	- Small fix to make strace work better.  Problem was due to
	  the fact that the kernel didn't notify the parent upon
	  returning from sigreturn.

	- Fix a suble error that caused time-warps on UP when the
	  system was under heavy load.  With these fixes in place, UP
	  systems pass the test program I'm using to verify that
	  gettimeofday() returns non-decreasing values even under
	  heavy load.

	- Fix a small bug in SET_UNALIGN_CTL() which had the effect of
	  making it possible to only turn unalign control bits on (no
	  way to turn them off ;-).

	- Reinstantiate ipc_parse_version() fixes to ensure that on
	  IA-64 we always use the IPC_64 version of the IPC syscalls.

As usual, the diff attached below is for informational purposes only.
The full diff is at ftp.kernel.org:/pub/linux/kernel/ports/ia64/ in:

	linux-2.3.99-pre6-ia64-000501.diff.bz2

This kernel has been tested with UP hardware and the HP simulator.  I
expect it to work on SMP as well.  Caveat: I don't think the NFS
server works in this kernel, at least not if V3 support is enabled.
It could be a nfs-utils problem, but I haven't tried to track it down
(the NFS client works fine though).

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/config.in linux-2.3.99-pre6-lia/arch/ia64/config.in
--- linux-davidm/arch/ia64/config.in	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/config.in	Fri Apr 28 21:18:19 2000
@@ -23,6 +23,7 @@
 
 if [ "$CONFIG_IA64_DIG" = "y" ]; then
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
+	bool '  Enable Itanium A1-step specific code' CONFIG_ITANIUM_A1_SPECIFIC
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable BigSur hacks' CONFIG_IA64_BIGSUR_HACKS
 	bool '  Enable Lion hacks' CONFIG_IA64_LION_HACKS
diff -urN linux-davidm/arch/ia64/dig/iosapic.c linux-2.3.99-pre6-lia/arch/ia64/dig/iosapic.c
--- linux-davidm/arch/ia64/dig/iosapic.c	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/dig/iosapic.c	Wed Apr 26 15:39:43 2000
@@ -240,6 +240,7 @@
 #endif
 	}
 
+#ifndef CONFIG_IA64_SOFTSDV_HACKS
 	/* 
 	 * Map the PCI Interrupt data into the ACPI IOSAPIC data using
 	 * the info that the bootstrap loader passed to us.
@@ -270,6 +271,7 @@
 		       irq, iosapic_pin(irq));
 #endif
 	}
+#endif /* CONFIG_IA64_SOFTSDV_HACKS */
 
 	for (i = 0; i < NR_IRQS; ++i) {
 		if (iosapic_pin(i) != -1) {
diff -urN linux-davidm/arch/ia64/dig/setup.c linux-2.3.99-pre6-lia/arch/ia64/dig/setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/dig/setup.c	Wed Apr 26 15:43:29 2000
@@ -53,6 +53,10 @@
 	 */
 	ROOT_DEV = to_kdev_t(0x0802);		/* default to second partition on first drive */
 
+#ifdef	CONFIG_IA64_SOFTSDV_HACKS
+	ROOT_DEV = to_kdev_t(0x0302);		/* 2nd partion on 1st IDE */
+#endif /* CONFIG_IA64_SOFTSDV_HACKS */
+
 #ifdef CONFIG_SMP
 	init_smp_config();
 #endif
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.3.99-pre6-lia/arch/ia64/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/ia32/sys_ia32.c	Wed Apr 26 15:44:18 2000
@@ -214,29 +214,21 @@
 		return -EINVAL;
 	if (prot & PROT_WRITE)
 		prot |= PROT_EXEC;
-#ifdef	DDD
-#else	// DDD
 	prot |= PROT_WRITE;
-#endif	// DDD
 	front = NULL;
 	back = NULL;
 	if ((baddr = (addr & PAGE_MASK)) != addr && get_user(c, (char *)baddr) = 0) {
 		front = kmalloc(addr - baddr, GFP_KERNEL);
 		memcpy(front, (void *)baddr, addr - baddr);
 	}
-#ifndef	DDD
-	if (addr)
-#endif
-	if (((addr + len) & ~PAGE_MASK) && get_user(c, (char *)(addr + len)) = 0) {
+	if (addr && ((addr + len) & ~PAGE_MASK) && get_user(c, (char *)(addr + len)) = 0) {
 		back = kmalloc(PAGE_SIZE - ((addr + len) & ~PAGE_MASK), GFP_KERNEL);
 		memcpy(back, addr + len, PAGE_SIZE - ((addr + len) & ~PAGE_MASK));
 	}
 	if ((r = do_mmap(0, baddr, len + (addr - baddr), prot, flags | MAP_ANONYMOUS, 0)) < 0)
 		return(r);
-#ifndef	DDD
 	if (addr = 0)
 		addr = r;
-#endif	// DDD
 	if (back) {
 		memcpy(addr + len, back, PAGE_SIZE - ((addr + len) & ~PAGE_MASK));
 		kfree(back);
@@ -300,11 +292,7 @@
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-#ifdef	DDD
 	if ((a.flags & MAP_FIXED) && ((a.addr & ~PAGE_MASK) || (a.offset & ~PAGE_MASK))) {
-#else	// DDD
-	if (1) {
-#endif	// DDD
 		unlock_kernel();
 		up(&current->mm->mmap_sem);
 		error = do_mmap_fake(file, a.addr, a.len, a.prot, a.flags, a.offset);
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.3.99-pre6-lia/arch/ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/entry.S	Wed Apr 26 15:42:43 2000
@@ -772,7 +772,9 @@
 	mov rp=loc1
 	br.ret.sptk.many rp
 	.endp invoke_schedule_tail
+#endif /* CONFIG_SMP */
 
+#if defined(CONFIG_SMP) || defined(CONFIG_IA64_SOFTSDV_HACKS)
 	.proc invoke_ia64_reset_itm
 invoke_ia64_reset_itm:
 	alloc loc0=ar.pfs,8,2,0,0
@@ -784,8 +786,7 @@
 	mov rp=loc1
 	br.ret.sptk.many rp
 	.endp invoke_ia64_reset_itm
-
-#endif /* CONFIG_SMP */
+#endif /* defined(CONFIG_SMP) || defined(CONFIG_IA64_SOFTSDV_HACKS) */
 
 	/*
 	 * Invoke do_softirq() while preserving in0-in7, which may be needed
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.3.99-pre6-lia/arch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Mon May  1 22:21:07 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/irq_ia64.c	Fri Apr 28 23:40:07 2000
@@ -33,7 +33,7 @@
 #include <asm/pgtable.h>
 #include <asm/system.h>
 
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
 spinlock_t ivr_read_lock;
 #endif
 
@@ -49,7 +49,7 @@
 	0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x40, 0x41
 };
 
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
 
 int usbfix;
 
@@ -63,7 +63,7 @@
 
 __setup("usbfix", usbfix_option);
 
-#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC */
+#endif /* CONFIG_ITANIUM_A1_SPECIFIC */
 
 /*
  * That's where the IVT branches when we get an external
@@ -74,12 +74,12 @@
 ia64_handle_irq (unsigned long vector, struct pt_regs *regs)
 {
 	unsigned long bsp, sp, saved_tpr;
-
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
 # ifndef CONFIG_SMP
 	static unsigned int max_prio = 0;
 	unsigned int prev_prio;
 # endif
+
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
 	unsigned long eoi_ptr;
  
 # ifdef CONFIG_USB
@@ -95,18 +95,14 @@
 	spin_lock(&ivr_read_lock);
 	{
 		unsigned int tmp;
-
 		/*
 		 * Disable PCI writes
 		 */
 		outl(0x80ff81c0, 0xcf8);
 		tmp = inl(0xcfc);
 		outl(tmp | 0x400, 0xcfc);
-
 		eoi_ptr = inl(0xcfc);
-
 		vector = ia64_get_ivr();
-
 		/*
 		 * Enable PCI writes
 		 */
@@ -118,72 +114,65 @@
 	if (usbfix)
 		reenable_usb();
 # endif
+#endif /* CONFIG_ITANIUM_A1_SPECIFIC */
 
 # ifndef CONFIG_SMP
 	prev_prio = max_prio;
 	if (vector < max_prio) {
-		printk ("ia64_handle_irq: got vector %lu while %u was in progress!\n",
-			vector, max_prio);
-		
+		printk ("ia64_handle_irq: got vector %lu while %u "
+			"was in progress!\n", vector, max_prio);
 	} else
 		max_prio = vector;
 # endif /* !CONFIG_SMP */
-#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC */
-
-	/*
-	 * Always set TPR to limit maximum interrupt nesting depth to
-	 * 16 (without this, it would be ~240, which could easily lead
-	 * to kernel stack overflows.
-	 */
-	saved_tpr = ia64_get_tpr();
-	ia64_srlz_d();
-	ia64_set_tpr(vector);
-	ia64_srlz_d();
 
 	asm ("mov %0=ar.bsp" : "=r"(bsp));
 	asm ("mov %0=sp" : "=r"(sp));
 
 	if ((sp - bsp) < 1024) {
-		static long last_time;
 		static unsigned char count;
+		static long last_time;
 
 		if (count > 5 && jiffies - last_time > 5*HZ)
 			count = 0;
 		if (++count < 5) {
 			last_time = jiffies;
-			printk("ia64_handle_irq: DANGER: less than 1KB of free stack space!!\n"
+			printk("ia64_handle_irq: DANGER: less than "
+			       "1KB of free stack space!!\n"
 			       "(bsp=0x%lx, sp=%lx)\n", bsp, sp);
 		}
 	}
 
 	/*
-	 * The interrupt is now said to be in service
+	 * Always set TPR to limit maximum interrupt nesting
+	 * depth to 16 (without this, it would be ~240, which
+	 * could easily lead to kernel stack overflows.
 	 */
-	if (vector >= NR_IRQS) {
-		printk("handle_irq: invalid vector %lu\n", vector);
-		goto out;
-	}
-
-	do_IRQ(vector, regs);
-  out:
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-	{
-		long pEOI;
+	saved_tpr = ia64_get_tpr();
+	ia64_srlz_d();
+	do {
+		ia64_set_tpr(vector);
+		ia64_srlz_d();
 
-		asm ("mov %0=0;; (p1) mov %0=1" : "=r"(pEOI));
-		if (!pEOI) {
-			printk("Yikes: ia64_handle_irq() without pEOI!!\n");
-			asm volatile ("cmp.eq p1,p0=r0,r0" : "=r"(pEOI));
+		/*
+		 * The interrupt is now said to be in service
+		 */
+		if (vector >= NR_IRQS) {
+			printk("handle_irq: invalid vector %lu\n", vector);
+			goto out;
 		}
-	}
+		do_IRQ(vector, regs);
 
-	local_irq_disable();
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
+		break;
+#endif
+		vector = ia64_get_ivr();
+	} while (vector != IA64_SPURIOUS_INT);
+  out:
 # ifndef CONFIG_SMP
-	if (max_prio = vector)
-		max_prio = prev_prio;
+	max_prio = prev_prio;
 # endif /* !CONFIG_SMP */
-#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC */
 
+	local_irq_disable();
 	ia64_srlz_d();
 	ia64_set_tpr(saved_tpr);
 	ia64_srlz_d();
@@ -234,7 +223,7 @@
 {
 	unsigned long ipi_addr;
 	unsigned long ipi_data;
-#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
 	unsigned long flags;
 #endif
 #	define EID	0
@@ -242,13 +231,13 @@
 	ipi_data = (delivery_mode << 8) | (vector & 0xff);
 	ipi_addr = ipi_base_addr | ((cpu << 8 | EID) << 4) | ((redirect & 1)  << 3);
 
-#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
 	spin_lock_irqsave(&ivr_read_lock, flags);
-#endif	/* CONFIG_ITANIUM_ASTEP_SPECIFIC */
+#endif
 
 	writeq(ipi_data, ipi_addr);
 
-#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
 	spin_unlock_irqrestore(&ivr_read_lock, flags);
 #endif
 }
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.3.99-pre6-lia/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Mon May  1 22:21:07 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/ivt.S	Fri Apr 28 21:24:15 2000
@@ -578,7 +578,7 @@
 	SAVE_REST
 	;;
 	alloc r14=ar.pfs,0,0,2,0 // must be first in an insn group
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
 	mov out0=r0		// defer reading of cr.ivr to handle_irq...
 #else
 	mov out0=cr.ivr		// pass cr.ivr as first arg
@@ -936,7 +936,6 @@
 	mov r31=pr		// prepare to save predicates
 	;;									
 	srlz.d			// ensure everyone knows psr.dt is off
-	mov r190		// error vector for fault_handler (when kernel)
 	br.cond.sptk.many dispatch_unaligned_handler
 
 	.align 256
diff -urN linux-davidm/arch/ia64/kernel/mca.c linux-2.3.99-pre6-lia/arch/ia64/kernel/mca.c
--- linux-davidm/arch/ia64/kernel/mca.c	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/mca.c	Wed Apr 19 22:52:25 2000
@@ -17,7 +17,6 @@
 #include <linux/sched.h>
 #include <linux/irq.h>
 #include <linux/smp_lock.h>
-#include <linux/config.h>
 
 #include <asm/page.h>
 #include <asm/ptrace.h>
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.3.99-pre6-lia/arch/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/signal.c	Tue Apr 25 16:32:12 2000
@@ -163,9 +163,15 @@
 	 * must not touch r8 or r10 as otherwise user-level stat could
 	 * be corrupted.
 	 */
-	retval = (long) &ia64_leave_kernel | 1;
-	if ((current->flags & PF_TRACESYS)
-	    && (sc->sc_flags & IA64_SC_FLAG_IN_SYSCALL))
+	retval = (long) &ia64_leave_kernel;
+	if (current->flags & PF_TRACESYS)
+		/*
+		 * strace expects to be notified after sigreturn
+		 * returns even though the context to which we return
+		 * may not be in the middle of a syscall.  Thus, the
+		 * return-value that strace displays for sigreturn is
+		 * meaningless.
+		 */
 		retval = (long) &ia64_strace_leave_kernel;
 
 	if (!access_ok(VERIFY_READ, sc, sizeof(*sc)))
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.3.99-pre6-lia/arch/ia64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/smp.c	Fri Apr 28 21:25:13 2000
@@ -68,7 +68,7 @@
 };
 static struct smp_call_struct *smp_call_function_data;
 
-#ifdef	CONFIG_ITANIUM_ASTEP_SPECIFIC
+#ifdef	CONFIG_ITANIUM_A1_SPECIFIC
 extern spinlock_t ivr_read_lock;
 #endif
 
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.3.99-pre6-lia/arch/ia64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Mon May  1 22:21:07 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/time.c	Thu Apr 27 23:13:33 2000
@@ -79,15 +79,18 @@
 	 */
 	return 0;
 #else
-	unsigned long now = ia64_get_itc();
-	unsigned long elapsed_cycles, lost;
-
-	elapsed_cycles = now - (itm.next[smp_processor_id()].count - itm.delta);
-
-	lost = lost_ticks;
-	if (lost)
-		elapsed_cycles += lost*itm.delta;
+	unsigned long now = ia64_get_itc(), last_tick;
+	unsigned long elapsed_cycles, lost = lost_ticks;
 
+	last_tick = (itm.next[smp_processor_id()].count - (lost+1)*itm.delta);
+# if 1
+	if ((long) (now - last_tick) < 0) {
+		printk("Yikes: now < last_tick (now=0x%lx,last_tick=%lx)!  No can do.\n",
+		       now, last_tick);
+		return 0;
+	}
+# endif
+	elapsed_cycles = now - last_tick;
 	return (elapsed_cycles*my_cpu_data.usec_per_cyc) >> IA64_USEC_PER_CYC_SHIFT;
 #endif
 }
@@ -148,6 +151,7 @@
 	static unsigned long last_time;
 	static unsigned char count;
 	int cpu = smp_processor_id();
+	unsigned long new_itm;
 	int printed = 0;
 
 	/*
@@ -157,6 +161,7 @@
 	 * xtime_lock.
 	 */
 	write_lock(&xtime_lock);
+	new_itm = itm.next[cpu].count;
 	while (1) {
 		/*
 		 * Do kernel PC profiling here.  We multiply the
@@ -175,25 +180,16 @@
 		do_timer(regs);
 #endif
 
-		itm.next[cpu].count += itm.delta;
-		/*
-		 * There is a race condition here: to be on the "safe"
-		 * side, we process timer ticks until itm.next is
-		 * ahead of the itc by at least half the timer
-		 * interval.  This should give us enough time to set
-		 * the new itm value without losing a timer tick.
-		 */
-		if (time_after(itm.next[cpu].count, ia64_get_itc() + itm.delta/2)) {
-			ia64_set_itm(itm.next[cpu].count);
+		new_itm += itm.delta;
+		itm.next[cpu].count = new_itm;
+		if (time_after(new_itm, ia64_get_itc()))
 			break;
-		}
 
 #if !(defined(CONFIG_IA64_SOFTSDV_HACKS) && defined(CONFIG_SMP))
 		/*
 		 * SoftSDV in SMP mode is _slow_, so we do "lose" ticks, 
 		 * but it's really OK...
 		 */
-		write_unlock(&xtime_lock);
 		if (count > 0 && jiffies - last_time > 5*HZ)
 			count = 0;
 		if (count++ = 0) {
@@ -207,10 +203,21 @@
 # endif
 			}
 		}
-		write_lock(&xtime_lock);
 #endif
 	}
 	write_unlock(&xtime_lock);
+
+	/*
+	 * If we're too close to the next clock tick for comfort, we
+	 * increase the saftey margin by intentionally dropping the
+	 * next tick(s).  We do NOT update itm.next accordingly
+	 * because that would force us to call do_timer() which in
+	 * turn would let our clock run too fast (with the potentially
+	 * devastating effect of losing monotony of time).
+	 */
+	while (!time_after(new_itm, ia64_get_itc() + itm.delta/2))
+		new_itm += itm.delta;
+	ia64_set_itm(new_itm);
 }
 
 #ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.3.99-pre6-lia/arch/ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Thu Apr 27 15:47:32 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/traps.c	Tue Apr 25 15:10:10 2000
@@ -450,11 +450,6 @@
 		force_sig_info(SIGTRAP, &siginfo, current);
 		return;
 
-	      case 30: /* Unaligned fault */
-		sprintf(buf, "Kernel unaligned trap accessing %016lx (ip=%016lx)!",
-			ifa, regs->cr_iip + ia64_psr(regs)->ri);
-		break;
-
 	      case 32: /* fp fault */
 	      case 33: /* fp trap */
 		result = handle_fpu_swa((vector = 32) ? 1 : 0, regs, isr);
diff -urN linux-davidm/drivers/char/Config.in linux-2.3.99-pre6-lia/drivers/char/Config.in
--- linux-davidm/drivers/char/Config.in	Thu Apr 27 15:47:33 2000
+++ linux-2.3.99-pre6-lia/drivers/char/Config.in	Thu Apr 27 15:49:42 2000
@@ -16,6 +16,11 @@
       tristate '   Dual serial port support' CONFIG_DUALSP_SERIAL
    fi
 fi
+
+if [ "$CONFIG_SERIAL" = "n" ]; then
+	bool 'Simulated serial driver support' CONFIG_SIM_SERIAL
+fi
+
 bool 'Extended dumb serial driver options' CONFIG_SERIAL_EXTENDED
 if [ "$CONFIG_SERIAL_EXTENDED" = "y" ]; then
    bool '  Support more than 4 serial ports' CONFIG_SERIAL_MANY_PORTS
diff -urN linux-davidm/drivers/char/Makefile linux-2.3.99-pre6-lia/drivers/char/Makefile
--- linux-davidm/drivers/char/Makefile	Sun Apr  2 15:38:53 2000
+++ linux-2.3.99-pre6-lia/drivers/char/Makefile	Thu Apr 20 00:16:43 2000
@@ -111,6 +111,7 @@
   endif
 endif
 
+obj-$(CONFIG_SIM_SERIAL) += simserial.o
 obj-$(CONFIG_ROCKETPORT) += rocket.o
 obj-$(CONFIG_MOXA_SMARTIO) += mxser.o
 obj-$(CONFIG_MOXA_INTELLIO) += moxa.o
diff -urN linux-davidm/drivers/ide/ide-cd.c linux-2.3.99-pre6-lia/drivers/ide/ide-cd.c
--- linux-davidm/drivers/ide/ide-cd.c	Thu Apr 27 15:47:33 2000
+++ linux-2.3.99-pre6-lia/drivers/ide/ide-cd.c	Thu Apr 27 15:49:46 2000
@@ -2075,6 +2075,7 @@
 
 	init_cdrom_command(&cgc, &buf, sizeof(buf), CGC_DATA_UNKNOWN);
 
+#ifndef CONFIG_IA64_SOFTSDV_HACKS      /* MODE_SENSE unsupported by simulator */
 #ifndef __ACER50__
 	/* Now with that done, update the speed fields */
         do {    /* we seem to get stat=0x01,err=0x00 the first time (??) */
@@ -2099,6 +2100,7 @@
 	if (ide_cdrom_get_capabilities(cdi,&buf))
 		return 0;
 #endif /* __ACER50__ */
+#endif /* CONFIG_IA64_SOFTSDV_HACKS */
 
         cdi->speed = CDROM_STATE_FLAGS (drive)->current_speed;
         return 0;
diff -urN linux-davidm/drivers/net/eepro100.c linux-2.3.99-pre6-lia/drivers/net/eepro100.c
--- linux-davidm/drivers/net/eepro100.c	Thu Apr 27 15:47:34 2000
+++ linux-2.3.99-pre6-lia/drivers/net/eepro100.c	Thu Apr 27 15:49:47 2000
@@ -50,9 +50,18 @@
 static int txdmacount = 128;
 static int rxdmacount = 0;
 
+#ifdef __ia64__
+/*
+ * Bug: this driver may generate unaligned accesses when not copying
+ * an incoming packet.  Setting rx_copybreak to a large value force a
+ * copy and prevents unaligned accesses.
+ */
+static int rx_copybreak = 0x10000;
+#else
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx method.
    Lower values use more memory, but are faster. */
 static int rx_copybreak = 200;
+#endif
 
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work = 20;
@@ -429,14 +438,14 @@
 
 /* The Speedo3 Rx and Tx frame/buffer descriptors. */
 struct descriptor {			    /* A generic descriptor. */
-	s32 cmd_status;				/* All command and status fields. */
+	volatile s32 cmd_status;	/* All command and status fields. */
 	u32 link;				    /* struct descriptor *  */
 	unsigned char params[0];
 };
 
 /* The Speedo3 Rx and Tx buffer descriptors. */
 struct RxFD {					/* Receive frame descriptor. */
-	s32 status;
+	volatile s32 status;
 	u32 link;					/* struct RxFD * */
 	u32 rx_buf_addr;			/* void * */
 	u32 count;
diff -urN linux-davidm/drivers/usb/devices.c linux-2.3.99-pre6-lia/drivers/usb/devices.c
--- linux-davidm/drivers/usb/devices.c	Thu Apr 27 15:47:36 2000
+++ linux-2.3.99-pre6-lia/drivers/usb/devices.c	Thu Apr 27 16:24:46 2000
@@ -53,6 +53,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/poll.h>
+#include <linux/smp_lock.h>
 #include <linux/usb.h>
 #include <linux/usbdevice_fs.h>
 #include <asm/uaccess.h>
diff -urN linux-davidm/drivers/usb/uhci.c linux-2.3.99-pre6-lia/drivers/usb/uhci.c
--- linux-davidm/drivers/usb/uhci.c	Tue Apr 11 09:57:43 2000
+++ linux-2.3.99-pre6-lia/drivers/usb/uhci.c	Fri Apr 28 21:30:48 2000
@@ -33,7 +33,7 @@
 #include <linux/unistd.h>
 #include <linux/interrupt.h>
 #include <linux/spinlock.h>
-#define DEBUG
+#undef DEBUG
 #include <linux/usb.h>
 
 #include <asm/uaccess.h>
@@ -67,6 +67,46 @@
 /* If a transfer is still active after this much time, turn off FSBR */
 #define IDLE_TIMEOUT	(HZ / 20)	/* 50 ms */
 
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
+
+static struct uhci *guhci;
+
+void
+disable_usb (void)
+{
+	unsigned short cmd;
+	unsigned int io_addr;
+
+	if (guhci = NULL)
+		return;
+
+	io_addr = guhci->io_addr;
+
+	cmd = inw (io_addr + USBCMD); 
+
+	outw(cmd & ~ USBCMD_RS, io_addr+USBCMD);
+
+	while ((inw (io_addr + USBSTS) & USBSTS_HCH) = 0);
+}
+
+void
+reenable_usb (void)
+{
+	unsigned int io_addr;
+	unsigned short cmd;
+
+	if (guhci = NULL)
+		return;
+
+	io_addr = guhci->io_addr;
+
+	cmd = inw (io_addr + USBCMD); 
+
+	outw(cmd | USBCMD_RS, io_addr+USBCMD);
+}
+
+#endif /* CONFIG_ITANIUM_A1_SPECIFIC */
+
 /*
  * Only the USB core should call uhci_alloc_dev and uhci_free_dev
  */
@@ -2192,6 +2232,11 @@
 		if (!uhci_start_root_hub(uhci)) {
 			struct pm_dev *pmdev;
 
+#ifdef CONFIG_ITANIUM_A1_SPECIFIC
+			guhci = uhci;
+			printk("%s: enabling Lion USB workaround io_addr=%x\n",
+			       __FILE__, guhci->io_addr);
+#endif
 			pmdev = pm_register(PM_PCI_DEV,
 					    PM_PCI_ID(dev),
 					    handle_pm_event);
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.3.99-pre6-lia/include/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Thu Apr 27 15:47:37 2000
+++ linux-2.3.99-pre6-lia/include/asm-ia64/processor.h	Fri Apr 28 14:03:34 2000
@@ -264,7 +264,8 @@
 
 #define SET_UNALIGN_CTL(task,value)								\
 ({												\
-	(task)->thread.flags |= ((value) << IA64_THREAD_UAC_SHIFT) & IA64_THREAD_UAC_MASK;	\
+	(task)->thread.flags = (((task)->thread.flags & ~IA64_THREAD_UAC_MASK)			\
+				| (((value) << IA64_THREAD_UAC_SHIFT) & IA64_THREAD_UAC_MASK));	\
 	0;											\
 })
 #define GET_UNALIGN_CTL(task,addr)								\
diff -urN linux-davidm/include/asm-ia64/spinlock.h linux-2.3.99-pre6-lia/include/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Mon May  1 22:21:07 2000
+++ linux-2.3.99-pre6-lia/include/asm-ia64/spinlock.h	Fri Apr 28 14:03:34 2000
@@ -11,8 +11,6 @@
 
 #include <linux/kernel.h>
 
-#include <linux/kernel.h>
-
 #include <asm/system.h>
 #include <asm/bitops.h>
 #include <asm/atomic.h>
diff -urN linux-davidm/ipc/util.c linux-2.3.99-pre6-lia/ipc/util.c
--- linux-davidm/ipc/util.c	Wed Mar  8 09:16:24 2000
+++ linux-2.3.99-pre6-lia/ipc/util.c	Mon May  1 18:12:06 2000
@@ -229,6 +229,8 @@
 	out->seq	= in->seq;
 }
 
+#ifndef __ia64__
+
 int ipc_parse_version (int *cmd)
 {
 	if (*cmd & IPC_64) {
@@ -238,6 +240,8 @@
 		return IPC_OLD;
 	}
 }
+
+#endif /* __ia64__ */
 
 #else
 /*
diff -urN linux-davidm/ipc/util.h linux-2.3.99-pre6-lia/ipc/util.h
--- linux-davidm/ipc/util.h	Tue Feb  8 18:23:13 2000
+++ linux-2.3.99-pre6-lia/ipc/util.h	Mon May  1 18:12:54 2000
@@ -99,4 +99,9 @@
 void kernel_to_ipc64_perm(struct kern_ipc_perm *in, struct ipc64_perm *out);
 void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out);
 
+#ifdef __ia64__
+  /* On IA-64, we always use the "64-bit version" of the IPC structures.  */ 
+# define ipc_parse_version(cmd)	IPC_64
+#else
 int ipc_parse_version (int *cmd);
+#endif


