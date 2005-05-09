From: Russ Anderson <rja@sgi.com>
Date: Mon, 09 May 2005 22:02:56 +0000
Subject: [patch 2.6.12] cpe interrupts not enabled
Message-Id: <200505092202.j49M2uiv10454090@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


cpe interrupts are not being enabled.

acpi_request_vector() is called in ia64_mca_init() to get the cpe_vector.
The problem is that acpi_request_vector() looks in platform_intr_list[] to 
get the vector, but platform_intr_list[] is not initialized with a valid
vector until later (in sn_setup()).  Without a valid vector the code
defaults to polling mode.

This patch moves the call to acpi_request_vector() from ia64_mca_init()
to ia64_mca_late_init(), which is after platform_intr_list[] is initialized.


Signed-off-by: Russ Anderson (rja@sgi.com)

----------------------------------------------------------------------
Index: linux-2.6/arch/ia64/kernel/mca.c
=================================--- linux-2.6.orig/arch/ia64/kernel/mca.c	2005-05-09 11:30:32.300055327 -0500
+++ linux-2.6/arch/ia64/kernel/mca.c	2005-05-09 11:33:18.387102068 -0500
@@ -1390,8 +1390,7 @@
 	register_percpu_irq(IA64_MCA_WAKEUP_VECTOR, &mca_wkup_irqaction);
 
 #ifdef CONFIG_ACPI
-	/* Setup the CPEI/P vector and handler */
-	cpe_vector = acpi_request_vector(ACPI_INTERRUPT_CPEI);
+	/* Setup the CPEI/P handler */
 	register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
 #endif
 
@@ -1436,6 +1435,7 @@
 
 #ifdef CONFIG_ACPI
 	/* Setup the CPEI/P vector and handler */
+	cpe_vector = acpi_request_vector(ACPI_INTERRUPT_CPEI);
 	init_timer(&cpe_poll_timer);
 	cpe_poll_timer.function = ia64_mca_cpe_poll;
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
