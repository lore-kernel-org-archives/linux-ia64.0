From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 13 May 2004 21:25:31 +0000
Subject: Re: [PATCH] fix "timer tick before it's due"
Message-Id: <200405131525.31855.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405121721.30863.bjorn.helgaas@hp.com>
In-Reply-To: <200405121721.30863.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 13 May 2004 2:33 pm, David Mosberger wrote:
> I think it may really be necessary to distinguish between "I'm a new
> CPU, tell me what to set the ITC to" and "my CPU's may haved drifted,
> let me resync". ...
> 
> IMHO, it makes sense to limit the syncing code to the former case for
> the time being (there hasn't been a real need for the latter).

I agree.  How about this (same as the first patch, plus the BUG_ON()
and removal of the "jumped tick" check):

=== arch/ia64/kernel/smpboot.c 1.49 vs edited ==--- 1.49/arch/ia64/kernel/smpboot.c	Thu Mar 25 12:53:03 2004
+++ edited/arch/ia64/kernel/smpboot.c	Thu May 13 15:15:57 2004
@@ -202,6 +202,14 @@
 	} t[NUM_ROUNDS];
 #endif
 
+	/*
+	 * Make sure local timer ticks are disabled while we sync.  If
+	 * they were enabled, we'd have to worry about nasty issues
+	 * like setting the ITC ahead of (or a long time before) the
+	 * next scheduled tick.
+	 */
+	BUG_ON((ia64_get_itv() & (1 << 16)) = 0);
+
 	go[MASTER] = 1;
 
 	if (smp_call_function_single(master, sync_master, NULL, 1, 0) < 0) {
@@ -247,16 +255,6 @@
 
 	printk(KERN_INFO "CPU %d: synchronized ITC with CPU %u (last diff %ld cycles, "
 	       "maxerr %lu cycles)\n", smp_processor_id(), master, delta, rt);
-
-	/*
-	 * Check whether we sync'd the itc ahead of the next timer interrupt.  If so, just
-	 * reset it.
-	 */
-	if (time_after(ia64_get_itc(), local_cpu_data->itm_next)) {
-		Dprintk("CPU %d: oops, jumped a timer tick; resetting timer.\n",
-			smp_processor_id());
-		ia64_cpu_local_tick();
-	}
 }
 
 /*
@@ -289,11 +287,6 @@
 	smp_setup_percpu_timer();
 
 	/*
-	 * Get our bogomips.
-	 */
-	ia64_init_itm();
-
-	/*
 	 * Set I/O port base per CPU
 	 */
 	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
@@ -305,11 +298,6 @@
 #endif
 
 	local_irq_enable();
-	calibrate_delay();
-	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
-#ifdef CONFIG_IA32_SUPPORT
-	ia32_gdt_init();
-#endif
 
 	if (!(sal_platform_features & IA64_SAL_PLATFORM_FEATURE_ITC_DRIFT)) {
 		/*
@@ -321,6 +309,17 @@
 		Dprintk("Going to syncup ITC with BP.\n");
 		ia64_sync_itc(0);
 	}
+
+	/*
+	 * Get our bogomips.
+	 */
+	ia64_init_itm();
+	calibrate_delay();
+	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
+
+#ifdef CONFIG_IA32_SUPPORT
+	ia32_gdt_init();
+#endif
 
 	/*
 	 * Allow the master to continue.
=== include/asm-ia64/delay.h 1.8 vs edited ==--- 1.8/include/asm-ia64/delay.h	Wed Oct 15 15:07:14 2003
+++ edited/include/asm-ia64/delay.h	Thu May 13 11:31:29 2004
@@ -44,6 +44,16 @@
 	ia64_srlz_d();
 }
 
+static __inline__ unsigned long
+ia64_get_itv (void)
+{
+	unsigned long result;
+
+	result = ia64_getreg(_IA64_REG_CR_ITV);
+	ia64_srlz_d();
+	return result;
+}
+
 static __inline__ void
 ia64_set_itc (unsigned long val)
 {
