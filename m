From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 26 Apr 2004 14:29:00 +0000
Subject: [PATCH] bug w/ shared interrupts
Message-Id: <1082989740.15656.20.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   I just ran into a bug introduced by cset 1.1371.519.37.  The scenario
is a builtin driver is up and running happily.  A module loads for a
devices that happens to share the same interrupt vector, in this case a
network driver.  The module calls pci_enable_device() as it should,
which eventually lands in iosapic_enable_intr().  We then proceed to
mask the interrupt and kill the device that's already running.  As a
bonus, request_interrupt() doesn't fix the problem because we only call
the startup for the interrupt handler on the first action attached to
the interrupt.

   I think the best way out of this is simply to detect when an action
is already attached to a vector and leave it alone.  This also prevents
interrupts from moving to other cpus (on boxes w/o irq redirection) for
no good reason.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

=== arch/ia64/kernel/iosapic.c 1.39 vs edited ==--- 1.39/arch/ia64/kernel/iosapic.c	Wed Apr 21 15:26:09 2004
+++ edited/arch/ia64/kernel/iosapic.c	Sun Apr 25 21:13:33 2004
@@ -648,6 +648,16 @@
 iosapic_enable_intr (unsigned int vector)
 {
 	unsigned int dest;
+	irq_desc_t *desc;
+
+	/*
+	 * In the case of a shared interrupt, do not re-route the vector, and
+	 * especially do not mask a running interrupt (startup will not get
+	 * called for a shared interrupt).
+	 */
+	desc = irq_descp(vector);
+	if (desc->action)
+		return;
 
 #ifdef CONFIG_SMP
 	/*


