From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 26 Aug 2003 20:49:49 +0000
Subject: Re: [PATCH] UP cmc/cpe polling fix
Message-Id: <marc-linux-ia64-106193126508317@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106183667010615@msgid-missing>
In-Reply-To: <marc-linux-ia64-106183667010615@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 25 August 2003 12:36 pm, Alex Williamson wrote:
>    Oops, I must have only tested the UP polling on a 2.4 kernel.  On
> 2.6, I hit the BUG_ON calling cpu_online(1).  Simply swapping the
> order of the test fixes it.  This should be applied for 2.6 and 2.4.

I applied this for 2.4 as follows:

#### AUTHOR alex.williamson@hp.com
#### COMMENT START
### Comments for ChangeSet
ia64: Correct NR_CPUS/cpu_online test order in CMC/CPE polling

   Oops, I must have only tested the UP polling on a 2.4 kernel.  On
2.6, I hit the BUG_ON calling cpu_online(1).  Simply swapping the
order of the test fixes it.  This should be applied for 2.6 and 2.4.
### Comments for arch/ia64/kernel/mca.c
(ia64_mca_cmc_int_caller): Reorder NR_CPUS/cpu_online test so
	we don't hit BUG_ON in cpu_online(1) in UP kernel.
(ia64_mca_cpe_int_caller): Ditto
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1094  -> 1.1095 
#	arch/ia64/kernel/mca.c	1.34    -> 1.35   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/26	bjorn.helgaas@hp.com	1.1095
# fix order
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
--- a/arch/ia64/kernel/mca.c	Tue Aug 26 16:18:24 2003
+++ b/arch/ia64/kernel/mca.c	Tue Aug 26 16:18:24 2003
@@ -1148,7 +1148,7 @@
 
 	ia64_mca_cmc_int_handler(cpe_irq, arg, ptregs);
 
-	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
 		
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
@@ -1226,7 +1226,7 @@
 
 	ia64_mca_cpe_int_handler(cpe_irq, arg, ptregs);
 
-	for (++cpuid ; !cpu_online(cpuid) && cpuid < NR_CPUS ; cpuid++);
+	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
 
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);

