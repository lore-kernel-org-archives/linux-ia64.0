From: Fenghua Yu <fenghua.yu@intel.com>
Date: Wed, 10 Nov 2004 03:35:26 +0000
Subject: [PATCH] add cpu_relax() in spin loops
Message-Id: <20041109193526.A4895@unix-os.sc.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch adds cpu_relax() in the body of spin loops in
smp_call_function(), smp_call_function_single(), and
ia64_mca_wakeup_ipi_wait().

The patch is against the latest linux-ia64-test-2.6.10
bk tree.

Thanks.

-Fenghua

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="spin_loops_ia64.patch"

--- a/arch/ia64/kernel/mca.c	2004-10-26 11:52:44.000000000 -0700
+++ b/arch/ia64/kernel/mca.c	2004-10-28 14:07:12.000000000 -0700
@@ -686,6 +686,7 @@ ia64_mca_wakeup_ipi_wait(void)
 			irr = ia64_getreg(_IA64_REG_CR_IRR3);
 			break;
 		}
+		cpu_relax();
 	} while (!(irr & (1UL << irr_bit))) ;
 }
 
--- a/arch/ia64/kernel/smp.c	2004-10-26 11:52:44.000000000 -0700
+++ b/arch/ia64/kernel/smp.c	2004-10-28 14:08:21.000000000 -0700
@@ -290,11 +290,11 @@ smp_call_function_single (int cpuid, voi
 
 	/* Wait for response */
 	while (atomic_read(&data.started) != cpus)
-		barrier();
+		cpu_relax();
 
 	if (wait)
 		while (atomic_read(&data.finished) != cpus)
-			barrier();
+			cpu_relax();
 	call_data = NULL;
 
 	spin_unlock_bh(&call_lock);
@@ -349,11 +349,11 @@ smp_call_function (void (*func) (void *i
 
 	/* Wait for response */
 	while (atomic_read(&data.started) != cpus)
-		barrier();
+		cpu_relax();
 
 	if (wait)
 		while (atomic_read(&data.finished) != cpus)
-			barrier();
+			cpu_relax();
 	call_data = NULL;
 
 	spin_unlock(&call_lock);

--0OAP2g/MAC+5xKAE--
