From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 04 May 2004 15:53:15 +0000
Subject: [PATCH] initialize IO port base early
Message-Id: <200405040953.15218.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(start_secondary): Set up IO port base here, in case early console
	needs it.
(smp_callin): Move IO port base setup to start_secondary().

=== arch/ia64/kernel/smpboot.c 1.49 vs edited ==--- 1.49/arch/ia64/kernel/smpboot.c	Thu Mar 25 12:53:03 2004
+++ edited/arch/ia64/kernel/smpboot.c	Tue May  4 09:40:11 2004
@@ -293,11 +293,6 @@
 	 */
 	ia64_init_itm();
 
-	/*
-	 * Set I/O port base per CPU
-	 */
-	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
-
 	ia64_mca_cmc_vector_setup();	/* Setup vector on AP & enable */
 
 #ifdef CONFIG_PERFMON
@@ -337,6 +332,9 @@
 start_secondary (void *unused)
 {
 	extern int cpu_idle (void);
+
+	/* Early console may use I/O ports */
+	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
 
 	Dprintk("start_secondary: starting CPU 0x%x\n", hard_smp_processor_id());
 	efi_map_pal_code();
