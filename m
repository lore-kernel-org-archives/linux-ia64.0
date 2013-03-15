From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 15 Mar 2013 20:21:06 +0000
Subject: RE: CMCI vector not initialized on BP
Message-Id: <514382b2802dc92a@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
In-Reply-To: <D8D957864D852146A97B866681B1DF2F0D16C73A@G9W0768.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

How about if we make sure that the relevent parts of
ia64_mca_late_init() are run on CPU0.  See patch below.
Does that fix it ... or do we need to do more surgery
to make the relevent pieces of smp_callin() callable
from CPU0.

-Tony

---
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 65bf9cd..bfb39de 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -2074,22 +2074,8 @@ ia64_mca_init(void)
 	printk(KERN_INFO "MCA related initialization done\n");
 }
 
-/*
- * ia64_mca_late_init
- *
- *	Opportunity to setup things that require initialization later
- *	than ia64_mca_init.  Setup a timer to poll for CPEs if the
- *	platform doesn't support an interrupt driven mechanism.
- *
- *  Inputs  :   None
- *  Outputs :   Status
- */
-static int __init
-ia64_mca_late_init(void)
+static void __init ia64_mca_late_init_bsp(void *dummy)
 {
-	if (!mca_init)
-		return 0;
-
 	/*
 	 *  Configure the CMCI/P vector and handler. Interrupts for CMC are
 	 *  per-processor, so AP CMC interrupts are setup in smp_callin() (smpboot.c).
@@ -2108,6 +2094,29 @@ ia64_mca_late_init(void)
 	/* Setup the CPEI/P handler */
 	register_percpu_irq(IA64_CPEP_VECTOR, &mca_cpep_irqaction);
 #endif
+}
+
+/*
+ * ia64_mca_late_init
+ *
+ *	Opportunity to setup things that require initialization later
+ *	than ia64_mca_init.  Setup a timer to poll for CPEs if the
+ *	platform doesn't support an interrupt driven mechanism.
+ *
+ *  Inputs  :   None
+ *  Outputs :   Status
+ */
+static int __init
+ia64_mca_late_init(void)
+{
+	if (!mca_init)
+		return 0;
+
+	/*
+	 * We are probably not running on cpu0, but we have some
+	 * things that must be set up there
+	 */
+	smp_call_function_single(0, ia64_mca_late_init_bsp, NULL, 1);
 
 	register_hotcpu_notifier(&mca_cpu_notifier);
 
