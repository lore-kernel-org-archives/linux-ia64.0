From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 26 Aug 2003 21:16:59 +0000
Subject: Re: kernel update (relative to 2.6.0-test4)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------B073035FCD607968ECEC0F2D"
Message-Id: <marc-linux-ia64-106193283610381@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106192276030286@msgid-missing>
In-Reply-To: <marc-linux-ia64-106192276030286@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------B073035FCD607968ECEC0F2D
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David,

   The second chunk of the "UP cmc/cpe polling fix" seems to have
gotten lost.  Please apply the attached for the cpe side of the
fix.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab
--------------B073035FCD607968ECEC0F2D
Content-Type: text/plain; charset=us-ascii;
 name="mca_fix.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mca_fix.diff"

--- linux-2.6.0-test4.orig/arch/ia64/kernel/mca.c	2003-08-26 13:13:27.000000000 -0600
+++ linux-2.6.0-test4/arch/ia64/kernel/mca.c	2003-08-26 14:42:37.000000000 -0600
@@ -1225,7 +1225,7 @@
 
 	ia64_mca_cpe_int_handler(cpe_irq, arg, ptregs);
 
-	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
 
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);

--------------B073035FCD607968ECEC0F2D--

