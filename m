From: Keith Owens <kaos@sgi.com>
Date: Tue, 27 Apr 2004 00:09:39 +0000
Subject: [patch] 2.6.5 BUG if smp_call_function is called with interrupts disabled
Message-Id: <9348.1083024579@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a nasty race if smp_call_function() is called with interrupts
disabled.

CPU A                               CPU B
Disable interrupts
                                    smp_call_function()
                                    Take call_lock
                                    Send IPIs
                                    Wait for all cpus to acknowledge IPI
                                    CPU A has not responded, spin waiting
                                    for cpu A to respond, holding call_lock
smp_call_function()
Spin waiting for call_lock
Deadlock                            Deadlock

This bug is hard to reproduce and even harder to diagnose.  Since the
comments at the start of smp_call_function() say it should never be
entered with interrupts disabled, make it so.

Index: linux/arch/ia64/kernel/smp.c
=================================--- linux.orig/arch/ia64/kernel/smp.c	Mon Apr 26 15:20:17 2004
+++ linux/arch/ia64/kernel/smp.c	Tue Apr 27 09:56:55 2004
@@ -319,10 +319,14 @@
 {
 	struct call_data_struct data;
 	int cpus = num_online_cpus()-1;
+	unsigned long psr;
 
 	if (!cpus)
 		return 0;
 
+	__asm__ __volatile__ ("mov %0=psr;; " : "=r" (psr));
+	BUG_ON(!(psr & IA64_PSR_I));
+
 	data.func = func;
 	data.info = info;
 	atomic_set(&data.started, 0);

