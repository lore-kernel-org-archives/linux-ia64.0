From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Mon, 01 Apr 2002 23:54:20 +0000
Subject: [Linux-ia64] [PATCH] set ar.k0 on APs
Message-Id: <marc-linux-ia64-105590701905355@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We currently set ar.k0 on the BP, but not on the APs.  The following
patch does it for APs as well.

Apparently Intel firmware sets ar.k0, but HP firmware doesn't.
If the kernel doesn't set ar.k0, X won't start up on APs because
it uses ar.k0 to access I/O port space.
-- 
Bjorn Helgaas - bjorn_helgaas@hp.com
Linux Systems Operation R&D
Hewlett-Packard


diff -u -r linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/smpboot.c linux-2.4.18-ia64-020226/arch/ia64/kernel/smpboot.c
--- linux-2.4.18-ia64-020226-orig/arch/ia64/kernel/smpboot.c	Mon Apr  1 16:43:58 2002
+++ linux-2.4.18-ia64-020226/arch/ia64/kernel/smpboot.c	Mon Apr  1 16:44:51 2002
@@ -68,6 +68,7 @@
 
 extern void __init calibrate_delay(void);
 extern void start_ap(void);
+extern unsigned long ia64_iobase;
 
 int cpucount;
 
@@ -343,6 +344,11 @@
 	 * Get our bogomips.
 	 */
 	ia64_init_itm();
+
+	/*
+	 * Set I/O port base per CPU
+	 */
+	ia64_set_kr(IA64_KR_IO_BASE, ia64_iobase & ~PAGE_OFFSET);
 
 #ifdef CONFIG_IA64_MCA
 	ia64_mca_cmc_vector_setup();	/* Setup vector on AP & enable */

