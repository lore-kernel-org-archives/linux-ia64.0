From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 25 Aug 2003 18:36:56 +0000
Subject: [PATCH] UP cmc/cpe polling fix
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------0DC4E1FC4AA28EE4D866B1DB"
Message-Id: <marc-linux-ia64-106183667010615@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------0DC4E1FC4AA28EE4D866B1DB
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


   Oops, I must have only tested the UP polling on a 2.4 kernel.  On
2.6, I hit the BUG_ON calling cpu_online(1).  Simply swapping the
order of the test fixes it.  This should be applied for 2.6 and 2.4.
Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
--------------0DC4E1FC4AA28EE4D866B1DB
Content-Type: text/plain; charset=us-ascii;
 name="mca_cpu_online_fixup.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca_cpu_online_fixup.diff"

--- linux-2.6.0-test3.orig/arch/ia64/kernel/mca.c	2003-08-25 09:04:18.000000000 -0600
+++ linux-2.6.0-test3/arch/ia64/kernel/mca.c	2003-08-25 11:16:23.000000000 -0600
@@ -1145,7 +1145,7 @@
 
 	ia64_mca_cmc_int_handler(cpe_irq, arg, ptregs);
 
-	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
 		
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
@@ -1225,7 +1225,7 @@
 
 	ia64_mca_cpe_int_handler(cpe_irq, arg, ptregs);
 
-	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
 
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);

--------------0DC4E1FC4AA28EE4D866B1DB--

